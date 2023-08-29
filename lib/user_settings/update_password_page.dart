import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';

class ChangePassword extends StatefulWidget {

  const ChangePassword({Key? key}) : super(key: key);

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {

  final newPassController = TextEditingController();
  final curPassController = TextEditingController();
  final curPinController = TextEditingController();
  
  final valueNotifierNew = ValueNotifier<bool>(false);
  final valueNotifierCur = ValueNotifier<bool>(false);

  final _locator = GetIt.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    curPassController.dispose();
    curPinController.dispose();
    newPassController.dispose();
    valueNotifierCur.dispose();
    valueNotifierNew.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController mainController,
    BuildContext context,
    bool isSecured,
    bool isPin,
    {ValueNotifier<bool>? valueNotifier}
  ) {

    valueNotifier ??= ValueNotifier<bool>(false); 

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
                obscureText: isSecured == true ? !isVisible : true,
                keyboardType: isPin == true ? TextInputType.number : TextInputType.text,
                maxLength: isPin == true ? 3 : 3000,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: isSecured == true
                      ? IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            valueNotifier!.value = !isVisible;
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
                      color: Colors.blue,
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
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Change Password", subTitle: "Change your Flowstorage password"),
        ),
        
        const SizedBox(height: 35),

        _buildTextField("Enter a new password", newPassController, context, true, false,valueNotifier: valueNotifierNew),

        const SizedBox(height: 12),

        _buildTextField("Enter your current password", curPassController, context, true, false,valueNotifier: valueNotifierCur),
        
        const SizedBox(height: 12),

        _buildTextField("Enter your current PIN key", curPinController, context, false, true),

        const SizedBox(height: 20),

        MainButton(
          text: "Update", 
          onPressed: () async {
            await _exceuteChanges(curPassController.text, newPassController.text,curPinController.text, context);
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
        body: _buildBody(context),
      ),
    );
  }

  Future<void> _exceuteChanges(String currentAuth, String newAuth,String curPin,BuildContext context) async {

    if(newAuth.isEmpty && currentAuth.isEmpty) {
      return;
    }

    final authCase0 = await _verifyAuth(currentAuth, "CUST_PASSWORD", context);
    final authCase1 = await _verifyAuth(curPin, "CUST_PIN", context);
    
    if (!authCase0 && !authCase1) {

      await _updateAuth(newAuth);

      CustomAlertDialog.alertDialogTitle("Password updated.","Your pasword has been updated successfully.", context);

    } else if (authCase0) {
      CustomAlertDialog.alertDialog("Password is incorrect.", context);
    } else {
      CustomAlertDialog.alertDialog("PIN key is incorrect.", context);
    }

  }

  Future<bool> _verifyAuth(String inputStr,String columnName,BuildContext context) async {

    final userData = _locator<UserDataProvider>();

    return await Verification().notEqual(
      userData.username, 
      AuthModel().computeAuth(inputStr),
      columnName
    );
    
  }

  Future<void> _updateAuth(String newAuth) async {

    final userData = _locator<UserDataProvider>();

    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :newauth WHERE CUST_USERNAME = :username"; 

    final params = {'newauth': AuthModel().computeAuth(newAuth), 'username': userData.username};
    await Crud().update(query: updateAuthQuery, params: params);

  }

}
