import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class MainTextField extends StatelessWidget {

  final String hintText;
  final TextEditingController controller;

  const MainTextField({
    super.key,
    required this.hintText,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 2.0, color: ThemeColor.darkBlack),
      ),
      child: TextFormField(
        cursorWidth: 3,
        style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
        enabled: true,
        controller: controller,
        decoration: GlobalsStyle.setupTextFieldDecoration(hintText),
      ),
    );
  }

}