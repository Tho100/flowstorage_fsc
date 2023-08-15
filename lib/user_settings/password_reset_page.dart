import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class ResetAuthentication extends StatefulWidget {

  final curPassController = TextEditingController();
  final newPassController = TextEditingController();

  final String custUsername;
  final String custEmail;

  ResetAuthentication({
    Key? key,
    required this.custUsername,
    required this.custEmail,
  }) : super (key: key);

  @override
  State<ResetAuthentication> createState() => ResetAuthenticationState();
}

class ResetAuthenticationState extends State<ResetAuthentication> {

  final sufixIconVisibilityNotifier = ValueNotifier<bool>(false);

  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured, bool isPin) {

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
              valueListenable: sufixIconVisibilityNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: mainController,
                obscureText: isSecured == true ? !isVisible : true,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: isSecured == true
                    ? IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromARGB(255, 141, 141, 141),
                        ),
                        onPressed: () {
                          sufixIconVisibilityNotifier.value = !isVisible;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(title: "Account Recovery", subTitle: "Reset your account password"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter a new password", widget.newPassController, context, true, false),

        const SizedBox(height: 12),

        _buildTextField("Confirm your password", widget.curPassController, context, true, false),
        
        const SizedBox(height: 20),

        MainButton(
          text: "Update Password",
          onPressed: () async {
            await _executeChanges(widget.curPassController.text, widget.newPassController.text, context);
          }
        ),

      ],
    );
  }

  @override
  void dispose() {
    sufixIconVisibilityNotifier.dispose();
    super.dispose();
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
          builder: (context) => _buildBody(context)
        ),
      ),
    );
  }

  Future<void> _executeChanges(String currentAuth, String newAuth,BuildContext context) async {

    try {

      if(newAuth.isEmpty && currentAuth.isEmpty) {
        return;
      }
      
      if(newAuth != currentAuth) {
        CustomAlertDialog.alertDialog("Password does not match.",context);
        return;
      }

      final getUsername = await _getUsername(widget.custEmail);

      await _updateAuth(newAuth, getUsername);

      if(!mounted) return;
      CustomAlertDialog.alertDialogTitle("Password Updated", "Password for ${widget.custEmail} has been updated. You may login into your account now", context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to update your password.", context);
    }
  }

  Future<void> _updateAuth(String newAuth,String username) async {
    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :newauth WHERE CUST_USERNAME = :username"; 
    final params = {'newauth': AuthModel().computeAuth(newAuth), 'username': username};
    await Crud().update(query: updateAuthQuery, params: params);
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
}