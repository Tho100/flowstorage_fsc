
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class MysqlInformation {

  Future<void> insertParams({
    required String? userName, 
    required String? auth0, 
    required String? email,
    required String? auth1,
    required String? createdDate,
    required BuildContext context
  }) async {
    
    final conn = await SqlConnection.insertValueParams();
    final crud = Crud();

    final verifyUsernameQue = await conn.execute(
      "SELECT CUST_USERNAME FROM information WHERE CUST_USERNAME = :username",
      {"username": userName},
    );

    if (verifyUsernameQue.rows.isNotEmpty) {
      CustomAlertDialog.alertDialog("Username is taken.", context);
      return;
    }

    final verifyEmailQue = await conn.execute(
      "SELECT CUST_EMAIL FROM information WHERE CUST_EMAIL = :email",
      {"email": email},
    );
    
    if (verifyEmailQue.rows.isNotEmpty) {
      CustomAlertDialog.alertDialog("Email already exists.", context);
      return;
    }

    if (userName!.length > 20) {
      CustomAlertDialog.alertDialog("Username character length limit is 20.", context);
      return;
    }

    if (auth0!.length <= 5) {
      CustomAlertDialog.alertDialog("Password length must be greater than 5.", context);
      return;
    }

    await insertUserInfo(userName, auth0, createdDate!, email!, auth1!,context);

    const List<String> insertExtraInfoQuery = [
      "INSERT INTO cust_type(CUST_USERNAME,CUST_EMAIL,ACC_TYPE) VALUES (:username,:email,:type)",
      "INSERT INTO lang_info(CUST_USERNAME,CUST_LANG) VALUES (:username,:lang)",
      "INSERT INTO sharing_info(CUST_USERNAME,DISABLED,SET_PASS) VALUES (:username,:disabled,:pass)"
    ];

    final params = [
      {"username": userName, "email": email, "type": "Basic"},
      {"username": userName, "lang": "US"},
      {"username": userName, "disabled": "0", "pass": "DEF"},
    ];

    for (var i = 0; i < insertExtraInfoQuery.length; i++) {

      final query = insertExtraInfoQuery[i];
      final param = params[i];

      await crud.insert(
        query: query,
        params: param,
      );
    }

    NavigatePage.permanentPageMainboard(context);

    auth0 = null;
    userName = null;
    email = null;
    auth1 = null;
  
  }

  Future<void> insertUserInfo(String? userName, String? passWord, String? createdDate, String? email, String? pin, BuildContext context) async {

    try {
      
      final conn = await SqlConnection.insertValueParams();

      final String setTokRecov = generateRandomString(16) + userName!;
      final String removeSpacesSetRecov = EncryptionClass().Encrypt(setTokRecov.replaceAll(RegExp(r'\s'), ''));

      final String setTokAcc = (generateRandomString(12) + userName).toLowerCase();
      final String removeSpacesSetTokAcc = AuthModel().computeAuth(setTokAcc.replaceAll(RegExp(r'\s'), ''));

      await conn.execute(
        "INSERT INTO information(CUST_USERNAME,CUST_PASSWORD,CREATED_DATE,CUST_EMAIL,CUST_PIN,RECOV_TOK,ACCESS_TOK) "
        "VALUES (:username,:password,:date,:email,:pin,:tok,:tok_acc)",
        {"username": userName, "password": passWord, "date": createdDate, "email": email, "pin": pin, "tok": removeSpacesSetRecov,"tok_acc": removeSpacesSetTokAcc},
      );

      await setupAutoLogin(userName,email!);

    } catch (duplicatedUsernameException) {
      // TODO: Ignore
    } 
  }

  String generateRandomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    ).toUpperCase();
  }


  Future<void> setupAutoLogin(String custUsername,String email) async {
    
    const accountType = "Basic";
    
    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);
    if (custUsername.isNotEmpty && email.isNotEmpty) {
      if (setupInfosDir.existsSync()) {
        setupInfosDir.deleteSync(recursive: true);
      }

      setupInfosDir.createSync();

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {

        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync('${EncryptionClass().Encrypt(custUsername)}\n${EncryptionClass().Encrypt(email)}\n$accountType');

      } catch (e) {
        // 
      }
    } else {
      // 
    }
  }
}