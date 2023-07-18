import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class OfflineMode {
  late Directory offlineDirs;

  OfflineMode() {
    initializeOfflineDirs();
  }

  Future<void> initializeOfflineDirs() async {
    final getDirApplication = await getApplicationDocumentsDirectory();
    offlineDirs = Directory('${getDirApplication.path}/offline_files');
  }

  Future<void> init() async {
    await initializeOfflineDirs();
  }

  Future<void> deleteFile(String fileName) async {
    await init();
    final file = File('${offlineDirs.path}/$fileName');
    file.deleteSync();
  }

  Future<void> renameFile(String fileName, String newFileName) async {
    await init();
    final file = File('${offlineDirs.path}/$fileName');
    String newPath = '${offlineDirs.path}/$newFileName';
    await file.rename(newPath);
  }


  Future<void> downloadFile(String fileName) async {

    await init();

    final file = File('${offlineDirs.path}/$fileName');
    final fileDataValue = file.readAsBytesSync();
    
    final fileType = fileName.split('.').last;
    if(Globals.imageType.contains(fileType)) {
      await ImageGallerySaver.saveImage(fileDataValue);
    } else if (Globals.textType.contains(fileType)) {
      final textData = utf8.decode(fileDataValue);
      SaveApi().saveFile(fileName: fileName, fileData: textData);
    }
  }

  Future<void> saveOfflineFile({
    required String fileName, 
    required Uint8List fileData
  }) async {

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirPath = Directory('${getDirApplication.path}/offline_files');

    if(!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
      final setupFiles = File('${offlineDirPath.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);
    } else {
      final setupFiles = File('${offlineDirPath.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);
    }
     
  }

  void saveOfflineTextFile({
    required String inputValue, 
    required String fileName, 
    required bool isFromCreateTxt
  }) async {

    final String getFileName = fileName;
    final toUtf8Bytes = utf8.encode(inputValue);

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirPath = Directory('${getDirApplication.path}/offline_files');

    if (!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
    }

    final setupFiles = File('${offlineDirPath.path}/$getFileName');
    await setupFiles.writeAsBytes(toUtf8Bytes);
  }

  Future<void> processSaveOfflineFile({
    required String fileName, 
    required Uint8List fileData,
    required BuildContext context
  }) async {

    try {
      
      final fileType = fileName.split('.').last;

      if(fileType == "pdf" || fileType == "docx" || fileType == "xlsx" || fileType == "xls" || fileType == "pptx" || fileType == "ptx") {
        CustomAlertDialog.alertDialogTitle("Couldn't make this file offline.", "File type is not yet supported for offline.", context);
        return;
      }

      await saveOfflineFile(fileName: fileName,fileData: fileData);
      
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Now available offline.",icon: Icons.check,context: context);
      
    } catch (err) {
      SnakeAlert.errorSnake("An error occurred.",context);
    }
  }

}