import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/account_type_getter.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/email_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {

  final emailGetterStartup = EmailGetter();
  final nameGetterStartup = NameGetter();
  final loginGetterStartup = LoginGetter();
  final dateGetterStartup = DateGetter();
  final crud = Crud();
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {

    if ((await _retrieveLocallyStoredInformation())[0] != '') {
      _timer = Timer(const Duration(milliseconds: 0), () {
        _navigateToNextScreen();
      });
    } else {
      _timer = Timer(const Duration(milliseconds: 2480), () {
        _navigateToNextScreen();
      });
    }
    
  }

  Future<void> _navigateToNextScreen() async {

    try {

      final getLocalUsername = (await _retrieveLocallyStoredInformation())[0];
      final getLocalEmail = (await _retrieveLocallyStoredInformation())[1];

      if(getLocalUsername == '') {
 
        NavigatePage.replacePageHome(context);

      } else {

        const storage = FlutterSecureStorage();
        bool isPassCodeExists = await storage.containsKey(key: "key0015");

        Globals.custUsername = getLocalUsername;
        Globals.custEmail = getLocalEmail;
        Globals.fileOrigin = "homeFiles";

        if(isPassCodeExists) {

          NavigatePage.goToPagePasscode(context);

        } else {

          final conn = await SqlConnection.insertValueParams();

          await _callData(conn,getLocalUsername,getLocalEmail,context);
          NavigatePage.permanentPageMainboard(context);
          
        }
      }
    } catch (err) {
      print("Exception from _navigateToNextScreen {SplashScreen}: $err");
      NavigatePage.replacePageHome(context);
    }
  }

  Future<List<String>> _retrieveLocallyStoredInformation() async {
    
    String username = '';
    String email = '';

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
        }
      }
    }

    List<String> accountInfo = [];
    accountInfo.add(EncryptionClass().Decrypt(username));
    accountInfo.add(EncryptionClass().Decrypt(email));

    return accountInfo;
  }

  Future<int> _countRowTable(String tableName) async {

    final query = "SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': Globals.custUsername};
    final rowCount = await crud.count(query: query, params: params);

    return rowCount;

  }

  Future<void> _callData(MySQLConnectionPool conn,String savedCustUsername,String savedCustEmail,BuildContext context) async {

    try {

      final accTypeGetter = await MySqlAccType().retrieveParams(savedCustEmail);

      Globals.custUsername = savedCustUsername;
      Globals.custEmail = savedCustEmail;
      Globals.accountType = accTypeGetter;

      final dirListCount = await _countRowTable("file_info_directory");
      final dirLists = List.generate(dirListCount, (_) => "file_info_directory");

      final tablesToCheck = ["file_info", "file_info_expand", "file_info_pdf", "file_info_vid","file_info_audi","file_info_ptx","file_info_exe","file_info_excel","file_info_apk", ...dirLists];

      final futures = tablesToCheck.map((table) async {
        final fileNames = await nameGetterStartup.retrieveParams(conn,savedCustUsername, table);
        final bytes = await loginGetterStartup.getLeadingParams(conn,savedCustUsername, table);
        final dates = table == "file_info_directory"
            ? List.generate(1, (_) => "Directory")
            : await dateGetterStartup.getDateParams(savedCustUsername, table);
        return [fileNames, bytes, dates];
      }).toList();

      final results = await Future.wait(futures);

      final fileNames = <String>{};
      final bytes = <Uint8List>[];
      final dates = <String>[];
      final retrieveFolders = <String>{};

      if (await _countRowTable("folder_upload_info") > 0) {
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

      Globals.fromLogin = true;

      Globals.fileValues.addAll(uniqueFileNames);
      Globals.foldValues.addAll(retrieveFolders);
      Globals.dateStoresValues.addAll(dates);
      Globals.imageByteValues.addAll(uniqueBytes);
      Globals.setDateValues.addAll(dates);

    } catch (err) {
      NavigatePage.replacePageHome(context);
      return;
    }

  }

  @override
  void dispose() {
    _timer?.cancel();
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