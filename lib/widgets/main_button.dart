import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final int? minusWidth;

  const MainButton({
    super.key, 
    required this.text,
    required this.onPressed,
    this.minusWidth,
  });

  @override 
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: minusWidth != null ? MediaQuery.of(context).size.width-minusWidth! : MediaQuery.of(context).size.width-45,
      child: ElevatedButton(
        style: GlobalsStyle.btnMainStyle,
        onPressed: onPressed,
        child: Text(
          text,
          style: GlobalsStyle.btnPageTextStyle,
        ),
      ),
    );
  }

}