import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/user_settings/password_reset_page.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';

class ResetBackup extends StatefulWidget {

  late String username;
  late String email;
  
  ResetBackup({
    Key? key,
    required this.username,
    required this.email,
  }) : super (key: key) {
    CustUsername = username;
    CustEmail = email;
  }

  String CustUsername = '';
  String CustEmail = '';

  @override
  State<ResetBackup> createState() => _ResetBackupState();
}

class _ResetBackupState extends State<ResetBackup> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController pinController = TextEditingController();

  final TextEditingController recoveryController = TextEditingController();

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
                maxLength: isFromPin == true ? 3 : null,
                keyboardType: isFromPin == true ? TextInputType.number : null,
                decoration: InputDecoration(
                  suffixIcon: isSecured == true
                      ? IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color.fromARGB(255, 141, 141, 141),
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
                  counterText: '',
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Reset Password", subTitle: "Reset password with recovery key"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter your email address",emailController,context,false),

        const SizedBox(height: 15),

        _buildTextField("Enter your PIN",pinController,context,true,isFromPin: true),

        const SizedBox(height: 20),

        _buildTextField("Enter your Recovery Key",recoveryController,context,false),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Proceed", 
          onPressed: () async {
            await _executeChanges(emailController.text,pinController.text,recoveryController.text, context);
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

  Future<String> _getRecov(String username) async {

    const selectAuth = "SELECT RECOV_TOK FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final returnedAuth = await Crud().select(
      query: selectAuth, 
      returnedColumn: "RECOV_TOK", 
      params: params
    );

    return EncryptionClass().Decrypt(returnedAuth);

  }

  Future<void> _executeChanges(String email,String authenticationString,String recovTokInput, BuildContext context) async {

    try {

      if(email.isEmpty || authenticationString.isEmpty || recovTokInput.isEmpty) {
        return;
      }

      if(await _getRecov(await _getUsername(email)) != recovTokInput) {
        AlertForm.alertDialog("Invalid recovery key.", context);
        return;
      }

      if(await _authIncorrect(await _getUsername(email), AuthModel().computeAuth(authenticationString))) {
        AlertForm.alertDialog("Entered PIN is incorrect.", context);
        return;

      } else {

        emailController.clear();
        pinController.clear();
        recoveryController.clear();        

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => ResetAuthentication(username: widget.CustUsername, email: email)));

      }

    } catch (exportBackupFailed) {
      AlertForm.alertDialogTitle("An error occurred","Failed to export your recovery key. Please try again later",context);
    }
  }

  Future<String> _getUsername(String custEmail) async {

    const selectUsername = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': custEmail};

    final returnedUsername = await Crud().select(
      query: selectUsername, 
      returnedColumn: "CUST_USERNAME", 
      params: params
    );

    return returnedUsername;
  
  }

  Future<bool> _authIncorrect(String getUsername,String getAuthString) async {

    return await Verification().notEqual(getUsername, getAuthString, "CUST_PIN");

  }
}