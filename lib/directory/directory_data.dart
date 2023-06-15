import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class DirectoryDataReceiver {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  final dateNow = DateTime.now();
  
  Future<String> retrieveFiles({
    required MySQLConnectionPool conn, 
    required String directoryTitle,
    required String query,
    required String fileName,
    required String returnColumn,
  }) async {

    final params = {"username": Globals.custUsername, "dirname": directoryTitle,"filename": fileName};
    final results = await conn.execute(query,params);

    for(final row in results.rows) {
      return row.assoc()[returnColumn]!;
    }

    return '';
  }
  
  Future<List<Map<String, dynamic>>> retrieveParams(
    String username,
    String dirName
    ) async {

    final connection = await SqlConnection.insertValueParams();

    final directoryName = encryption.Encrypt(dirName);

    const query = 'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname';
    final params = {'username': username,'dirname': directoryName};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      Uint8List fileBytes = Uint8List(0);

      for (final row in result.rows) {

        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final fileNames = encryption.Decrypt(encryptedFileNames);
        final fileType = fileNames.split('.').last.toLowerCase();

        if(Globals.imageType.contains(fileType)) {

          const query = 'SELECT CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname';
          final encryptedImageBase64 = await retrieveFiles(
            conn: connection, 
            directoryTitle: directoryName, 
            query: query,
            fileName: encryptedFileNames, 
            returnColumn: "CUST_FILE"
          );

          fileBytes = base64.decode(encryption.Decrypt(encryptedImageBase64));
      
        } else if (Globals.videoType.contains(fileType)) {

          const query = 'SELECT CUST_THUMB FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname';

          final thumbnailBase64 = await retrieveFiles(
            conn: connection, 
            directoryTitle: directoryName, 
            query: query, 
            fileName: encryptedFileNames,
            returnColumn: "CUST_THUMB"
          );

          fileBytes = base64.decode(thumbnailBase64);

        } else {

          fileBytes = await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);

        }

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final dateValueWithDashes = dateValue.replaceAll('/', '-');
        final dateComponents = dateValueWithDashes.split('-');
        
        final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
        final difference = dateNow.difference(date).inDays;

        final formattedDate = DateFormat('MMM d yyyy').format(date);
        final buffer = ByteData.view(fileBytes.buffer);

        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': fileNames,
          'date': '$difference days ago, $formattedDate',
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet;

    } catch (failedRetrieval) {
      print("Exception from retrieveParams {directory_data}: $failedRetrieval");
      return <Map<String, dynamic>>[];
    }
  }
}