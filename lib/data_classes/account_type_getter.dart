import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

/// <summary>
/// 
/// Class to retrieve the user basic account information 
/// 
/// Username
/// Account Type
/// 
/// </summary>

class MySqlAccType {

  Future<String> retrieveParams(String? email) async {

    final conn = await SqlConnection.insertValueParams();

    const retrieveCase =
        "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': email};

    final results = await conn.execute(retrieveCase,params);

    String? accountType = '';
    for(final row in results.rows) {
      accountType = row.assoc()['ACC_TYPE'];
    }

    return accountType!;

  }
}