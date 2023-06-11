import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flowstorage_fsc/user_settings/ResetBackup.dart';
import 'package:flowstorage_fsc/widgets/HeaderText.dart';
import 'package:flowstorage_fsc/widgets/MainButton.dart';
import 'package:flowstorage_fsc/widgets/MainTextField.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/data_classes/MYSQL_login.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';

class InsertLoginInfo {

  static insert(
    String custEmail,
    String custPass,
    String custPin,
    BuildContext context,
    bool iSChecked
  ) async {

    final loginSetup = MysqlLogin();
    await loginSetup.logParams(custEmail, custPass, custPin,iSChecked, context);

  }

}

class cakeLogin extends StatefulWidget {

  const cakeLogin({Key? key}) : super(key: key);

  @override
  cakeLoginPageMain createState() => cakeLoginPageMain(); 
}

class cakeLoginPageMain extends State<cakeLogin> {

  String _CustEmailInit = ''; 
  String _CustPassInit = '';
  String _CustPinInit = '';
  BuildContext? loginContext;

  bool isChecked = false; 
  bool _visiblePassword = false;

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _pinController = TextEditingController();

  bool validateEmail(String emailInput) {
    final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(emailInput);
  }

  Future<void> setupLoginCaller(String custEmail, String custPass, String custPin) async {

    setState(() {
      Globals.fromLogin = true;
      _CustEmailInit = custEmail;
      _CustPassInit = custPass;
      _CustPinInit = custPin;
      loginContext = context;
    });

    InsertLoginInfo.insert(
      _CustEmailInit,
      _CustPassInit,
      _CustPinInit,
      loginContext!,
      isChecked,
    );
  }

  @override
  void initState() {
    super.initState();
    _visiblePassword = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: const Text('',
          style: TextStyle(
            fontSize: 22,
            color: ThemeColor.darkPurple,
            fontWeight: FontWeight.bold
          )),
        backgroundColor: ThemeColor.darkBlack,
        centerTitle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      ),

      backgroundColor: ThemeColor.darkBlack,
      body: Padding (

        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.02,
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
            controller: _emailController,
          ),

         const SizedBox(height: 18),
            
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.66,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2.0, color: ThemeColor.darkBlack),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: _passController,
                    obscureText: !_visiblePassword,
                    
                    decoration: InputDecoration(
                      
                      suffixIcon: IconButton(
                        icon: Icon(
                          _visiblePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromARGB(255, 141, 141, 141),
                        ), 
                        onPressed: () { 
                          setState(() {
                            _visiblePassword = !_visiblePassword;
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
                width: MediaQuery.of(context).size.width*0.2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: _pinController,
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
              onPressed: _processLogin
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
                        MaterialPageRoute(builder: (context) => ResetBackup(username: Globals.custUsername, email: Globals.custEmail)));
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

  Future<void> _processLogin() async {

    try {

      final custAuth0Input = _passController.text.trim();
      final custAuth1Input = _pinController.text.trim();
      final custEmailInput = _emailController.text.trim();

      if (!validateEmail(custEmailInput)) {
        AlertForm.alertDialogTitle("Sign In Failed","Email address is not valid.", context);
        return;
      }

      if (custAuth1Input.isEmpty) {
        AlertForm.alertDialogTitle("Sign In Failed","Please enter your PIN key.",context);
        return;
      }

      if (custEmailInput.isEmpty) {
        AlertForm.alertDialogTitle("Sign In Failed","Please enter your email address.",context);
        return;
      }

      if (custAuth0Input.isEmpty) {
        AlertForm.alertDialogTitle("Sign In Failed","Please enter your password.",context);              
        return;
      }

      await setupLoginCaller(custEmailInput, custAuth0Input, custAuth1Input);

    } catch (exceptionSignIn) {
      // TODO: Ignore
    }
  }

}