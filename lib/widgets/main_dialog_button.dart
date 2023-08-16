import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class MainDialogButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final bool isButtonClose;

  const MainDialogButton({
    super.key, 
    required this.text,
    required this.onPressed,
    required this.isButtonClose
  });

  Widget buildCloseButton() {
    return SizedBox(
      width: 85,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: ThemeColor.darkPurple,
              width: 2
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16, color: ThemeColor.darkPurple)
        ),
      ),
    );
  }

  Widget buildDefaultButton() {
    return SizedBox(
      width: 85,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: GlobalsStyle.btnMainStyle,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isButtonClose 
    ? buildCloseButton() : buildDefaultButton();
  }
}