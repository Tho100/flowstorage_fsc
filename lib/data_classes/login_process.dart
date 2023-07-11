import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/JustLoading.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';

import 'package:flowstorage_fsc/data_classes/username_getter.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/email_getter.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';

/// <summary>
/// 
/// Authentication class for login
/// 
/// </summary>

class MysqlLogin {

  final usernameGetterLogin = UsernameGetter();
  final emailGetterLogin = EmailGetter();
  final nameGetterLogin = NameGetter();
  final loginGetterLogin = LoginGetter();
  final dateGetterLogin = DateGetter();
  
  final crud = Crud();
  final logger = Logger();

  String custEmailInit = '';

  Future<int> _countRowTable(String tableName,String username) async {

    final query = "SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': username};
    
    final totalRow = await crud.count(
      query: query, 
      params: params
    );

    return totalRow;

  }

  Future<void> _callData(MySQLConnectionPool conn,bool isChecked) async {
    
    final custUsernameList = await usernameGetterLogin.retrieveParams(custEmailInit);
    final custUsernameGetter = custUsernameList[0]!;
    final custTypeGetter = custUsernameList[1]!;

    Globals.fileOrigin = "homeFiles";
    Globals.custUsername = custUsernameGetter;
    Globals.custEmail = custEmailInit;
    Globals.accountType = custTypeGetter;

    final dirListCount = await _countRowTable(GlobalsTable.directoryInfoTable, Globals.custUsername);

    final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

    final tablesToCheck = [
      GlobalsTable.homeImageTable, GlobalsTable.homeTextTable, 
      GlobalsTable.homePdfTable, GlobalsTable.homeExcelTable, 
      GlobalsTable.homeVideoTable, GlobalsTable.homeAudioTable,
      GlobalsTable.homePtxTable, GlobalsTable.homeWordTable,
       ...dirLists
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

    if (await _countRowTable(GlobalsTable.folderUploadTable, custUsernameGetter) > 0) {
      retrieveFolders.addAll(await FolderRetrieve().retrieveParams(custUsernameGetter));
    }

    Globals.fromLogin = true;
    Globals.fileValues.addAll(uniqueFileNames);
    Globals.foldValues.addAll(retrieveFolders);
    Globals.imageByteValues.addAll(uniqueBytes);
    Globals.dateStoresValues.addAll(dates);
    Globals.setDateValues.addAll(dates);

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

        setupFiles.writeAsStringSync("${EncryptionClass().Encrypt(custUsername)}\n${EncryptionClass().Encrypt(custEmail)}\n$accountType");

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

      final custUsername = await getCustUsername(email, conn);

      if (custUsername.isNotEmpty) {

        custEmailInit = email!;

        final custPasOriginal = await getCustPassword(custUsername, conn);
        final custPinOriginal = await getCustPin(custUsername, conn);

        final case0 = AuthModel().computeAuth(auth0!) == custPasOriginal;
        final case1 = AuthModel().computeAuth(auth1!) == custPinOriginal;

        if (case0 && case1) {

          final conn = await SqlConnection.insertValueParams();
          
          final justLoading = JustLoading();

          justLoading.startLoading(context: context);
          await _callData(conn,isChecked);

          justLoading.stopLoading();
          
          NavigatePage.permanentPageMainboard(context);

        } else {
          AlertForm.alertDialog("Password or PIN Key is incorrect.", context);
        }
      } else {
        AlertForm.alertDialog("Account not found.", context);
      }
    } catch (err, st) {
      AlertForm.alertDialogTitle("Something is wrong...", "No internet connection.", context);
      logger.e("Exception from logParams {MYSQL_login}", err, st);
      
    } finally {
      await conn.close();
    }
  }

  Future<String> getCustUsername(String? email, conn) async {
    var getCase0 = await conn.execute(
        "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email",
        {"email": email});

    for (var usernameIterates in getCase0.rows) {
      return usernameIterates.assoc()['CUST_USERNAME']!;
    }

    return '';
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