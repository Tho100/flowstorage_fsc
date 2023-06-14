import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class SaveApi {
  
  Future<String> saveFile({
    required String fileName, 
    required dynamic fileData,
  }) async {

    late String filePath;
    
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {

      final getFilePath = '$result/$fileName';
      final file = File(getFilePath);
      filePath = file.path;

      if (fileData is Uint8List) {
        await file.writeAsBytes(fileData);
      } else if (fileData is String) {
        await file.writeAsString(fileData);
      } else {
        print('Exception from saveMultipleFiles {save_api}: unsupported file format');
      }
    }

    return filePath;
  }

  Future<void> saveMultipleFiles({
    required String directoryPath,
    required String fileName,
    required dynamic fileData,
  }) async {

    final path = '$directoryPath/$fileName';
    final file = File(path);
   
    if (fileData is Uint8List) {
      await file.writeAsBytes(fileData);
    } else if (fileData is String) {
      await file.writeAsString(fileData);
    } else {
      print('Exception from saveMultipleFiles {save_api}: unsupported file format');
    }

  }

}