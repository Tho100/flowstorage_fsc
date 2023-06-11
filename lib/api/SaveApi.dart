import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SaveApi {
  
  Future<String> saveFile({
    required String fileName, 
    required dynamic fileData,
  }) async {

    late String filePath;

    String fileType = fileName.split('.').last;
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {

      final path = '$result/$fileName';
      filePath = path;
      final file = File(path);
      fileType != 'txt' ? await file.writeAsBytes(fileData) : await file.writeAsString(fileData);

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
    String fileType = fileName.split('.').last;
    fileType != 'txt'
        ? await file.writeAsBytes(fileData)
        : await file.writeAsString(fileData);
  }

}