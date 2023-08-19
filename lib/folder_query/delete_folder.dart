import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class DeleteFolder {

  final _locator = GetIt.instance;

  Future<void> deletionParams({required folderName}) async {

    final userData = _locator<UserDataProvider>();

    final crud = Crud();
    const deleteFolderQuery = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle";
    final params = {'username': userData.username, 'foldtitle': EncryptionClass().encrypt(folderName)};

    await crud.delete(
      query: deleteFolderQuery, 
      params: params
    );

  }
}