import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';

class CallPreviewData {

  final retrieveData = RetrieveData();
  final uploaderName = UploaderName();

  Future<Uint8List> callDataAsync({
    required String tableNamePs, 
    required String tableNameHome, 
    required Set<dynamic> fileValues
  }) async {

    final tableName = Globals.fileOrigin == "psFiles" ? tableNamePs : tableNameHome;
    final uploaderUsername = Globals.fileOrigin == "psFiles" 
    ? await uploaderName.getUploaderName(tableName: tableNamePs, fileValues: fileValues)
    : Globals.custUsername;

    final fileBytesData = await retrieveData.retrieveDataParams(
      uploaderUsername,
      Globals.selectedFileName,
      tableName,
      Globals.fileOrigin,
    );

    return fileBytesData;
  }
}