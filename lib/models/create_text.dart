import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CreateText extends StatefulWidget {
  const CreateText({super.key});

  @override
  State<CreateText> createState() => _CreateText();
}

class _CreateText extends State<CreateText> {

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  final logger = Logger();
  final getAssets = GetAssets();
  
  bool _saveVisibility = true;
  bool _textFormEnabled = true;

  Future<void> _insertUserFile({
    
    required String table,
    required String filePath,
    required dynamic fileValue,

  }) async {
    
    List<Future<void>> isolatedFileFutures = [];

    isolatedFileFutures.add(InsertData().insertValueParams(
      tableName: table,
      filePath: filePath,
      userName: Globals.custUsername,
      fileVal: fileValue,
    ));

    await Future.wait(isolatedFileFutures);

  }

  Future<bool> _isFileExists(String fileName) async {
    return Globals.fileValues.contains(EncryptionClass().Decrypt(fileName));
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
                    controller: _fileNameController,
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
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _fileNameController.clear();
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

                            String getFileTitle = _fileNameController.text.trim();

                            if (getFileTitle.isEmpty) {
                              return;
                            }
                            
                            await _saveText(_textEditingController.text);

                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
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

  String _tableToUploadTo() {

    late String tableToUploadTo = "";

    if(Globals.fileOrigin == "homeFiles") {
      tableToUploadTo = GlobalsTable.homeTextTable;
    } else if (Globals.fileOrigin == "dirFiles") {
      tableToUploadTo = "upload_info_directory";
    } else if (Globals.fileOrigin == "foldFiles") {
      tableToUploadTo = "folder_upload_info";
    } else if (Globals.fileOrigin == "psFiles") {
      tableToUploadTo = "ps_info_text";
    }

    return tableToUploadTo;
  }

  void _addTextFileToListView({required String fileName}) async {

    final txtImageFile = await getAssets.loadAssetsFile('txt0.png');
    final txtImageData = await getAssets.loadAssetsData('txt0.png');

    Globals.setDateValues.add("Just now");
    Globals.fileValues.add(fileName);
    Globals.filteredSearchedFiles.add(fileName);
    
    Globals.imageValues.add(txtImageFile);
    Globals.filteredSearchedImage.add(txtImageFile);
    Globals.imageByteValues.add(txtImageData);
    Globals.filteredSearchedBytes.add(txtImageData);
  }

  Future<void> _saveText(String inputValue) async {

    try {
    
      if(inputValue.isEmpty) {
        return;
      }

      if (await _isFileExists(EncryptionClass().Encrypt("$inputValue.txt"))) {
        AlertForm.alertDialog("File with this name already exists.", context);
        return;
      }

      final toUtf8Bytes = utf8.encode(inputValue);
      final String bodyBytes = base64.encode(toUtf8Bytes);

      final String getFileName = "${_fileNameController.text.trim().replaceAll(".", "")}.txt";

      await _insertUserFile(
        table: _tableToUploadTo(), 
        filePath: getFileName, 
        fileValue: bodyBytes
      );

      setState(() {
        _saveVisibility = false;
        _textFormEnabled = false;
        _addTextFileToListView(fileName: getFileName);
      });

      SnakeAlert.okSnake(message: "`${_fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved.", icon: Icons.check, context: context);
      await CallNotify().customNotification(title: "Text File Saved", subMesssage: ShortenText().cutText("$getFileName Has been saved"));

      _fileNameController.clear();

      Navigator.pop(context);

    } catch (err, st) {

      logger.e("Exception from _saveText {create_text}", err, st);

      _saveFileAsOffline(inputValue);
      SnakeAlert.okSnake(message: "`${_fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved as offline file.", icon: Icons.check, context: context);

      _fileNameController.clear();

      Navigator.pop(context);

      return;

    }

  }

  void _saveFileAsOffline(String inputValue) async {

    final String getFileName = "${_fileNameController.text.trim().replaceAll(".", "")}.txt";

    final toUtf8Bytes = utf8.encode(inputValue);

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirPath = Directory('${getDirApplication.path}/offline_files');

    if(!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
      final setupFiles = File('${offlineDirPath.path}/$getFileName');
      await setupFiles.writeAsBytes(toUtf8Bytes);
    } else {
      final setupFiles = File('${offlineDirPath.path}/$getFileName');
      await setupFiles.writeAsBytes(toUtf8Bytes);
    } 
  }

  Widget _buildTxt(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          autofocus: true,
          controller: _textEditingController,
          enabled: _textFormEnabled,
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
    _textEditingController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        actions: [

          Visibility(
            visible: _saveVisibility,
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