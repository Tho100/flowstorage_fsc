import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/directory/directory_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/SingleText.dart';

class SaveDirectory {
  
  Future<void> selectDirectoryUserDirectory({
    required String directoryName,
    required BuildContext context
  }) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      await downloadDirectoryFiles(directoryName: directoryName, directoryPath: directoryPath,context: context);
    } else {
      return;
    }
  }

  Future<void> downloadDirectoryFiles({
    required String directoryName,
    required String directoryPath,
    required BuildContext context
  }) async {

    try {

      final loadingDialog = SingleTextLoading();      
      loadingDialog.startLoading(title: "Saving...", context: context);

      final directoryDataReceiver = DirectoryDataReceiver();
      final dataList = await directoryDataReceiver.retrieveParams(Globals.custUsername,directoryName);

      final nameList = dataList.map((data) => data['name'] as String).toList();
      final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
      
      for(int i=0; i<nameList.length; i++) {
        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: nameList[i], fileData: byteList[i]);
      }

      loadingDialog.stopLoading();
      SnakeAlert.okSnake(message: "${nameList.length} item(s) has been saved.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save the directory.", context);
    }

  }
}