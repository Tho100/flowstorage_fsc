import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/public_storage/byte_getter.dart';
import 'package:flowstorage_fsc/public_storage/date_getter.dart';
import 'package:flowstorage_fsc/public_storage/name_getter.dart';

class PublicStorageDataRetriever {
  
  final nameGetter = NameGetterPs();
  final dateGetter = DateGetterPs();
  final byteGetter = ByteGetterPs();

  final dataSet = <Map<String, dynamic>>[];

  Future<List<Map<String, dynamic>>> retrieveParams() async {

    final conn = await SqlConnection.insertValueParams();
    const tablesToCheck = Globals.tableNamesPs;

    final futures = tablesToCheck.map((table) async {

      final fileNames = await nameGetter.retrieveParams(conn, table);
      final bytes = await byteGetter.getLeadingParams(conn, table);
      final dates = await dateGetter.getDateParams(conn, table);

      return {
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