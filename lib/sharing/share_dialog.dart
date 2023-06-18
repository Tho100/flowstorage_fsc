import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/data_classes/thumbnail_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/sharing/ask_sharing_password_dialog.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/sharing/verify_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/MultipleText.dart';
import 'package:flutter/material.dart';

class SharingDialog {

  final retrieveData = RetrieveData();

  Future<void> _shareFileToOther({
    required String shareToName, 
    required String encryptedFileName, 
    required String shareToComment, 
    required String fileExtension, 
    required dynamic fileData,
    dynamic thumbnail,
    BuildContext? context,
    }) async {

      final mySqlSharing = MySqlSharing();

      await mySqlSharing.insertValuesParams(
      shareToName, 
      encryptedFileName, 
      shareToComment,
      fileData,
      fileExtension,
      thumbnail: thumbnail,
      context!
    );
  }

  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(Globals.custUsername, selectedFilename, tableName,Globals.fileOrigin);
  }
  
  Future buildSharingDialog({
    String? fileName,
    TextEditingController? shareToController, 
    TextEditingController? commentController,
    BuildContext? context
    }) {
    return showDialog(
      context: context!,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      fileName!.length > 42 ? "${fileName.substring(0,42)}..." : fileName,
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Text(
                      "Share this file",
                      style: TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 16,
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
                    style: const TextStyle(color: ThemeColor.secondaryWhite),
                    enabled: true,
                    controller: shareToController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter receiver username"),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                    ),
                    child: TextFormField(
                      style: const TextStyle(color: ThemeColor.secondaryWhite),
                      enabled: true,
                      controller: commentController,
                      maxLines: 5,
                      decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment"),
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
                            shareToController!.clear();
                            commentController!.clear();
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
                          onPressed: () async {

                            final shareToName = shareToController!.text;

                            if (shareToName.isEmpty) {
                              AlertForm.alertDialog("Please enter the receiver username.", context);
                              return;
                            }
                            
                            if (shareToName == Globals.custUsername) {
                              AlertForm.alertDialog("You cannot share to yourself.", context);
                              return;
                            }

                            String fileExtension = fileName.split('.').last;
                            String tableName = Globals.fileTypesToTableNames[fileExtension]!;
                            String? thumbnail;

                            final shareToComment = commentController!.text.isEmpty ? '' : EncryptionClass().Encrypt(commentController.text);
                            final encryptedFileName = EncryptionClass().Encrypt(fileName);

                            if (await VerifySharing().isAlreadyUploaded(encryptedFileName, shareToName, Globals.custUsername)) {
                              AlertForm.alertDialogTitle("Sharing Failed", "You've already shared this file.", context);
                              return;
                            }

                            if (await VerifySharing().unknownUser(shareToName)) {
                              AlertForm.alertDialogTitle("Sharing Failed", "User `$shareToName` not found.", context);
                              return;
                            }

                            final getReceiverDisabled = await SharingOptions.retrieveDisabled(shareToName);

                            if(getReceiverDisabled == '1') {
                              AlertForm.alertDialogTitle('Sharing Failed', 'User $shareToName disabled their file sharing.', context);
                              return;
                            }

                            final getSharingAuth = await SharingOptions.retrievePassword(shareToName);

                            final loadingDialog = MultipleTextLoading();

                            if(Globals.videoType.contains(fileExtension)) {
                              
                              thumbnail = await Future.value(ThumbnailGetter().retrieveParamsSingle(fileName: fileName));
                            }

                            if(getSharingAuth != "DEF") {

                              final fileData = EncryptionClass().Encrypt(base64.encode(await _callData(fileName, tableName)));  
                              SharingPassword().buildAskPasswordDialog(shareToName,encryptedFileName,shareToComment,fileData,'.$fileExtension',getSharingAuth,context,thumbnail: thumbnail);
                              return;

                            }

                            loadingDialog.startLoading(title: "Sharing...",subText: "Sharing to $shareToName",context: context);

                            final fileData = EncryptionClass().Encrypt(base64.encode(await _callData(fileName, tableName)));  

                            await _shareFileToOther(
                              shareToName: shareToName,
                              encryptedFileName: encryptedFileName, 
                              shareToComment: shareToComment, 
                              fileExtension: '.$fileExtension', 
                              fileData: fileData,
                              thumbnail: thumbnail != null ? thumbnail : '',
                              context: context
                            );

                            loadingDialog.stopLoading();

                          },
                          style: GlobalsStyle.btnMainStyle,
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