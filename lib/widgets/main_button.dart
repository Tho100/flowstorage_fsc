import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final int? minusWidth;
  final int? minusHeight;

  const MainButton({
    super.key, 
    required this.text,
    required this.onPressed,
    this.minusWidth,
    this.minusHeight
  });

  @override 
  Widget build(BuildContext context) {

    final mediaQuerySize = MediaQuery.of(context).size;

    return SizedBox(
      height: minusHeight != null ? mediaQuerySize.height-minusHeight! : 68,
      width: minusWidth != null ? mediaQuerySize.width-minusWidth! : MediaQuery.of(context).size.width-45,
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