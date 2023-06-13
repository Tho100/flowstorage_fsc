import 'dart:convert';
import 'dart:io';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
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

}