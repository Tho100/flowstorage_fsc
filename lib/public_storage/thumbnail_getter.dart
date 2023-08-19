import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class ThumbnailGetterPs {

  final _locator = GetIt.instance;

  Future<List<Uint8List>> retrieveParams() async {

    final conn = await SqlConnection.insertValueParams();
    const query = 'SELECT CUST_THUMB FROM ps_info_video ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    
    final getThumbBytesQue = await conn.execute(query);
    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;

  }

  Future<List<Uint8List>> myRetrieveParams() async {

    final userData = _locator<UserDataProvider>();

    final conn = await SqlConnection.insertValueParams();
    const query = "SELECT CUST_THUMB FROM ps_info_video WHERE CUST_USERNAME = :username";
    
    final params = {'username': userData.username};
    final getThumbBytesQue = await conn.execute(query, params);

    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;

  }

}