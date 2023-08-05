import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/directory_query/directory_data.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/folder_query/folder_data_retriever.dart';
import 'package:flowstorage_fsc/global/global_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/public_storage/data_retriever.dart';
import 'package:flowstorage_fsc/sharing/sharing_data_receiver.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';

class DataCaller {

  final _crud = Crud();
  final _offlineMode = OfflineMode();
  
  final _fileNameGetterHome = NameGetter();
  final _dataGetterHome = DataRetriever();
  final _dateGetterHome = DateGetter();
  
  final _directoryDataReceiver = DirectoryDataReceiver();
  final _sharingDataRetriever = SharingDataReceiver();
  
  Future<void> offlineData() async {
    
    final getAssets = GetAssets();
    final offlineDirPath = await _offlineMode.returnOfflinePath();

    if(!offlineDirPath.existsSync()) { 
      offlineDirPath.createSync();
    }

    Globals.fileOrigin = "offlineFiles";

    final files = offlineDirPath.listSync().whereType<File>().toList();

    List<String> fileValues = [];
    List<String> filteredSearchedFiles = [];
    List<String> setDateValues = [];
    List<Uint8List> imageByteValues = [];
    List<Uint8List> filteredSearchedBytes = [];

    for (var file in files) {

      String fileName = path.basename(file.path);
      String? fileType = fileName.split('.').last;

      Uint8List imageBytes;
      String actualFileSize = '';

      if(!(Globals.imageType.contains(fileType))) {
        actualFileSize = "Unknown";
      }

      if (Globals.imageType.contains(fileType)) {

        imageBytes = await file.readAsBytes();

        int fileSize = imageBytes.length;
        double fileSizeMB = fileSize / (1024 * 1024);
        actualFileSize = "${fileSizeMB.toStringAsFixed(2)}Mb";

      } else if (Globals.textType.contains(fileType)) {
        
        imageBytes = await getAssets.loadAssetsData("txt0.png");

      } else if (Globals.audioType.contains(fileType)) {

        imageBytes = await getAssets.loadAssetsData("music0.png");

      } else if (fileType == "pdf") {

        imageBytes = await getAssets.loadAssetsData("pdf0.png");

      } else if (Globals.wordType.contains(fileType)) {

        imageBytes = await getAssets.loadAssetsData("doc0.png");

      } else if (Globals.excelType.contains(fileType)) {

        imageBytes = await getAssets.loadAssetsData("exl0.png");

      } else if (fileType == "exe") {
        
        imageBytes = await getAssets.loadAssetsData("exe0.png");

      } else {
        continue;
      }

      fileValues.add(fileName);
      filteredSearchedFiles.add(fileName);
      setDateValues.add(actualFileSize);
      imageByteValues.add(imageBytes);
      filteredSearchedBytes.add(imageBytes);
    }

    Globals.fileValues = fileValues;
    Globals.filteredSearchedFiles = filteredSearchedFiles;
    Globals.setDateValues = setDateValues;
    Globals.imageByteValues = imageByteValues;
    Globals.filteredSearchedBytes = filteredSearchedBytes;
    
  }

  Future<void> homeData() async {

    final conn = await SqlConnection.insertValueParams();

    final dirListCount = await _crud.countUserTableRow(GlobalsTable.directoryInfoTable);
    final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

    final tablesToCheck = [
      ...dirLists,
      GlobalsTable.homeImage, GlobalsTable.homeText, 
      GlobalsTable.homePdf, GlobalsTable.homeExcel, 
      GlobalsTable.homeVideo, GlobalsTable.homeAudio,
      GlobalsTable.homePtx, GlobalsTable.homeWord,
      GlobalsTable.homeExe, GlobalsTable.homeApk
    ];

    final futures = tablesToCheck.map((table) async {
      final fileNames = await _fileNameGetterHome.retrieveParams(conn,Globals.custUsername, table);
      final bytes = await _dataGetterHome.getLeadingParams(conn,Globals.custUsername, table);
      final dates = table == GlobalsTable.directoryInfoTable
          ? List.generate(1,(_) => "Directory")
          : await _dateGetterHome.getDateParams(Globals.custUsername, table);
      return [fileNames, bytes, dates];
    }).toList();

    final results = await Future.wait(futures);

    final fileNames = <String>{};
    final bytes = <Uint8List>[];
    final dates = <String>[];

    for (final result in results) {
      final fileNamesForTable = result[0] as List<String>;
      final bytesForTable = result[1] as List<Uint8List>;
      final datesForTable = result[2] as List<String>;

      fileNames.addAll(fileNamesForTable);
      bytes.addAll(bytesForTable);
      dates.addAll(datesForTable);
    }

    final uniqueFileNames = fileNames.toList();
    final uniqueBytes = bytes.toList();

    Globals.fileValues.addAll(uniqueFileNames);
    Globals.imageByteValues.addAll(uniqueBytes);
    Globals.setDateValues.addAll(dates);

    Globals.filteredSearchedFiles.clear();
    Globals.filteredSearchedBytes.clear();

  }

  Future<void> publicStorageData({required BuildContext context}) async {

    final justLoading = JustLoading();

    justLoading.startLoading(context: context);

    GlobalsData.psTagsValuesData.clear();

    final psDataRetriever = PublicStorageDataRetriever();
    final dataList = await psDataRetriever.retrieveParams();

    final nameList = dataList.expand((data) => data['name'] as List<String>).toList();
    final dateList = dataList.expand((data) => data['date'] as List<String>).toList();
    final byteList = dataList.expand((data) => data['file_data'] as List<Uint8List>).toList();

    final getTagsValue = dateList.
      map((tags) => tags.split(' ').last).toList();

    GlobalsData.psTagsValuesData.addAll(getTagsValue);

    Globals.fileValues.addAll(nameList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

    Globals.fileOrigin = "psFiles";

    justLoading.stopLoading();
    
  }

  Future<void> directoryData({required String directoryName}) async {

    final dataList = await _directoryDataReceiver.retrieveParams(dirName: directoryName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
    
    Globals.fileValues.addAll(nameList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

    Globals.fileOrigin = "dirFiles";

  }

  Future<void> sharingData(String originFrom) async {

    final dataList = await _sharingDataRetriever.retrieveParams(Globals.custUsername,originFrom);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    Globals.fileValues.addAll(nameList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

  }

  Future<void> folderData({required String folderName}) async {

    final folderDataReceiver = FolderDataReceiver();
    final dataList = await folderDataReceiver.retrieveParams(Globals.custUsername, folderName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    Globals.fileValues.addAll(nameList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

  }

}