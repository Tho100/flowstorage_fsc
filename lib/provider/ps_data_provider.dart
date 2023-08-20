import 'package:flutter/material.dart';

class PsUploadDataProvider extends ChangeNotifier {
  
  bool _psUploadPassed = false;
  String _psCommentValue = '';
  String _psTagValue = '';

  bool get psUploadPassed => _psUploadPassed;
  String get psCommentValue => _psCommentValue;
  String get psTagValue => _psTagValue;

  void setUploadPassed(bool value) {
    _psUploadPassed = value;
    notifyListeners();
  }

  void setCommentValue(String value) {
    _psCommentValue = value;
    notifyListeners();
  }

    void setTagValue(String value) {
    _psTagValue = value;
    notifyListeners();
  }

}