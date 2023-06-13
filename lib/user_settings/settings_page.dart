import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/sharing/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/main.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CakeSettingsPage extends StatefulWidget {

  final String custUsername;
  final String custEmail;
  final String accType;
  final int uploadLimit;
  final String sharingEnabledButton;

  const CakeSettingsPage({
    Key? key, 
    required this.custUsername, 
    required this.custEmail, 
    required this.accType,
    required this.uploadLimit,
    required this.sharingEnabledButton,
  }) : super(key: key);

  @override
  _CakeSettingsPageState createState() => _CakeSettingsPageState();
}

class _CakeSettingsPageState extends State<CakeSettingsPage> {

  late String _custUsername;
  late String _custEmail;
  late String _accType;
  late int _uploadLimit;
  late String _sharingEnabledButton;

  final TextEditingController addPasswordController = TextEditingController();
  final TextEditingController addPasscodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _custUsername = widget.custUsername;
    _custEmail = widget.custEmail;
    _accType = widget.accType;
    _uploadLimit = widget.uploadLimit;
    _sharingEnabledButton = widget.sharingEnabledButton == '0' ? 'Disable' : 'Enable';
  }

  @override 
  void dispose() {
    addPasswordController.dispose();
    super.dispose();
  }

  Future _buildAddPasswordDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      "Password for File Sharing",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: addPasswordController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter password")
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            addPasswordController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {

                            try {

                              if(addPasswordController.text.isEmpty) {
                                return;
                              }

                              final getAddPassword = AddPasswordSharing();
                              getAddPassword.insertValuesParams(username: _custUsername, newAuth: addPasswordController.text);

                              SnakeAlert.okSnake(message: "Password for file sharing has been added.",icon: Icons.check,context: context);

                            } catch (err) {
                              print(err);
                              AlertForm.alertDialogTitle("An error occurred", "Faild to add/update pasword for File Sharing. Please try again later.", context);
                            }

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  void _addPasscode() async {

    try {

      if(addPasscodeController.text.isEmpty) {
        return;
      }

      final passcodeInput = addPasscodeController.text;

      const storage = FlutterSecureStorage();
      await storage.write(key: "key0015",value: passcodeInput);

      AlertForm.alertDialogTitle("Passcode Added", "You have set a passcode that will be required each time you open the app.\n\nYou can remove the passcode by sign in again to your account.", context);

    } catch (err) {
      print("Exception from _addPasscode {SettingsMenu}: $err");
      AlertForm.alertDialogTitle("An error occurred", "Please try again.", context);
    }

  }

  Future _buildAddPasscodeDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      "Passcode",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    controller: addPasscodeController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter passcode")
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            addPasscodeController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _addPasscode();
                          },
                          style: GlobalsStyle.btnMainStyle,
                          child: const Text('Confirm'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteAutoLoginAndOfflineFiles() async {

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);

    if (setupInfosDir.existsSync()) {
      setupInfosDir.deleteSync(recursive: true);
    }

    final offlineDirs = Directory('${getDirApplication.path}/offline_files');
    if(offlineDirs.existsSync()) {
      offlineDirs.delete(recursive: true);
    }

    const storage = FlutterSecureStorage();
    
    if(await storage.containsKey(key: "key0015")) {
      await storage.delete(key: "key0015");
    }

  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          content: const Text(
            'Logout from your Flowstorage account? Your offline files will be deleted.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: () async {
                Mainboard.clearUserRecords();
                await _deleteAutoLoginAndOfflineFiles();
                NavigatePage.replacePageHome(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildTabs(context),
    );
  }

  Widget _buildRow(String leftText,String rightText) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(leftText,
            style: GlobalsStyle.settingsLeftTextStyle
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(rightText,
            style: GlobalsStyle.settingsRightTextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
        ),
        onPressed: () {
          _showSignOutDialog(context);
        },
        child: const Text("Logout from my account",
          style: TextStyle(
            fontSize: 17,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildRowWithButtons({
    required String topText, 
    required String bottomText, 
    required VoidCallback onPressed
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topText,
                    style: GlobalsStyle.settingsLeftTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bottomText,
                    style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: ThemeColor.thirdWhite),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text,
            style: GlobalsStyle.settingsInfoTextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
      
            const SizedBox(height: 5),
      
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _custUsername.substring(0, 2),
                        style: const TextStyle(
                          fontSize: 24,
                          color: ThemeColor.darkPurple,
                        ),
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(width: 5),
      
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _custUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Globals.accountType,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 185, 185, 185),
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
      
                const Spacer(),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        NavigatePage.goToPageUpgrade(context);
                      },
                      style: GlobalsStyle.btnMainStyle,
                      child: const Text('Upgrade'),
                    ),
                  ),
                const SizedBox(width: 10),
              ],
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Account Information"),
      
            _buildRow("Email",_custEmail),
            _buildRow("Account Type",_accType),
            _buildRow("Upload Limit",_uploadLimit.toString()),
            
            const SizedBox(height: 10),
      
            _buildInfoText("Update Information"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Change my username", 
              bottomText: "Change your Flowstorage Username", 
              onPressed: () {
                NavigatePage.goToPageChangeUser(context);
              }
            ),
      
            const SizedBox(height: 15),
      
            _buildRowWithButtons(
              topText: "Change my password", 
              bottomText: "Change your Flowstorage password", 
              onPressed: () {
                NavigatePage.goToPageChangePass(context);
              }
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Sharing"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "File sharing", 
              bottomText: _sharingEnabledButton, 
              onPressed: () async {
                _sharingEnabledButton == 'Disable' 
                ? await SharingOptions.disableSharing(_custUsername) 
                : await SharingOptions.enableSharing(_custUsername);
      
                setState(() {
                  _sharingEnabledButton = _sharingEnabledButton == "Disable" ? "Enable" : "Disable";
                });
              }
            ),
      
            const SizedBox(height: 15),
      
            _buildRowWithButtons(
              topText: "Add password", 
              bottomText: "Require password for file sharing with you", 
              onPressed: () async {
                await _buildAddPasswordDialog();
              }
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Backup"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Backup recovery key", 
              bottomText: "Recovery key enables password reset in case of forgotten passwords", 
              onPressed: () async {
                NavigatePage.goToPageBackupRecovery(context);
              }
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Security"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Add Passcode", 
              bottomText: "Require to enter passcode before allowing to open Flowstorage", 
              onPressed: () async {
                _buildAddPasscodeDialog();
              }
            ),
            
            const SizedBox(height: 20),

            _buildLogoutButton(),
      
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text(
          'Settings',
          style: GlobalsStyle.appBarTextStyle
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(context),
    );
  }
}