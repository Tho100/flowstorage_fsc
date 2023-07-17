import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class SnakeAlert {

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorSnake(String message, BuildContext context) {

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row( 
          children: [
            const Icon(Icons.close,color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: ThemeColor.darkRed,
      )
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> okSnake({
    required String message,
    IconData? icon,
    required BuildContext context,
  }) {
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (icon != null) const SizedBox(width: 10),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: ThemeColor.mediumGrey,
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> uploadingSnake({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
      SnackBar(
        backgroundColor: ThemeColor.mediumGrey,
        content: Row(
          children: [
            Text(message), 
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Cancel upload operation
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> temporarySnake({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: ThemeColor.mediumGrey,
      )
    );
  }

}