import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class RenameDirectory {

  static Future<void> renameDirectory(String oldDirectoryName,String newDirectoryName) async {

    final encryption = EncryptionClass();
    final crud = Crud();

    const List<String> updateDirectoryQueries = [
      "UPDATE file_info_directory SET DIR_NAME = :newname WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "UPDATE upload_info_directory SET DIR_NAME = :newname WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = [
      {'newname': encryption.encrypt(newDirectoryName), 'dirname': encryption.encrypt(oldDirectoryName),'username': Globals.custUsername},
    ];

    for(int i=0; i<updateDirectoryQueries.length; i++) {

      final query = updateDirectoryQueries[i];
      final param = params[0];

      await crud.update(query: query, params: param);

    }

  }
}