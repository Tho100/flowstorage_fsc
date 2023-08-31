import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/directory_query/directory_data.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/folder_query/folder_data_retriever.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage/data_retriever.dart';
import 'package:flowstorage_fsc/sharing/sharing_data_receiver.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';

class DataCaller {

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

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

    tempData.setOrigin("offlineFiles");

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

      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;
      final fileSizeMB = fileSize / (1024 * 1024);

      actualFileSize = "${fileSizeMB.toStringAsFixed(2)}Mb";

      if (Globals.imageType.contains(fileType)) {

        imageBytes = await file.readAsBytes();

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

      } else if (fileType == "apk") {
        
        imageBytes = await getAssets.loadAssetsData("apk0.png");

      } else if (Globals.ptxType.contains(fileType)) {

        imageBytes = await getAssets.loadAssetsData("pptx0.png");

      } else {
        continue;
      }

      fileValues.add(fileName);
      filteredSearchedFiles.add(fileName);
      setDateValues.add(actualFileSize);
      imageByteValues.add(imageBytes);
      filteredSearchedBytes.add(imageBytes);
    }

    storageData.setFilesName(fileValues);
    storageData.setFilteredFilesName(filteredSearchedFiles);
    storageData.setFilesDate(setDateValues);
    storageData.setImageBytes(imageByteValues);
    storageData.setFilteredImageBytes(filteredSearchedBytes);
    
  }

  Future<void> homeData({bool? isFromStatistics = false}) async {

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
      final fileNames = await _fileNameGetterHome.retrieveParams(conn,userData.username, table);
      final bytes = await _dataGetterHome.getLeadingParams(conn,userData.username, table);
      final dates = table == GlobalsTable.directoryInfoTable
          ? List.generate(1,(_) => "Directory")
          : await _dateGetterHome.getDateParams(userData.username, table);
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

    if(isFromStatistics!) {
      storageData.setStatsFilesName(uniqueFileNames);
      return;
    }

    storageData.setFilesName(uniqueFileNames);
    storageData.setImageBytes(uniqueBytes);
    storageData.setFilesDate(dates);

    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();

  }

  Future<void> publicStorageData({required BuildContext context}) async {

    final justLoading = JustLoading();

    justLoading.startLoading(context: context);

    psStorageData.psTagsList.clear();

    final psDataRetriever = PublicStorageDataRetriever();
    final dataList = await psDataRetriever.retrieveParams(isFromMyPs: false);

    final uploaderList = dataList.expand((data) => data['uploader_name'] as List<String>).toList();
    final nameList = dataList.expand((data) => data['name'] as List<String>).toList();
    final fileDateList = dataList.expand((data) => data['date'] as List<String>).toList();
    final byteList = dataList.expand((data) => data['file_data'] as List<Uint8List>).toList();

    final getTagsValue = fileDateList.
      map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploaderList);

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);
    tempData.setOrigin("psFiles");

    justLoading.stopLoading();
    
  }

  Future<void> myPublicStorageData({required BuildContext context}) async {

    final justLoading = JustLoading();

    justLoading.startLoading(context: context);

    psStorageData.psImageBytesList.clear();
    psStorageData.psUploaderList.clear();
    psStorageData.psThumbnailBytesList.clear();

    psStorageData.psTagsList.clear();
    psStorageData.psTagsColorList.clear();

    final psDataRetriever = PublicStorageDataRetriever();
    final dataList = await psDataRetriever.retrieveParams(isFromMyPs: true);

    final uploaderList = dataList.expand((data) => data['uploader_name'] as List<String>).toList();
    final nameList = dataList.expand((data) => data['name'] as List<String>).toList();
    final fileDateList = dataList.expand((data) => data['date'] as List<String>).toList();
    final byteList = dataList.expand((data) => data['file_data'] as List<Uint8List>).toList();

    final getTagsValue = fileDateList.
      map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploaderList);

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin("psFiles");

    justLoading.stopLoading();
    
  }

  Future<void> directoryData({required String directoryName}) async {

    final dataList = await _directoryDataReceiver.retrieveParams(dirName: directoryName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
    
    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin("dirFiles");

  }

  Future<void> sharingData(String originFrom) async {

    final dataList = await _sharingDataRetriever.retrieveParams(userData.username,originFrom);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

  }

  Future<void> folderData({required String folderName}) async {

    final folderDataReceiver = FolderDataReceiver();
    final dataList = await folderDataReceiver.retrieveParams(userData.username, folderName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin("folderFiles");
    
  }

}