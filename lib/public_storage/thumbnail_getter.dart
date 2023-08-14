import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class ThumbnailGetterPs {

  Future<List<Uint8List>> retrieveParams() async {

    final conn = await SqlConnection.insertValueParams();
    const query = "SELECT CUST_THUMB FROM ps_info_video";
    
    final getThumbBytesQue = await conn.execute(query);
    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;

  }

  Future<List<Uint8List>> myRetrieveParams() async {

    final conn = await SqlConnection.insertValueParams();
    const query = "SELECT CUST_THUMB FROM ps_info_video WHERE CUST_USERNAME = :username";
    
    final params = {'username': Globals.custUsername};
    final getThumbBytesQue = await conn.execute(query, params);

    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;

  }

}