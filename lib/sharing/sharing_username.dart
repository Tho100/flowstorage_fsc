import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class SharingName {

  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<String> shareToOtherName({required int usernameIndex}) async {

    final connection = await SqlConnection.insertValueParams();

    List<String> sharedToNameList = <String>[];

    const query = "SELECT CUST_TO FROM cust_sharing WHERE CUST_FROM = :from";
    final params = {'from': userData.username};
    final results = await connection.execute(query,params);

    String? sharedToName;
    for(final row in results.rows) {
      sharedToName = row.assoc()['CUST_TO'];
      sharedToNameList.add(sharedToName!);
    }

    return sharedToNameList[usernameIndex];
    
  }

  Future<String> sharerName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_FROM FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': userData.username, 'filename': EncryptionClass().encrypt(tempData.selectedFileName)};
    final results = await connection.execute(query,params);

    String? sharedToMeName;
    for(final row in results.rows) {
      sharedToMeName = row.assoc()['CUST_FROM'];
    }

    return sharedToMeName!;
    
  }
}