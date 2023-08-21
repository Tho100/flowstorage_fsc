import 'package:flutter/material.dart';

class PsUploadDataProvider extends ChangeNotifier {
  
  String _psCommentValue = '';
  String _psTagValue = '';

  String get psCommentValue => _psCommentValue;
  String get psTagValue => _psTagValue;

  void setCommentValue(String value) {
    _psCommentValue = value;
    notifyListeners();
  }

    void setTagValue(String value) {
    _psTagValue = value;
    notifyListeners();
  }

}