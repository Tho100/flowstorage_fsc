import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class DeleteDirectory {

  static final _locator = GetIt.instance;

  static Future<void> deleteDirectory({required String? directoryName}) async {

    final userData = _locator<UserDataProvider>();

    final encryption = EncryptionClass();
    final crud = Crud();

    const List<String> deleteDirectoryQueries = [
      "DELETE FROM file_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = [
      {'dirname': encryption.encrypt(directoryName),'username': userData.username},
      {'dirname': encryption.encrypt(directoryName),'username': userData.username}
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