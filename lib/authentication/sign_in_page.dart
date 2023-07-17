import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/validate_email.dart';
import 'package:flowstorage_fsc/user_settings/password_recovery_page.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flowstorage_fsc/widgets/main_text_field.dart';
import 'package:flowstorage_fsc/data_classes/login_process.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'package:flutter/material.dart';

class CakeSignInPage extends StatefulWidget {

  const CakeSignInPage({Key? key}) : super(key: key);

  @override
  CakeSignInPageState createState() => CakeSignInPageState(); 
}

class CakeSignInPageState extends State<CakeSignInPage> {

  BuildContext? loginContext;

  bool isChecked = false; 
  bool visiblePassword = false; 

  final emailController = TextEditingController();
  final auth0Controller = TextEditingController();
  final auth1Controller = TextEditingController();

  Future<void> verifyUserSignInInformation({
    required String email, 
    required String auth0, 
    required String auth1
  }) async {

    Globals.fromLogin = true;
    loginContext = context;

    final loginSetup = MysqlLogin();
    await loginSetup.logParams(email, auth0, auth1, isChecked, context);

  }
  
  Future<void> processSignIn() async {

    final custAuth0Input = auth0Controller.text.trim();
    final custAuth1Input = auth1Controller.text.trim();
    final custEmailInput = emailController.text.trim();

    if (!EmailValidator().validateEmail(custEmailInput)) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Email address is not valid.", context);
      return;
    }

    if (custAuth1Input.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your PIN key.",context);
      return;
    }

    if (custEmailInput.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your email address.",context);
      return;
    }

    if (custAuth0Input.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your password.",context);              
      return;
    }

    await verifyUserSignInInformation(
      email: custEmailInput, 
      auth0: custAuth0Input, 
      auth1: custAuth1Input
    );
  }

  @override
  void initState() {
    super.initState();
    visiblePassword = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    auth0Controller.dispose();
    auth1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          )
      ),
      backgroundColor: ThemeColor.darkBlack,
      body: Padding (

        padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.size.width * 0.05,
          vertical: mediaQuery.size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.02,
                vertical: mediaQuery.size.height * 0.02,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  HeaderText(title: "Sign In", subTitle: "Sign in to your Flowstorage account"),

                ],
              ),
            ),

          const SizedBox(height: 15),

          MainTextField(
            hintText: "Enter your email address", 
            controller: emailController,
          ),

         const SizedBox(height: 18),
            
          Row(
            children: [
              SizedBox(
                width: mediaQuery.size.width*0.66,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2.0, color: ThemeColor.darkBlack),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: auth0Controller,
                    obscureText: !visiblePassword,
                    
                    decoration: InputDecoration(
                      
                      suffixIcon: IconButton(
                        icon: Icon(
                          visiblePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromARGB(255, 141, 141, 141),
                        ), 
                        onPressed: () { 
                          setState(() {
                            visiblePassword = !visiblePassword;
                          });
                        },
                      ),
              
                      hintText: "Enter a password",
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                      fillColor: ThemeColor.darkGrey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
              
              const SizedBox(width: 18),

              SizedBox(
                width: mediaQuery.size.width*0.2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: auth1Controller,
                    obscureText: true,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: "PIN",
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                      fillColor: ThemeColor.darkGrey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 2.0,
                          color: Color.fromARGB(255, 6, 102, 226),
                        ),
                      ),
                      counterStyle: const TextStyle(color: Color.fromARGB(255,199,199,199)),
                    ),
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 15),

          CheckboxTheme(
              data: CheckboxThemeData(
                fillColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.darkGrey,
                ),
                checkColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite,
                ),
                overlayColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite.withOpacity(0.1),
                ),
                side: const BorderSide(
                  color: ThemeColor.darkGrey,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    "Remember Me",
                    style: TextStyle(
                      color: Color.fromARGB(225, 225, 225, 225),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            MainButton(
              text: "Sign In", 
              onPressed: processSignIn
            ),
        
            const Spacer(),

            Center(

              child: Column(
                children: [
                  const Text('Forgot your password?',
                    style: TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ResetBackup(username: Globals.custUsername)));
                    },
                    child: const Text('Reset with Recovery Key',  
                      style: TextStyle(
                        color: ThemeColor.darkPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                      ),
                    ),
                  ),

                ],
              )
            ),

          ],
        ),
      ),      
    );
  }

}