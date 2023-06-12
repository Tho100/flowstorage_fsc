import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class FailedLoad {
  
  static Widget buildFailedLoad() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 25),
            Text(
            'An error occurred',
              style: TextStyle(
                color: ThemeColor.darkPurple,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
    
            SizedBox(height: 10),
    
            Text(
            'Failed to load this file',
              style: TextStyle(
                color: Color.fromARGB(255, 195, 195, 195),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}