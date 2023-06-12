import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

/// <summary>
/// 
/// Class to retrieve user encrypted files names
/// and decrypt them later for user to see
/// 
/// </summary>

class NameGetter {

  static final _encryptionClass = EncryptionClass();

  Future<List<String>> retrieveParams(String custUsername, String tableName) async {

    final conn = await SqlConnection.insertValueParams();

    final query = tableName != 'file_info_directory'
        ? 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username'
        : 'SELECT DIR_NAME FROM file_info_directory WHERE CUST_USERNAME = :username';

    final params = {'username': custUsername};

    try {   

      final retrieveNames = await conn.execute(query, params);
      final nameSet = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = row.assoc()['CUST_FILE_PATH'] ?? row.assoc()['DIR_NAME'];
        nameSet.add(_encryptionClass.Decrypt(getNameValues));
      }

      return nameSet.toList();

    } catch (failedLoadNames) {
      return <String>[];
    } 
  }
}
