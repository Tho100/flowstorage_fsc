import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing/ask_sharing_password_dialog.dart';
import 'package:flowstorage_fsc/sharing/sharing_options.dart';
import 'package:flowstorage_fsc/sharing/verify_sharing.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/sharing/share_file.dart';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({super.key});

  @override
  State<SharingPage> createState() => SharingPageState();
}

class SharingPageState extends State<SharingPage> {

  File? selectedFilePath;  

  String fileExtensionToType = "";

  late String fileBase64Encoded = "";
  late String selectedFileName = "";
  late List<int> videoThumbnail = [];

  final  previewerIsVisibleNotifier = ValueNotifier<bool>(false);

  final shareToController = TextEditingController();
  final commentController = TextEditingController(text: '');

  final Map<String,String> mapFileType = {
    "mp3": "Audio File",
    "wav": "Audio File",
    "xls": "Document File",
    "xlsx": "Document File",
    "doc": "Document File",
    "docx": "Document File",
    "pdf": "Document File",
    "txt": "Text File",
    "csv": "Text File",
    "sql": "Text File",
    "md": "Text File",
    "exe": "Executable File",
    "ptx": "Presentation File",
    "pptx": "Presentation File"
  };    

  final _locator = GetIt.instance;

  Future<void> _openDialogFile() async {

    final result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }

    final file = File(result.files.single.path!);
    final fileName = path.basename(file.path);
    final extension = fileName.split('.').last;

    selectedFileName = fileName;
    selectedFilePath = file;
    fileBase64Encoded = '';

    final supportedExtensions = Globals.supportedFileTypes.contains(extension);

    if (supportedExtensions) {

      fileExtensionToType = "";
      previewerIsVisibleNotifier.value = false;
      videoThumbnail = [];

      if (Globals.videoType.contains(extension)) {

        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 40,
        );

        videoThumbnail = thumbnailBytes!;
        fileBase64Encoded = base64.encode(file.readAsBytesSync());
        previewerIsVisibleNotifier.value = true;

      } else if (Globals.imageType.contains(extension)) {

        final compressedImage = await FlutterNativeImage.compressImage(
          file.path,
          quality: 84,
        );

        setState(() {
          fileBase64Encoded = base64.encode(compressedImage.readAsBytesSync());
        });

        previewerIsVisibleNotifier.value = true;

      } else {

        fileExtensionToType = mapFileType[extension]!;
        previewerIsVisibleNotifier.value = true;
        fileBase64Encoded = base64.encode(file.readAsBytesSync());
        
      }
    } else {
      if (!mounted) return;
      CustomFormDialog.startDialog(fileName, "File type is not supported.", context);
    }

  }

  Future<void> _startSharing(BuildContext? context) async {

    final shareToComment = commentController.text.isEmpty ? '' : EncryptionClass().encrypt(commentController.text);
    final shareToUsername = shareToController.text;
    final fileName = selectedFileName;
    final fileExtension = fileName.substring(fileName.length - 4);

    final userData = _locator<UserDataProvider>();

    try {

      final encryptedFileName = EncryptionClass().encrypt(fileName);

      if (await VerifySharing().isAlreadyUploaded(encryptedFileName, shareToUsername, userData.username)) {
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

      final fileData = EncryptionClass().encrypt(fileBase64Encoded);

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

        const SizedBox(height: 15),

        _buildTextField(
          controller: commentController, 
          headerText: "Enter a comment", 
          fromComment: true,
          customHeight: 25.0, 
          customWidth: 0.9,
          enabled: true
        ),

        const SizedBox(height: 15.0),

        MainButton(text: "Select File", onPressed: _openDialogFile),

        const SizedBox(height: 35),

        _buildPreviewer(fileBase64Encoded), 
      
      ],
    );       
  }

  Widget _buildPreviewer(String encodedValues) {
    return ValueListenableBuilder<bool>(
      valueListenable: previewerIsVisibleNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Center(
            child: Column(
              children: [

                Row(
                  children: [

                    const SizedBox(width: 28),

                    Text(
                      fileExtensionToType != "" ? fileExtensionToType : "Preview",
                      style: const TextStyle(
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
                      ShortenText().cutText(selectedFileName, customLength: 48),
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Divider(color: ThemeColor.lightGrey),

                const SizedBox(height: 12),

                if (fileExtensionToType == "") 
                _buildPreviewThumbnailFile(encodedValues)
                
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPreviewThumbnailFile(String encodedValues) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 265,
        width: 240,
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
    shareToController.dispose();
    commentController.dispose();
    previewerIsVisibleNotifier.dispose();
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
        actions: [
          TextButton(
            onPressed: () async {

              final userData = _locator<UserDataProvider>();

              if(shareToController.text.isEmpty) {
                CustomAlertDialog.alertDialogTitle("Sharing Failed", "Please enter receiver username.", context);
                return;
              }

              if(selectedFileName.isEmpty) {
                CustomAlertDialog.alertDialogTitle("Sharing Failed", "Please select a file.", context);
                return;
              }

              if(shareToController.text == userData.username) {
                CustomAlertDialog.alertDialogTitle("Sharing Failed", "You can't share to yourself.", context);
                return;
              }

              await _startSharing(context);

            },
            child: const Text("Share",
              style: TextStyle(
                color: ThemeColor.darkPurple,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}