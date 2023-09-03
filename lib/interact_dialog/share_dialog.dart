import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/data_classes/thumbnail_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing/ask_sharing_password_dialog.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/sharing/verify_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SharingDialog {

  final shareToController = TextEditingController();
  final commentController = TextEditingController();

  final retrieveData = RetrieveData();
  final shareFileData = ShareFileData();
  
  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<void> _sendFileToShare({
    required String shareToName, 
    required String encryptedFileName, 
    required String shareToComment, 
    required String fileExtension, 
    required dynamic fileData,
    dynamic thumbnail,
    BuildContext? context,
  }) async {

      await shareFileData.insertValuesParams(
      sendTo: shareToName, 
      fileName: encryptedFileName, 
      comment: shareToComment,
      fileData: fileData,
      fileType: fileExtension,
      thumbnail: thumbnail,
      context: context!
    );
  }

  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(userData.username, selectedFilename, tableName,tempData.fileOrigin);
  }

  Future<void> _prepareFileToShare({
    required String username,
    required String fileName,
    required String? commentInput,
    required BuildContext context
  }) async {

    final fileExtension = fileName.split('.').last;
    final tableName = tempData.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileExtension]! : Globals.fileTypesToTableNames[fileExtension]!;

    String? thumbnailBase64;

    final shareToComment = commentInput!.isEmpty ? '' : EncryptionClass().encrypt(commentInput);
    final encryptedFileName = EncryptionClass().encrypt(fileName);

    if (await VerifySharing().isAlreadyUploaded(encryptedFileName, username, userData.username)) {
      if(context.mounted) {
        CustomAlertDialog.alertDialogTitle("Sharing Failed", "You've already shared this file.", context);
      }
      return;
    }

    if (await VerifySharing().unknownUser(username)) {
      if(context.mounted) {
        CustomAlertDialog.alertDialogTitle("Sharing Failed", "User `$username` not found.", context);
      }
      return;
    }

    final getReceiverDisabled = await SharingOptions.retrieveDisabled(username);

    if(getReceiverDisabled == '1') {
      if(context.mounted) {
        CustomAlertDialog.alertDialogTitle('Sharing Failed', 'User $username disabled their file sharing.', context);
      }
      return;
    }

    final getSharingAuth = await SharingOptions.retrievePassword(username);

    if(Globals.videoType.contains(fileExtension)) {
      
      thumbnailBase64 = await Future.value(ThumbnailGetter().retrieveParamsSingle(fileName: fileName));
      
    }

    if(getSharingAuth != "DEF") {

      final fileData = EncryptionClass().encrypt(base64.encode(await _callData(fileName, tableName)));  

      if(context.mounted) {

        SharingPassword().buildAskPasswordDialog(
          username, 
          encryptedFileName,
          shareToComment,
          fileData,
          '.$fileExtension',
          getSharingAuth,
          context,
          thumbnail: thumbnailBase64
        );

      }

      return;

    }

    await CallNotify().customNotification(
      title: "Sharing...", subMesssage: "Sharing to $username");
    
    final singleTextLoading = SingleTextLoading();

    if(context.mounted) {
      singleTextLoading.startLoading(
        title: "Sharing...", context: context);
    }

    final fileData = base64.encode(await _callData(fileName, tableName));
    final encryptedFileData = EncryptionClass().encrypt(fileData);  

    if(context.mounted) {
      
      await _sendFileToShare(
        shareToName: username,
        encryptedFileName: encryptedFileName, 
        shareToComment: shareToComment, 
        fileExtension: '.$fileExtension', 
        fileData: encryptedFileData,
        thumbnail: thumbnailBase64 ?? '',
        context: context
      );

    }

    singleTextLoading.stopLoading();

    await NotificationApi.stopNotification(0);

  }

  void _onSharePressed({
    required String receiverUsername,
    required String fileName,
    required String commentInput,
    required BuildContext context
  }) async {

    if (receiverUsername.isEmpty) {
      CustomAlertDialog.alertDialog("Please enter the receiver username.", context);
      return;
    }
    
    if (receiverUsername == userData.username) {
      CustomAlertDialog.alertDialog("You cannot share to yourself.", context);
      return;
    }

    await _prepareFileToShare(
      username: receiverUsername,
      fileName: fileName,
      commentInput: commentInput,
      context: context
    );
  }

  Future buildSharingDialog({
    String? fileName,
    BuildContext? context
  }) {
    return showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Row(
                children: [

                  Stack(
                    children: [
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                          ),
                        ),
                      ),

                      if(Globals.videoType.contains(fileName!.split('.').last))
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0, left: 24.0),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ThemeColor.mediumGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          ShortenText().cutText(fileName, customLength: 42),
                          style: const TextStyle(
                            color: ThemeColor.justWhite,
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),

              const Divider(color: ThemeColor.lightGrey),
              const SizedBox(height: 8),

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
                    borderRadius: BorderRadius.circular(14),
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
                      borderRadius: BorderRadius.circular(14),
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

              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MainDialogButton(
                        text: "Close",
                        onPressed: () {
                          shareToController.clear();
                          commentController.clear();
                          Navigator.pop(context);
                        },
                        isButtonClose: true,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MainDialogButton(
                        text: "Share",
                        onPressed: () {

                          final shareToInput = shareToController.text;
                          final comment = commentController.text;

                          _onSharePressed(
                            receiverUsername: shareToInput,
                            fileName: fileName,
                            commentInput: comment,
                            context: context
                          );
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