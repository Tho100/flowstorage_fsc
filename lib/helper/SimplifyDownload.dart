import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/SaveApi.dart';
import 'package:flowstorage_fsc/helper/CallNotify.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/MultipleText.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

      if(currentTableValue == "file_info") {

        await ImageGallerySaver.saveImage(fileDataValue!);

      } else if (currentTableValue == "file_info_expand") {

        String textFileContent = utf8.decode(fileDataValue!);
        await SaveApi().saveFile(fileName: fileNameValue!,fileData: textFileContent);
        
      } else if (currentTableValue == "file_info_vid") { 

        await _videoGallerySaver(fileDataValue!);

      } else if (currentTableValue != "file_info_expand" || currentTableValue != "file_info_vid" || currentTableValue != "file_info_video") {

        await SaveApi().saveFile(fileName: fileNameValue!, fileData: fileDataValue!);

      }

      await CallNotify().downloadedNotification(fileName: fileNameValue!);

    } catch (err) {
      print("Exception from downloadFile {SimplifyDownload}: $err");
      await CallNotify().customNotification(title: "Something went wrong",subMesssage: "Failed to download $fileNameValue");
    } 
   
  }

}