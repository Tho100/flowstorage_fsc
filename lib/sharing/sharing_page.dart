import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/sharing/ask_sharing_password_dialog.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/sharing/verify_sharing.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({super.key});

  @override
  State<SharingPage> createState() => _SharingPage();
}

class _SharingPage extends State<SharingPage> {

  File? fileToShare;  

  late String bodyBytes = "";
  late String fileName = "";
  late List<int> videoThumbnail = [];

  final selectedFileController = TextEditingController(text: 'Please select a file');
  final shareToController = TextEditingController();
  final commentController = TextEditingController(text: '');

  Future<void> _openDialogFile() async {
    
    final result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }

    final file = File(result.files.single.path!);
    final fileName = path.basename(file.path);
    final extension = path.extension(fileName).toLowerCase();

    fileToShare = file;
    selectedFileController.text = fileName;
    bodyBytes = '';

    final supportedExtensions = Globals.supportedFileTypes.map((fileType) => '.$fileType').toList();

    if (supportedExtensions.contains(extension)) {

      if (extension == '.mp4' || extension == '.mov' || extension == '.wmv') {

        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 40,
        );

        videoThumbnail = thumbnailBytes!;
      }

      if(extension == '.png' || extension == '.jpeg'  || extension == '.jpg' || extension == '.webp') {

        File compressedImage = await FlutterNativeImage.compressImage(
          file.path,
          quality: 84,
        );

        setState(() {
          bodyBytes = base64.encode(compressedImage.readAsBytesSync());
        });


        return;
      }

      bodyBytes = base64.encode(file.readAsBytesSync());

    } else {
      CustomAlertDialog.alertDialog("File type is unsupported.", context);
    }
  }

  Future<void> _startSharing(BuildContext? context) async {

    final shareToComment = commentController.text.isEmpty ? '' : EncryptionClass().Encrypt(commentController.text);
    final shareToUsername = shareToController.text;
    final fileName = selectedFileController.text;
    final fileExtension = fileName.substring(fileName.length - 4);

    try {

      final encryptedFileName = EncryptionClass().Encrypt(fileName);

      if (await VerifySharing().isAlreadyUploaded(encryptedFileName, shareToUsername, Globals.custUsername)) {
        CustomAlertDialog.alertDialogTitle("Sharing Failed", "You've already shared this file.", context!);
        return;
      }

      if (await VerifySharing().unknownUser(shareToUsername)) {
        CustomAlertDialog.alertDialogTitle("Sharing Failed", "User `$shareToUsername` not found.", context!);
        return;
      }

      final getReceiverDisabled = await SharingOptions.retrieveDisabled(shareToUsername);

      if(getReceiverDisabled == '1') {
        CustomAlertDialog.alertDialogTitle('Sharing Failed', 'User $shareToUsername disabled their file sharing.', context!);
        return;
      }

      final fileData = EncryptionClass().Encrypt(bodyBytes);

      final getSharingAuth = await SharingOptions.retrievePassword(shareToUsername);

      if(getSharingAuth != "DEF") {
        SharingPassword().buildAskPasswordDialog(shareToUsername,encryptedFileName,shareToComment,fileData,fileExtension,getSharingAuth,context!,thumbnail: base64.encode(videoThumbnail));
        return;
      }

      final mySqlSharing = MySqlSharing();
      final loadingDialog = MultipleTextLoading();

      loadingDialog.startLoading(title: "Sharing...", subText: "Sharing to $shareToUsername", context: context!);

      await mySqlSharing.insertValuesParams(
        sendTo: shareToUsername, 
        fileName: encryptedFileName, 
        comment: shareToComment,
        fileData: fileData,
        fileType: fileExtension,
        thumbnail: base64.encode(videoThumbnail),
        context: context
      );

      loadingDialog.stopLoading();

    } catch (failedShare) {
      CustomAlertDialog.alertDialog("Failed to share this file.", context!);
    }
  }

  Widget _buildBody() {
    return Column(
        children: [

          const Padding(
            padding: EdgeInsets.only(left: 28),
            child: HeaderText(title: "File Sharing", subTitle: "Share a file to anyone"),
          ),
          
          const SizedBox(height: 35),

          _buildTextField(shareToController, "Enter receiver username", false,0.0,true),

          const SizedBox(height: 18),

          _buildTextField(selectedFileController, selectedFileController.text, false,0.0,false),

          const SizedBox(height: 10.0),

          SizedBox(
            height: 55,
            width: MediaQuery.of(context).size.width-45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ThemeColor.darkBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
              ),
              onPressed: () async {
                await _openDialogFile();
              },
              child: const Text(
                "Select file",
                style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
     

          const SizedBox(height: 25),

          _buildTextField(commentController, "Enter a comment", false,55.0,true),

          const SizedBox(height: 25),

          MainButton(
            text: "Share", 
            onPressed: () async {
              if(shareToController.text.isNotEmpty) {
                if(selectedFileController.text.isNotEmpty) {
                  await _startSharing(context);
                }
              }
            },
          ),

        const SizedBox(height: 15),

        _buildPreviewer(bodyBytes), 
      
      ],
    );       
  }

  Widget _buildPreviewer(String encodedValues) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Preview',
              style: TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 165,
              width: 185,
              child: Visibility(
                visible: encodedValues.isNotEmpty,
                replacement: Container(),
                child: Builder(
                  builder: (context) {

                    try {

                      if(videoThumbnail.isNotEmpty) {
                        return Image.memory(Uint8List.fromList(videoThumbnail));
                      } else {
                        return Image.memory(base64Decode(encodedValues));
                      }

                    } catch (err) {
                      return Container();
                    }

                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController? controller,String headerText,bool fromComment,double commentHeight,bool enabled) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
          enabled: enabled,
          maxLines: commentHeight != 0 ? 5 : 1,
          controller: controller,
          decoration: GlobalsStyle.setupTextFieldDecoration(headerText),
        ),
      ),
    );
  }

  @override
  void dispose() {
    selectedFileController.dispose();
    shareToController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }
}