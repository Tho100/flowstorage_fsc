import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage/byte_getter.dart';
import 'package:flowstorage_fsc/public_storage/date_getter.dart';
import 'package:flowstorage_fsc/public_storage/name_getter.dart';
import 'package:flowstorage_fsc/public_storage/uploader_getter.dart';
import 'package:get_it/get_it.dart';

class PublicStorageDataRetriever {
  
  final uploaderNameGetter = UploaderGetterPs();
  final nameGetter = NameGetterPs();
  final dateGetter = DateGetterPs();
  final byteGetter = ByteGetterPs();

  final dataSet = <Map<String, dynamic>>[];

  final _locator = GetIt.instance;

  Future<List<Map<String, dynamic>>> retrieveParams({
    required bool isFromMyPs
  }) async {

    final userData = _locator<UserDataProvider>();
    
    final conn = await SqlConnection.insertValueParams();
    const tablesToCheck = GlobalsTable.tableNamesPs;

    if(isFromMyPs) {

      final futures = tablesToCheck.map((table) async {

        final fileNames = await nameGetter.myRetrieveParams(conn, table);
        final bytes = await byteGetter.myGetLeadingParams(conn, table);
        final dates = await dateGetter.myGetDateParams(conn, table);

        final uploaderNameList = List<String>.generate(fileNames.length, (_) => userData.username);

        return {
          'uploader_name': uploaderNameList,
          'name': fileNames,
          'date': dates,
          'file_data': bytes,
        };
      }).toList();

      final results = await Future.wait(futures);

      for (final result in results) {
        dataSet.add(result);
      }

    } else {

      final futures = tablesToCheck.map((table) async {
        
        final uploaderName = await uploaderNameGetter.retrieveParams(conn, table);
        final fileNames = await nameGetter.retrieveParams(conn, table);
        final bytes = await byteGetter.getLeadingParams(conn, table);
        final dates = await dateGetter.getDateParams(conn, table);

        return {
          'uploader_name': uploaderName,
          'name': fileNames,
          'date': dates,
          'file_data': bytes,
        };
      }).toList();


      final results = await Future.wait(futures);

      for (final result in results) {
        dataSet.add(result);
      }

    }

    return dataSet;

  }
}