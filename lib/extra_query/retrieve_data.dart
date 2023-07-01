import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';

import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';

/// <summary>
/// 
/// Class to retrieve user encrypted files metadata
/// and decrypt/decode them later for user to see
/// 
/// </summary>

class RetrieveData {

  final encryption = EncryptionClass();

  Future<Uint8List> retrieveDataModules(
    MySQLConnectionPool fscDbCon,
    String? username,
    String? fileName,
    String? tableName,
    String? originFrom
  ) async {

    final encryptedFileName = encryption.Encrypt(fileName!);

    late final String query;
    late final Map<String, String> queryParams;

    if (originFrom == "homeFiles") {
      query = "SELECT CUST_FILE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "sharedToMe") {
      query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "sharedFiles") {
      query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "folderFiles") {
      query = "SELECT CUST_FILE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "foldtitle": encryption.Encrypt(Globals.folderTitleValue), "filename": encryptedFileName};
    } else if (originFrom == "dirFiles") {
      query = "SELECT CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "dirname": encryption.Encrypt(Globals.directoryTitleValue), "filename": encryptedFileName};
    } else if (originFrom == "psFiles") {
      query = "SELECT CUST_FILE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      queryParams = {"username": username!, "filename": encryptedFileName};
    }

    final row = (await fscDbCon.execute(query, queryParams)).rows.first;
    final byteData = base64.decode(encryption.Decrypt(row.assoc()['CUST_FILE']!));
    return byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Future<Uint8List> retrieveDataParams(
    String? username,
    String? fileName,
    String? tableName,
    String? originFrom,
  ) async {

    final fscDbCon = await SqlConnection.insertValueParams();

    return await retrieveDataModules(
      fscDbCon,
      username,
      fileName,
      tableName,
      originFrom
    );
  }

}