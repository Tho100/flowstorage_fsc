import 'dart:convert';
import 'dart:io';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class StripeCustomers {

  static final _locator = GetIt.instance;

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

  static Future<void> cancelCustomerSubscriptionByEmail(String email, BuildContext context) async {

    final userData = _locator<UserDataProvider>();

    final crud = Crud();

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
        
        await crud.update(
          query: "UPDATE cust_type SET ACC_TYPE = :type WHERE CUST_EMAIL = :email", 
          params: {"type": "Basic", "email": userData.email});

        await crud.delete(
          query: "DELETE FROM cust_buyer WHERE CUST_USERNAME = :username", 
          params: {"username": userData.username});


        userData.setAccountType("Basic");

        await deleteEmailByEmail(userData.email);
        await _updateLocallyStoredAccountType();

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

  static Future<void> _updateLocallyStoredAccountType() async {
      
    final userData = _locator<UserDataProvider>();

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);
    if (setupInfosDir.existsSync()) {
      setupInfosDir.deleteSync(recursive: true);
    }

    setupInfosDir.createSync();

    final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

    try {
      
      if (setupFiles.existsSync()) {
        setupFiles.deleteSync();
      }

      setupFiles.writeAsStringSync('${EncryptionClass().encrypt(userData.username)}\n${EncryptionClass().encrypt(userData.email)}\nBasic');

    } catch (e, st) {
      Logger().e(e, st);
    }
    
  }

}