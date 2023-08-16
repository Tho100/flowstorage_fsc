import 'package:mysql_client/mysql_client.dart';

class UploaderGetterPs {

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_USERNAME FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

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