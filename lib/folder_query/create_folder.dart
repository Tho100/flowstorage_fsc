
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:intl/intl.dart';

class CreateFolder {

  final encryption = EncryptionClass();
  final dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now()); 

  Future<void> insertParams(
    String titleFolder,
    List<String> fileValues,
    List<String> fileNames,
    List<String> fileTypes,
    {List<dynamic>? videoThumbnail}
  ) async {

    final conn = await SqlConnection.insertValueParams();

    const query = 
    "INSERT INTO folder_upload_info VALUES (:folder_name,:username,:file_data,:file_type,:upload_date,:file_name,:thumbnail)";

    final encryptedFolderName = encryption.encrypt(titleFolder);

    for (int i = 0; i < fileNames.length; i++) {

      final params = {
        'folder_name': encryptedFolderName, 
        'username': Globals.custUsername, 
        'file_data': encryption.encrypt(fileValues[i]),
        'file_type': fileTypes[i],
        'upload_date': dateNow,
        'file_name': encryption.encrypt(fileNames[i]),
        'thumbnail': videoThumbnail != null && videoThumbnail.length > i
              ? videoThumbnail[i]
              : '0'
      };

      await conn.execute(query, params);
      
    }
  }
}
