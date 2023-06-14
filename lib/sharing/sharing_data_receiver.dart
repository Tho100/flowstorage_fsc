import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../encryption/encryption_model.dart';

/// <summary>
/// 
/// Class to retrieve user  encrypted shared files names
/// and decrypt them later for user to see
/// 
/// </summary>

class SharingDataReceiver {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  final now = DateTime.now();

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String originFrom) async {

    final connection = await SqlConnection.insertValueParams();

    String query =
        'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username';
    final params = {'username': username};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      for (final row in result.rows) {
        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final fileNames = encryption.Decrypt(encryptedFileNames);
        final fileType = fileNames.split('.').last.toLowerCase();

        Uint8List fileBytes = Uint8List(0);

        switch (fileType) {

          case 'jpg':
          case 'png':
          case 'jpeg':
          case 'webp':

            final retrieveEncryptedMetadata =
                'SELECT CUST_FILE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';
            final params = {'username': username, 'filename': encryptedFileNames};
            final executeRetrieval = await connection.execute(retrieveEncryptedMetadata, params);

            for (final row in executeRetrieval.rows) {
              final encryptedFile = row.assoc()['CUST_FILE']!;
              final decodedFile = base64.decode(EncryptionClass().Decrypt(encryptedFile));
              fileBytes = decodedFile;
            }

            break;

          case 'mp4':
          case 'wmv':
          case 'avi':
          case 'mov':
          case 'mkv':
          
            final retrieveEncryptedMetadata =
                'SELECT CUST_THUMB FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';
            final params = {'username': username, 'filename': encryptedFileNames};
            final executeRetrieval = await connection.execute(retrieveEncryptedMetadata, params);

            for (final row in executeRetrieval.rows) {
              final getThumbEncoded = row.assoc()['CUST_THUMB']!;
              final decodedFile = base64.decode(getThumbEncoded);
              fileBytes = decodedFile;
            }

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
          'name': fileNames,
          'date': '$difference days ago, $formattedDate',
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
