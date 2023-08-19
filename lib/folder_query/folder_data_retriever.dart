import 'dart:convert';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

class FolderDataReceiver {

  final _locator = GetIt.instance;

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  final dateNow = DateTime.now();

  Future<String> retrieveFiles({
    required MySQLConnectionPool conn, 
    required String folderTitle,
    required String query,
    required String fileName,
    required String returnColumn
  }) async {
    
    final userData = _locator<UserDataProvider>();

    final params = {"username": userData.username,"foldname": encryption.encrypt(folderTitle),"filename": fileName};

    final results = await conn.execute(query,params);

    for(final row in results.rows) {
      return row.assoc()[returnColumn]!;
    }

    return '';
  }

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String folderTitle) async {

    final connection = await SqlConnection.insertValueParams();

    const querySelectThumbnail = "SELECT CUST_THUMB FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldname AND CUST_FILE_PATH = :filename";
    const querySelectImage = "SELECT CUST_FILE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldname AND CUST_FILE_PATH = :filename";

    const query = 'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM folder_upload_info WHERE FOLDER_TITLE = :foldtitle AND CUST_USERNAME = :username';
    final params = {'username': username,'foldtitle': encryption.encrypt(folderTitle)};

    try {

      final result = await connection.execute(query, params);
      final dataSet = <Map<String, dynamic>>{};

      late Uint8List fileBytes = Uint8List(0);

      late String encryptedFileNames;
      late String decryptedFileNames;
      late String fileType;

      for (final row in result.rows) {
        
        encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        decryptedFileNames = encryption.decrypt(encryptedFileNames);

        fileType = decryptedFileNames.split('.').last.toLowerCase();

        if (Globals.imageType.contains(fileType)) {
          
          final encryptedImageBase64 = await retrieveFiles(
            conn: connection, 
            folderTitle: folderTitle, 
            query: querySelectImage, 
            fileName: encryptedFileNames,
            returnColumn: "CUST_FILE"
          );

          fileBytes = base64.decode(encryption.decrypt(encryptedImageBase64));

        } else if (Globals.videoType.contains(fileType)) {
          
          final thumbnailBase64 = await retrieveFiles(
            conn: connection,
            folderTitle: folderTitle,
            query: querySelectThumbnail,
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
          'name': decryptedFileNames,
          'date': '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate',
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet.toList();

    } catch (err, st) {
      Logger().e("Exception from retrieveParams {folder_data_retriever}", err, st);
      return <Map<String, dynamic>>[];
    }
  }
}
