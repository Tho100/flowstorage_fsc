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

  File? selectedFilePath;  

  late String fileBase64Encoded = "";
  late String fileName = "";
  late List<int> videoThumbnail = [];

  final ValueNotifier<bool> previewerIsVisible = ValueNotifier<bool>(false);

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
    final extension = fileName.split('.').last;

    selectedFilePath = file;
    selectedFileController.text = fileName;
    fileBase64Encoded = '';

    final supportedExtensions = Globals.supportedFileTypes.contains(extension);

    if (supportedExtensions) {

      previewerIsVisible.value = false;
      videoThumbnail = [];

      if (Globals.videoType.contains(extension)) {

        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 40,
        );

        videoThumbnail = thumbnailBytes!;
        fileBase64Encoded = base64.encode(file.readAsBytesSync());

        previewerIsVisible.value = true;

        return;

      }

      if(Globals.imageType.contains(extension)) {

        File compressedImage = await FlutterNativeImage.compressImage(
          file.path,
          quality: 84,
        );

        setState(() {
          fileBase64Encoded = base64.encode(compressedImage.readAsBytesSync());
        });

        previewerIsVisible.value = true;

        return;

      }        

      previewerIsVisible.value = false;
      fileBase64Encoded = base64.encode(file.readAsBytesSync());

    } else {
      if(!mounted) return;
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

      final fileData = EncryptionClass().Encrypt(fileBase64Encoded);

      final getSharingAuth = await SharingOptions.retrievePassword(shareToUsername);

      if(getSharingAuth != "DEF") {
        SharingPassword().buildAskPasswordDialog(shareToUsername,encryptedFileName,shareToComment,fileData,fileExtension,getSharingAuth,context!,thumbnail: base64.encode(videoThumbnail));
        return;
      }

      final shareFileData = ShareFileData();
      final loadingDialog = MultipleTextLoading();

      loadingDialog.startLoading(title: "Sharing...", subText: "Sharing to $shareToUsername", context: context!);

      if(!mounted) return;

      await shareFileData.insertValuesParams(
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

        _buildTextField(
          controller: shareToController, 
          headerText: "Enter receiver username", 
          fromComment: false, 
          customHeight: 0.0,
          customWidth: 0.9,
          enabled: true
        ),

        const SizedBox(height: 10),

        MainButton(text: "Select File", onPressed: _openDialogFile, minusHeight: 800),

        const SizedBox(height: 20.0),

        _buildTextField(
          controller: commentController, 
          headerText: "Enter a comment", 
          fromComment: true,
          customHeight: 25.0, 
          customWidth: 0.9,
          enabled: true
        ),

        const SizedBox(height: 15),

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

        const SizedBox(height: 25),

        _buildPreviewer(fileBase64Encoded), 
      
      ],
    );       
  }

  Widget _buildPreviewer(String encodedValues) {
    return ValueListenableBuilder<bool>(
      valueListenable: previewerIsVisible,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Center(
            child: Column(
              children: [

                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Text(
                      GlobalsStyle.dotSeperator,
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      selectedFileController.text,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Divider(color: ThemeColor.thirdWhite),

                const SizedBox(height: 5),

                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: InteractiveViewer(
                    scaleEnabled: true,
                    panEnabled: true,
                    child: Builder(
                      builder: (context) {
                        if (videoThumbnail.isNotEmpty) {
                          return Image.memory(Uint8List.fromList(videoThumbnail));
                        } else {
                          return Image.memory(
                            base64Decode(encodedValues),
                            fit: BoxFit.fitWidth,
                          );
                        }
                      },
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required String headerText,
    required bool fromComment,
    required double customWidth,
    required double customHeight,
    required bool enabled
  }) {

    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: mediaQueryWidth * customWidth,
        child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
          enabled: enabled,
          maxLines: customHeight != 0 ? 5 : 1,
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