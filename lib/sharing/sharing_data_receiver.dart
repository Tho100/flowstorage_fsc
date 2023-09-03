import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
import '../encryption/encryption_model.dart';

class SharingDataReceiver {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  final now = DateTime.now();
  
  Future<String> retrieveFiles({
    required String query,
    required String returnedColumn,
    required String fileName,
    required String username,
    required MySQLConnectionPool connection
  }) async {
    
    final params = {'username': username, 'filename': fileName};
    final executeRetrieval = await connection.execute(query, params);

    for (final row in executeRetrieval.rows) {
      return row.assoc()[returnedColumn]!;
    }

    return '';
  }

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String originFrom) async {

    final connection = await SqlConnection.insertValueParams();

    String query =
        'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username';
    final params = {'username': username};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      late Uint8List fileBytes = Uint8List(0);

      late String encryptedFileNames;
      late String decryptedFileNames;
      late String fileType;

      for (final row in result.rows) {

        encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        decryptedFileNames = encryption.decrypt(encryptedFileNames);
        fileType = decryptedFileNames.split('.').last.toLowerCase();

        switch (fileType) {

          case 'jpg':
          case 'png':
          case 'jpeg':
          case 'webp':

            final retrieveEncryptedMetadata =
                'SELECT CUST_FILE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';

            final encryptedBase64 = await retrieveFiles(
              query: retrieveEncryptedMetadata, 
              returnedColumn: "CUST_FILE", 
              fileName: encryptedFileNames, 
              username: username, 
              connection: connection
            );

            fileBytes = base64.decode(EncryptionClass().decrypt(encryptedBase64));

            break;

          case 'mp4':
          case 'wmv':
          case 'avi':
          case 'mov':
          case 'mkv':
          
            final querySelectThumbnail =
                'SELECT CUST_THUMB FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';

            final base64EncodedThumbnail = await retrieveFiles(
              query: querySelectThumbnail, 
              returnedColumn: "CUST_THUMB", 
              fileName: encryptedFileNames, 
              username: username, 
              connection: connection
            );

            fileBytes = base64.decode(base64EncodedThumbnail);

            break;

          default:
            fileBytes = await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);
        }

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final dateValueWithDashes = dateValue.replaceAll('/', '-');
        final dateComponents = dateValueWithDashes.split('-');
        
        final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
        final difference = now.difference(date).inDays;

        final formattedDate = DateFormat('MMM d yyyy').format(date);
        final buffer = ByteData.view(fileBytes.buffer);

        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': decryptedFileNames,
          'date': '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate',
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet;
    } catch (failedRetrieval) {
      return <Map<String, dynamic>>[];
    }
  }
}
