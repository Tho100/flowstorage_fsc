import 'package:flowstorage_fsc/connection/ClusterFsc.dart';
import 'package:flowstorage_fsc/navigator/NavigatePage.dart';

import 'package:flutter/material.dart';

/// <summary>
/// 
/// Class to retrieve user encrypted 
/// email address
/// 
/// </summary>

class EmailGetter {

  Future<String> retrieveParams(String? custUsername,{BuildContext? context}) async {
    
    try {

      final conn = await SqlConnection.insertValueParams();

      const retrieveCase0 = "SELECT CUST_EMAIL FROM information WHERE CUST_USERNAME = :username";
      final params = {'username': custUsername};

      final executeCase0 = await conn.execute(retrieveCase0,params);
      String? emailDetected;

      for(final rowsOfUser in executeCase0.rows) {
        emailDetected = rowsOfUser.assoc()['CUST_EMAIL']!;
      }
      return emailDetected!;

    } catch (err) {
      NavigatePage.permanentPageMainboard(context!);
      return "";
    }
  
  }
}