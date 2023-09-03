import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';

import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';

class SignInUser {

  final _locator = GetIt.instance;

  final nameGetterLogin = NameGetter();
  final loginGetterLogin = DataRetriever();
  final dateGetterLogin = DateGetter();
  final userDataRetriever = UserDataRetriever();
  
  final crud = Crud();
  final logger = Logger();

  String custEmailInit = '';

  Future<void> _callData(MySQLConnectionPool conn, bool isChecked, BuildContext context) async {

    final userData = _locator<UserDataProvider>();
    final storageData = _locator<StorageDataProvider>();
    final tempData = _locator<TempDataProvider>();

    final custUsernameList = await userDataRetriever.retrieveAccountTypeAndUsername(email: custEmailInit);
    final custUsernameGetter = custUsernameList[0]!;
    final custTypeGetter = custUsernameList[1]!;

    tempData.setOrigin("homeFiles");
    userData.setUsername(custUsernameGetter);
    userData.setEmail(custEmailInit);
    userData.setAccountType(custTypeGetter);

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
      final fileNames = await nameGetterLogin.retrieveParams(conn,custUsernameGetter, table);
      final bytes = await loginGetterLogin.getLeadingParams(conn,custUsernameGetter, table);
      final dates = table == GlobalsTable.directoryInfoTable
          ? List.generate(1,(_) => "Directory")
          : await dateGetterLogin.getDateParams(custUsernameGetter, table);
      return [fileNames, bytes, dates];
    }).toList();
  
    final results = await Future.wait(futures);

    final fileNames = <String>{};
    final bytes = <Uint8List>[];
    final dates = <String>[];
    final retrieveFolders = <String>{};

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

    if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
      retrieveFolders.addAll(await FolderRetriever().retrieveParams(custUsernameGetter));
    }

    final uniqueFolder = retrieveFolders.toList();

    storageData.setFilesName(uniqueFileNames);
    storageData.setFoldersName(uniqueFolder);
    storageData.setImageBytes(uniqueBytes);
    storageData.setFilesDate(dates);

    if (isChecked) {
      await _setupAutoLogin(custUsernameGetter,custEmailInit,custTypeGetter);
    }

    custUsernameList.clear();
    dirLists.clear();
  }


  Future<void> _setupAutoLogin(String custUsername,String custEmail, String accountType) async {

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);
    
    if (custUsername.isNotEmpty) {

      if (setupInfosDir.existsSync()) {
        setupInfosDir.deleteSync(recursive: true);
      }

      setupInfosDir.createSync();

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {
        
        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync("${EncryptionClass().encrypt(custUsername)}\n${EncryptionClass().encrypt(custEmail)}\n$accountType");

      } catch (e) {
        // TODO: Ignore
      }
    } else {
      // TODO: Ignore
    }

  }

  Future<void> logParams(
    String? email, String? auth0, String? auth1, bool isChecked, BuildContext context) async {

    final conn = await SqlConnection.insertValueParams();

    try {

      final custUsername = await userDataRetriever.retrieveUsername(email: email);

      if (custUsername.isNotEmpty) {

        custEmailInit = email!;

        final custPasOriginal = await getCustPassword(custUsername, conn);
        final custPinOriginal = await getCustPin(custUsername, conn);

        final case0 = AuthModel().computeAuth(auth0!) == custPasOriginal;
        final case1 = AuthModel().computeAuth(auth1!) == custPinOriginal;

        if (case0 && case1) {

          final conn = await SqlConnection.insertValueParams();
          
          final justLoading = JustLoading();

          if(context.mounted) {
            justLoading.startLoading(context: context);
          }

          await _callData(conn,isChecked, context);

          justLoading.stopLoading();
          
          if(context.mounted) {
            NavigatePage.permanentPageMainboard(context);
          }

        } else {
          
          if(context.mounted) {
            CustomAlertDialog.alertDialog("Password or PIN Key is incorrect.", context);
          }

        }
      } else {

        if(context.mounted) {
          CustomAlertDialog.alertDialog("Account not found.", context);
        }

      }
    } catch (err, st) {

      if(context.mounted) {
        CustomAlertDialog.alertDialogTitle("Something is wrong...", "No internet connection.", context);
      }

      logger.e("Exception from logParams {MYSQL_login}", err, st);
      
    } finally {
      await conn.close();
    }
  }

  Future<String> getCustPassword(String custUsername, conn) async {
    var getPassword = await conn.execute(
        "SELECT CUST_PASSWORD FROM information WHERE CUST_USERNAME = :username",
        {"username": custUsername});

    for (var passIterates in getPassword.rows) {
      return passIterates.assoc()['CUST_PASSWORD']!;
    }

    return '';
  }

  Future<String> getCustPin(String custUsername, conn) async {
    var getPin = await conn.execute(
        "SELECT CUST_PIN FROM information WHERE CUST_USERNAME = :username",
        {"username": custUsername});

    for (var pinIterates in getPin.rows) {
      return pinIterates.assoc()['CUST_PIN']!;
    }

    return '';
  }
}