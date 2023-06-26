import 'dart:convert';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:flowstorage_fsc/data_classes/thumbnail_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:mysql_client/mysql_client.dart';

/// <summary>
/// 
/// Class to retrieve user files leading image
/// based on the file type
/// 
/// </summary>

class LoginGetter {

  int countDirCurr = 0;

  final crud = Crud();
  final getAssets = GetAssets();
  final thumbnailGetter = ThumbnailGetter();

  final tableNameToAssetsImage = {
    GlobalsTable.homeTextTable: "txt0.png",
    GlobalsTable.homePdfTable: "pdf0.png",
    GlobalsTable.homeAudioTable: "music0.png",
    GlobalsTable.homeExcelTable: "exl0.png",
    GlobalsTable.homePtxTable: "ptx0.png",
    GlobalsTable.homeWordTable: "doc0.png",
    GlobalsTable.homeExeTable: "exe0.png",
    GlobalsTable.homeApkTable: "apk0.png"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String? username, String tableName) async {
    if (tableName == GlobalsTable.homeImageTable) {
      return _getFileInfoParams(conn, username);
    } else {
      return _getOtherTableParams(conn, username, tableName);
    }
  }

  Future<List<Uint8List>> _getFileInfoParams(MySQLConnectionPool conn, String? username) async {

    const query = 'SELECT CUST_FILE FROM ${GlobalsTable.homeImageTable} WHERE CUST_USERNAME = :username';
    final params = {'username': username};
    final executeRetrieval = await conn.execute(query, params);
    final getByteValue = <Uint8List>[];

    for (final row in executeRetrieval.rows) {
      final encryptedFile = row.assoc()['CUST_FILE']!;
      final decodedFile = base64.decode(EncryptionClass().Decrypt(encryptedFile));

      final buffer = ByteData.view(decodedFile.buffer);
      final bufferedFileBytes =
          Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

      getByteValue.add(bufferedFileBytes);
    }

    return getByteValue;
  }

  Future<List<Uint8List>> _getOtherTableParams(MySQLConnectionPool conn, String? username, String tableName) async {

    final getByteValue = <Uint8List>{};

    Future<void> retrieveValue(String iconName) async {
      final retrieveCountQuery = 'SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username';
      final params = {'username': Globals.custUsername};
      final countTotalRows = await crud.count(query: retrieveCountQuery, params: params);

      final loadPdfImg = await Future.wait(List.generate(countTotalRows, (_) => GetAssets().loadAssetsData(iconName)));
      getByteValue.addAll(loadPdfImg);
    }

    if (tableName == GlobalsTable.homeVideoTable) {

      final thumbnailBytes = await thumbnailGetter.retrieveParams(fileName: '');
      getByteValue.addAll(thumbnailBytes);

    } else if (tableName == GlobalsTable.directoryInfoTable) {

      final images = await Future.wait(List.generate(1, (_) => getAssets.loadAssetsData('dir0.png')));
      getByteValue.addAll(images);

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
}