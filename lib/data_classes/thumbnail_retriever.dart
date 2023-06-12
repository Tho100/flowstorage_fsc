import 'dart:convert';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';

/// <summary>
/// 
/// Class to retrieve user video thumbnail
/// and decode them for user to see 
/// 
/// </summary>

class ThumbnailGetter {
  
  Future<List<Uint8List>> retrieveParams({required String? fileName}) async {

    final conn = await SqlConnection.insertValueParams();

    String query;
    Map<String, dynamic> params;
  
    if (fileName != null) {
      query = "SELECT CUST_THUMB FROM ";
      if (Globals.fileOrigin == "homeFiles") {
        query += "file_info_vid WHERE CUST_USERNAME = :username";
      } else {
        query += "cust_sharing WHERE CUST_FROM = :username";
        if (Globals.fileOrigin == "sharedFiles") {
          query += " AND CUST_TO = :username";
        } else if (Globals.fileOrigin == "sharedToMe") {
          query += " AND CUST_FILE_PATH = :filename";
          params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(fileName)};
        }
      }
      params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(fileName)};
    } else {
      query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username";
      params = {'username': Globals.custUsername};
    }

    try {

      final getThumbBytesQue = await conn.execute(query, params);
      final thumbnailBytesList = <Uint8List>[];

      for (final res in getThumbBytesQue.rows) {
        final thumbBytes = res.assoc()['CUST_THUMB'];
        thumbnailBytesList.add(base64.decode(thumbBytes!));
      }

      return thumbnailBytesList;
    } finally {
      //
    }
  }

  Future<String?> retrieveParamsSingle({required String? fileName}) async {

    final conn = await SqlConnection.insertValueParams();

    String? base64EncodeThumbnail;

    if(Globals.fileOrigin == "homeFiles") {

      const query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      final params = {'username': Globals.custUsername,'filename': EncryptionClass().Encrypt(fileName)};

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    } else if (Globals.fileOrigin == "dirFiles") {

    } else if (Globals.fileOrigin == "folderFiles") {
      
    } else if (Globals.fileOrigin == "sharedFiles") {

    } else if (Globals.fileOrigin == "sharedToMe") {

    }
  
    return base64EncodeThumbnail!;

  }
}


/*class ThumbnailGetter {

  Future<List<Uint8List>> retrieveParams(String? custUsername, {String? fileName}) async {

    final conn = await SqlConnection.insertValueParams();

    late String query;
    late Map<String, dynamic> params;

    if (fileName != null) {
      
      if(getFileOrigin == "homeFiles") {
        query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': custUsername, 'filename': EncryptionClass().Encrypt(fileName)};
      } else if (getFileOrigin == "sharedFiles") {
        query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {'username': custUsername, 'filename': EncryptionClass().Encrypt(fileName)};
      } else if (getFileOrigin == "sharedToMe") {
        query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {'username': custUsername, 'filename': EncryptionClass().Encrypt(fileName)};
      } 

    } else {

      if(getFileOrigin == "homeFiles") {
        query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username";
        params = {'username': custUsername};
      }

    }

    try {

      final getThumbBytesQue = await conn.execute(query, params);
      final thumbnailBytesList = <Uint8List>[];

      for (final res in getThumbBytesQue.rows) {
        final thumbBytes = res.assoc()['CUST_THUMB'];
        thumbnailBytesList.add(base64.decode(thumbBytes!));
      }

      return thumbnailBytesList;

    } finally {
      //
    }
  }
}*/