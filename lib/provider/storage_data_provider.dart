import 'package:flutter/material.dart';

class StorageDataProvider extends ChangeNotifier {

  List<String> _statisticsFilesName = <String>[];
  List<String> _folderNamesList = <String>[];

  List<String> get statisticsFilesName => _statisticsFilesName;
  List<String> get foldersNameList => _folderNamesList;

  void setStatsFilesName(List<String> statisticsFilesName) {
    _statisticsFilesName = statisticsFilesName;
    notifyListeners();
  }

  void setFolderName(List<String> folderName) {
    _folderNamesList = folderName;
    notifyListeners();
  }

}