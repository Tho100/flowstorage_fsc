import 'dart:convert';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_data.dart';
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

class DataRetriever {

  int countDirCurr = 0;

  final crud = Crud();
  final getAssets = GetAssets();
  final thumbnailGetter = ThumbnailGetter();

  final tableNameToAssetsImage = {
    GlobalsTable.homeText: "txt0.png",
    GlobalsTable.homePdf: "pdf0.png",
    GlobalsTable.homeAudio: "music0.png",
    GlobalsTable.homeExcel: "exl0.png",
    GlobalsTable.homePtx: "ptx0.png",
    GlobalsTable.homeWord: "doc0.png",
    GlobalsTable.homeExe: "exe0.png",
    GlobalsTable.homeApk: "apk0.png"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String? username, String tableName) async {

    if (tableName == GlobalsTable.homeImage) {

      if(GlobalsData.homeImageData.isEmpty) {
        return getFileInfoParams(conn, username);
      } else {
        return GlobalsData.homeImageData;
      }

    } else {
      return getOtherTableParams(conn, username, tableName);
    }

  }

  Future<List<Uint8List>> getFileInfoParams(MySQLConnectionPool conn, String? username) async {

    const query = 'SELECT CUST_FILE FROM ${GlobalsTable.homeImage} WHERE CUST_USERNAME = :username';
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

    GlobalsData.homeImageData.addAll(getByteValue);

    return getByteValue;
  }

  Future<List<Uint8List>> getOtherTableParams(MySQLConnectionPool conn, String? username, String tableName) async {

    final getByteValue = <Uint8List>{};

    Future<void> retrieveValue(String iconName) async {

      final retrieveCountQuery = 'SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username';
      final params = {'username': Globals.custUsername};
      final countTotalRows = await crud.count(query: retrieveCountQuery, params: params);

      final loadAssetImage = await Future.wait(List.generate(countTotalRows, (_) => GetAssets().loadAssetsData(iconName)));
      getByteValue.addAll(loadAssetImage);

    }

    if (tableName == GlobalsTable.homeVideo) {

      if(GlobalsData.homeThumbnailData.isEmpty) {
        
        final thumbnailBytes = await thumbnailGetter.retrieveParams(fileName: '');

        GlobalsData.homeThumbnailData.addAll(thumbnailBytes);
        getByteValue.addAll(thumbnailBytes);

      } else {
        getByteValue.addAll(GlobalsData.homeThumbnailData);
      }

    } else if (tableName == GlobalsTable.directoryInfoTable) {

      if(GlobalsData.directoryImageData.isEmpty) {

        final dirImage = await Future.wait(List.generate(1, (_) => getAssets.loadAssetsData('dir0.png')));
        getByteValue.addAll(dirImage);

        GlobalsData.directoryImageData.addAll(dirImage);

      } else {
        getByteValue.addAll(GlobalsData.directoryImageData);
      }

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
}