import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class MultipleTextLoading {

  late String title;
  late String subText;
  late BuildContext context;
  
  Future<void> startLoading({
    required String title,
    required String subText,
    required BuildContext context
  }) {

    this.title = title;
    this.subText = subText;
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
      content: SizedBox(
        width: 325,
        height: 78,
        child: Column(

          children: [
            Row(
              children: [
                const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(color: color),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(

              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    subText,
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: ThemeColor.darkRed,
            ),
          ),
        ),
      ],
    );

  }

}