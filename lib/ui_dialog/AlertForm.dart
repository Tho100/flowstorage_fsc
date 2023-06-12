import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class AlertForm {

  static Future alertDialog(String messages, BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          content: Text(messages,
            style: const TextStyle(
              color: Colors.white
            )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK',
                style: TextStyle(
                  color: Colors.white
                )),
            ),
          ],
        );
      },
    );
  }

  static Future alertDialogTitle(String title, String messages, BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          title: Text(title,
            style: const TextStyle(
              color: Colors.white
          )),
          content: Text(messages,
            style: const TextStyle(
              color: Colors.white
            )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK',
                style: TextStyle(
                  color: Colors.white
                )),
            ),
          ],
        );
      },
    );
  }

}