import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class SimplifyDownload {

  String? fileNameValue;
  String? currentTableValue;
  Uint8List? fileDataValue;
  
  final loadingDialog = MultipleTextLoading();

  SimplifyDownload({
    required String? fileName, 
    required String currentTable,
    required Uint8List? fileData
  }) {
    fileNameValue = fileName;
    fileDataValue = fileData;
    currentTableValue = currentTable;
  } 

  Future<void> _videoGallerySaver(Uint8List videoData) async {

    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    String videoPath = '${directory!.path}/$fileNameValue';
    File videoFile = File(videoPath);
    await videoFile.writeAsBytes(videoData);

    await GallerySaver.saveVideo(videoPath);
    
    await videoFile.delete();

  }


  Future<void> downloadFile() async {

    try {

      const generalFilesTableName = {GlobalsTable.homeText,GlobalsTable.psText,GlobalsTable.homeVideo,GlobalsTable.psVideo};

      if(currentTableValue == GlobalsTable.homeImage || currentTableValue == GlobalsTable.psImage) {

        await ImageGallerySaver.saveImage(fileDataValue!);

      } else if (currentTableValue == GlobalsTable.homeText || currentTableValue == GlobalsTable.psText) {

        String textFileContent = utf8.decode(fileDataValue!);
        await SaveApi().saveFile(fileName: fileNameValue!,fileData: textFileContent);
        
      } else if (currentTableValue == GlobalsTable.homeVideo || currentTableValue == GlobalsTable.psVideo) { 

        await _videoGallerySaver(fileDataValue!);

      } else if (!(generalFilesTableName.contains(currentTableValue))) {

        await SaveApi().saveFile(fileName: fileNameValue!, fileData: fileDataValue!);

      }

      await CallNotify().downloadedNotification(fileName: fileNameValue!);

    } catch (err, st) {
      Logger().e("Exception from downloadFile {SimplifyDownload}", err, st);
      await CallNotify().customNotification(title: "Something went wrong",subMesssage: "Failed to download $fileNameValue");
    } 
   
  }

}