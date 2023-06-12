import 'package:flowstorage_fsc/Connection/ClusterFsc.dart';

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

    try {

      final results = await conn.execute(retrieveCase,params);

      String? accountType = '';
      for(final row in results.rows) {
        accountType = row.assoc()['ACC_TYPE'];
      }

      return accountType!;

    } finally  {
      email = null;
    }

  }
}