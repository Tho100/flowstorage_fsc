import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class SharingName {
  
  /// <summary>
  /// 
  /// Start building widgets that will be shown on the bottom
  /// of the screen while previewing files like Comments and 
  /// _buildBottomButtons()
  /// 
  /// </summary>

  Future<String> shareToOtherName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_TO FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName)};
    final results = await connection.execute(query,params);

    String? sharedToName;
    for(final row in results.rows) {
      sharedToName = row.assoc()['CUST_TO'];
    }

    return sharedToName!;
    
  }

  /// <summary>
  /// 
  /// Retrieve username of the user that shared a file
  /// 
  /// </summary>
  /// 
  Future<String> sharerName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_FROM FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName)};
    final results = await connection.execute(query,params);

    String? sharedToMeName;
    for(final row in results.rows) {
      sharedToMeName = row.assoc()['CUST_FROM'];
    }

    return sharedToMeName!;
    
  }
}