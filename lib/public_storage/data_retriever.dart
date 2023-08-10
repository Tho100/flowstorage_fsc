import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/public_storage/byte_getter.dart';
import 'package:flowstorage_fsc/public_storage/date_getter.dart';
import 'package:flowstorage_fsc/public_storage/name_getter.dart';
import 'package:flowstorage_fsc/public_storage/uploader_getter.dart';

class PublicStorageDataRetriever {
  
  final uploaderNameGetter = UploaderGetterPs();
  final nameGetter = NameGetterPs();
  final dateGetter = DateGetterPs();
  final byteGetter = ByteGetterPs();

  final dataSet = <Map<String, dynamic>>[];

  Future<List<Map<String, dynamic>>> retrieveParams() async {

    final conn = await SqlConnection.insertValueParams();
    const tablesToCheck = GlobalsTable.tableNamesPs;

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

    return dataSet;
  }
}