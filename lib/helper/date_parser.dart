import 'package:intl/intl.dart';

class DateParser {

    DateTime parseDate(String dateString) {

    DateTime now = DateTime.now();

    if(dateString == "Directory") {
      return now;
    }
    
    if (dateString.contains('days ago')) {

      int daysAgo = int.parse(dateString.split(' ')[0]);
      
      return now.subtract(Duration(days: daysAgo));

    } else {
      return DateFormat('MMM dd yyyy').parse(dateString);
    }
    
  }
  
}