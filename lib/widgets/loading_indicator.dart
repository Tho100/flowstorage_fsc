import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class LoadingFile {
  
  static Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
      ),
    );
  }
}