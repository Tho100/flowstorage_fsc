import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class UpgradeDialog {
  
  static Future buildUpgradeDialog({
    required String message,
    required BuildContext context
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkGrey,
          title: const Text('Upgrade Account',
          style: TextStyle(
              color: Colors.white
          )),
          content: Text(message,
            style: const TextStyle(
              color: Colors.white,
            )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK',
                style: TextStyle(
                  color: Colors.white,
                )),
            ),

            TextButton(
              onPressed: () async {

                Navigator.pop(context);
                NavigatePage.goToPageUpgrade(context);

              },
              child: const Text('Upgrade',
                style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
            ),

          ],
        );
      },
    );
  }
}