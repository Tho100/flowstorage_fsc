import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class Delete {

  Future<void> deletionParams({
    required String? username, 
    required String? fileName, 
    required String? tableName,
    }) async {
    
    late final String query;
    late final Map<String,String> params;
    final crud = Crud();

    if(Globals.fileOrigin == "homeFiles") {
      query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (Globals.fileOrigin == "sharedToMe") {
      query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (Globals.fileOrigin == "sharedFiles") {
      query = "DELETE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (Globals.fileOrigin == "folderFiles") {
      query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'foldtitle': EncryptionClass().Encrypt(Globals.folderTitleValue),'filename': fileName!};
    } else if (Globals.fileOrigin == "dirFiles") {
      query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'dirname': EncryptionClass().Encrypt(Globals.directoryTitleValue),'filename': fileName!};
    }

    await crud.delete(query: query, params: params);

  }
}