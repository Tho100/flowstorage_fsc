import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class DeleteDirectory {

  static Future<void> deleteDirectory({required String? directoryName}) async {

    final encryption = EncryptionClass();
    final crud = Crud();

    const List<String> deleteDirectoryQueries = [
      "DELETE FROM file_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = [
      {'dirname': encryption.encrypt(directoryName),'username': Globals.custUsername},
      {'dirname': encryption.encrypt(directoryName),'username': Globals.custUsername}
    ];

    for(int i=0; i<deleteDirectoryQueries.length; i++) {

      final query = deleteDirectoryQueries[i];
      final param = params[i];

      await crud.delete(
        query: query, 
        params: param
      );

    }

  }
}