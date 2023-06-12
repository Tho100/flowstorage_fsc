import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
  
/// <summary>
/// 
/// Class to insert user uploaded file 
/// encrypted information e.g it's metadata and file name
/// 
/// </summary>

class InsertData {

  final _encryptionClass = EncryptionClass();
  final _uploadDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> insertValueParams({
    required String tableName,
    required String filePath,
    required String userName,
    required dynamic fileVal,
    dynamic vidThumb,
  }) async {

    final conn = await SqlConnection.insertValueParams();

    final encryptedFilePath = _encryptionClass.Encrypt(filePath);
    final encryptedFileVal = _encryptionClass.Encrypt(fileVal);

    final thumb = vidThumb != null ? base64.encode(vidThumb) : null;

    switch (tableName) {

      case 'file_info':
      case 'file_info_expand':
      case 'file_info_pdf':
      case 'file_info_ptx':
      case 'file_info_audi':
      case 'file_info_excel':
      case 'file_info_word':
      case 'file_info_gif':
      case 'file_info_exe':

        await insertFileInfo(conn,tableName,encryptedFilePath,userName,_uploadDate,encryptedFileVal,);
        break;

      case 'file_info_vid':
        await insertVideoInfo(conn,tableName,encryptedFilePath,userName,_uploadDate,encryptedFileVal,thumb);
        break;

      case 'upload_info_directory':
        await insertDirectoryInfo(conn,tableName,userName,encryptedFileVal,Globals.directoryTitleValue,encryptedFilePath,_uploadDate,thumb,filePath);
        break;

      default:
        throw ArgumentError('Invalid tableName: $tableName');
    }
  }

  Future<void> insertFileInfo(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String uploadDate,
    String encryptedFileVal,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE) VALUES (?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, uploadDate, encryptedFileVal]);
  }

  Future<void> insertVideoInfo(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String uploadDate,
    String encryptedFileVal,
    String? thumb,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_THUMB) VALUES (?, ?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, uploadDate, encryptedFileVal, thumb]);
  }

  Future<void> insertDirectoryInfo(
    MySQLConnectionPool conn,
    String tableName,
    String custUsername,
    String encryptedFileVal,
    String? directoryName,
    String encryptedFilePath,
    String uploadDate,
    String? thumb,
    String localFilePath,

  ) async {

    final fileExtension = localFilePath.substring(localFilePath.length - 4);
    final encryptedDirName = _encryptionClass.Encrypt(directoryName);

    await conn.prepare('INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, FILE_EXT, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?, ?)')
        ..execute([custUsername, encryptedFileVal, encryptedDirName, encryptedFilePath, uploadDate, fileExtension, thumb]);
  }
}
