import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:get_it/get_it.dart';

class SaveFolder {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  
  final _locator = GetIt.instance;

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String folderTitle) async {

    final connection = await SqlConnection.insertValueParams();

    const query = 'SELECT CUST_FILE_PATH, CUST_FILE FROM folder_upload_info WHERE FOLDER_TITLE = :foldtitle AND CUST_USERNAME = :username';
    final params = {'username': username,'foldtitle': encryption.encrypt(folderTitle)};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>{};

      Uint8List fileBytes = Uint8List(0);
      
      for (final row in result.rows) {
        
        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final fileNames = encryption.decrypt(encryptedFileNames);

        final encryptedbyteFile = row.assoc()['CUST_FILE']!;
        fileBytes = base64.decode(encryption.decrypt(encryptedbyteFile));

        final buffer = ByteData.view(fileBytes.buffer);
        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': fileNames,
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet.toList();

    } catch (failedRetrieval) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> selectDirectoryUserFolder({
    required String folderName,
    required BuildContext context
  }) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      await downloadDirectoryFiles(folderName: folderName, directoryPath: directoryPath,context: context);
    } else {
      return;
    }
  }

  Future<void> downloadDirectoryFiles({
    required String folderName,
    required String directoryPath,
    required BuildContext context
  }) async {

    try {

      final userData = _locator<UserDataProvider>();

      final loadingDialog = SingleTextLoading();      
      loadingDialog.startLoading(title: "Saving...", context: context);

      final dataList = await retrieveParams(userData.username,folderName);

      final nameList = dataList.map((data) => data['name'] as String).toList();
      final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

      for(int i=0; i<nameList.length; i++) {
        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: nameList[i], fileData: byteList[i]);
      }

      loadingDialog.stopLoading();
      SnakeAlert.okSnake(message: "${nameList.length} item(s) has been saved.",icon: Icons.check,context: context);
      
      await CallNotify().customNotification(title: "Folder Saved", subMesssage: "${nameList.length} File(s) has been downloaded");

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save the directory.", context);
    }

  }
}