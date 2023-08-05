import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class DeleteFolder {

  Future<void> deletionParams() async {

    final crud = Crud();
    const deleteFolderQuery = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle";
    final params = {'username': Globals.custUsername, 'foldtitle': EncryptionClass().encrypt(Globals.folderTitleValue)};

    await crud.delete(
      query: deleteFolderQuery, 
      params: params
    );

  }
}