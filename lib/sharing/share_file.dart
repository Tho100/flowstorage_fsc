import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/ui_dialog/TitledAlert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MySqlSharing {

  final TextEditingController sharingPasswordController = TextEditingController();

  Future _buildAskPasswordDialog(
    String? sendTo, 
    String? fileName, 
    String? comment, 
    var fileVal, 
    String? fileExt, 
    String? authString,
    BuildContext context, 
    {dynamic thumbnail}){

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
                      "Enter this user Sharing Password",
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
                    controller: sharingPasswordController,
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
                            sharingPasswordController.clear();
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

                            final compare = AuthModel().computeAuth(sharingPasswordController.text);
                            if(compare == authString) {
                              startSharing(sendTo, fileName, comment, fileVal, fileExt, thumbnail: thumbnail);
                            }

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Share'),
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

  Future<void> startSharing(String? sendTo, String? fileName, String? comment, var fileVal, String? fileExt, {dynamic thumbnail}) async {

    final uploadDate = DateFormat('dd/MM/yyyy').format(DateTime.now()); 
    final crud = Crud();

    try {

      const insertSharingData = 'INSERT INTO cust_sharing(CUST_TO, CUST_FROM, CUST_FILE_PATH, CUST_FILE, UPLOAD_DATE, FILE_EXT, CUST_THUMB, CUST_COMMENT) '
        'VALUES (:to, :from, :filename, :fileval, :date, :ext, :thumbnail, :comment)';
      final params = {'to': sendTo!, 'from': Globals.custUsername, 'fileval': fileVal!, 'filename': fileName!, 'date': uploadDate, 'ext': fileExt!, 'thumbnail': thumbnail!, 'comment': comment!};

      await crud.insert(query: insertSharingData, params: params);

    } catch (err) {
      print("Exception from startSharing {MySqlSharing}: $err");
    }

  }

  Future<void> insertValuesParams(String? sendTo, String? fileName, String? comment, var fileVal, String? fileExt, BuildContext context, {dynamic thumbnail}) async {
    
    try {

      final getReceiverDisabled = await SharingOptions.retrieveDisabled(sendTo!);

      if(getReceiverDisabled == '1') {
        TitledDialog.startDialog('Sharing Failed', 'User $sendTo disabled their file sharing.', context);
        return;
      }

      final getSharingAuth = await SharingOptions.retrievePassword(sendTo);


      if(getSharingAuth != "DEF") {
        _buildAskPasswordDialog(sendTo,fileName,comment,fileVal,fileExt,getSharingAuth,context,thumbnail: thumbnail);
        return;
      }

      if(sendTo == Globals.custUsername) {
        TitledDialog.startDialog('Sharing Failed', "You can't share to yourself.", context);
        return;
      }

      await startSharing(sendTo, fileName, comment, fileVal, fileExt,thumbnail: thumbnail);

      SnakeAlert.okSnake(message: "${EncryptionClass().Decrypt(ShortenText().cutText(fileName!))} Has been shared to $sendTo.", icon: Icons.check,context: context);

      await CallNotify().customNotification(title: "File Shared", subMesssage: "${EncryptionClass().Decrypt(fileName)} Has been shared to $sendTo");

    } catch (err) {
      await CallNotify().customNotification(title: "Something went wrong",subMesssage: "Failed to share ${EncryptionClass().Decrypt(fileName)}");
      SnakeAlert.errorSnake("Failed to share this file.",context);
    } 

  }

}