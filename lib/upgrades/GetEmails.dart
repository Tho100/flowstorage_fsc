import 'dart:convert';
import 'package:http/http.dart' as http;

class GetEmails {

  static Future<List<dynamic>> getEmails() async {

    const apiKey = 'sk_test_51MO4YYF2lxRV33xsBfTJLQypyLBjhoxYdz18VoLrZZ6hin4eJrAV9O6NzduqR02vosmC4INFgBgxD5TkrkpM3sZs00hqhx3ZzN';
    const url = 'https://api.stripe.com/v1/customers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'];
      final List emails = data.map((customer) => customer['email']).toList();

      return emails;

    } else {
      throw Exception('Failed to retrieve customer emails');
    }
    
  }
}