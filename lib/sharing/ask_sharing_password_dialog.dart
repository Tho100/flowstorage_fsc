import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';

class SharingPassword {

  final sharingPasswordController = TextEditingController();
  final shareFileData = ShareFileData();

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
                    borderRadius: BorderRadius.circular(14),
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
                      child: MainDialogButton(
                        text: "Close",
                        onPressed: () {
                          sharingPasswordController.clear();
                          Navigator.pop(context);
                        },
                        isButtonClose: true,
                      )
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MainDialogButton(
                        text: "Share", 
                        onPressed: () {

                          final loadingDialog = MultipleTextLoading();
                          final compare = AuthModel().computeAuth(sharingPasswordController.text);
              
                          if(compare == authString) {
                            
                            loadingDialog.startLoading(title: "Sharing...",subText: "Sharing to $sendTo",context: context);  

                            shareFileData.insertValuesParams(
                              sendTo: sendTo, 
                              fileName: fileName, 
                              comment: comment, 
                              fileData: fileVal, 
                              fileType: fileExt, 
                              context: context,
                              thumbnail: thumbnail
                            );

                          } else {
                            CustomAlertDialog.alertDialogTitle("Sharing failed", "Entered password is incorrect.", context);
                          }
                          
                          loadingDialog.stopLoading();

                          Navigator.pop(context);
                        }, 
                        isButtonClose: false
                      )
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