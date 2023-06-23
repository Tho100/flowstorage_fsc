import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:mysql_client/mysql_client.dart';

class NameGetterPs {

  static final _encryptionClass = EncryptionClass();

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    final query = 'SELECT CUST_FILE_PATH FROM $tableName';

    try {   

      final retrieveNames = await conn.execute(query);
      final nameSet = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_FILE_PATH'];
        nameSet.add(_encryptionClass.Decrypt(getNameValues));
      }

      return nameSet.toList();

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }

}