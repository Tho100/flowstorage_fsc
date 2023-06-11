import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flowstorage_fsc/Encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/Connection/ClusterFsc.dart';
import 'package:collection/collection.dart';
import 'package:flowstorage_fsc/global/Globals.dart';

/// <summary>
/// 
/// Class to retrieve user encrypted files metadata
/// and decrypt/decode them later for user to see
/// 
/// </summary>

class RetrieveData {

  Future<Uint8List> retrieveDataModules(
    String? username, 
    String? fileName, 
    String? tableName, 
    String? originFrom, 
    ) async {

    final encryptedFileName = EncryptionClass().Encrypt(fileName);

    late final String query;
    late final Map<String, String> params;

    if (originFrom == "homeFiles") {
      query = "SELECT CUST_FILE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      params = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "sharedToMe") {
      query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      params = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "sharedFiles") {
      query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      params = {"username": username!, "filename": encryptedFileName};
    } else if (originFrom == "folderFiles") {
      query = "SELECT CUST_FILE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle AND CUST_FILE_PATH = :filename";
      params = {"username": username!,"foldtitle": EncryptionClass().Encrypt(Globals.folderTitleValue), "filename": encryptedFileName};
    } else if (originFrom == "dirFiles") {
      query = "SELECT CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
      params = {"username": username!,"dirname": EncryptionClass().Encrypt(Globals.directoryTitleValue), "filename": encryptedFileName};
    }

    final fscDbCon = await SqlConnection.insertValueParams();

    final row = (await fscDbCon.execute(query, params)).rows.firstOrNull;
    final byteData = base64.decode(EncryptionClass().Decrypt(row!.assoc()['CUST_FILE']!));
    return byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

  }

  Future<Uint8List> retrieveDataParams(
    String? username, 
    String? fileName, 
    String? tableName, 
    String? originFrom, 
    ) async {

    return await Future(() => retrieveDataModules(username, fileName, tableName, originFrom));

  }

}