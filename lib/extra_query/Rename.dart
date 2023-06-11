import 'package:flowstorage_fsc/Encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/Globals.dart';

class Rename {

  Future<void> renameParams(String? oldFileName, String? newFileName, String? tableName,{String? username}) async {

    final encryptionClass = EncryptionClass();
    final crud = Crud();
    
    late final String query;
    late final Map<String,String> params;
    
    if(Globals.fileOrigin == "homeFiles") {

      String updateFileNameQuery = "UPDATE $tableName SET CUST_FILE_PATH = :newName WHERE CUST_FILE_PATH = :oldName AND CUST_USERNAME = :username";
      query = updateFileNameQuery;
      params = {
        'newName': encryptionClass.Encrypt(newFileName!),
        'oldName': encryptionClass.Encrypt(oldFileName!),
        'username': Globals.custUsername,
      };

    } else if (Globals.fileOrigin == "sharedFiles") {

      const updateFileNameQuery = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_FROM = :username";
      query = updateFileNameQuery;
      params = {
        'username': username!,
        'newname': encryptionClass.Encrypt(newFileName),
        'oldname': encryptionClass.Encrypt(oldFileName),
      };

    } else if (Globals.fileOrigin == "sharedToMe") {

      const updateFileNameQuery = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_TO = :username";
      query = updateFileNameQuery;
      params = {
        'username': username!,
        'newname': encryptionClass.Encrypt(newFileName),
        'oldname': encryptionClass.Encrypt(oldFileName),
      };

    } else if (Globals.fileOrigin == "folderFiles") {

      const updateFileNameQuery = "UPDATE folder_upload_info SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle";
      query = updateFileNameQuery;
      params =  {
        'username': Globals.custUsername,
        'newname': encryptionClass.Encrypt(newFileName),
        'oldname': encryptionClass.Encrypt(oldFileName),
        'foldtitle': encryptionClass.Encrypt(Globals.folderTitleValue),
      };

    } else if (Globals.fileOrigin == "dirFiles") {

      const updateFileNameQuery = "UPDATE upload_info_directory SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND DIR_NAME = :dirname";
      query = updateFileNameQuery;
      params =  {
        'username': Globals.custUsername,
        'newname': encryptionClass.Encrypt(newFileName),
        'oldname': encryptionClass.Encrypt(oldFileName),
        'dirname': encryptionClass.Encrypt(Globals.directoryTitleValue),
      };

    }

    await crud.update(query: query, params: params);
   
  }
}