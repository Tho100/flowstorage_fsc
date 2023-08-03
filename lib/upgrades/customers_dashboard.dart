import 'dart:convert';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class StripeCustomers {

  static Future<String> getCustomerIdByEmail(String email) async {

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

      for (var customer in data) {
        if (customer['email'] == email) {
          return customer['id'];
        }
      }

      return '';
      
    } else {
      throw Exception('Failed to retrieve customer emails');
    }
  }

  static Future<List<dynamic>> getCustomersEmails(String customEmail) async {

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

      if(customEmail != "") {
        final filteredEmails = emails.where((email) => email == customEmail).toList();
        return filteredEmails;
      }

      return emails;

    } else {
      throw Exception('Failed to retrieve customer emails');
    }
    
  }

  static Future<List<dynamic>> getCustomerSubscriptionsByEmail(String email) async {

    const apiKey = 'sk_test_51MO4YYF2lxRV33xsBfTJLQypyLBjhoxYdz18VoLrZZ6hin4eJrAV9O6NzduqR02vosmC4INFgBgxD5TkrkpM3sZs00hqhx3ZzN';
    
    final url = Uri.https('api.stripe.com', '/v1/customers', {'email': email});
    final headers = {
      'Authorization': 'Bearer $apiKey',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final customerData = jsonData['data'] as List<dynamic>;
      if (customerData.isNotEmpty) {
        final customer = customerData.first;
        final customerId = customer['id'];
        final subscriptionsUrl = Uri.https('api.stripe.com', '/v1/customers/$customerId/subscriptions');
        final subscriptionsResponse = await http.get(subscriptionsUrl, headers: headers);

        if (subscriptionsResponse.statusCode == 200) {
          final subscriptionsData = jsonDecode(subscriptionsResponse.body);
          final List<dynamic> subscriptions = subscriptionsData['data'] as List<dynamic>;
          return subscriptions;
        } else {
          throw Exception('Failed to fetch customer subscriptions: ${subscriptionsResponse.body}');
        }
      } else {
        throw Exception('No customer found for the given email.');
      }
    } else {
      throw Exception('Failed to retrieve customer data: ${response.body}');
    }
  }

  static Future<void> cancelCustomerSubscriptionByEmail(String email) async {

    const apiKey = 'sk_test_51MO4YYF2lxRV33xsBfTJLQypyLBjhoxYdz18VoLrZZ6hin4eJrAV9O6NzduqR02vosmC4INFgBgxD5TkrkpM3sZs00hqhx3ZzN';
    
    final subscriptions = await getCustomerSubscriptionsByEmail(email);

    if (subscriptions.isNotEmpty) {
      
      final subscriptionId = subscriptions[0]['id'];

      final cancelUrl = Uri.https('api.stripe.com', '/v1/subscriptions/$subscriptionId');
      final headers = {
        'Authorization': 'Bearer $apiKey',
      };

      final cancelData = {
        'cancel_at_period_end': true,
      };
      
      final cancelResponse = await http.delete(cancelUrl, headers: headers, body: jsonEncode(cancelData));
      
      if (cancelResponse.statusCode == 200) {
        Globals.accountType = "Basic";
      } else {
        return;
      }
    } else {
      return;
    }
  
  }

  static Future<void> deleteEmailByEmail(String email) async {
    final customerId = await getCustomerIdByEmail(email);
    await deleteEmail(customerId);
  }

  static Future<void> deleteEmail(String customerId) async {
    const apiKey = 'sk_test_51MO4YYF2lxRV33xsBfTJLQypyLBjhoxYdz18VoLrZZ6hin4eJrAV9O6NzduqR02vosmC4INFgBgxD5TkrkpM3sZs00hqhx3ZzN';
    final url = 'https://api.stripe.com/v1/customers/$customerId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      Logger().i('Email deleted successfully.');
    } else {
      Logger().i('Failed to delete email');
    }

  }

}