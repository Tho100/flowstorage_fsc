import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/public_storage/thumbnail_getter.dart';
import 'package:mysql_client/mysql_client.dart';

class ByteGetterPs {

  static const _fileInfoTable = 'ps_info_image';
  static const _fileInfoExpandTable = 'ps_info_text';
  static const _fileInfoVidTable = 'ps_info_video';
  static const _fileInfoPdfTable = 'ps_info_pdf';
  static const _fileInfoPtx = 'ps_info_ptx';
  static const _fileInfoExl = 'ps_info_excel';
  static const _fileInfoDoc = 'ps_info_word';
  static const _fileInfoApk = 'ps_info_apk';
  static const _fileInfoAudio = 'ps_info_audio';
  static const _fileInfoExe = 'ps_info_exe';
  static const _fileInfoMsi = 'ps_info_msi';

  final crud = Crud();
  final getAssets = GetAssets();
  final thumbnailGetter = ThumbnailGetterPs();

  final tableNameToAssetsImage = {
    _fileInfoExpandTable: "txt0.png",
    _fileInfoPdfTable: "pdf0.png",
    _fileInfoAudio: "music0.png",
    _fileInfoExl: "exl0.png",
    _fileInfoPtx: "ptx0.png",
    _fileInfoMsi: "exe0.png",
    _fileInfoDoc: "doc0.png",
    _fileInfoExe: "exe0.png",
    _fileInfoApk: "apk0.png"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String tableName) async {
    if (tableName == _fileInfoTable) {
      if(GlobalsData.psImageData.isEmpty) {
        return getFileInfoParams(conn, false);
      } else {
        return GlobalsData.psImageData;
      }
    } else {
      return getOtherTableParams(conn, tableName, isFromMyPs: false);
    }
  }

  Future<List<Uint8List>> myGetLeadingParams(MySQLConnectionPool conn, String tableName) async {
    if (tableName == _fileInfoTable) {
      if(GlobalsData.myPsImageData.isEmpty) {
        return getFileInfoParams(conn, true);
      } else {
        return GlobalsData.myPsImageData;
      }
    } else {
      return getOtherTableParams(conn, tableName, isFromMyPs: true);
    }
  }

  Future<List<Uint8List>> getFileInfoParams(MySQLConnectionPool conn, bool isFromMyPs) async {

    final String query; 
    final IResultSet executeRetrieval;

    if(isFromMyPs) {

      query = 'SELECT CUST_FILE FROM $_fileInfoTable WHERE CUST_USERNAME = :username';
      final params = {'username': Globals.custUsername};

      executeRetrieval = await conn.execute(query,params);

    } else {
      query = 'SELECT CUST_FILE FROM $_fileInfoTable ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
      executeRetrieval = await conn.execute(query);
    }
    
    final getByteValue = <Uint8List>[];

    for (final row in executeRetrieval.rows) {
      final encryptedFile = row.assoc()['CUST_FILE']!;
      final decodedFile = base64.decode(EncryptionClass().decrypt(encryptedFile));

      final buffer = ByteData.view(decodedFile.buffer);
      final bufferedFileBytes =
          Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

      getByteValue.add(bufferedFileBytes);
    }
    
    isFromMyPs 
    ? GlobalsData.myPsImageData.addAll(getByteValue)
    : GlobalsData.psImageData.addAll(getByteValue);

    return getByteValue;
  }

  Future<List<Uint8List>> getOtherTableParams(
    MySQLConnectionPool conn, 
    String tableName, 
    {required bool isFromMyPs}
  ) async {

    final getByteValue = <Uint8List>{};

    retrieveValue(String iconName) async {
      
      final String query;
      final IResultSet executedRows;
      
      if(isFromMyPs) {

        query = 'SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username';
        final params = {'username': Globals.custUsername};

        executedRows = await conn.execute(query,params);

      } else {
        query = 'SELECT COUNT(*) FROM $tableName';
        executedRows = await conn.execute(query);
      }

      int totalCount = 0;

      for(final row in executedRows.rows) {
        totalCount = row.typedColAt<int>(0)!;
      }

      final loadImg = await Future.wait(List.generate(totalCount, (_) => GetAssets().loadAssetsData(iconName)));
      getByteValue.addAll(loadImg);
    }

    if (tableName == _fileInfoVidTable) {

      if(GlobalsData.psThumbnailData.isEmpty || GlobalsData.myPsThumbnailData.isEmpty) {

        final thumbnailBytes = isFromMyPs 
          ? await thumbnailGetter.myRetrieveParams() 
          : await thumbnailGetter.retrieveParams();

        isFromMyPs 
        ? GlobalsData.myPsThumbnailData.addAll(thumbnailBytes)
        : GlobalsData.psThumbnailData.addAll(thumbnailBytes);

        getByteValue.addAll(thumbnailBytes);

      } else {
        isFromMyPs 
        ? getByteValue.addAll(GlobalsData.myPsThumbnailData)
        : getByteValue.addAll(GlobalsData.psThumbnailData);
      }

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
}