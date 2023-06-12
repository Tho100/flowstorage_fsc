import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

/// <summary>
/// 
/// Class to create user directory
/// 
/// </summary>

class DirectoryClass {

  final _encryptionClass = EncryptionClass();
  final now = DateTime.now();

  Future<void> createDirectory(String? directoryName,String? username) async {
    
    try {

      final conn = await SqlConnection.insertValueParams();

      const query = "INSERT INTO file_info_directory(DIR_NAME,CUST_USERNAME) VALUES (:dirname,:username)";
      final params = {'dirname': _encryptionClass.Encrypt(directoryName),'username': username};

      await conn.execute(query,params);

    } catch (err) {
      print("Exception from DirectoryCreate class: $err");
    }
  }

}