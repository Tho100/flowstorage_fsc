import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:logger/logger.dart';

class DirectoryClass {

  final logger = Logger();
  final encryption = EncryptionClass();

  Future<void> createDirectory(String? directoryName,String? username) async {
    
    try {

      final conn = await SqlConnection.insertValueParams();

      const query = "INSERT INTO file_info_directory(DIR_NAME,CUST_USERNAME) VALUES (:dirname,:username)";
      final params = {'dirname': encryption.encrypt(directoryName),'username': username};

      await conn.execute(query,params);

    } catch (err, st) {
      logger.e("Exception from createDirectory {create_directory}",err, st);
    }
  }

}