import 'dart:convert';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/thumbnail_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

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

  Future<List<Uint8List>> getLeadingParams(String? username, String? tableName) async {

    final conn = await SqlConnection.insertValueParams();

    final getByteValue = <Uint8List>{};

    if (tableName == _fileInfoTable) {

      const retrieveEncryptedMetadata = 'SELECT CUST_FILE FROM $_fileInfoTable WHERE CUST_USERNAME = :username';
      final params = {'username': username};

      final executeRetrieval = await conn.execute(retrieveEncryptedMetadata, params);

      for (final row in executeRetrieval.rows) {
        
        final encryptedFile = row.assoc()['CUST_FILE']!;
        final decodedFile = base64.decode(EncryptionClass().Decrypt(encryptedFile));

        final buffer = ByteData.view(decodedFile.buffer);
        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);
        
        getByteValue.add(bufferedFileBytes);
      }

    } else {

      Future<void> retrieveValue(String iconName) async {

        final retrieveCountQuery = 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username';
        final params = {'username': username};
        final executeRetrieval = await conn.execute(retrieveCountQuery, params);
        final countTotalFileName = executeRetrieval.numOfRows;

        final loadPdfImg = await Future.wait(List.generate(countTotalFileName,(_) => GetAssets().loadAssetsData(iconName)));
        getByteValue.addAll(loadPdfImg);
      }

      if (tableName == _fileInfoVidTable) {
        final thumbnailGetter = ThumbnailGetter();
        final thumbnailBytes = await thumbnailGetter.retrieveParams(fileName: '');
        getByteValue.addAll(thumbnailBytes);

      } else if (tableName == _fileInfoPdfTable) {

        await retrieveValue("pdf0.png");

      } else if (tableName == _fileInfoExpandTable) {

        await retrieveValue("txt0.png");

      } else if (tableName == _fileInfoDirectory) {

        /*const retrieveCountQuery = 'SELECT DIR_NAME FROM file_info_directory WHERE CUST_USERNAME = :username';
        final params = {'username': username};
        final executeRetrieval = await conn.execute(retrieveCountQuery, params);
        final countTotalFileName = executeRetrieval.numOfRows;
          */
        //final loadDirImg = await Future.wait(List.generate(countTotalFileName,(_) => loadAssetImage('assets/nice/dir0.png')));
        final images = await Future.wait(List.generate(1,(_) => GetAssets().loadAssetsData('dir0.png'))); 
        getByteValue.addAll(images);

      } else if (tableName == _fileInfoAudio) {

        await retrieveValue("music0.png");

      } else if (tableName == _fileInfoPtx) {

        await retrieveValue("pptx0.png");

      } else if (tableName == _fileInfoExe) {

        await retrieveValue("exe0.png");
        
      } else if (tableName == _fileInfoExl) {

        await retrieveValue("exl0.png");

      } else if (tableName == _fileInfoDoc) {

        await retrieveValue("doc0.png");

      } else if (tableName == _fileInfoApk) {

        await retrieveValue("apk0.png");

      }
      
    }

    return getByteValue.toList();
  }
}
