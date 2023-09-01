import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CreateText extends StatefulWidget {
  const CreateText({super.key});

  @override
  State<CreateText> createState() => CreateTextPageState();
}

class CreateTextPageState extends State<CreateText> {
  
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final textEditingController = TextEditingController();
  final fileNameController = TextEditingController();

  final logger = Logger();
  final getAssets = GetAssets();
  
  bool saveVisibility = true;
  bool textFormEnabled = true;

  Future<void> _insertUserFile({
    required String table,
    required String filePath,
    required dynamic fileValue,
  }) async {
    
    List<Future<void>> isolatedFileFutures = [];

    isolatedFileFutures.add(InsertData().insertValueParams(
      tableName: table,
      filePath: filePath,
      userName: userData.username,
      fileVal: fileValue,
    ));

    await Future.wait(isolatedFileFutures);

  }

  Future<bool> _isFileExists(String fileName) async {
    return storageData
      .fileNamesList.contains(EncryptionClass().decrypt(fileName));
  }

  Future _askFileName() {
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
                      "Save Text File",
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
                    autofocus: true,
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: fileNameController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("filename.txt")
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
                        text: "Cancel", 
                        onPressed: () {
                          fileNameController.clear();
                          Navigator.pop(context);
                        }, 
                        isButtonClose: true
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MainDialogButton(
                        text: "Save", 
                        onPressed: () async {

                          final getFileTitle = fileNameController.text.trim();
                          if (getFileTitle.isEmpty) {
                            return;
                          }
                          
                          await _saveText(textEditingController.text);

                        }, 
                        isButtonClose: false
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

  String _tableToUploadTo() {

    late String tableToUploadTo = "";

    if(tempData.fileOrigin == "homeFiles") {
      tableToUploadTo = GlobalsTable.homeText;
    } else if (tempData.fileOrigin == "dirFiles") {
      tableToUploadTo = GlobalsTable.directoryUploadTable;
    } else if (tempData.fileOrigin == "foldFiles") {
      tableToUploadTo = GlobalsTable.folderUploadTable;
    } else if (tempData.fileOrigin == "psFiles") {
      tableToUploadTo = GlobalsTable.psText;
    }

    return tableToUploadTo;
  }

  void _addTextFileToListView({required String fileName}) async {

    final txtImageData = await getAssets.loadAssetsData('txt0.png');

    storageData.fileDateList.add("Just now");
    storageData.fileDateFilteredList.add("Just now");

    storageData.fileNamesList.add(fileName);
    storageData.fileNamesFilteredList.add(fileName);
    
    storageData.imageBytesList.add(txtImageData);
    storageData.imageBytesFilteredList.add(txtImageData);
    
  }

  Future<void> _saveText(String inputValue) async {

    try {

      if (await _isFileExists(EncryptionClass().encrypt("$inputValue.txt"))) {
        if (!mounted) return;
        CustomAlertDialog.alertDialog("File with this name already exists.", context);
        return;
      }

      final toUtf8Bytes = utf8.encode(inputValue);
      final base64Encoded = base64.encode(toUtf8Bytes);
      final getFileName = "${fileNameController.text.trim().replaceAll(".", "")}.txt";

      await _insertUserFile(
        table: _tableToUploadTo(),
        filePath: getFileName,
        fileValue: base64Encoded,
      );

      saveVisibility = false;
      textFormEnabled = false;
      _addTextFileToListView(fileName: getFileName);

      await CallNotify().customNotification(
        title: "Text File Saved",
        subMesssage: ShortenText().cutText("$getFileName Has been saved"),
      );

      if (!mounted) return;

      SnakeAlert.okSnake(
        message: "`${fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved.",
        icon: Icons.check,
        context: context,
      );

      Navigator.pop(context);

      fileNameController.clear();

    } catch (err, st) {

      logger.e("Exception from _saveText {create_text}", err, st);

      final String getFileName = "${fileNameController.text.trim().replaceAll(".", "")}.txt";

      OfflineMode().saveOfflineTextFile(
        inputValue: inputValue,
        fileName: getFileName,
        isFromCreateTxt: true,
      );

      if(tempData.fileOrigin == "offlineFiles") {
        _addTextFileToListView(fileName: getFileName);
      }

      setState(() {
        saveVisibility = false;
        textFormEnabled = false;
      });

      await CallNotify().customNotification(
        title: "Text File Saved",
        subMesssage: ShortenText().cutText("${fileNameController.text} Has been saved"),
      );

      if (!mounted) return;

      SnakeAlert.okSnake(
        message: "`${fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved as an offline file.",
        icon: Icons.check,
        context: context,
      );

      fileNameController.clear();
      Navigator.pop(context);
    }
  }


  Widget _buildTxt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        autofocus: true,
        controller: textEditingController,
        enabled: textFormEnabled,
        keyboardType: TextInputType.multiline,
          maxLines: null,
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 214, 213, 213),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        actions: [

          Visibility(
            visible: saveVisibility,
            child: TextButton(
              onPressed: () {
                _askFileName();
              },
              child: const Text("Save",
                style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("New Text File",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: _buildTxt(context),
    );
  }
}