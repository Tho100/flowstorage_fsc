import 'dart:typed_data';

import 'package:flutter/material.dart';

class StorageDataProvider extends ChangeNotifier {

  List<String> _statisticsFilesName = <String>[];

  List<String> _folderNamesList = <String>[];
  List<String> _fileNamesList = <String>[];
  List<String> _fileNamesFilteredList = <String>[];
  List<String> _fileDateList = <String>[];

  List<Uint8List?> _imageBytesList = <Uint8List?>[];
  List<Uint8List?> _imageBytesFilteredList = <Uint8List?>[];

  List<String> get statisticsFilesName => _statisticsFilesName;

  List<String> get foldersNameList => _folderNamesList;

  List<String> get fileNamesList => _fileNamesList;
  List<String> get fileNamesFilteredList => _fileNamesFilteredList;
  List<String> get fileDateList => _fileDateList;

  List<Uint8List?> get imageBytesList => _imageBytesList;
  List<Uint8List?> get imageBytesFilteredList => _imageBytesFilteredList;


  void setStatsFilesName(List<String> statisticsFilesName) {
    _statisticsFilesName = statisticsFilesName;
    notifyListeners();
  }

  void setFoldersName(List<String> folderName) {
    _folderNamesList = folderName;
    notifyListeners();
  }

  void setFilesName(List<String> filesName) {
    _fileNamesList = filesName;
    notifyListeners();
  }

  void setFilteredFilesName(List<String> filesName) {
    _fileNamesFilteredList = filesName;
    notifyListeners();
  }

  void setFilesDate(List<String> date) {
    _fileDateList = date;
    notifyListeners();
  }

  void setImageBytes(List<Uint8List?> bytes) {
    _imageBytesList = bytes;
    notifyListeners();
  }

  void setFilteredImageBytes(List<Uint8List?> bytes) {
    _imageBytesFilteredList = bytes;
    notifyListeners();
  }

}