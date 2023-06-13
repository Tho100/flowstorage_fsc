import 'dart:io';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:path_provider/path_provider.dart';


class ChangeUsername extends StatelessWidget {

  const ChangeUsername({Key? key}) : super (key: key);

  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured) {

    final valueNotifier = ValueNotifier<bool>(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: valueNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: mainController,
                obscureText: isSecured == true ? !isVisible : false,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: isSecured == true
                      ? IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: ThemeColor.thirdWhite,
                          ),
                          onPressed: () {
                            valueNotifier.value = !isVisible;
                          },
                        )
                      : null,
                  hintText: hintText,
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                  hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                  fillColor: ThemeColor.darkGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      width: 2.0,
                      color: Color.fromARGB(255, 6, 102, 226),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    
    final TextEditingController newUserController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(title: "Change Username", subTitle: "Change your Flowstorage username"),
        ),
        
        const SizedBox(height: 35),

        _buildTextField("Enter a new username",newUserController,context,false),

        const SizedBox(height: 15),

        _buildTextField("Enter your password",passController,context,true),
        
        const SizedBox(height: 20),

        MainButton(
          text: "Change", 
          onPressed: () async {
            await _executeChanges(newUserController.text,passController.text, context);
          }
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: ThemeColor.darkBlack,
         body: Builder(
          builder: (context) => _buildBody(context),
        ),
      ),
    );
  }

  Future<void> setupAutoLogin(String custUsername) async {
      
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

        setupFiles.writeAsStringSync('${EncryptionClass().Encrypt(custUsername)}\n${EncryptionClass().Encrypt(Globals.custEmail)}');

      } catch (e) {
        // TODO: Ignore
      }
    } else {
      // TODO: Ignore
    }
    
  }

  Future<void> _updateUsername(String newUsername) async {

    for(final tables in Globals.tableNames) {

      final updateNameQuery = "UPDATE $tables SET CUST_USERNAME = :newname WHERE CUST_USERNAME = :oldname";
      final params = {'newname': newUsername,'oldname': Globals.custUsername};

      await Crud().update(
        query: updateNameQuery, 
        params: params
      );
    }

    const updateNameQuery = "UPDATE cust_sharing SET CUST_FROM = :newname WHERE CUST_FROM = :oldname";
    final params = {'newname': newUsername,'oldname': Globals.custUsername};

    await Crud().update(
      query: updateNameQuery, 
      params: params
    );

    const updateUsernameQuery = "UPDATE information SET CUST_USERNAME = :newusername WHERE CUST_USERNAME = :oldusername";
    final usernameParam = {'newusername': newUsername,'oldusername': Globals.custUsername};
    await Crud().update(query: updateUsernameQuery, params: usernameParam);

  }

  Future<void> _executeChanges(String newUsername,String authenticationString, BuildContext context) async {

    try {

      if(newUsername.isEmpty && authenticationString.isEmpty) {
        return;
      }

      if(newUsername == Globals.custUsername) {
        AlertForm.alertDialog("The new entered username is your current username.", context);
        return;
      }

      if(await _verifyAuthentication(Globals.custUsername, AuthModel().computeAuth(authenticationString))) {
        AlertForm.alertDialog("Password is incorrect.", context);
        return;

      } else {

        if(await _isUsernameTaken(newUsername)) {
          AlertForm.alertDialog("Username is taken.", context);
          return;
        }

        await Future(() => _updateUsername(newUsername));

        Globals.custUsername = newUsername;

        await setupAutoLogin(newUsername);
      
        SnakeAlert.okSnake(message: 'Username updated to $newUsername' ,icon: Icons.check, context: context);

      }

    } catch (usernameException) {
      AlertForm.alertDialog("An error occurred while trying to update your username\nPlease try again later.",context);
    }
  }

  Future<bool> _isUsernameTaken(String getUsername) async {

    const selectUsername = "SELECT CUST_USERNAME FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': getUsername};

    final returnedUsername = await Crud().select(
      query: selectUsername, 
      returnedColumn: "CUST_USERNAME", 
      params: params
    );

    return returnedUsername != null;

  }

  Future<bool> _verifyAuthentication(String getUsername,String getAuthString) async {

    return await Verification().notEqual(getUsername, getAuthString, "CUST_PASSWORD");

  }

}