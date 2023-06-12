import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class RenameFolder {

  Future<void> renameParams({
    required String? oldFolderTitle, 
    required String? newFolderTitle
    }) async {

    const updateFolderName = "UPDATE folder_upload_info SET FOLDER_TITLE = :newname WHERE FOLDER_TITLE = :oldname AND CUST_USERNAME = :username";

    final Map<String,String> params = 
    {
      'username': Globals.custUsername,
      'newname': EncryptionClass().Encrypt(newFolderTitle),
      'oldname': EncryptionClass().Encrypt(oldFolderTitle),
    };

    await Crud().update(
      query: updateFolderName, 
      params: params
    );
    
  }
}