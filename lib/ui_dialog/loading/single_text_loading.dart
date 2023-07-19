import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class SingleTextLoading {

  late String title;
  late BuildContext context;
  
  Future<void> startLoading({
    required String title,
    required BuildContext context
  }) {

    this.title = title;
    this.context = context;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => buildLoadingDialog(context),
    );
  }

  void stopLoading() {
    Navigator.pop(context);
  }

  AlertDialog buildLoadingDialog(BuildContext context) {
    
    const backgroundColor = ThemeColor.darkGrey;
    const color = ThemeColor.darkPurple;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: color),
            ),
            const SizedBox(width: 30),
            Text(title,
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontSize: 18,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          ]
        ),
      
    );
  }

}