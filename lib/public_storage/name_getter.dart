import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:mysql_client/mysql_client.dart';

class NameGetterPs {

  static final encryption = EncryptionClass();

  Future<List<String>> myRetrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username';

      final params = {'username': Globals.custUsername};
      final retrieveNames = await conn.execute(query, params);

      final nameSet = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_FILE_PATH'];
        nameSet.add(encryption.decrypt(getNameValues));
      }

      return nameSet.toList();  

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_FILE_PATH FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

      final retrieveNames = await conn.execute(query);
      final nameSet = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_FILE_PATH'];
        nameSet.add(encryption.decrypt(getNameValues));
      }

      return nameSet.toList();  

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }

}