
import 'package:flowstorage_fsc/Connection/ClusterFsc.dart';
import 'package:flowstorage_fsc/Encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:intl/intl.dart';

/// <summary>
/// 
/// Class to insert folder values
/// 
/// </summary>

class CreateFolder {

  final encryptionClass = EncryptionClass();
  final uploadDate = DateFormat('dd/MM/yyyy').format(DateTime.now()); 

  Future<void> insertParams(
    String titleFolder,
    List<String> fileValues,
    List<String> fileNames,
    List<String> fileTypes,
    {List<dynamic>? videoThumbnail}
  ) async {

    final conn = await SqlConnection.insertValueParams();

    const query = "INSERT INTO folder_upload_info VALUES (:fold_title,:username,:file,:type,:date,:filename,:thumbnail)";

    for (int i = 0; i < fileNames.length; i++) {

      final params = {
        'fold_title': encryptionClass.Encrypt(titleFolder), 
        'username': Globals.custUsername, 
        'file': encryptionClass.Encrypt(fileValues[i]),
        'type': fileTypes[i],
        'date': uploadDate,
        'filename': encryptionClass.Encrypt(fileNames[i]),
        'thumbnail': videoThumbnail != null && videoThumbnail.length > i
                    ? videoThumbnail[i]
                    : 'n0'
      };

      await conn.execute(query, params);
      
    }
  }
}
