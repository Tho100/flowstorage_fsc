import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

/// <summary>
/// 
/// Class to retrieve user folders
/// 
/// </summary>

class FolderRetrieve {

  final _encryptionClass = EncryptionClass();

  Future<List<String>> retrieveParams(String? custUsername) async {

    final conn = await SqlConnection.insertValueParams();

    const query = 'SELECT FOLDER_TITLE FROM folder_upload_info WHERE CUST_USERNAME = :username';
    final params = {'username': custUsername};

    try {

      final retrieveNames = await conn.execute(query, params);
      final fileNameList = <String>{};

      for (final row in retrieveNames.rows) {
        final getNameValues = _encryptionClass.Decrypt(row.assoc()['FOLDER_TITLE']!);
        fileNameList.add(getNameValues);
      }

      return fileNameList.toList();

    } catch (failedLoadNames) {
      return <String>[];
    } finally {
      custUsername = null;
    }
  }
}