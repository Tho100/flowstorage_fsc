import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
/// <summary>
/// 
/// Class to retrieve user  encrypted shared files names
/// and decrypt them later for user to see
/// 
/// </summary>

class FolderDataReceiver {

  final _encryptionClass = EncryptionClass();
  final now = DateTime.now();

  Future<Uint8List> loadAssetImage(String assetName) async {
    final ByteData data = await rootBundle.load(assetName);
    return data.buffer.asUint8List();
  }

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String folderTitle) async {

    final connection = await SqlConnection.insertValueParams();

    const query = 'SELECT CUST_FILE_PATH, UPLOAD_DATE, CUST_THUMB, CUST_FILE FROM folder_upload_info WHERE FOLDER_TITLE = :foldtitle AND CUST_USERNAME = :username';
    final params = {'username': username,'foldtitle': EncryptionClass().Encrypt(folderTitle)};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>{};

      Uint8List fileBytes = Uint8List(0);
      
      for (final row in result.rows) {
        
        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final fileNames = _encryptionClass.Decrypt(encryptedFileNames);

        final fileType = fileNames.split('.').last.toLowerCase();

        if (fileType == "jpg" || fileType == "png" || fileType == "jpeg") {
          final encryptedByteFile = row.assoc()['CUST_FILE']!;
          fileBytes = base64.decode(_encryptionClass.Decrypt(encryptedByteFile));
        } else if (fileType == "txt") {
          fileBytes = await loadAssetImage('assets/nice/txt0.png');
        } else if (fileType == "pdf") {
          fileBytes = await loadAssetImage('assets/nice/pdf0.png');
        } else if (fileType == "mp4" || fileType == "wmv" || fileType == "avi" || fileType == "mov" || fileType == "mkv") {
          final thumbnailbase64String = row.assoc()['CUST_THUMB']!;
          fileBytes = base64.decode(thumbnailbase64String);
        } else if (fileType == "exl") {
          fileBytes = await loadAssetImage('assets/nice/exl0.png');
        } 

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final dateValueWithDashes = dateValue.replaceAll('/', '-');
        final dateComponents = dateValueWithDashes.split('-');

        final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
        final now = DateTime.now();
        final difference = now.difference(date).inDays;

        final formattedDate = DateFormat('MM/dd/yyyy').format(date);

        final buffer = ByteData.view(fileBytes.buffer);
        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': fileNames,
          'date': '$difference days ago, $formattedDate',
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet.toList();

    } catch (failedRetrieval) {
      return <Map<String, dynamic>>[];
    }
  }
}
