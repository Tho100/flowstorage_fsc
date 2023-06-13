import 'dart:convert';
import 'package:flowstorage_fsc/extra_query/crud.dart';
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

  static const _fileInfoTable = 'file_info';
  static const _fileInfoExpandTable = 'file_info_expand';
  static const _fileInfoVidTable = 'file_info_vid';
  static const _fileInfoPdfTable = 'file_info_pdf';
  static const _fileInfoPtx = 'file_info_ptx';
  static const _fileInfoExl = 'file_info_excel';
  static const _fileInfoDoc = 'file_info_word';
  static const _fileInfoApk = 'file_info_apk';
  static const _fileInfoAudio = 'file_info_audi';
  static const _fileInfoExe = 'file_info_exe';
  static const _fileInfoDirectory = 'file_info_directory';

  int countDirCurr = 0;

  final crud = Crud();
  final getAssets = GetAssets();
  final thumbnailGetter = ThumbnailGetter();

  final tableNameToAssetsImage = {
    _fileInfoExpandTable: "txt0.png",
    _fileInfoPdfTable: "pdf0.png",
    _fileInfoAudio: "txt0.png",
    _fileInfoExl: "exl0.png",
    _fileInfoPtx: "ptx0.png",
    _fileInfoDoc: "doc0.png",
    _fileInfoExe: "exe0.png",
    _fileInfoApk: "apk0.png"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String? username, String tableName) async {
    if (tableName == _fileInfoTable) {
      return _getFileInfoParams(conn, username);
    } else {
      return _getOtherTableParams(conn, username, tableName);
    }
  }

  Future<List<Uint8List>> _getFileInfoParams(MySQLConnectionPool conn, String? username) async {

    const query = 'SELECT CUST_FILE FROM $_fileInfoTable WHERE CUST_USERNAME = :username';
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

    if (tableName == _fileInfoVidTable) {

      final thumbnailBytes = await thumbnailGetter.retrieveParams(fileName: '');
      getByteValue.addAll(thumbnailBytes);

    } else if (tableName == _fileInfoDirectory) {

      final images = await Future.wait(List.generate(1, (_) => getAssets.loadAssetsData('dir0.png')));
      getByteValue.addAll(images);

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
}