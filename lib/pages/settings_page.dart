import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';import 'package:flowstorage_fsc/sharing/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
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
  CakeSettingsPageState createState() => CakeSettingsPageState();
}

class CakeSettingsPageState extends State<CakeSettingsPage> {

  late String custUsername;
  late String custEmail;
  late String accountType;
  late int uploadLimit;
  late String sharingEnabledButton;

  final addPasswordController = TextEditingController();
  final dataCaller = DataCaller();

  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  @override
  void initState() {
    super.initState();
    custUsername = widget.custUsername;
    custEmail = widget.custEmail;
    accountType = widget.accType;
    uploadLimit = widget.uploadLimit;
    sharingEnabledButton = widget.sharingEnabledButton == '0' ? 'Disable' : 'Enable';
  }

  @override 
  void dispose() {
    addPasswordController.dispose();
    super.dispose();
  }

  void _clearUserRecords() {
    storageData.fileNamesList.clear();
    storageData.foldersNameList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.imageBytesList.clear();
    storageData.imageBytesFilteredList.clear();
  }

  void _clearAppCache() async {
    var cacheDir = await getTemporaryDirectory();
    await DefaultCacheManager().emptyCache();
    cacheDir.delete(recursive: true);
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
                    borderRadius: BorderRadius.circular(14),
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
                      child: MainDialogButton(
                        text: "Close", 
                        onPressed: () {
                          addPasswordController.clear();
                          Navigator.pop(context);
                        }, 
                        isButtonClose: true
                      )
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MainDialogButton(
                        text: "Confirm",
                        onPressed: () async {

                          try {

                            if(addPasswordController.text.isEmpty) {
                              return;
                            }

                            final getAddPassword = AddPasswordSharing();
                            getAddPassword.insertValuesParams(username: custUsername, newAuth: addPasswordController.text);

                            CustomAlertDialog.alertDialogTitle("Added password for File Sharing", "Users are required to enter the password before they can share a file with you.", context);

                          } catch (err, st) {
                            Logger().e("Exception from _buildAddPassword {settings_page}", err, st);
                            CustomAlertDialog.alertDialogTitle("An error occurred", "Faild to add/update pasword for File Sharing. Please try again later.", context);
                          }

                        },
                        isButtonClose: false,
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
                _clearUserRecords();
                await _deleteAutoLoginAndOfflineFiles();

                if(!mounted) return;
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
                        custUsername.substring(0, 2),
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
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: custUsername));
                        CallToast.call(message: "Username copied.");
                      },
                      child: Text(
                        custUsername,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      accountType,
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
                  width: 110,
                  height: 40,
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
      
            _buildRow("Email",custEmail),
            _buildRow("Account Type",accountType),
            _buildRow("Upload Limit",uploadLimit.toString()),
            
            const SizedBox(height: 10),
      
            _buildInfoText("Update Information"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Change my password", 
              bottomText: "Update your Flowstorage password", 
              onPressed: () {
                NavigatePage.goToPageChangePass(context);
              }
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Sharing"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "File sharing", 
              bottomText: sharingEnabledButton, 
              onPressed: () async {

                sharingEnabledButton == 'Disable' 
                ? await SharingOptions.disableSharing(custUsername) 
                : await SharingOptions.enableSharing(custUsername);
      
                setState(() {
                  sharingEnabledButton = sharingEnabledButton == "Disable" ? "Enable" : "Disable";
                });

                final sharingStatus = sharingEnabledButton == "Enable" ? "Disabled" : "Enabled";

                const fileSharingDisabledMsg = "File sharing disabled. No one can share a file to you.";
                const fileSharingEnabledMsg = "File sharing enabled. People can share a file to you.";

                final updatedStatus = sharingEnabledButton == "Enable" ? "1" : "0";

                userData.setSharingStatus(updatedStatus);

                final conclusionSubMsg = sharingStatus == "Disabled" ? fileSharingDisabledMsg : fileSharingEnabledMsg;

                if(!mounted) return;
                CustomAlertDialog.alertDialogTitle("Sharing $sharingStatus", conclusionSubMsg, context);
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
      
            _buildInfoText("Security"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Add Passcode", 
              bottomText: "Require to enter passcode before allowing to open Flowstorage", 
              onPressed: () async {
                NavigatePage.goToAddPasscodePage(context);
              }
            ),

            const SizedBox(height: 15),

            _buildRowWithButtons(
              topText: "Backup recovery key", 
              bottomText: "Recovery key enables password reset in case of forgotten passwords", 
              onPressed: () async {
                NavigatePage.goToPageBackupRecovery(context);
              }
            ),

            const SizedBox(height: 10),
      
            _buildInfoText("Insight"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Statistics", 
              bottomText: "Get more insight about your Flowstorage activity", 
              onPressed: () async {

                if(tempData.fileOrigin != "homeFiles") {
                  await dataCaller.homeData(isFromStatistics: true);
                }

                if(!mounted) return;
                NavigatePage.goToPageStatistics(context);

              }
            ),

            const SizedBox(height: 10),
      
            _buildInfoText("Cache"),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Clear cache", 
              bottomText: "Clear Flowstorage cache", 
              onPressed: () {
                _clearAppCache();
                CallToast.call(message: "Cache cleared.");
              }
            ),

            Visibility(
              visible: accountType != "Basic",
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  _buildInfoText("Plan"),
                  
                  const SizedBox(height: 10),
                  
                  _buildRowWithButtons(
                    topText: "My plan", 
                    bottomText: "See your subscription plan details", 
                    onPressed: () async {
                      NavigatePage.goToPageMyPlan(context);
                    }
                  ),
                ],
              ),
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
