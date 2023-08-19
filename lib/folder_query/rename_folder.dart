import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class RenameFolder {

  final _locator = GetIt.instance;

  Future<void> renameParams({
    required String? oldFolderTitle, 
    required String? newFolderTitle
    }) async {

    final userData = _locator<UserDataProvider>();

    const updateFolderName = "UPDATE folder_upload_info SET FOLDER_TITLE = :newname WHERE FOLDER_TITLE = :oldname AND CUST_USERNAME = :username";

    final Map<String,String> params = 
    {
      'username': userData.username,
      'newname': EncryptionClass().encrypt(newFolderTitle),
      'oldname': EncryptionClass().encrypt(oldFolderTitle),
    };

    await Crud().update(
      query: updateFolderName, 
      params: params
    );
    
  }
}