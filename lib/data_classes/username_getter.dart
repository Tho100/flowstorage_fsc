import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

class UsernameGetter {

  Future<List<String?>> retrieveParams(String? custEmail) async {

    final conn = await SqlConnection.insertValueParams();

    const retrieveCase1 =
        "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    const retrieveCase2 =
        "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': custEmail};


    final results = await Future.wait([
      conn.execute(retrieveCase1, params),
      conn.execute(retrieveCase2, params),
    ]);

    return results
        .expand((result) => result.rows.map((row) => row.assoc().values.first))
        .toList();
  }
}