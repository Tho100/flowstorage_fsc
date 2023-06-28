import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/MultipleText.dart';
import 'package:flutter/material.dart';

class SharingPassword {

  final TextEditingController sharingPasswordController = TextEditingController();
  final mysqlSharing = MySqlSharing();

  Future buildAskPasswordDialog(
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

                            final loadingDialog = MultipleTextLoading();
                            final compare = AuthModel().computeAuth(sharingPasswordController.text);
                
                            if(compare == authString) {
                              
                              loadingDialog.startLoading(title: "Sharing...",subText: "Sharing to $sendTo",context: context);  

                              mysqlSharing.insertValuesParams(
                                sendTo: sendTo, 
                                fileName: fileName, 
                                comment: comment, 
                                fileData: fileVal, 
                                fileType: fileExt, 
                                context: context,
                                thumbnail: thumbnail
                              );

                            } else {
                              AlertForm.alertDialogTitle("Sharing failed", "Entered password is incorrect.", context);
                            }
                            
                            loadingDialog.stopLoading();

                            Navigator.pop(context);

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
}