import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

class Verification {

  Future<bool> notEqual(String getUsername,String getAuthString,String columnName) async {

    final conn = await SqlConnection.insertValueParams();

    final que = "SELECT $columnName FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': getUsername};
    final result = await conn.execute(que,params);
    
    String? authString = '';
    for(final row in result.rows) {
      final getAuthRows = columnName == "CUST_PASSWORD" ? row.assoc()['CUST_PASSWORD'] : row.assoc()['CUST_PIN'];
      authString = getAuthRows;
    }
    
    return authString != getAuthString;
  }

}