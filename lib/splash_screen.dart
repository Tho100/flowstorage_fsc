import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final logger = Logger();

  final nameGetterStartup = NameGetter();
  final dataGetterStartup = DataRetriever();
  final dateGetterStartup = DateGetter();
  final accountInformationRetriever = UserDataRetriever();

  final crud = Crud();
  
  Timer? splashScreenTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {

    if ((await _retrieveLocallyStoredInformation())[0] != '') {
      splashScreenTimer = Timer(const Duration(milliseconds: 0), () {
        _navigateToNextScreen();
      });
    } else {
      splashScreenTimer = Timer(const Duration(milliseconds: 2480), () {
        _navigateToNextScreen();
      });
    }
    
  }

  Future<void> _navigateToNextScreen() async {

    try {

      final getLocalUsername = (await _retrieveLocallyStoredInformation())[0];
      final getLocalEmail = (await _retrieveLocallyStoredInformation())[1];
      final getLocalAccountType = (await _retrieveLocallyStoredInformation())[2];

      if(getLocalUsername == '') {

        if(!mounted) return;
        NavigatePage.replacePageHome(context);

      } else {

        const storage = FlutterSecureStorage();
        bool isPassCodeExists = await storage.containsKey(key: "key0015");

        Globals.custUsername = getLocalUsername;
        Globals.accountType = getLocalAccountType;
        Globals.custEmail = getLocalEmail;
        Globals.fileOrigin = "homeFiles";

        if(isPassCodeExists) {

          if(!mounted) return;
          NavigatePage.goToPagePasscode(context);

        } else {

          final conn = await SqlConnection.insertValueParams();

          if(!mounted) return;
          await _callData(conn,getLocalUsername,getLocalEmail,getLocalAccountType,context);
          
          if(!mounted) return;
          NavigatePage.permanentPageMainboard(context);
          
        }
      }
    } catch (err, st) {
      logger.e("Exception from _navigateToNextScreen {SplashScreen}",err, st);
      NavigatePage.replacePageHome(context);
    }
  }

  Future<List<String>> _retrieveLocallyStoredInformation() async {
    
    String username = '';
    String email = '';
    String accountType = '';

    final getDirApplication = await getApplicationDocumentsDirectory();
    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);

    if (setupInfosDir.existsSync()) {
      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      if (setupFiles.existsSync()) {
        final lines = setupFiles.readAsLinesSync();

        if (lines.length >= 2) {
          username = lines[0];
          email = lines[1];
          accountType = lines[2];
        }
      }
    }

    List<String> accountInfo = [];
    accountInfo.add(EncryptionClass().decrypt(username));
    accountInfo.add(EncryptionClass().decrypt(email));
    accountInfo.add(accountType);

    return accountInfo;
  }

  Future<void> _callData(MySQLConnectionPool conn, String savedCustUsername, String savedCustEmail, String savedAccountType,BuildContext context) async {

    try {

      Globals.custUsername = savedCustUsername;
      Globals.custEmail = savedCustEmail;
      Globals.accountType = savedAccountType;

      final accountType = await accountInformationRetriever.retrieveAccountType(email: savedCustEmail);
      Globals.accountType = accountType;

      final dirListCount = await crud.countUserTableRow(GlobalsTable.directoryInfoTable);
      final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

      final tablesToCheck = [
        ...dirLists,
        GlobalsTable.homeImage, GlobalsTable.homeText, 
        GlobalsTable.homePdf, GlobalsTable.homeExcel, 
        GlobalsTable.homeVideo, GlobalsTable.homeAudio,
        GlobalsTable.homePtx, GlobalsTable.homeWord,
        GlobalsTable.homeExe, GlobalsTable.homeApk
      ];

      final futures = tablesToCheck.map((table) async {
        final fileNames = await nameGetterStartup.retrieveParams(conn,savedCustUsername, table);
        final bytes = await dataGetterStartup.getLeadingParams(conn,savedCustUsername, table);
        final dates = table == GlobalsTable.directoryInfoTable
            ? List.generate(1, (_) => "Directory")
            : await dateGetterStartup.getDateParams(savedCustUsername, table);
        return [fileNames, bytes, dates];
      }).toList();

      final results = await Future.wait(futures);

      final fileNames = <String>{};
      final bytes = <Uint8List>[];
      final dates = <String>[];
      final retrieveFolders = <String>{};

      if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
        retrieveFolders.addAll(await FolderRetrieve().retrieveParams(savedCustUsername));
      }

      for (final result in results) {
        final fileNamesForTable = result[0] as List<String>;
        final bytesForTable = result[1] as List<Uint8List>;
        final datesForTable = result[2] as List<String>;

        fileNames.addAll(fileNamesForTable);
        bytes.addAll(bytesForTable);
        dates.addAll(datesForTable);
      }

      final uniqueFileNames = fileNames.toList();
      final uniqueBytes = bytes.toList();

      Globals.fileValues.addAll(uniqueFileNames);
      Globals.foldValues.addAll(retrieveFolders);
      Globals.imageByteValues.addAll(uniqueBytes);
      Globals.setDateValues.addAll(dates);

    } catch (err) {
      NavigatePage.replacePageHome(context);
      return;
    }

  }

  @override
  void dispose() {
    splashScreenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplashScreen(context),
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    return Container(
     color: ThemeColor.darkPurple,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                height: 95,
                child: Image.asset(
                  'assets/nice/SplashMain.png',
                ),
              ),
            ),
            const SizedBox(height: 265),
            Text(
              'Flowstorage',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 65),
          ],
        ),
      ),
    );
  }

}