import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';
  
/// <summary>
/// 
/// Class to insert user uploaded file 
/// encrypted information e.g it's metadata and file name
/// 
/// </summary>

class InsertData {
  
  final logger = Logger();
  final _encryptionClass = EncryptionClass();
  final _uploadDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> insertValueParams({
    required String tableName,
    required String filePath,
    required String userName,
    required dynamic fileVal,
    dynamic vidThumb,
  }) async {

    try {

      final conn = await SqlConnection.insertValueParams();

      final encryptedFilePath = _encryptionClass.Encrypt(filePath);
      final encryptedFileVal = _encryptionClass.Encrypt(fileVal);

      final thumb = vidThumb != null ? base64.encode(vidThumb) : null;

      switch (tableName) {

        case GlobalsTable.homeImageTable:
        case GlobalsTable.homeTextTable:
        case GlobalsTable.homePdfTable:
        case GlobalsTable.homePtxTable:
        case GlobalsTable.homeAudioTable:
        case GlobalsTable.homeExcelTable:
        case GlobalsTable.homeWordTable:
        case GlobalsTable.homeExeTable:

          await insertFileInfo(conn,tableName,encryptedFilePath,userName,encryptedFileVal);
          break;

        case GlobalsTable.homeVideoTable:
          await insertVideoInfo(conn,tableName,encryptedFilePath,userName,encryptedFileVal,thumb);
          break;

        case 'upload_info_directory':
          await insertDirectoryInfo(conn,tableName,userName,encryptedFileVal,Globals.directoryTitleValue,encryptedFilePath,thumb,filePath);
          break;

        case 'ps_info_text':
        case 'ps_info_image':
        case 'ps_info_excel':
        case 'ps_info_pdf':
        case 'ps_info_word':

          await insertFileInfoPs(conn, tableName, encryptedFilePath, userName, encryptedFileVal);
          break;

        case 'ps_info_video':
          await insertVideoInfoPs(conn,encryptedFilePath,userName,encryptedFileVal,thumb);
          break;

        default:
          throw ArgumentError('Invalid tableName: $tableName');
      }
    } catch (err, st) {
      logger.e("Exception from insertValueParams {insert_data}", err, st);
    }
    // added try/catch
  }

  Future<void> insertFileInfo(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE) VALUES (?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, _uploadDate, encryptedFileVal]);
  }

  Future<void> insertVideoInfo(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
    String? thumb,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_THUMB) VALUES (?, ?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, _uploadDate, encryptedFileVal, thumb]);
  }

  Future<void> insertDirectoryInfo(
    MySQLConnectionPool conn,
    String tableName,
    String custUsername,
    String encryptedFileVal,
    String? directoryName,
    String encryptedFilePath,
    String? thumb,
    String localFilePath,

  ) async {

    final fileExtension = localFilePath.substring(localFilePath.length - 4);
    final encryptedDirName = _encryptionClass.Encrypt(directoryName);

    await conn.prepare('INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, FILE_EXT, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?, ?)')
        ..execute([custUsername, encryptedFileVal, encryptedDirName, encryptedFilePath, _uploadDate, fileExtension, thumb]);
  }

  Future<void> insertFileInfoPs(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_COMMENT) VALUES (?, ?, ?, ?,?)')
        ..execute([encryptedFilePath, userName, _uploadDate, encryptedFileVal, EncryptionClass().Encrypt(Globals.psCommentValue)]);
  }

  Future<void> insertVideoInfoPs(
    MySQLConnectionPool conn,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
    String? thumb,
  ) async {

    await conn.prepare('INSERT INTO ps_info_video (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_THUMB, CUST_COMMENT) VALUES (?, ?, ?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, _uploadDate, encryptedFileVal, thumb, EncryptionClass().Encrypt(Globals.psCommentValue)]);
  }

}
