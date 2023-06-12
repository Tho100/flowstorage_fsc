import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class JustLoading {
  
  late BuildContext context;

  Future<void> startLoading({required BuildContext context}) {
    
    this.context = context;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => buildLoadingDialog(),
    );
  }

  void stopLoading() {
    Navigator.pop(context);
  }

  AlertDialog buildLoadingDialog() {
    
    const backgroundColor = ThemeColor.darkGrey;
    const color = ThemeColor.darkPurple;

    return const AlertDialog(
      backgroundColor: backgroundColor,
      content: SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: color),
        ),
      ),
    );
  }
}