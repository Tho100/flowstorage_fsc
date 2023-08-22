import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
import 'package:get_it/get_it.dart';

class CallPreviewData {

  final retrieveData = RetrieveData();
  final uploaderName = UploaderName();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<Uint8List> callDataAsync({
    required String tableNamePs, 
    required String tableNameHome, 
    required Set<dynamic> fileValues
  }) async {

    final tableName = tempData.fileOrigin == "psFiles" ? tableNamePs : tableNameHome;
    final uploaderUsername = tempData.fileOrigin == "psFiles" 
    ? await uploaderName.getUploaderName(tableName: tableNamePs, fileValues: fileValues)
    : userData.username;

    final fileBytesData = await retrieveData.retrieveDataParams(
      uploaderUsername,
      tempData.selectedFileName,
      tableName,
      tempData.fileOrigin,
    );

    return fileBytesData;
  }
}