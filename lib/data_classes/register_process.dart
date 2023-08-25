
import 'package:flowstorage_fsc/api/email_api.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class RegisterUser {

// WELCOME

/*<html>
        <head>
          <style>
            .container {
              background-color: #121212; /* Set your desired background color */
              padding: 10px; /* Set your desired padding */
              display: inline-block; /* Display as an inline block to fit the content */
              border-radius: 5px; /* Add rounded corners */
            }
          </style>
        </head>
        <body>
          <h1 style="color: #f6f6f6;"><span class="container">Account Created Successfully</span></h1>
          <h3>Hello newly registered <span style="color: #4a03a4;">Flowstorage</span> user! You've successfully created an account.</h3>
          <h2>Here’s a little of things you can do with Flowstorage:</h2>
          <ul>
            <li>Backup your photos and videos</li>
            <li>Backup your files, including documents, text files, etc.</li>
            <li>... and more!</li>
            <!-- ...and more -->
          </ul>
        </body>
      </html>*/

// ACCOUNT PLAN UPGARDED

/*    final message = Message()
    ..from = const Address("nfrealyt@gmail.com", 'Flowstorage')
    ..recipients.add('flowstoragebusiness@gmail.com')
    ..subject = 'Flowstorage - Account plan upgraded'
    ..text = ''
    ..html = '''
      <html>
        <head>
          <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
          <style>
            .container {
              background-color: #121212;
              padding: 20px; 
              display: inline-block; 
              width: 95%;
              text-align: center;
              color: #f6f6f6;
              font-family: 'Poppins', sans-serif; 
            }

            table {
              width: 100%;
              border-collapse: collapse;
              border-radius: 15px;
            }

            table, th, td {
              border: 3px solid #121212;
            }

            th, td {
              padding: 10px;
              text-align: center;
              color: #121212;
              font-weight: bold;
              font-size: 24px;
              font-family: 'Poppins', sans-serif;
            }

            .price {
              font-size: 30px;
              font-family: 'Poppins', sans-serif;
            }

            .plan {
              font-size: 30px;
              color: #3164a9;
              font-family: 'Poppins', sans-serif;
            }

            h2 {
              color: #121212;
              font-family: 'Poppins', sans-serif;
            }

            ul li {
              font-weight: 600;
              color: #121212;
              font-family: 'Poppins', sans-serif;
            }

            h3 {
              color: #121212;
              font-family: 'Poppins', sans-serif;
            }

          </style>
        </head>
        <body>
          <h1><span class="container">Account Plan Upgraded</span></h1>
          <table>
            <tr>
              <th>PLAN</th>
              <th>PRICE</th>
            </tr>
            <tr>
              <td class="plan">EXPRESS</td>
              <td class="price">\$8/monthly</td>
            </tr>
          </table>
          <h2>FEATURES</h2>
          <ul>
            <li>Upload Up To 500 Files</li>
            <li>Upload Up To 20 Folders</li>
            <li>Unlocked Folder Download</li>
          </ul>
          <h3>Cancel anytime without getting extra charges.</h3>
        </body>
      </html>
    '''; */

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
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Username is taken.", context);
      }
      return;
    }

    final verifyEmailQue = await conn.execute(
      "SELECT CUST_EMAIL FROM information WHERE CUST_EMAIL = :email",
      {"email": email},
    );
    
    if (verifyEmailQue.rows.isNotEmpty) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Email already exists.", context);
      }
      return;
    }

    if (userName!.length > 20) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Username character length limit is 20.", context);
      }
      return;
    }

    if (auth0!.length <= 5) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Password length must be greater than 5.", context);
      }
      return;
    }

    if(context.mounted) {
      await insertUserInfo(userName, auth0, createdDate!, email!, auth1!,context);
    }

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

    final emailSent = await EmailApi() 
                            .sendFinishedRegistration(email: email!);
    
    if(emailSent == true) {
      NavigatePage.permanentPageMainboard(context);
    }

    auth0 = null;
    userName = null;
    email = null;
    auth1 = null;
  
  }

  Future<void> insertUserInfo(String? userName, String? passWord, String? createdDate, String? email, String? pin, BuildContext context) async {

    try {
      
      final conn = await SqlConnection.insertValueParams();

      final String setTokRecov = generateRandomString(16) + userName!;
      final String removeSpacesSetRecov = EncryptionClass().encrypt(setTokRecov.replaceAll(RegExp(r'\s'), ''));

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

        setupFiles.writeAsStringSync('${EncryptionClass().encrypt(custUsername)}\n${EncryptionClass().encrypt(email)}\n$accountType');

      } catch (e) {
        // 
      }
    } else {
      // 
    }
  }
}