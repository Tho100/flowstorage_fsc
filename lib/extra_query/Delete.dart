import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class Delete {

  Future<void> deletionParams({
  required String? username, 
  required String? fileName, 
  required String? tableName,
  }) async {

    final tempData = GetIt.instance<TempDataProvider>();
    
    late final String query;
    late final Map<String,String> params;
    final crud = Crud();

    if(tempData.fileOrigin == "homeFiles") {
      query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (tempData.fileOrigin == "sharedToMe") {
      query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (tempData.fileOrigin == "sharedFiles") {
      query = "DELETE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'filename': fileName!};
    } else if (tempData.fileOrigin == "folderFiles") {
      query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'foldtitle': EncryptionClass().encrypt(tempData.folderName),'filename': fileName!};
    } else if (tempData.fileOrigin == "dirFiles") {
      query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
      params = {'username': username!, 'dirname': EncryptionClass().encrypt(tempData.directoryName),'filename': fileName!};
    }

    await crud.delete(query: query, params: params);

  }
}