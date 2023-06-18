import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/validate_email.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flowstorage_fsc/widgets/main_text_field.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/data_classes/register_process.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:intl/intl.dart';

class cakeMySignUp extends StatefulWidget {
  const cakeMySignUp({super.key});

  @override
  State<cakeMySignUp> createState() => cakeSignUpPage();
}

class cakeSignUpPage extends State<cakeMySignUp> {

  final dateToStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

  bool _visiblePasswordSignUp = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final auth0Controller = TextEditingController();
  final auth1Controller = TextEditingController(); 

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    auth0Controller.dispose();
    emailController.dispose();
    auth1Controller.dispose();
    usernameController.clear();
    auth0Controller.clear();
    emailController.clear();
    auth1Controller.clear();
    super.dispose();
  }

  Future<void> insertUserRegistrationInformation({
    required String username,
    required String email,
    required String auth0,
    required String auth1
  }) async {

    try {

      var valueCase0 = AuthModel().computeAuth(auth0);
      var valueCase1 = AuthModel().computeAuth(auth1);
      
      final informationCon = MysqlInformation();
      await informationCon.insertParams(
        userName: username,
        auth0: valueCase0,
        email: email,
        auth1: valueCase1,
        createdDate: dateToStr,
        context: context
      );

    } catch (exceptionConnectionFsc) {
      AlertForm.alertDialogTitle("Something is wrong...", "No internet connection.", context);
    }
    
  }

  Future<void> processRegistration() async {
    
    var custUsernameInput = usernameController.text;
    var custEmailInput = emailController.text;
    var custAuth0Input = auth0Controller.text;
    var custAuth1Input = auth1Controller.text;

    if(custEmailInput.isEmpty && custUsernameInput.isEmpty && custAuth0Input.isEmpty && custAuth1Input.isEmpty) {
      AlertForm.alertDialog("Please fill all the required forms.",context);
      return;
    }

    if (custUsernameInput.contains(RegExp(r'[&%;?]'))) {
      AlertForm.alertDialogTitle("Sign Up Failed","Username cannot contain special characters.",context);
      return;
    }

    if (custAuth0Input.contains(RegExp(r'[?!]'))) {
      AlertForm.alertDialogTitle("Sign Up Failed","Password cannot contain special characters.",context);
      return;
    }

    if (custAuth0Input.length <= 5) {
      AlertForm.alertDialogTitle("Sign Up Failed","Password must contain more than 5 characters.",context);
      return;
    }

    if (custAuth1Input.length != 3) {
      AlertForm.alertDialogTitle("Sign Up Failed","PIN Number must have 3 digits.",context);
      return;
    }

    if (custAuth1Input.isEmpty) {
      AlertForm.alertDialogTitle("Sign Up Failed","Please add a PIN number to protect your account.",context);
      return;
    }

    if (!EmailValidator().validateEmail(custEmailInput)) {
      AlertForm.alertDialogTitle("Sign Up Failed","Email address is not valid.",context);
      return;
    }

    if (custUsernameInput.isEmpty) {
      AlertForm.alertDialogTitle("Sign Up Failed","Please enter a username.",context);
      return;
    }

    if (custAuth0Input.isEmpty) {
      AlertForm.alertDialog("Please enter a password.",context);
      return;
    }

    if (custEmailInput.isEmpty) {
      AlertForm.alertDialog("Please enter your email.",context);
      return;
    }

    Globals.fileValues.clear();
    Globals.imageValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();              
    Globals.imageByteValues.clear();
    
    Globals.custUsername = custUsernameInput;
    Globals.custEmail = custEmailInput;
    Globals.fileOrigin = "homeFiles";
    Globals.accountType = "Basic";

    Globals.fromLogin = true;
    
    await insertUserRegistrationInformation(
      username: custUsernameInput, 
      email: custEmailInput, 
      auth0: custAuth0Input, 
      auth1: custAuth1Input
    );
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          )
      ),

      backgroundColor: ThemeColor.darkBlack,
      resizeToAvoidBottomInset: false,
      body: Padding(  
        padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.size.width * 0.05,
          vertical: mediaQuery.size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.02,
                vertical: mediaQuery.size.height * 0.02,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  HeaderText(title: "Sign Up", subTitle: "Create an account for Flowstorage"),

                ],
              ),
            ),

            const SizedBox(height: 15),

            MainTextField(
              hintText: "Enter a username", 
              controller: usernameController
            ),

            const SizedBox(height: 18),

            MainTextField(
              hintText: "Enter your email address", 
              controller: emailController
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
                      obscureText: !_visiblePasswordSignUp,
                      
                      decoration: InputDecoration(
                        
                        suffixIcon: IconButton(
                          icon: Icon(
                            _visiblePasswordSignUp ? Icons.visibility : Icons.visibility_off,
                            color: const Color.fromARGB(255, 141, 141, 141),
                          ), 
                          onPressed: () { 
                            setState(() {
                              _visiblePasswordSignUp = !_visiblePasswordSignUp;
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
          
          const SizedBox(height: 40),

          MainButton(
            text: "Sign Up",
            onPressed: processRegistration,
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 35,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?  ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 233, 232, 232),
                    ),
                  ),

                  const SizedBox(width: 2), 

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.darkBlack,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () {
                        NavigatePage.goToPageLogin(context);
                      },
                      child: const Text("Sign In",
                        style: TextStyle(
                          color: ThemeColor.darkPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),      
    );
  }
}