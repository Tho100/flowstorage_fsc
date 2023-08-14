import 'package:flowstorage_fsc/global/globals.dart';
import 'package:mysql_client/mysql_client.dart';

class UploaderGetterPs {

  Future<List<String>> myRetrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_USERNAME FROM $tableName WHERE CUST_USERNAME = :username';

      final params = {'username': Globals.custUsername};
      final retrieveNames = await conn.execute(query,params);
      
      final nameSet = <String>[];

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_USERNAME']!;
        nameSet.add(getNameValues);
      }

      return nameSet.toList();  

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_USERNAME FROM $tableName';

      final retrieveNames = await conn.execute(query);
      final nameSet = <String>[];

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_USERNAME']!;
        nameSet.add(getNameValues);
      }

      return nameSet.toList();  

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }
}