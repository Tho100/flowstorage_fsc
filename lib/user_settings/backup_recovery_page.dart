import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';

class BackupRecovery extends StatelessWidget {

  BackupRecovery({Key? key}) : super (key: key);
  
  final _locator = GetIt.instance;

  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured, {bool isFromPin = false}) {

    final valueNotifier = ValueNotifier<bool>(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: valueNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: mainController,
                obscureText: isSecured == true ? !isVisible : false,
                maxLines: 1,
                maxLength: isFromPin == true ? 3 : null,
                keyboardType: isFromPin == true ? TextInputType.number : null,
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
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 18.0, 10.0, 25.0),
                  hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                  fillColor: ThemeColor.darkGrey,
                  filled: true,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
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
    
    final TextEditingController pinController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Recovery Key",subTitle: "Backup your Recovery Key"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter your Password",passController,context,true),

        const SizedBox(height: 15),

        _buildTextField("Enter your PIN",pinController,context,true,isFromPin: true),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Export Recovery Key",
          onPressed: () async {
            await _executeChanges(pinController.text,passController.text, context);
          },
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

  Future<String> _getBackup(String username) async {

    const selectAuth = "SELECT RECOV_TOK FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};    

    final returnAuth = await Crud().select(
      query: selectAuth, 
      returnedColumn: "RECOV_TOK", 
      params: params
    );

    return EncryptionClass().decrypt(returnAuth);

  }

  Future<void> _executeChanges(String auth0,String auth1, BuildContext context) async {

    try {

      final userData = _locator<UserDataProvider>();

      if(auth0.isEmpty && auth1.isEmpty) {
        return;
      }

      if(await _incorrectAuth(userData.username, AuthModel().computeAuth(auth0),"CUST_PIN")) {
        CustomAlertDialog.alertDialog("Entered PIN is incorrect.", context);
        return;
      }

      if(await _incorrectAuth(userData.username, AuthModel().computeAuth(auth1),"CUST_PASSWORD")) {
        CustomAlertDialog.alertDialog("Password is incorrect.", context);
        return;

      } 

      final getBackupData = await _getBackup(userData.username);
      final saveBackup = await SaveApi().saveFile(fileName: "FlowstorageRECOVERYKEY.txt", fileData: getBackupData);

      CustomFormDialog.startDialog(
        "Recovery key has been backed up",
        "Location path: $saveBackup",
        context,
      );

    } catch (err) {
      CustomAlertDialog.alertDialog("Failed to backup your recovery key.",context);
    }
  }

  Future<bool> _incorrectAuth(String getUsername,String getAuthString,String originFrom) async {

    return await Verification().notEqual(getUsername, getAuthString, originFrom);

  }

}