import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetterPs {

  final _locator = GetIt.instance;

  String formatDate(String dateString) {
    final originalFormat = DateFormat('dd/MM/yyyy');
    final newFormat = DateFormat('MMM d yyyy');
    final date = originalFormat.parse(dateString);
    return newFormat.format(date);
  }

  Future<List<String>> myGetDateParams(MySQLConnectionPool conn, String tableName) async {
    
    final userData = _locator<UserDataProvider>();

    final selectUploadDate = "SELECT UPLOAD_DATE, CUST_TAG FROM $tableName WHERE CUST_USERNAME = :username";

    final params = {'username': userData.username};
    final retrieveUploadDate = await conn.execute(selectUploadDate,params);

    final storeDateValues = <String>[];

    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final tagValue = res.assoc()['CUST_TAG']!;

      final dateValueWithDashes = dateValue.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);

      storeDateValues.add('$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate ${GlobalsStyle.dotSeperator} $tagValue');

    }

    return storeDateValues;

  }

  Future<List<String>> getDateParams(MySQLConnectionPool conn, String tableName) async {
    
    final selectUploadDate = 'SELECT UPLOAD_DATE, CUST_TAG FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    final retrieveUploadDate = await conn.execute(selectUploadDate);

    final storeDateValues = <String>[];

    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final tagValue = res.assoc()['CUST_TAG']!;

      final dateValueWithDashes = dateValue.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);

      storeDateValues.add('$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate ${GlobalsStyle.dotSeperator} $tagValue');

    }

    return storeDateValues;

  }

}