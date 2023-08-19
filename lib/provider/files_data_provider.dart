import 'package:flutter/material.dart';

class FilesDataProvider extends ChangeNotifier {

  List<String> _statisticsFilesName = <String>[];

  List<String> get statisticsFilesName => _statisticsFilesName;

  void setStatsFilesName(List<String> statisticsFilesName) {
    _statisticsFilesName = statisticsFilesName;
    notifyListeners();
  }

}