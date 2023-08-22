import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class Rename {

  final _locator = GetIt.instance;

  Future<void> renameParams(String? oldFileName, String? newFileName, String? tableName,{String? username}) async {

    final userData = _locator<UserDataProvider>();
    final tempData = _locator<TempDataProvider>();

    final encryption = EncryptionClass();
    final crud = Crud();
    
    late final String query;
    late final Map<String,String> params;
    
    if(tempData.fileOrigin == "homeFiles") {

      String updateFileNameQuery = "UPDATE $tableName SET CUST_FILE_PATH = :newName WHERE CUST_FILE_PATH = :oldName AND CUST_USERNAME = :username";
      query = updateFileNameQuery;
      params = {
        'newName': encryption.encrypt(newFileName!),
        'oldName': encryption.encrypt(oldFileName!),
        'username': userData.username,
      };

    } else if (tempData.fileOrigin == "sharedFiles") {

      const updateFileNameQuery = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_FROM = :username";
      query = updateFileNameQuery;
      params = {
        'username': username!,
        'newname': encryption.encrypt(newFileName),
        'oldname': encryption.encrypt(oldFileName),
      };

    } else if (tempData.fileOrigin == "sharedToMe") {

      const updateFileNameQuery = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_TO = :username";
      query = updateFileNameQuery;
      params = {
        'username': username!,
        'newname': encryption.encrypt(newFileName),
        'oldname': encryption.encrypt(oldFileName),
      };

    } else if (tempData.fileOrigin == "folderFiles") {

      const updateFileNameQuery = "UPDATE folder_upload_info SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle";
      query = updateFileNameQuery;
      params =  {
        'username': userData.username,
        'newname': encryption.encrypt(newFileName),
        'oldname': encryption.encrypt(oldFileName),
        'foldtitle': encryption.encrypt(tempData.folderName),
      };

    } else if (tempData.fileOrigin == "dirFiles") {

      const updateFileNameQuery = "UPDATE upload_info_directory SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND DIR_NAME = :dirname";
      query = updateFileNameQuery;
      params =  {
        'username': userData.username,
        'newname': encryption.encrypt(newFileName),
        'oldname': encryption.encrypt(oldFileName),
        'dirname': encryption.encrypt(tempData.directoryName),
      };

    }

    await crud.update(query: query, params: params);
   
  }
}