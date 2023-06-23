import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals.dart';

class UploaderName {

  Future<String> getUploaderName({
    required String tableName,
    required Set fileValues
  }) async {

    final connection = await SqlConnection.insertValueParams();

    List<String> uploaderNameList = <String>[];

    final query = "SELECT CUST_USERNAME FROM $tableName";
    final results = await connection.execute(query);

    String? uploaderName;
    for(final row in results.rows) {
      uploaderName = row.assoc()['CUST_USERNAME'];
      uploaderNameList.add(uploaderName!);
    }

    return uploaderNameList[getUsernameIndex(fileValues)];
    
  }

  int getUsernameIndex(Set fileValues) {

    final getVideoFiles = Globals.fileValues.where((file) {
    for (var fileType in fileValues) {
      if (file.endsWith('.$fileType')) {
        return true;
      }
    }
    return false;
    }).toList();

    final usernameIndex = getVideoFiles.indexOf(Globals.selectedFileName);

    return usernameIndex;
  }

}