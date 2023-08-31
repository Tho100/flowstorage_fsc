import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class DeleteDialog {

  Future buildDeleteDialog({
    required String fileName,
    required VoidCallback onDeletePressed,
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
          title: Text(fileName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Delete this item? Action is permanent.',
            style: TextStyle(color: ThemeColor.secondaryWhite),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(context);
                onDeletePressed();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}