import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

class Crud {

  Future<void> processCud(
    String? query,
    Map<String,dynamic>? params
  ) async {
    final conn = await SqlConnection.insertValueParams();
    await conn.execute(query!,params!);
  }

  Future<void> insert({
    required String? query,
    required Map<String,dynamic>? params
  }) async {
    await processCud(query,params);
  }

  Future<void> update({
    required String? query,
    required Map<String,dynamic>? params
  }) async {
    await processCud(query,params);
  }

  Future<void> delete({
    required String? query,
    required Map<String,dynamic>? params
  }) async {
    await processCud(query,params);
  }

  Future<int> count({
    required String? query, 
    required Map<String,String>? params
  }) async {

    final conn = await SqlConnection.insertValueParams();
    final results = await conn.execute(query!,params!);

    int totalRow = 0;
    for(var row in results.rows) {
      totalRow = row.typedColAt<int>(0)!;
    }

    return totalRow;
  }

  Future<dynamic> select({
    required String? query,
    required String? returnedColumn,
    required Map<String,String>? params
  }) async {

    final conn = await SqlConnection.insertValueParams();
    final results = await conn.execute(query!,params!);

    for(final row in results.rows) {
      return row.assoc()[returnedColumn]!;
    }
  }

}