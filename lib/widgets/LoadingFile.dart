import 'package:flowstorage_fsc/themes/ThemeColor.dart';
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