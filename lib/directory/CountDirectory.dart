import 'package:flowstorage_fsc/extra_query/crud.dart';

class CountDirectory {

  static Future<int> countTotalDirectory(String username) async {

    final crud = Crud();
    const countDirectory = "SELECT COUNT(*) FROM file_info_directory WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final directoryRowsCount = await crud.count(
      query: countDirectory, 
      params: params
    );

    return directoryRowsCount;
  }
}