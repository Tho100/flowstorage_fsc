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
  final encryption = EncryptionClass();
  final dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> insertValueParams({
    required String tableName,
    required String filePath,
    required String userName,
    required dynamic fileVal,
    dynamic vidThumb,
  }) async {

    final conn = await SqlConnection.insertValueParams();

    final encryptedFilePath = encryption.encrypt(filePath);
    final encryptedFileVal = encryption.encrypt(fileVal);

    final thumb = vidThumb != null ? base64.encode(vidThumb) : null;

    switch (tableName) {

      case GlobalsTable.homeImage:
      case GlobalsTable.homeText:
      case GlobalsTable.homePdf:
      case GlobalsTable.homePtx:
      case GlobalsTable.homeAudio:
      case GlobalsTable.homeExcel:
      case GlobalsTable.homeWord:
      case GlobalsTable.homeExe:

        await insertFileInfo(conn,tableName,encryptedFilePath,userName,encryptedFileVal);
        break;

      case GlobalsTable.homeVideo:
        await insertVideoInfo(conn,tableName,encryptedFilePath,userName,encryptedFileVal,thumb);
        break;

      case GlobalsTable.directoryUploadTable:
        await insertDirectoryInfo(conn,tableName,userName,encryptedFileVal,Globals.directoryTitleValue,encryptedFilePath,thumb,filePath);
        break;

      case GlobalsTable.psText:
      case GlobalsTable.psImage:
      case GlobalsTable.psExe:
      case GlobalsTable.psExcel:
      case GlobalsTable.psPdf:
      case GlobalsTable.psWord:
      case GlobalsTable.psAudio:
      case GlobalsTable.psApk:

        await insertFileInfoPs(conn, tableName, encryptedFilePath, userName, encryptedFileVal);
        break;

      case GlobalsTable.psVideo:
        await insertVideoInfoPs(conn,encryptedFilePath,userName,encryptedFileVal,thumb);
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
    String encryptedFileVal,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE) VALUES (?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileVal]);
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
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileVal, thumb]);
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
    final encryptedDirName = encryption.encrypt(directoryName);

    await conn.prepare('INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, FILE_EXT, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?, ?)')
        ..execute([custUsername, encryptedFileVal, encryptedDirName, encryptedFilePath, dateNow, fileExtension, thumb]);
  }

  Future<void> insertFileInfoPs(
    MySQLConnectionPool conn,
    String tableName,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
  ) async {

    await conn.prepare('INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_COMMENT, CUST_TAG) VALUES (?, ?, ?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileVal, EncryptionClass().encrypt(Globals.psCommentValue), Globals.psTagValue]);
  }

  Future<void> insertVideoInfoPs(
    MySQLConnectionPool conn,
    String encryptedFilePath,
    String userName,
    String encryptedFileVal,
    String? thumb,
  ) async {

    await conn.prepare('INSERT INTO ps_info_video (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_THUMB, CUST_COMMENT, CUST_TAG) VALUES (?, ?, ?, ?, ?, ?, ?)')
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileVal, thumb, EncryptionClass().encrypt(Globals.psCommentValue),Globals.psTagValue]);
  }

}
