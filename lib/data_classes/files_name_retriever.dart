import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:mysql_client/mysql_client.dart';

class NameGetter {

  static final encryption = EncryptionClass();

  Future<List<String>> retrieveParams(MySQLConnectionPool conn,String custUsername, String tableName) async {

    try {

      final query = tableName != GlobalsTable.directoryInfoTable
        ? 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username'
        : 'SELECT DIR_NAME FROM file_info_directory WHERE CUST_USERNAME = :username';

      final params = {'username': custUsername};

      final retrieveNames = await conn.execute(query, params);
      final nameSet = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_FILE_PATH'] ?? row.assoc()['DIR_NAME'];
        nameSet.add(encryption.decrypt(getNameValues));
      }

      return nameSet.toList();

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }
}
