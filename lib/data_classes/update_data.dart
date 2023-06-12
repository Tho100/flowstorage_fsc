import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/Globals.dart';

/// <summary>
/// 
/// Class to update for values like text changes
/// and username update will be perform here
/// 
/// </summary>

class UpdateValues  {
  
  Future<void> insertValueParams({
    required String tableName,
    required String filePath,
    required String userName,
    required var newValue,
    required String columnName,
  }) async {
  
    final conn = await SqlConnection.insertValueParams();

    late final String encryptedFilePath;
    late final String encryptedFileVal;

    encryptedFilePath = EncryptionClass().Encrypt(filePath);
    encryptedFileVal = EncryptionClass().Encrypt(newValue);

    if (Globals.fileOrigin == "homeFiles") {

      if (tableName == "information") {

        final query = "UPDATE $tableName SET $columnName = :newuser WHERE CUST_USERNAME = :username";
        final params = {"newuser": newValue, "username": userName};

        await conn.execute(query, params);

      } else if (tableName == "file_info_expand") {

        final List<int> getUnits = newValue.codeUnits;  
        final String getEncodedVers = base64.encode(getUnits);
        final encryptedFileValText = EncryptionClass().Encrypt(getEncodedVers);

        final query = "UPDATE $tableName SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        final params = {"username": userName, "newvalue": encryptedFileValText, "filename": encryptedFilePath};

        await conn.execute(query, params);

      } else if (tableName == "file_info_excel") {
        final query = "UPDATE $tableName SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        final params = {"username": userName, "newvalue": encryptedFileVal, "filename": encryptedFilePath};

        await conn.execute(query, params);
      }
      
    } else if (Globals.fileOrigin == "dirFiles") {

      final encryptedDirectoryName = EncryptionClass().Encrypt(Globals.directoryTitleValue);

      const query = "UPDATE upload_info_directory SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
      final params = {"username": userName, "newvalue": encryptedFileVal, "filename": encryptedFilePath, "dirname": encryptedDirectoryName};

      await conn.execute(query, params);
    } else if (Globals.fileOrigin == "folderFiles") {

      final encryptedFolderName = EncryptionClass().Encrypt(Globals.folderTitleValue);

      const query = "UPDATE folder_upload_info SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
      final params = {"username": userName, "newvalue": encryptedFileVal, "filename": encryptedFilePath, "foldname": encryptedFolderName};

      await conn.execute(query, params);
    }

    
  }
}