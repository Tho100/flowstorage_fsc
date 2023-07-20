import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
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
    _fileInfoMsi: "dir0.png",
    _fileInfoDoc: "doc0.png",
    _fileInfoExe: "exe0.png",
    _fileInfoApk: "apk0.png"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String tableName) async {
    if (tableName == _fileInfoTable) {
      return _getFileInfoParams(conn);
    } else {
      return _getOtherTableParams(conn, tableName);
    }
  }

  Future<List<Uint8List>> _getFileInfoParams(MySQLConnectionPool conn) async {

    const query = 'SELECT CUST_FILE FROM $_fileInfoTable';
    final executeRetrieval = await conn.execute(query);

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

  Future<List<Uint8List>> _getOtherTableParams(MySQLConnectionPool conn, String tableName) async {

    final getByteValue = <Uint8List>{};

    retrieveValue(String iconName) async {

      final retrieveCountQuery = 'SELECT COUNT(*) FROM $tableName';
      final countTotalRows = await conn.execute(retrieveCountQuery);

      int totalCount = 0;

      for(final row in countTotalRows.rows) {
        totalCount = row.typedColAt<int>(0)!;
      }

      final loadImg = await Future.wait(List.generate(totalCount, (_) => GetAssets().loadAssetsData(iconName)));
      getByteValue.addAll(loadImg);
    }

    if (tableName == _fileInfoVidTable) {

      final thumbnailBytes = await thumbnailGetter.retrieveParams();
      getByteValue.addAll(thumbnailBytes);

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
}