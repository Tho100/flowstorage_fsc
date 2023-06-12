import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/Globals.dart';

class DeleteDirectory {

  static Future<void> deleteDirectory({required String? directoryName}) async {

    final encryptionClass = EncryptionClass();
    final crud = Crud();

    const List<String> deleteDirectoryQueries = [
      "DELETE FROM file_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = [
      {'dirname': encryptionClass.Encrypt(directoryName),'username': Globals.custUsername},
      {'dirname': encryptionClass.Encrypt(directoryName),'username': Globals.custUsername}
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