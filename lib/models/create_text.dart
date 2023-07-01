import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CreateText extends StatefulWidget {
  const CreateText({super.key});

  @override
  State<CreateText> createState() => _CreateText();
}

class _CreateText extends State<CreateText> {

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  
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
                            
                            if (await _isFileExists(EncryptionClass().Encrypt("$getFileTitle.txt"))) {
                              AlertForm.alertDialog("File with this name already exists.", context);
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

  Future<File> getImageFileFromAssets(String path) async {   
    final byteData = await rootBundle.load('assets/$path');   
    final file = await File('${(await getTemporaryDirectory()).path}/$path')       
    .create(recursive: true);   
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));   
    return file; 
  }

  Future<void> _saveText(String inputValue) async {

    try {
      
      if(inputValue.isEmpty) {
        return;
      }

      final toUtf8Bytes = utf8.encode(inputValue);
      final String bodyBytes = base64.encode(toUtf8Bytes);

      final String getFileName = "${_fileNameController.text.trim().replaceAll(".", "")}.txt";
      final String setTableUpload = 
      Globals.fileOrigin == "homeFiles" 
      ? GlobalsTable.homeTextTable 
      : Globals.fileOrigin == "dirFiles" 
      ? "upload_info_directory" 
      : GlobalsTable.folderUploadTable;

      await _insertUserFile(table: setTableUpload,filePath: getFileName,fileValue: bodyBytes);

      setState(() {
        _saveVisibility = false;
        _textFormEnabled = false;
      });

      SnakeAlert.okSnake(message: "`${_fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved.", icon: Icons.check, context: context);

      _fileNameController.clear();

      Navigator.pop(context);


    } catch (err) {
      
      // User save the file without connect, an exception will arise.
      // Save file as offline file instead
      
      SnakeAlert.okSnake(message: "`${_fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved as offline file.", icon: Icons.check, context: context);
      _saveFileAsOffline(inputValue);

      _fileNameController.clear();
      Navigator.pop(context);

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