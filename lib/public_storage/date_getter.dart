import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetterPs {

  String formatDate(String dateString) {
    final originalFormat = DateFormat('dd/MM/yyyy');
    final newFormat = DateFormat('MMM d yyyy');
    final date = originalFormat.parse(dateString);
    return newFormat.format(date);
  }

  Future<List<String>> getDateParams(MySQLConnectionPool conn, String tableName) async {
    
    final selectUploadDate = "SELECT UPLOAD_DATE FROM $tableName";
    final retrieveUploadDate = await conn.execute(selectUploadDate);

    final storeDateValues = <String>[];
    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final dateValueWithDashes = dateValue.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);
      storeDateValues.add('$difference days ago, $formattedDate');

    }
    
    return storeDateValues;

  }

}