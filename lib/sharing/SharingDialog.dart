import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/data_classes/ThumbnailGetter.dart';
import 'package:flowstorage_fsc/encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/extra_query/RetrieveData.dart';
import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flowstorage_fsc/global/GlobalsStyle.dart';
import 'package:flowstorage_fsc/sharing/MySqlSharing.dart';
import 'package:flowstorage_fsc/sharing/Verification.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';
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

                            final loadingDialog = MultipleTextLoading();

                            loadingDialog.startLoading(title: "Sharing...",subText: "Sharing to\t\t$shareToName\nFile name\t\t$fileName",context: context);

                            if(Globals.videoType.contains(fileExtension)) {
                              
                              thumbnail = await Future.value(ThumbnailGetter().retrieveParamsSingle(fileName: fileName));
                            }

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