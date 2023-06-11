
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flowstorage_fsc/api/SaveApi.dart';
import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flowstorage_fsc/global/GlobalsStyle.dart';
import 'package:flowstorage_fsc/helper/Generator.dart';
import 'package:flowstorage_fsc/helper/GetAsset.dart';
import 'package:flowstorage_fsc/helper/ScannerPdf.dart';
import 'package:flowstorage_fsc/helper/ShortenText.dart';
import 'package:flowstorage_fsc/sharing/SharingDialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/MultipleText.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/SingleText.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:flowstorage_fsc/data_classes/FolderDataReceiver.dart';
import 'package:flowstorage_fsc/directory/CountDirectory.dart';
import 'package:flowstorage_fsc/directory/DeleteDirectory.dart';
import 'package:flowstorage_fsc/directory/DirectoryData.dart';
import 'package:flowstorage_fsc/directory/RenameDirectory.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/helper/ImagePicker.dart';
import 'package:flowstorage_fsc/helper/CallNotify.dart';
import 'package:flowstorage_fsc/helper/SimplifyDownload.dart';
import 'package:flowstorage_fsc/navigator/NavigatePage.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/ui_dialog/TitledAlert.dart';
import 'package:flowstorage_fsc/folder_query/DeleteFold.dart';
import 'package:flowstorage_fsc/folder_query/RenameFold.dart';
import 'package:flowstorage_fsc/authentication/SignUp.dart';
import 'package:flowstorage_fsc/sharing/SharingData.dart';

import 'package:flowstorage_fsc/encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/models/PreviewFile.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flowstorage_fsc/user_settings/AccountPlan.dart';

import 'package:flowstorage_fsc/folder_query/CreateFolder.dart';
import 'package:flowstorage_fsc/directory/CreateDirectory.dart';
import 'package:flowstorage_fsc/extra_query/RetrieveData.dart';
import 'package:flowstorage_fsc/extra_query/InsertData.dart';
import 'package:flowstorage_fsc/extra_query/Delete.dart';
import 'package:flowstorage_fsc/data_classes/NameGetter.dart';
import 'package:flowstorage_fsc/data_classes/DateGetter.dart';
import 'package:flowstorage_fsc/data_classes/LoginGetter.dart';
import 'package:flowstorage_fsc/extra_query/Rename.dart';

import 'SplashScreen.dart';

void main() async {
  runApp(const MainRun());
}

class MainRun extends StatelessWidget {
  const MainRun({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

void homePage() => runApp(MaterialApp(
  theme: ThemeData(
    scaffoldBackgroundColor: ThemeColor.darkBlack
  ),
  home: const cakeMySignUp(),
));

class Mainboard extends StatefulWidget {
  
  const Mainboard({super.key});
  @override
  State<Mainboard> createState() => cakeHomeWidgetState();

  static void clearUserRecords() {
    Globals.fromLogin = false;
    Globals.fileValues.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();
    Globals.foldValues.clear();
    Globals.dateStoresValues.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
  }
}
  
class cakeHomeWidgetState extends State<Mainboard> { 

  final GlobalKey<ScaffoldState> sidebarMenuScaffoldKey = GlobalKey<ScaffoldState>();

  final _focusNode = FocusNode();
  final _searchController = TextEditingController();
  final _renameController = TextEditingController();

  final focusNodeRedudane = FocusNode();
  final searchControllerRedudane = TextEditingController();

  final folderRenameController = TextEditingController();
  final directoryCreateController = TextEditingController();
  final shareController = TextEditingController();
  final commentController = TextEditingController();

  String _fileType = '';

  ValueNotifier<String> appBarTitle  = ValueNotifier<String>('');
  ValueNotifier<String> sortingText  = ValueNotifier<String>('Default');

  bool editAllIsPressed = false;
  bool itemIsChecked = false;

  List<bool> checkedList = List.generate(Globals.filteredSearchedFiles.length, (index) => false);
  List<String> checkedItemsName = [];

  ValueNotifier<bool> navDirectoryButtonVisible = ValueNotifier<bool>(true);
  ValueNotifier<bool> floatingActionButtonVisible = ValueNotifier<bool>(true);
  ValueNotifier<bool> homeButtonVisible = ValueNotifier<bool>(false);

  bool _isFromUpload = false;
  File? fileToDisplay;

  dynamic leadingImageSearchedValue;
  dynamic fileTitleSearchedValue;

  bool isAscendingItemName = false;
  bool isAscendingUploadDate = false;

  Future<void>? _debounceSearch;

  final fileNameGetterHome = NameGetter();
  final loginGetterHome = LoginGetter();
  final dateGetterHome = DateGetter();
  final retrieveData = RetrieveData();
  final insertData = InsertData();

  void _clearSelectAll() {
    appBarTitle.value = Globals.originToName[Globals.fileOrigin]!;
    setState(() {
      itemIsChecked = false;
      editAllIsPressed = false;
    });
    checkedItemsName.clear();
  }

  Future<void> _selectDirectoryMultipleSave(int count) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      _callMultipleFilesDownload(count: count, directoryPath: directoryPath);
    } else {
      return;
    }
  }

  Future<void> _callMultipleFilesDownload({
    required int count,
    required String directoryPath
  }) async {

    try {

      final loadingDialog = SingleTextLoading();      
      loadingDialog.startLoading(title: "Saving...", context: context);

      for(int i=0; i<count; i++) {

        final fileType = checkedItemsName[i].split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        Uint8List getBytes = await _callData(checkedItemsName[i],tableName!);
        SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: checkedItemsName[i], fileData: getBytes);

      }

      loadingDialog.stopLoading();
      SnakeAlert.okSnake(message: "$count items has been saved.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save files.",context);
    }

  }

  Future<void> _saveOfflineFile({
    required String fileName, 
    required Uint8List fileData
  }) async {

    final getDirApplication = await getApplicationDocumentsDirectory();
    final picturesDir = Directory('${getDirApplication.path}/offline_files');

    if(!picturesDir.existsSync()) {
      picturesDir.createSync();
      final setupFiles = File('${picturesDir.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);
    } else {
      final setupFiles = File('${picturesDir.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);
    }
     
  }

  Future<void> _processSaveOfflineFile({required String fileName}) async {

    final singleLoading = SingleTextLoading();

    try {
      
      final fileType = fileName.split('.').last;

      if(fileType == "pdf" || fileType == "docx" || fileType == "xlsx" || fileType == "xls" || fileType == "pptx" || fileType == "ptx") {
        AlertForm.alertDialogTitle("Couldn't make this file offline.", "File type is not yet supported for offline.", context);
        return;
      }

      final tableName = Globals.fileTypesToTableNames[fileType]!;

      singleLoading.startLoading(title: "Preparing...", context: context);

      final fileData = await _callData(fileName,tableName);
      await _saveOfflineFile(fileName: fileName,fileData: fileData);

      singleLoading.stopLoading();
      _clearSelectAll();
      
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Now available offline.",icon: Icons.check,context: context);
      
    } catch (err) {
      singleLoading.stopLoading();
      SnakeAlert.errorSnake("An error occurred.",context);
    }
  }

  Future<void> _processSaveOfflineFileSelectAll({required int count}) async {

    try {

      final singleLoading = SingleTextLoading();
      singleLoading.startLoading(title: "Preparing...", context: context);

      for(int i=0; i<count; i++) {
        
        final fileType = checkedItemsName[i].split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType]!;

        final fileData = await _callData(checkedItemsName[i],tableName);
        await _saveOfflineFile(fileName: checkedItemsName[i],fileData: fileData);
      }

      singleLoading.stopLoading();
      _clearSelectAll();

      SnakeAlert.okSnake(message: "$count Items now available offline.",icon: Icons.check,context: context);
      
    } catch (err) {
      SnakeAlert.errorSnake("An error occurred.",context);
    }
  }

  Future<void> _callOfflineData() async {

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirs = Directory('${getDirApplication.path}/offline_files');

    if(!offlineDirs.existsSync()) { 
      AlertForm.alertDialog("No offline file is available yet.", context);
      return;
    }

    Globals.fileOrigin = "offlineFiles";
    appBarTitle.value = "Offline files";
    _clearSelectAll(); 

    final files = offlineDirs.listSync().whereType<File>().toList();

    List<String> fileValues = [];
    List<String> filteredSearchedFiles = [];
    List<String> dateStoresValues = [];
    List<String> setDateValues = [];
    List<Uint8List> imageByteValues = [];
    List<Uint8List> filteredSearchedBytes = [];

    for (var file in files) {

      String fileName = path.basename(file.path);
      String? fileType = fileName.split('.').last;

      Uint8List imageBytes;
      String actualFileSize = '';

      if (Globals.imageType.contains(fileType)) {

        imageBytes = await file.readAsBytes();

        int fileSize = imageBytes.length;
        double fileSizeMB = fileSize / (1024 * 1024);
        actualFileSize = "${fileSizeMB.toStringAsFixed(2)}Mb";

      } else if (Globals.textType.contains(fileType)) {
        
        imageBytes = await GetAssets().loadAssetsData("txt0.png");
        actualFileSize = "Unknown";

      }  else {
        continue;
      }

      fileValues.add(fileName);
      filteredSearchedFiles.add(fileName);
      dateStoresValues.add(actualFileSize);
      setDateValues.add(actualFileSize);
      imageByteValues.add(imageBytes);
      filteredSearchedBytes.add(imageBytes);
    }

    setState(() {
      Globals.fileValues = fileValues;
      Globals.filteredSearchedFiles = filteredSearchedFiles;
      Globals.dateStoresValues = dateStoresValues;
      Globals.setDateValues = setDateValues;
      Globals.imageByteValues = imageByteValues;
      Globals.filteredSearchedBytes = filteredSearchedBytes;
    });

    _navHomeButtonVisibility(true);
    _navDirectoryButtonVisibility(false);
    _floatingButtonVisiblity(false);
    
  }

  DateTime _parseDate(String dateString) {
    
    if (dateString.contains('days ago')) {

      int daysAgo = int.parse(dateString.split(' ')[0]);
      DateTime now = DateTime.now();
      
      return now.subtract(Duration(days: daysAgo));

    } else {
      return DateFormat('MMM dd yyyy').parse(dateString);
    }
    
  }

  String _formatDateTime(DateTime dateTime) {

    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    final adjustedDateTime = difference.isNegative ? dateTime.add(Duration(days: 1)) : dateTime;
    final adjustedDifference = adjustedDateTime.difference(now).inDays.abs();

    if (adjustedDifference == 0) {
      return '0 days ago, ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    } else {
      final daysAgoText = '$adjustedDifference days ago';
      return '$daysAgoText, ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    }
  }

  void _sortUploadDate() {
    isAscendingUploadDate = !isAscendingUploadDate;
    sortingText.value = "Upload Date";
    _processUploadDateSorting();
  }

  void _sortItemName() {
    isAscendingItemName = !isAscendingItemName;
    sortingText.value = "Item Name";
    _processfileNameSorting();
  }

  void _processUploadDateSorting() {

    List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < Globals.filteredSearchedFiles.length; i++) {
      itemList.add({
        'file_name': Globals.filteredSearchedFiles[i],
        'image_byte': Globals.filteredSearchedBytes[i],
        'upload_date': _parseDate(Globals.setDateValues[i])
      });
    }

    isAscendingUploadDate 
    ? itemList.sort((a, b) => a['upload_date'].compareTo(b['upload_date']))
    : itemList.sort((a, b) => b['upload_date'].compareTo(a['upload_date']));

    setState(() {
      Globals.setDateValues.clear();
      Globals.filteredSearchedFiles.clear();
      Globals.filteredSearchedBytes.clear();
      Globals.dateStoresValues.clear();
      for (var item in itemList) {
        Globals.filteredSearchedFiles.add(item['file_name']);
        Globals.filteredSearchedBytes.add(item['image_byte']);
        Globals.dateStoresValues.add(_formatDateTime(item['upload_date']));
        Globals.setDateValues.add(_formatDateTime(item['upload_date']));
      }
    });

    itemList.clear();

  }

  void _processfileNameSorting() {

   List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < Globals.filteredSearchedFiles.length; i++) {
      itemList.add({
        'file_name': Globals.filteredSearchedFiles[i],
        'image_byte': Globals.filteredSearchedBytes[i],
      });
    }

    isAscendingItemName 
    ? itemList.sort((a, b) => a['file_name'].compareTo(b['file_name']))
    : itemList.sort((a, b) => b['file_name'].compareTo(a['file_name']));

    setState(() {
      Globals.filteredSearchedFiles.clear();
      Globals.filteredSearchedBytes.clear();
      for (var item in itemList) {
        Globals.filteredSearchedFiles.add(item['file_name']);
        Globals.filteredSearchedBytes.add(item['image_byte']);
      }
    });

    itemList.clear();

  }

  void _addItemToListView({required String fileName}) {
    _isFromUpload = true;
    setState(() {
      Globals.setDateValues.add("Just now");
      Globals.fileValues.add(fileName);
      Globals.filteredSearchedFiles.add(fileName);
    });
  }

  Future<void> _initializeCameraScanner() async {

    try {

      final scannerPdf = ScannerPdf();

      final imagePath = await CunningDocumentScanner.getPictures();
      final generateFileName = Generator.generateRandomString(Generator.generateRandomInt(5,15));

      for(var images in imagePath!) {

        File compressedDocImage = await _processImageCompression(path: images,quality: 65); 
        await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
        
      }

      await scannerPdf.savePdf(fileName: generateFileName,context: context);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$generateFileName.pdf');

      final toBase64Encoded = base64.encode(file.readAsBytesSync());

      final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.png");
      await _processUploadListView(filePathVal: file.path,selectedFileName: "$generateFileName.pdf",tableName: "file_info_pdf",fileBase64Encoded: toBase64Encoded,newFileToDisplay: newFileToDisplay);

      _addItemToListView(fileName: "$generateFileName.pdf");

      await file.delete();

      SnakeAlert.okSnake(message: "$generateFileName.pdf Has been added",icon: Icons.check,context: context);

      await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

    } catch (err) {
      print("Exception from _initializeCameraScanner {main}: $err");
      SnakeAlert.errorSnake("Failed to start scanner.",context);
    }
  }

  /// <summary>
  /// 
  /// Delete all the selected items on checkboxes check
  /// 
  /// </summary>
  
  Future<void> _deleteOfflineFilesSelectAll(String fileName) async {

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirs = Directory('${getDirApplication.path}/offline_files');

    final file = File('${offlineDirs.path}/$fileName');
    file.deleteSync();

  }

  Future<void> _deleteAllSelectedItems({
    required int count
  }) async {

    late String? query;
    late Map<String,String> params;

    final crud = Crud();

    for(int i=0; i<count; i++) {

      if(Globals.fileOrigin == "homeFiles") {

        final fileType = checkedItemsName[i].split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(checkedItemsName[i])};

      } else if (Globals.fileOrigin == "dirFiles") {

        query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
        params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(checkedItemsName[i]),'dirname': EncryptionClass().Encrypt(Globals.directoryTitleValue)};

      } else if (Globals.fileOrigin == "folderFiles") {
        
        query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
        params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(checkedItemsName[i]),'foldname': EncryptionClass().Encrypt(Globals.folderTitleValue)};

      } else if (Globals.fileOrigin == "sharedToMe") {
      
        query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(checkedItemsName[i])};

      } else if (Globals.fileOrigin == "sharedFiles") {
        query = "DELETE FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {'username': Globals.custUsername, 'filename': EncryptionClass().Encrypt(checkedItemsName[i])};
      } else if (Globals.fileOrigin == "offlineFiles") {
        query = "";
        params = {};
        _deleteOfflineFilesSelectAll(checkedItemsName[i]);
      }

      Globals.fileOrigin != "offlineFiles" ? await crud.delete(query: query, params: params) : null;
      await Future.delayed(const Duration(milliseconds: 855));

      _removeFileFromListView(fileName: checkedItemsName[i],isFromSelectAll: true, onTextChanged: _onTextChanged);
    }

    _clearSelectAll();
  }

  Future<void> _processDeletingAllItems({
    required int count
  }) async {

    try {

      await _deleteAllSelectedItems(count: count);

      SnakeAlert.okSnake(message: "$count Items has been deleted.", icon: Icons.check, context: context);

    } catch (err) {
      print("Exception from _processDeletingAllItems {main}: $err");
      SnakeAlert.errorSnake("An error occurred.", context);
    } 
  }

  void _editAllOnPressed() {
    setState(() {
      editAllIsPressed = !editAllIsPressed;
    });
    if(editAllIsPressed == true) {
      checkedList.clear();
      checkedList = List.generate(Globals.filteredSearchedFiles.length, (index) => false);
    }
    if(!editAllIsPressed) {
      appBarTitle.value = Globals.originToName[Globals.fileOrigin]!;
      setState(() {
        itemIsChecked = false;
      });
    }
  }

  void _updateCheckboxState(int index, bool value) {
    setState(() {
      checkedList[index] = value;
      itemIsChecked = checkedList.where((item) => item == true).length > 0 ? true : false;
      value == true ? checkedItemsName.add(Globals.filteredSearchedFiles[index]) : checkedItemsName.removeWhere((item) => item == Globals.filteredSearchedFiles[index]);
    });
    appBarTitle.value = "${(checkedList.where((item) => item == true).length).toString()} items selected";
  }

  /// <summary>
  /// 
  /// File searching functionality implemented
  /// on this function
  /// 
  /// </summary>
  
  void _onTextChanged(String value) {
    _debounceSearch = null;
    _debounceSearch = Future.delayed(const Duration(milliseconds: 280), () {
      final searchTerms = value.split(",").map((term) => term.trim().toLowerCase()).toList();

      final filteredFiles = Globals.fileValues.where((file) {
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredImageValues = Globals.imageValues.where((image) {
        final index = Globals.imageValues.indexOf(image);
        final file = Globals.fileValues[index];
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredByteValues = Globals.imageByteValues.where((bytes) {
      final index = Globals.imageByteValues.indexOf(bytes);
      final file = Globals.fileValues[index];
      return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      setState(() {
        
        Globals.filteredSearchedFiles = filteredFiles;
        Globals.filteredSearchedImage = filteredImageValues;
        Globals.filteredSearchedBytes = filteredByteValues;

        if (filteredFiles.isNotEmpty) {
          final index = Globals.fileValues.indexOf(filteredFiles.first);
          leadingImageSearchedValue = Globals.fromLogin == false && filteredImageValues.isNotEmpty && filteredImageValues.length > index
            ? Image.file(filteredImageValues[index])
            : filteredByteValues.isNotEmpty && filteredByteValues.length > index
              ? Image.memory(filteredByteValues[index]!)
              : null;
        } else {
          leadingImageSearchedValue = null;
        }
      });
    });
  }

  Future<int> _getUsageProgressBar() async {

    try {

      final int maxValue = AccountPlan.mapFilesUpload[Globals.accountType]!;
      final int percentage = ((Globals.fileValues.length/maxValue) * 100).toInt();

      return percentage;

    } catch (err) {
      print("Exception on _getUsageProgressBar (main): $err");
      return 0;
    }

  }

  void _floatingButtonVisiblity(bool visible) {
    floatingActionButtonVisible.value = visible;
  }

  void _navHomeButtonVisibility(bool visible) {
    homeButtonVisible.value = visible;
  }

  void _navDirectoryButtonVisibility(bool visible) {
    navDirectoryButtonVisible.value = visible;
  }

  void _returnBackHomeFiles() {
    setState(() { 
      Globals.fileOrigin = "homeFiles";
      Globals.folderTitleValue = '';
      Globals.directoryTitleValue = '';
    });
    _navHomeButtonVisibility(false);
  }

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    setState(() {
      Globals.fileValues[indexOldFile] = newFileName;
      Globals.filteredSearchedFiles[indexOldFileSearched] = newFileName;
      _renameController.clear();
    });
  }
  
  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(Globals.custUsername, selectedFilename, tableName,Globals.fileOrigin);
  }

  Future<void> _callFolderData(String folderTitle) async {

    final sharingDataReceiver = FolderDataReceiver();
    final dataList = await sharingDataReceiver.retrieveParams(Globals.custUsername,folderTitle);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    Globals.fileValues.clear();
    Globals.dateStoresValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();

    Globals.fileValues.addAll(nameList);
    Globals.dateStoresValues.addAll(dateList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

    _onTextChanged('');
    _searchController.text = '';
    _navHomeButtonVisibility(true);
  }

  Future<void> _deleteFolder(String folderName) async {
    
    try {

      final deleteClass = DeleteFolder();

      await deleteClass.deletionParams();

      setState(() {
        Globals.foldValues.remove(folderName);
        Globals.fileOrigin = 'homeFiles';
      });

      SnakeAlert.okSnake(message: "$folderName Folder has been deleted.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to delete this folder.",context);
    }

  }

  Future<void> _renameFolder(String oldFolderName, String newFolderName) async {

    try {

      final renameClass = RenameFolder();
      await renameClass.renameParams(oldFolderTitle: oldFolderName, newFolderTitle: newFolderName);

      int indexOldFolder = Globals.foldValues.indexWhere((name) => name == oldFolderName);
      if(indexOldFolder != -1) {
        setState(() {
          Globals.foldValues[indexOldFolder] = newFolderName;
        });
      }

      SnakeAlert.okSnake(message: "`$oldFolderName` Has been renamed to `$newFolderName`", context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to rename this folder.", context);
    }

  }

  Future<int> _countRowTable(String tableName,String username) async {

    final crud = Crud();
    final countQueryRow = "SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final int totalRowCount = await crud.count(
      query: countQueryRow, 
      params: params
    );

    return totalRowCount;

  }

  Future<void> _refreshHomeFiles() async {

    final dirListCount = await _countRowTable("file_info_directory", Globals.custUsername);
    final dirLists = List.generate(dirListCount, (_) => "file_info_directory");

    final tablesToCheck = ["file_info", "file_info_expand", "file_info_pdf","file_info_excel", "file_info_vid","file_info_audi","file_info_ptx","file_info_word", ...dirLists];

    final futures = tablesToCheck.map((table) async {
      final fileNames = await fileNameGetterHome.retrieveParams(Globals.custUsername, table);
      final bytes = await loginGetterHome.getLeadingParams(Globals.custUsername, table);
      final dates = table == "file_info_directory"
          ? List.generate(1,(_) => "Directory")
          : await dateGetterHome.getDateParams(Globals.custUsername, table);
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

    Globals.fromLogin = true;

    Globals.fileValues.addAll(uniqueFileNames);
    Globals.imageByteValues.addAll(uniqueBytes);
    Globals.dateStoresValues.addAll(dates);
    Globals.setDateValues.addAll(dates);

    _navHomeButtonVisibility(false);

    Globals.filteredSearchedFiles.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();

  }

  Future<void> _refreshListView() async {

    Globals.fileValues.clear();
    Globals.dateStoresValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();

    if(Globals.fileOrigin == "homeFiles") {
      await _refreshHomeFiles();
    } else if (Globals.fileOrigin == "sharedFiles") {
      await _callSharingData("sharedFiles");
    } else if (Globals.fileOrigin == "sharedToMe") {
      await _callSharingData("sharedToMe");
    } else if (Globals.fileOrigin == "folderFiles") {
      await _callFolderData(Globals.folderTitleValue);
    } else if (Globals.fileOrigin == "dirFiles") {
      await _callDirectoryData();
    } else if (Globals.fileOrigin == "offlineFiles") {
      await _callOfflineData();
    }
  
    _onTextChanged('');
    _searchController.text = '';
    sortingText.value = "Default";

    if(Globals.fileValues.isEmpty) {
      _buildEmptyBody(context);
    }

  }

  Future<void> _callDirectoryData() async {

    final directoryDataReceiver = DirectoryDataReceiver();
    final dataList = await directoryDataReceiver.retrieveParams(Globals.custUsername,appBarTitle.value);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
    
    Globals.fileValues.clear();
    Globals.dateStoresValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();

    Globals.fileValues.addAll(nameList);
    Globals.dateStoresValues.addAll(dateList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

    _onTextChanged('');
    _searchController.text = '';
    _navHomeButtonVisibility(true);
    Globals.fileOrigin = "dirFiles";
  }

  Future<void> _buildDirectory(String directoryName) async {

    try {

      await DirectoryClass().createDirectory(directoryName, Globals.custUsername);

      final directoryImage = await GetAssets().loadAssetsFile('dir0.png');

      setState(() {

        _isFromUpload = true;
        Globals.setDateValues.add("Directory");
        Globals.filteredSearchedImage.add(directoryImage);
        Globals.imageByteValues.add(directoryImage.readAsBytesSync());
        Globals.filteredSearchedBytes.add(directoryImage.readAsBytesSync());
        Globals.imageValues.add(directoryImage);

      });

      Globals.filteredSearchedFiles.add(directoryName);
      Globals.fileValues.add(directoryName);

    } catch (err) {
      print("Exception from _buildDirectory: $err");
      AlertForm.alertDialog('Failed to create directory.', context);
    }
  }
  

  Future<void> _deletionDirectory(String directoryName) async {

    try {

      await DeleteDirectory.deleteDirectory(directoryName: directoryName);
      SnakeAlert.okSnake(message: "Directory `$directoryName` has been deleted.",context: context);

    } catch (err) {
      print("Exception from _deletionDirectory: $err");
      SnakeAlert.errorSnake("Failed to delete $directoryName",context);
    }

  }

  Future<void> _deleteFile(String fileName, List<String> fileValues, List<String> filteredSearchedFiles, List<Uint8List?> imageByteValues, List<File> imageValues, bool isFromLogin, Function onTextChanged) async {

    String extension = fileName.split('.').last;

    if(extension == fileName) {
      await _deletionDirectory(fileName);
    } else {
      await _deletionFile(Globals.custUsername,fileName,Globals.fileTypesToTableNames[extension]!);
    }

    _removeFileFromListView(fileName: fileName, isFromSelectAll: false, onTextChanged: onTextChanged);

  }

  Future<void> _callSharingData(String originFrom) async {

    final sharingDataReceiver = SharingDataReceiver();
    final dataList = await sharingDataReceiver.retrieveParams(Globals.custUsername,originFrom);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    Globals.fileValues.clear();
    Globals.dateStoresValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();

    Globals.fileValues.addAll(nameList);
    Globals.dateStoresValues.addAll(dateList);
    Globals.setDateValues.addAll(dateList);
    Globals.imageByteValues.addAll(byteList);

    _onTextChanged('');
    _searchController.text = '';
    _navHomeButtonVisibility(true);
  }

  // TODO: Open the user camera and 
  // retrieve photo data, encrypt the byte value

  Future<void> _initializeCamera() async {

    try {

      final takenPhoto = await Image_Picker.pickerImage(source: ImageSource.camera);

      if (takenPhoto == null) {
        return;
      }

      final imageName = takenPhoto.name;
      final imagePath = takenPhoto.path;

      List<int> bytes = await _compressedByteImage(path: imagePath,quality: 56);
      
      final imageBytes = base64.encode(bytes); 

      if(Globals.fileValues.contains(imageName)) {
        _buildIsAlreadyUploadedDialog(imageName);
        return;
      }

      await _processUploadListView(
        filePathVal: imagePath, 
        selectedFileName: imageName, 
        tableName: "file_info", 
        fileBase64Encoded: imageBytes
      );

      _isFromUpload = true;

      setState(() {
        Globals.setDateValues.add("Just now");
        Globals.fileValues.add(imageName);
        Globals.filteredSearchedFiles.add(imageName);
      });

      await CallNotify().uploadedNotification(title: "Upload Finished",count: 1);

    } catch (err) {
      AlertForm.alertDialogTitle("Something is wrong..","$err",context);
    }

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileType];
      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: "File name  $fileName", context: context);

      Uint8List getBytes = await _callData(fileName,tableName!);

      await SimplifyDownload(
        fileName: fileName,
        currentTable: tableName,
        fileData: getBytes
      ).downloadFile();

      loadingDialog.stopLoading();
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been downloaded.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to download ${ShortenText().cutText(fileName)}",context);
    }

  }

  Future<File> _processImageCompression({
    required String path, 
    required int quality
    }) async {

    final compressedFile = await FlutterNativeImage.compressImage(
      path,
      quality: quality,
    );
    
    return Future.value(compressedFile);
  }

  Future<List<int>> _compressedByteImage({
    required String path,
    required int quality,
  }) async {

    File? compressedFile = await _processImageCompression(path: path, quality: quality);

    List<int> bytes = await compressedFile.readAsBytes();
    return bytes;

  }

  void _removeFileFromListView({
    required String fileName, 
    required bool isFromSelectAll, 
    required Function onTextChanged
  }) {

    int indexOfFile = Globals.filteredSearchedFiles.indexOf(fileName);

    isFromSelectAll == true 
    ? setState(() {
      Globals.fromLogin = true;
      if (indexOfFile >= 0 && indexOfFile < Globals.fileValues.length) {
        Globals.fileValues.removeAt(indexOfFile);
        Globals.filteredSearchedFiles.removeAt(indexOfFile);
        Globals.imageByteValues.removeAt(indexOfFile);
        Globals.filteredSearchedBytes.removeAt(indexOfFile);
        leadingImageSearchedValue = null;
        fileTitleSearchedValue = null;  
      }         
    }) 
    
    : setState(() {
      Globals.fromLogin = true;
      if (indexOfFile >= 0 && indexOfFile < Globals.fileValues.length) {
        Globals.fileValues.removeAt(indexOfFile);
        Globals.filteredSearchedFiles.removeAt(indexOfFile);
        Globals.imageByteValues.removeAt(indexOfFile);
        Globals.filteredSearchedBytes.removeAt(indexOfFile);
        leadingImageSearchedValue = null;
        fileTitleSearchedValue = null;  
      }
      Navigator.pop(context);
    });

    onTextChanged('');

  }

  void _onRenameCancelled() {
    _renameController.clear();
    Navigator.pop(context);
  }

  void _onRenamePressed(String fileName) async {

    try {

      String verifyItemType = fileName.split('.').last;
      String newItemValue = _renameController.text;

      if(verifyItemType == fileName) {

        await _renameDirectory(oldDirName: fileName,newDirName: newItemValue);

        int indexOldFile = Globals.fileValues.indexOf(fileName);
        int indexOldFileSearched = Globals.filteredSearchedFiles.indexOf(fileName);

        _updateRenameFile(newItemValue, indexOldFile, indexOldFileSearched);
        _renameController.clear();

        return;
      }

      String newRenameValue = "$newItemValue.${fileName.split('.').last}";
      if (Globals.fileValues.contains(newRenameValue)) {
        AlertForm.alertDialogTitle(newRenameValue, "Item with this name already exists.", context);
      } else {
        if (_renameController.text.isNotEmpty) {
          await _renameFile(fileName, newRenameValue);
          _renameController.clear();
        }
      }
    } catch (err) {
      print("Exception from _onRenamePressed {main}: $err");
    }
  }

  Future<void> _renameDirectory({
    required String oldDirName, 
    required String newDirName
    }) async {

      await RenameDirectory.renameDirectory(oldDirName,newDirName);
      SnakeAlert.okSnake(message: "Directory `$oldDirName` renamed to `$newDirName`.",context: context);
  }

  Future<void> _renameFile(String oldFileName, String newFileName) async {
    
    String fileType = oldFileName.split('.').last;
    String tableName = Globals.fileTypesToTableNames[fileType]!;

    try {

      await Rename().renameParams(oldFileName, newFileName, tableName);
      int indexOldFile = Globals.fileValues.indexOf(oldFileName);
      int indexOldFileSearched = Globals.filteredSearchedFiles.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {
        _updateRenameFile(newFileName,indexOldFile,indexOldFileSearched);
        SnakeAlert.okSnake(message: "`$oldFileName` Renamed to `$newFileName`.",context: context);
      }

    } catch (failedRename) {
      print("Exception from _renameFile {main}: $failedRename");
      SnakeAlert.errorSnake("Failed to rename this file.",context);
    }
  }

  Future<void> _deletionFile(String username, String fileName, String tableName) async {

    try {

      if(Globals.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().Encrypt(fileName);
        await Delete().deletionParams(username: username, fileName: encryptVals, tableName: tableName);

        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted",context: context);

      } else {
        
        final getDirApplication = await getApplicationDocumentsDirectory();
        final offlineDirs = Directory('${getDirApplication.path}/offline_files');

        final file = File('${offlineDirs.path}/$fileName');
        file.deleteSync();

      }

    } catch (err) {
      print("Exception from _deletionFile {main}: $err");
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}",context);
    }

  }

  /// <summary>
  /// 
  /// Convert asset file from path to File
  /// 
  /// </summary>

  Future<void> _insertUserFile({
    required String table,
    required String filePath,
    required dynamic fileValue,
    dynamic vidThumbnail,
  }) async {

    List<Future<void>> isolatedFileFutures = [];

    isolatedFileFutures.add(insertData.insertValueParams(
      tableName: table,
      filePath: filePath,
      userName: Globals.custUsername,
      fileVal: fileValue,
      vidThumb: vidThumbnail,
    ));

    await Future.wait(isolatedFileFutures);
  }

  /// <summary>
  /// 
  /// If user tried to upload a file that has already 
  /// been uploaded then throw this message dialog
  /// 
  /// </summary>

  void _buildIsAlreadyUploadedDialog(String selectedFileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Upload Failed",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        content: Text("'$selectedFileName' Already exists.",
          style: const TextStyle(
            color: Colors.white,
          ),),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, "OK"),
            child: const Text("OK",
            style: TextStyle(
              color: Colors.white,
            )),
          )
        ]
      )
    );
  }

  /// <summary>
  /// 
  /// Open user gallery (Video)
  /// 
  /// </summary>
  
  Future<void> _openGalleryVideo() async {
    
    try {

      final shortenText = ShortenText();
      final XFile? pickedVideo = await Image_Picker.pickerVideo(source: ImageSource.gallery);

      if (pickedVideo == null) {
        return;
      }

      File? newFileToDisplay;
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final selectedFileName = pickedVideo.name;
      _fileType = selectedFileName.split('.').last;

      if (!Globals.videoType.contains(_fileType)) {
        TitledDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported. Try to use Upload Files instead.",context);
        return;
      }

      if (Globals.fileValues.contains(selectedFileName)) {
        _buildIsAlreadyUploadedDialog(selectedFileName);
        return;
      } 

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: SizedBox(
            height: 30,
            child: Row(
              children: [
                Text("Uploading ${shortenText.cutText(selectedFileName)}"), 
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Cancel upload operation
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          backgroundColor: ThemeColor.mediumGrey,
          
        ),
      );
  
      final filePathVal = pickedVideo.path.toString();

      String bodyBytes;
      bodyBytes = base64.encode(File(filePathVal).readAsBytesSync());

      if (Globals.videoType.contains(_fileType)) {

        String setupThumbnailName = selectedFileName.replaceRange(selectedFileName.lastIndexOf("."), selectedFileName.length, ".jpeg");

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

        Directory tempDir = await getTemporaryDirectory();
        String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

        File thumbnailFile = File(tempThumbnailPath);
        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: filePathVal,
          imageFormat: ImageFormat.WEBP,
          quality: 50,
        );

        await thumbnailFile.writeAsBytes(thumbnailBytes!);

        await thumbnailFile.copy(thumbnailPath);

        newFileToDisplay = thumbnailFile;

        await _processUploadListView(
          filePathVal: filePathVal,
          selectedFileName: selectedFileName,
          tableName: "file_info_vid",
          fileBase64Encoded: bodyBytes,
          newFileToDisplay: newFileToDisplay,
          thumbnailBytes: thumbnailBytes);

      } 

      scaffoldMessenger.hideCurrentSnackBar();
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("${shortenText.cutText(selectedFileName)} Has been added."),
          duration: const Duration(seconds: 2),
          backgroundColor: ThemeColor.mediumGrey,
        )
      );

      _addItemToListView(fileName: selectedFileName);

      await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

    } catch (failedUpload) {
      print("Exception from _openGalleryVideo {main}: $failedUpload");
      SnakeAlert.errorSnake("Upload failed.",context);
    }
  }

  /// <summary>
  /// 
  /// Open user gallery (Image)
  /// 
  /// </summary>
  
  Future<void> _openGalleryImage() async {

    try {

        final shortenText = ShortenText();
        final List<XFile>? pickedImages = await Image_Picker.pickMultiImage();

        if (pickedImages == null) {
          return;
        }

        final scaffoldMessenger = ScaffoldMessenger.of(context);
        int countSelectedFiles = pickedImages.length;

        if(countSelectedFiles > 2) {

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Text("Uploading $countSelectedFiles items..."),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Cancel upload operation
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              backgroundColor: ThemeColor.mediumGrey,
              
            ),
          );
        }

        for (final pickedFile in pickedImages) {

          final selectedFileName = pickedFile.name;
          _fileType = selectedFileName.split('.').last;

          if (!Globals.imageType.contains(_fileType)) {
            TitledDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported. Try to use Upload Files instead.",context);
            continue;
          }

          if (Globals.fileValues.contains(selectedFileName)) {
            _buildIsAlreadyUploadedDialog(selectedFileName);
            continue;
          } 

          if(countSelectedFiles < 2) {

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Text("Uploading ${shortenText.cutText(selectedFileName)}"),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Cancel upload operation
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
                backgroundColor: ThemeColor.mediumGrey,
                
              ),
            );
          }

          final filePathVal = pickedFile.path.toString();

          List<int> bytes = await _compressedByteImage(path: filePathVal,quality: 85);
          String bodyBytes = base64.encode(bytes);

          if (Globals.imageType.contains(_fileType)) {

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info",fileBase64Encoded: bodyBytes);

          }

          scaffoldMessenger.hideCurrentSnackBar();

          if(countSelectedFiles < 2) {

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("${shortenText.cutText(selectedFileName)} Has been added."),
                duration: const Duration(seconds: 2),
                backgroundColor: ThemeColor.mediumGrey,
              )
            );
            countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;
          }
          
          _addItemToListView(fileName: selectedFileName);

        }

      if(countSelectedFiles >= 2) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("${countSelectedFiles.toString()} Items has been added"),
            duration: const Duration(seconds: 2),
            backgroundColor: ThemeColor.mediumGrey
          )
        );

        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;
      } 

    } catch (failedUpload) {
      print("Exception from _openGalleryImage {main}: $failedUpload");
      SnakeAlert.errorSnake("Upload failed.",context);
    }
  }

  /// <summary>
  /// 
  /// Open file dialog for user to select files to upload
  /// and start retrieving it's file information
  /// File name, data in bytes, etc
  /// 
  /// </summary>
  
  Future<void> _processUploadListView({
    required String filePathVal, 
    required String selectedFileName, 
    required String tableName,
    required String fileBase64Encoded, 
    File? newFileToDisplay,
    dynamic thumbnailBytes}) async {

    final List<File> newImageValues = [];
    final List<File> newFilteredSearchedImage = [];
    final List<Uint8List> newImageByteValues = [];
    final List<Uint8List> newFilteredSearchedBytes = [];

    tableName == "file_info" ? newImageByteValues.add(File(filePathVal).readAsBytesSync()) : newImageByteValues.add(newFileToDisplay!.readAsBytesSync());
    tableName == "file_info" ? newFilteredSearchedBytes.add(File(filePathVal).readAsBytesSync()) : newFilteredSearchedBytes.add(newFileToDisplay!.readAsBytesSync());

    final verifyTableName = Globals.fileOrigin == "dirFiles" ? "upload_info_directory" : tableName;
  
    await _insertUserFile(table: verifyTableName, filePath: selectedFileName, fileValue: fileBase64Encoded,vidThumbnail: thumbnailBytes);

    setState(() {
      Globals.fileOrigin = Globals.fileOrigin == "dirFiles" ? "dirFiles" : "homeFiles";
      Globals.imageValues.addAll(newImageValues);
      Globals.filteredSearchedImage.addAll(newFilteredSearchedImage);
      Globals.imageByteValues.addAll(newImageByteValues);
      Globals.filteredSearchedBytes.addAll(newFilteredSearchedBytes);
      newFileToDisplay != null ? fileToDisplay = newFileToDisplay : null;
    });
  }

  Future<void> _convertDocToPdf({
    required String fileName, 
    required String filePath,
    required String base64Encoded
  }) async {
    
    final getFileName = fileName.replaceFirst(".docx","");

    final scannerPdf = ScannerPdf();

    await scannerPdf.convertDocToPdf(docBase64: base64Encoded);
    await scannerPdf.savePdf(fileName: getFileName,context: context);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$getFileName.pdf');

    final toBase64Encoded = base64.encode(file.readAsBytesSync());

    final newFileToDisplay = await GetAssets().loadAssetsFile("doc0.png");
    await _processUploadListView(filePathVal: file.path, selectedFileName: fileName, tableName: "file_info_word",fileBase64Encoded: toBase64Encoded,newFileToDisplay: newFileToDisplay);

    _addItemToListView(fileName: "$getFileName.docx");

    await file.delete();
  }

  Future<void> _openDialogFile() async {

    try {

        final shortenText = ShortenText();
        final resultPicker = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: true,
          
        );

        if (resultPicker == null) {
          return;
        }

        final scaffoldMessenger = ScaffoldMessenger.of(context);
        int countSelectedFiles = resultPicker.files.length;

        if(countSelectedFiles > 2) {

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Text("Uploading $countSelectedFiles items..."),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Cancel upload operation
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              backgroundColor: ThemeColor.mediumGrey,
              
            ),
          );
        }

        File? newFileToDisplay;

        for (final pickedFile in resultPicker.files) {

          final selectedFileName = pickedFile.name;
          _fileType = selectedFileName.split('.').last;

          if (!Globals.supportedFileTypes.contains(_fileType)) {
            TitledDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported.",context);
            continue;
          }

          if (Globals.fileValues.contains(selectedFileName)) {
            _buildIsAlreadyUploadedDialog(selectedFileName);
            continue;
          }

          if(countSelectedFiles < 2) {

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Text("Uploading ${shortenText.cutText(selectedFileName)}"),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Cancel upload operation
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
                backgroundColor: ThemeColor.mediumGrey,
                
              ),
            );
          }

          final filePathVal = pickedFile.path.toString();

          String? bodyBytes;

          if (_fileType != 'png' && _fileType != 'jpg' && _fileType != 'jpeg' && _fileType != 'webp') {
            bodyBytes = base64.encode(File(filePathVal).readAsBytesSync());
          }

          if (Globals.imageType.contains(_fileType)) {

            List<int> bytes = await _compressedByteImage(path: filePathVal,quality: 85);
            String compressedImageBase64Encoded = base64.encode(bytes);

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info",fileBase64Encoded: compressedImageBase64Encoded);

          } else if (_fileType == "txt" || _fileType == "csv" || _fileType == "html" || _fileType == "sql" || _fileType == "md") {

            newFileToDisplay = _fileType == "txt" || _fileType == "html" || _fileType == "sql" || _fileType == "md" ? await GetAssets().loadAssetsFile("txt0.png") : await GetAssets().loadAssetsFile("csv0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_expand",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (_fileType == "pdf") {

            newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_pdf",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (Globals.videoType.contains(_fileType)) {

            String setupThumbnailName = selectedFileName.replaceRange(selectedFileName.lastIndexOf("."), selectedFileName.length, ".jpeg");

            Directory appDocDir = await getApplicationDocumentsDirectory();
            String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

            Directory tempDir = await getTemporaryDirectory();
            String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

            File thumbnailFile = File(tempThumbnailPath);
            final thumbnailBytes = await VideoThumbnail.thumbnailData(
              video: filePathVal,
              imageFormat: ImageFormat.WEBP,
              quality: 20,
            );

            await thumbnailFile.writeAsBytes(thumbnailBytes!);

            await thumbnailFile.copy(thumbnailPath);

            newFileToDisplay = thumbnailFile;

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_vid",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay,thumbnailBytes: thumbnailBytes);

          } else if (_fileType == "mp3" || _fileType == "wav") {

            newFileToDisplay = await GetAssets().loadAssetsFile("music0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_audi",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (_fileType == "ptx" || _fileType == "pptx") {

            newFileToDisplay = await GetAssets().loadAssetsFile("pptx0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_ptx",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);
          } else if (_fileType == "exe") {

            newFileToDisplay = await GetAssets().loadAssetsFile("exe0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_exe",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (_fileType == "xlsx" || _fileType == "xls") {

            newFileToDisplay = await GetAssets().loadAssetsFile("exl0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_excel",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (_fileType == "docx" || _fileType == "doc") {

            //newFileToDisplay = await getImageFileFromAssets("nice/doc0.png");


            //final docBytes = File(filePathVal).readAsBytesSync();
            await _convertDocToPdf(fileName: selectedFileName,filePath: filePathVal,base64Encoded: bodyBytes!);

            //await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_word",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);

          } else if (_fileType == "apk") {

            newFileToDisplay = await GetAssets().loadAssetsFile("apk0.png");
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_exe",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);
            
          }

          scaffoldMessenger.hideCurrentSnackBar();

          if(countSelectedFiles < 2) {

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Uploading ${shortenText.cutText(selectedFileName)}"),
                duration: const Duration(seconds: 2),
                backgroundColor: ThemeColor.mediumGrey,
              )
            );
          }

          _addItemToListView(fileName: selectedFileName);

        }

        if(countSelectedFiles > 2) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("${countSelectedFiles.toString()} Items has been added"),
              duration: const Duration(seconds: 2),
              backgroundColor: ThemeColor.mediumGrey
            )
          );
        }

      countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished",count: countSelectedFiles) : null;

    } catch (failedUpload) {
      print("Exception from _openDialogFile {main}: $failedUpload");
      SnakeAlert.errorSnake("Upload failed.",context);
    }
  }

  Future<String> _getVideoThumbnail(String videoPath) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String thumbnailPath = '${appDocDir.path}/${path.basename(videoPath)}.jpg';

    Directory tempDir = await getTemporaryDirectory();
    String tempThumbnailPath = '${tempDir.path}/${path.basename(videoPath)}.jpg';

    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.WEBP,
      quality: 30,
    );

    File thumbnailFile = File(tempThumbnailPath);
    await thumbnailFile.writeAsBytes(thumbnailBytes!);

    await thumbnailFile.copy(thumbnailPath);

    return thumbnailPath;
  }

  Future<void> _openDialogFolder() async {

    try {

      final result = await FilePicker.platform.getDirectoryPath();

      if (result == null) {
        return;
      }

      final folderName = path.basename(result);

      if (Globals.foldValues.contains(folderName)) {
        _buildIsAlreadyUploadedDialog(folderName);
        return;
      }

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Uploading $folderName folder..."),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      await _uploadFolder(folderPath: result, folderName: folderName);

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Folder $folderName has been added"),
          duration: const Duration(seconds: 2),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      await CallNotify().customNotification(title: "Folder Uploaded", subMesssage: "$folderName Has been added");

    } catch (err) {
      print("Exception on _openDialogFolder {main}: $err");
      SnakeAlert.errorSnake("Upload failed.",context);
    }
  }

  Future<void> _uploadFolder({
    required String folderPath, 
    required String folderName
    }) async {

    final fileTypes = <String>[];
    final videoThumbnails = <String>[];
    final fileNames = <String>[];
    final fileValues = <String>[];

    final files = Directory(folderPath).listSync().whereType<File>().toList();

    if(files.length == Globals.filesUploadLimit[Globals.accountType]) {
      TitledDialog.startDialog("Couldn't upload $folderName", "It looks like the number of files in this folder exceeded the number of file you can upload. Please upgrade your account plan.", context);
      return;
    }

    for (final folderFile in files) {

      final getFileName = path.basename(folderFile.path);
      final getExtension = getFileName.split('.').last;

      if (Globals.videoType.contains(getExtension)) {

        final thumbnailPath = await _getVideoThumbnail(folderFile.path);
        videoThumbnails.add(thumbnailPath);

      } else if (Globals.imageType.contains(getExtension)) {

        final compressedImage = await _compressedByteImage(
          path: folderFile.path,
          quality: 85,
        );

        final base64Encoded = base64.encode(compressedImage);
        fileValues.add(base64Encoded);

      } else {

        final base64encoded = base64.encode(folderFile.readAsBytesSync());
        fileValues.add(base64encoded);

      }

      fileTypes.add(getExtension);
      fileNames.add(getFileName);
    }

    await CreateFolder().insertParams(
      folderName,
      fileValues,
      fileNames,
      fileTypes,
      videoThumbnail: videoThumbnails,
    );

    setState(() {
      Globals.foldValues.add(folderName);
    });
  }

  Future<void> _openDialogGallery() async {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 250,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Upload from Gallery',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ThemeColor.darkPurple,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _openGalleryImage();
                                },
                                icon: const Icon(Icons.image_rounded,size: 56),
                                color: ThemeColor.darkPurple,
                              ),
                            ),

                            const SizedBox(height: 12),
                            const Text(
                              'Image',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16), 

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ThemeColor.darkPurple,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _openGalleryVideo();
                                },
                                icon: const Icon(Icons.video_collection_rounded,size: 56),
                                color: ThemeColor.darkPurple,
                              ),
                            ),

                            const SizedBox(height: 12),
                            const Text(
                              'Video',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ),
          ),
        );
      },
    );
   
  }

 Widget _buildSidebarButtons({
    required String title, 
    required IconData icon, 
    required VoidCallback onPressed
  }) {
    return InkWell(
      onTap: onPressed,
      splashColor: ThemeColor.secondaryWhite,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        color: Colors.grey,
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          title: Text(
            title,
            style: GlobalsStyle.sidebarMenuButtonsStyle,
          ),
        ),
      ),
    );
  }


  Widget _buildSidebarMenu() {
    return Drawer(
      child: Container(
        color: ThemeColor.darkBlack,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: ThemeColor.darkBlack,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          Globals.custUsername != "" ? Globals.custUsername.substring(0, 2) : "",
                          style: const TextStyle(
                            fontSize: 24,
                            color: ThemeColor.darkPurple,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Globals.custUsername,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            Globals.custEmail,
                            style: const TextStyle(
                              color: Color.fromARGB(255,185,185,185),
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    NavigatePage.goToPageUpgrade(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: ThemeColor.darkPurple,
                  ),
                  child: const Text(
                    'Get more storage',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Divider(color: ThemeColor.mediumGrey),

              Expanded(
                child: ListView(
                  children: [

                    _buildSidebarButtons(
                      title: "Shared to me",
                      icon: Icons.inbox_rounded,
                      onPressed: () async {

                        Globals.fileOrigin = "sharedToMe";
                        appBarTitle.value = "Shared to me";

                        _floatingButtonVisiblity(false);
                        _navDirectoryButtonVisibility(false);
                        _navHomeButtonVisibility(true);
                        
                        Navigator.pop(context);
                        await _callSharingData("sharedToMe");

                      }
                    ),

                    _buildSidebarButtons(
                      title: "Backup recovery key",
                      icon: Icons.key_rounded,
                      onPressed: () {
                        NavigatePage.goToPageBackupRecovery(context);
                      }
                    ),

                    _buildSidebarButtons(
                      title: "Offline files",
                      icon: Icons.wifi_off_rounded,
                      onPressed: () async {
                        Navigator.pop(context);
                        await _callOfflineData();
                      }
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 22.0),
                    child: Text(
                      "Storage Usage",
                      style: TextStyle(
                        color: ThemeColor.thirdWhite,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(

                    padding: const EdgeInsets.only(right: 25.0),
                    child: FutureBuilder<int>(
                      future: _getUsageProgressBar(),
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        return Text(
                          "${snapshot.data.toString()}%",
                          style: const TextStyle(
                            color: ThemeColor.thirdWhite,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 10,
                  width: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ThemeColor.darkGrey,
                      width: 2.0,
                    ),
                  ),
                  child: FutureBuilder<int>(
                    future: _getUsageProgressBar(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                        );
                      }
                      final double progressValue = snapshot.data! / 100.0;
                      return LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
                        value: progressValue,
                      );
                    },
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }

  /// <summary>
  /// 
  /// Dialog to show if the user tried to upload a file 
  /// when they've exceed the number of files they can upload
  /// 
  /// </summary>

  Future _upgradeDialog(String Messages) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ThemeColor.darkGrey,
            title: const Text('Upgrade Account',
            style: TextStyle(
                color: Colors.white
            )),
            content: Text(Messages,
              style: const TextStyle(
                color: Colors.white,
              )),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              ),

              TextButton(
                onPressed: () async {

                  Navigator.pop(context);
                  NavigatePage.goToPageUpgrade(context);

                },
                child: const Text('Upgrade',
                  style: TextStyle(
                    color: ThemeColor.darkPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
              ),

            ],
          );
        },
      );
  }

  Future _buildRenameDialog(String fileName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                       fileName.length > 50 ? "${fileName.substring(0, 50)}..." : fileName,
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: ThemeColor.secondaryWhite),
                    enabled: true,
                    controller: _renameController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter a new name"),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _onRenameCancelled();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _onRenamePressed(fileName);
                            Navigator.pop(context);
                          },
                          style: GlobalsStyle.btnMainStyle,
                          child: const Text('Rename'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }
  
  Future _deleteFileDialog(String fileName) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          title: Text(fileName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Delete this item? Action is permanent.',
            style: TextStyle(color: ThemeColor.secondaryWhite),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _deleteFile(fileName, Globals.fileValues, Globals.filteredSearchedFiles, Globals.imageByteValues, Globals.imageValues, Globals.fromLogin, _onTextChanged);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// <summary>
  /// 
  /// Build bottom share file menu that has 
  /// textifled and buttons on it for user to send
  /// 
  /// </summary>

  

  /// <summary>
  /// 
  /// Build bottom menu when the user clicked on the 
  /// item trailing and shows options:
  /// 
  /// Rename File
  /// Share File
  /// Availale Offline
  /// Remove File
  /// 
  /// </summary>
  
  Future _buildBottomTrailing(String fileName) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      fileName.length > 50 ? "${fileName.substring(0,50)}..." : fileName,
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _buildRenameDialog(fileName);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10.0),
                  Text(
                    'Rename File',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: fileName.split('.').last != fileName,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  SharingDialog().buildSharingDialog(fileName: fileName,shareToController: shareController,commentController: commentController,context: context);
                },
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                  child: const Row(
                  children: [
                    Icon(Icons.share_rounded),
                    SizedBox(width: 10.0),
                    Text('Share File',
                      style: GlobalsStyle.btnBottomDialogTextStyle
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: ThemeColor.thirdWhite),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processSaveOfflineFile(fileName: fileName);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded),
                  SizedBox(width: 10.0),
                  Text('Make available Offline',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),

            const Divider(color: ThemeColor.thirdWhite),

            ElevatedButton(
              onPressed: () async {

                Navigator.pop(context);
                await _callFileDownload(fileName: fileName);
                
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 10.0),
                  Text('Download',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _deleteFileDialog(fileName);
              },

              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.delete,color: ThemeColor.darkRed),
                  SizedBox(width: 10.0),
                  Text('Delete',
                    style: TextStyle(
                      color: ThemeColor.darkRed,
                      fontSize: 17,
                    )
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  /// <summary>
  /// 
  /// Build file search filtering for listView bottom menu 
  /// when the user clicked on "Filter Type" button
  /// 
  /// </summary>

  Widget _buildFilterTypeButtons(String filterName, IconData icon, String filterType) {
    return ElevatedButton.icon(
      onPressed: () {
        _onTextChanged(filterType);
        Navigator.pop(context);
      },
      icon: Icon(icon),
      label: Text(filterName),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(112,25),
        backgroundColor: ThemeColor.mediumGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
      ),
    );
  }

  Future _buildFilterType() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 315,
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Filter Type",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ), 
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                        
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 5),
              
                        _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg,.webp'),
              
                        Row(
              
                          children: [
              
                          _buildFilterTypeButtons("Text",Icons.text_snippet_rounded,'.txt,.html'),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio",Icons.music_note_rounded,'.mp3,.wav'),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Video",Icons.video_collection_rounded,'.mp4,.avi,.mov,.wmv'),
              
                        ],
                      ),
                      ],
                    ),
                      
                    const SizedBox(height: 5),
                      
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 5),
              
                        Row(
                          children: [

                            _buildFilterTypeButtons("PDFs",Icons.picture_as_pdf,'.pdf'),
                            const SizedBox(width: 8),
                            _buildFilterTypeButtons("Sheets",Icons.table_chart,'.xls,.xlsx'),

                          ]
                        ),
              
                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("DOCs",Icons.text_snippet_outlined,'.docx,.doc'),
              
                            const SizedBox(width: 8),
              
                            _buildFilterTypeButtons("CSV",Icons.insert_chart_outlined,'.csv'),
                  
                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("All",Icons.shape_line_rounded,' '),
                                    
                          ],
                        ),
                      ],
                    ),  
                          
                  ],
              
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// <summary>
  /// 
  /// Build shared bottom menu options:
  /// 
  /// Shared to me 
  /// Shared to others
  /// 
  /// </summary>

  Future _buildSharedBottom() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Shared",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () async {

                Globals.fileOrigin = "sharedToMe";
                appBarTitle.value = "Shared to me";

                _floatingButtonVisiblity(false);
                _navDirectoryButtonVisibility(false);
                
                Navigator.pop(context);
                await _callSharingData("sharedToMe");
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 10.0),
                  Text(
                    'Shared to me',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                Globals.fileOrigin = "sharedFiles";
                appBarTitle.value = "Shared files";

                _floatingButtonVisiblity(false);
                _navDirectoryButtonVisibility(false);
                
                Navigator.pop(context);
                await _callSharingData("sharedFiles");
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.upload),
                  SizedBox(width: 10.0),
                  Text(
                    'Shared files',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }

  Future _buildSortItemBottom() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Sort By",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () {
                _sortUploadDate();
                Navigator.pop(context);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  SizedBox(width: 10.0),
                  Text(
                    'Upload Date',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _sortItemName();
                Navigator.pop(context);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  SizedBox(width: 10.0),
                  Text(
                    'Item Name',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                sortingText.value = "Default";
                isAscendingItemName = false;
                isAscendingUploadDate = false;

                await _refreshListView();
                Navigator.pop(context);

              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  SizedBox(width: 10.0),
                  Text(
                    'Default',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildCheckboxItem(int index) {
    return CheckboxTheme(
      data: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.secondaryWhite,
        ),
        checkColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.darkPurple,
        ),
        overlayColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.darkPurple.withOpacity(0.1),
        ),
        side: const BorderSide(
          color: ThemeColor.secondaryWhite,
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
      child: Checkbox(
        value: checkedList[index], 
        onChanged: (bool? value) { 
          _updateCheckboxState(index, value!);
        },
      )
    );
  }

  /// <summary>
  /// 
  /// Main page for listView item when the user added/loaded
  /// files
  /// 
  /// </summary>

  Widget _buildHomeBody(BuildContext context) {

    const double itemExtentValue = 58;
    final double mediaHeight = MediaQuery.of(context).size.height - 325;

    return RefreshIndicator(
      color: ThemeColor.darkPurple,
      onRefresh: () async {
        await _refreshListView();
      },
      child: SizedBox(
        height: mediaHeight,
        child: ListView.builder(
          itemExtent: itemExtentValue,
          itemCount: Globals.filteredSearchedFiles.length,
          itemBuilder: (BuildContext context, int index) {
            
            final fileTitleSearchedValue = Globals.filteredSearchedFiles[index];
            final setLeadingImageSearched = Globals.fromLogin == false &&
                    Globals.filteredSearchedImage.length > index
                ? Image.file(Globals.filteredSearchedImage[index])
                : Globals.filteredSearchedBytes.length > index
                    ? Image.memory(Globals.filteredSearchedBytes[index]!)
                    : null;

            return InkWell(
              onLongPress: () {
                _buildBottomTrailing(Globals.filteredSearchedFiles[index]);
              },
              onTap: () async {
                Globals.selectedFileName = Globals.filteredSearchedFiles[index];
                _fileType = Globals.selectedFileName.split('.').last;

                if (Globals.supportedFileTypes.contains(_fileType)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CakePreviewFile(
                        custUsername: Globals.custUsername,
                        fileValues: Globals.fileValues,
                        selectedFilename: Globals.selectedFileName,
                        originFrom: Globals.fileOrigin,
                        fileType: _fileType,
                      ),
                    ),
                  );
                } else if (_fileType == Globals.selectedFileName) {
                  
                  Globals.fileOrigin = "dirFiles";
                  Globals.directoryTitleValue = Globals.selectedFileName;
                  appBarTitle.value = Globals.selectedFileName;

                  _navDirectoryButtonVisibility(false);
                  
                  final loadingDialog = MultipleTextLoading();

                  loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${Globals.directoryTitleValue} files.",context: context);
                  await _callDirectoryData();

                  loadingDialog.stopLoading();

                  return;
                } else {
                  TitledDialog.startDialog(
                    "Couldn't open ${Globals.selectedFileName}",
                    "It looks like you're trying to open a file which is not supported by Flowstorage",
                    context,
                  );
                }
              },
              child: Ink(
                color: ThemeColor.darkBlack,
                child: ListTile(
                  leading: setLeadingImageSearched != null
                      ? Image(
                          image: setLeadingImageSearched.image,
                          fit: BoxFit.cover,
                          height: 31,
                          width: 31,
                        )
                      : const SizedBox(),
                  trailing: GestureDetector(
                    onTap: () {
                      _buildBottomTrailing(Globals.filteredSearchedFiles[index]);
                    },
                    child: editAllIsPressed
                        ? _buildCheckboxItem(index)
                        : const Icon(Icons.more_vert, color: Colors.white),
                  ),
                  title: Text(
                    fileTitleSearchedValue,
                    style: const TextStyle(
                      color: ThemeColor.justWhite,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    _isFromUpload == true
                        ? Globals.setDateValues[index]
                        : Globals.dateStoresValues[index],
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 12.8,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  /// <summary>
  /// 
  /// Opens a showModalBotom for directory creation
  /// 
  /// </summary>

  Future _buildCreateDirectoryDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      "Create a new Directory",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    autofocus: true,
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: directoryCreateController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter directory name"),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            directoryCreateController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {

                            final getDirectoryTitle = directoryCreateController.text.trim();

                            if(getDirectoryTitle.isEmpty) {
                              return;
                            }

                            if(Globals.fileValues.contains(getDirectoryTitle)) {
                              AlertForm.alertDialog("Directory with this name already exists.",context);
                              return;
                            }

                            await _buildDirectory(getDirectoryTitle);
                            directoryCreateController.clear();
                            Navigator.pop(context);

                          },
                          style: GlobalsStyle.btnMainStyle,
                          child: const Text('Create'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Future _deleteFolderDialog(BuildContext context, String folderName) async {

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          title: Text(folderName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Delete this folder? Action is permanent.',
            style: TextStyle(color: Color.fromARGB(255, 212, 212, 212)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: () async {
                await _deleteFolder(folderName);
                Navigator.pop(context);
              },

              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFolderDialog(BuildContext context, String folderName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      folderName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Text(
                      "Rename this file",
                      style: TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: folderRenameController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter a new name"),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            directoryCreateController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                        onPressed: () async {

                          String newFolderName = folderRenameController.text;
                          if (Globals.foldValues.contains(newFolderName)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: ThemeColor.darkGrey,
                                title: Text(
                                  newFolderName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Folder with this name already exists.',
                                  style: TextStyle(color: Color.fromARGB(255, 212, 212, 212)),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            if (newFolderName.isNotEmpty) {
                              _renameFolder(folderName, newFolderName);
                            } else {
                              AlertForm.alertDialog('Folder name cannot be empty.', context);
                            }
                          }

                          Navigator.pop(context);
                          folderRenameController.clear();

                          },
                          style: GlobalsStyle.btnMainStyle,
                          child: const Text('Rename'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Future _buildFolderBottomTrailing(String folderName) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      folderName.length > 50 ? "${folderName.substring(0,50)}..." : "$folderName Folder",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _renameFolderDialog(context,folderName);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10.0),
                  Text(
                    'Rename Folder',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                // TODO: Download folder

                //final String _fileType = _folderName.split('.').last;
                //await _downloadFile(_fileType,_folderName);
                
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 8.0),
                  Text('Download',
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200),
                        fontSize: 16,
                      )),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteFolderDialog(context,folderName);
              },

              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.delete,color: ThemeColor.darkRed),
                  SizedBox(width: 10.0),
                  Text('Delete',
                    style: TextStyle(
                      color: ThemeColor.darkRed,
                      fontSize: 17,
                    )
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Future _buildFoldersDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, 
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: Globals.foldValues.length,
                  separatorBuilder: (BuildContext context, int index) => const Divider(
                    color: ThemeColor.thirdWhite,
                    height: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () async {

                        Globals.fileOrigin = "folderFiles";
                        Globals.folderTitleValue = Globals.foldValues[index];

                        _floatingButtonVisiblity(false);
                        _navDirectoryButtonVisibility(false);
                        _navHomeButtonVisibility(true);

                        appBarTitle.value = Globals.folderTitleValue;

                        final loadingDialog = MultipleTextLoading();

                        loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${Globals.folderTitleValue} files.",context: context);
                        await _callFolderData(Globals.foldValues[index]);

                        loadingDialog.stopLoading();

                        Navigator.pop(context);

                      },
                      child: Ink(
                        child: ListTile(
                          leading: Image.asset(
                            'assets/nice/dir0.png',
                            width: 35,
                            height: 35,
                          ),
                          title: Text(
                            Globals.foldValues[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              _buildFolderBottomTrailing(Globals.foldValues[index]);
                            },
                            child: const Icon(Icons.more_vert,color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Folders',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        const SizedBox(height: 8),

        Row(

          children: [

            const SizedBox(width: 16),

            ElevatedButton(
              onPressed: () {
                _buildSharedBottom();
              },
              style: GlobalsStyle.btnNavigationBarStyle,
              child: const Row(
                children: [
                  Icon(Icons.share, color: Colors.white),
                  Text(
                    '  Shared',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton(
              onPressed: () async {
                await _initializeCameraScanner();
              },
              style: GlobalsStyle.btnNavigationBarStyle,
              child: const Row(
                children: [
                  Icon(Icons.center_focus_strong_rounded, color: Colors.white),
                  Text(
                    '  Scan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            ValueListenableBuilder<bool>(
              valueListenable: navDirectoryButtonVisible,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: value,
                  child: ElevatedButton(
                    onPressed: () {
                      _buildCreateDirectoryDialog();
                    },
                    style: GlobalsStyle.btnNavigationBarStyle,
                    child: const Row(
                      children: [
                        Icon(Icons.add_box, color: Colors.white),
                        Text(
                          '  Directory',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            ValueListenableBuilder<bool>(
              valueListenable: homeButtonVisible,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: value,
                  child: ElevatedButton(
                    onPressed: () async {
                      appBarTitle.value = "Home";
                      _navDirectoryButtonVisibility(true);
                      _floatingButtonVisiblity(true);
                      _returnBackHomeFiles();
                      await _refreshListView();
                    },
                    style: GlobalsStyle.btnNavigationBarStyle,
                    child: const Row(
                      children: [
                        Icon(Icons.home, color: Colors.white),
                        Text(
                          '  Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _buildSortItemBottom();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ThemeColor.darkBlack,
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: sortingText,
                builder: (BuildContext context, String value, Widget? child) {
                  return Row(
                    children: [
                      Text(
                        '  $value',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,color: Colors.white),
                    ],
                  );
                }
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _buildFilterType();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ThemeColor.darkBlack,
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_list_rounded,size: 25),
                ],
              ),
            ),
          ]
        ),

        const Divider(color: ThemeColor.thirdWhite,height: 0),

      ],
    );
  }


  Widget _buildSearchBar() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _focusNode.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: ThemeColor.mediumGrey,
        ),
        height: 45,
        child: FractionallySizedBox(
          widthFactor: 0.94, 
          child: TextField(
            onChanged: (value) {
              if (value.isEmpty) {
                _focusNode.unfocus();
              }
              _onTextChanged(value);
            },
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(
              color: Color.fromARGB(230, 255, 255, 255)
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: ThemeColor.mediumGrey),
                borderRadius: BorderRadius.circular(25.0),
              ),
              hintText: 'Search your Flowstorage files',
              hintStyle: const TextStyle(color: Color.fromARGB(255, 200,200,200)),
              prefixIcon: const Icon(Icons.search,color: Color.fromARGB(255, 200, 200,200),size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future _buildAddItemBottom() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Add item to Flowstorage",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
      
            ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length != AccountPlan.mapFilesUpload[Globals.accountType]) {
                  Navigator.pop(context);
                  await _openDialogGallery();
                } else {
                  _upgradeDialog(
                    "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                  );
                }
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.photo),
                  SizedBox(width: 10.0),
                  Text(
                    'Upload from Gallery',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),
              
            ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length != AccountPlan.mapFilesUpload[Globals.accountType]) {
                  Navigator.pop(context);
                  await _openDialogFile();
                } else {
                  _upgradeDialog(
                    "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                  );
                }
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.upload_file),
                  SizedBox(width: 10.0),
                  Text(
                    'Upload Files',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: Globals.fileOrigin == "dirFiles" || Globals.fileOrigin == "folderFiles" ? false : true,
              child: ElevatedButton(
              onPressed: () async {

                if(Globals.foldValues.length != AccountPlan.mapFoldersUpload[Globals.accountType]) {
                  await _openDialogFolder();
                  Navigator.pop(context);
                } else {
                  _upgradeDialog("You're currently limited to ${AccountPlan.mapFoldersUpload[Globals.accountType]} folders upload. Upgrade your account plan to upload more folder.");
                }

              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.folder),
                  SizedBox(width: 10.0),
                  Text('Upload Folder',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: ThemeColor.thirdWhite),

          ElevatedButton(
            onPressed: () async {
              if(Globals.fileValues.length != AccountPlan.mapFilesUpload[Globals.accountType]) {
                Navigator.pop(context);
                await _initializeCamera();
              } else {
                _upgradeDialog(
                  "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                );
              }
            },

            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.camera_alt_rounded),
                SizedBox(width: 10.0),
                Text(
                  'Take a photo',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

         ElevatedButton(
            onPressed: () async {
              if(Globals.fileValues.length != AccountPlan.mapFilesUpload[Globals.accountType]) {
                Navigator.pop(context);
                await _initializeCameraScanner();
              } else {
                _upgradeDialog(
                  "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                );
              }
            },

            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.center_focus_strong_rounded),
                SizedBox(width: 10.0),
                Text(
                  'Scan Document',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

          const Divider(color: ThemeColor.thirdWhite),

          ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length != AccountPlan.mapFilesUpload[Globals.accountType]) {
                  Navigator.pop(context);
                  NavigatePage.goToPageCreateText(context);
                } else {
                  _upgradeDialog(
                    "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                  );
                }
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.add_box),
                  SizedBox(width: 10.0),
                  Text(
                    'Create Text file',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),
        
            Visibility(
              visible: Globals.fileOrigin == "dirFiles" || Globals.fileOrigin == "folderFiles" ? false : true,
              child: ElevatedButton(
              onPressed: () async {
                if(await CountDirectory.countTotalDirectory(Globals.custUsername) != AccountPlan.mapDirectoryUpload[Globals.accountType]!) {
                  _buildCreateDirectoryDialog();
                } else {
                  _upgradeDialog("Upgrade your account to upload more directory.");
                }
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.add_box),
                    SizedBox(width: 10.0),
                    Text(
                      'Create Directory',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildCustomBottomBar() {

    int bottomNavigationBarIndex = 0;

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ThemeColor.mediumGrey,
        unselectedItemColor: Colors.grey,
        fixedColor: Colors.grey,
        currentIndex: bottomNavigationBarIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            backgroundColor: ThemeColor.darkPurple,
            label: "My Folder",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_rounded),
            backgroundColor: ThemeColor.darkPurple,
            label: "File Sharing",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            backgroundColor: ThemeColor.darkPurple,
            label: "Statistics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            backgroundColor: ThemeColor.darkPurple,
            label: "Settings"
          ),
        ],
        
        onTap: (indexValue) async {

          switch (indexValue) {
            case 0:
              _buildFoldersDialog();
              break;

            case 1:
              NavigatePage.goToPageSharing(context);
                break;
            
            case 2:
              NavigatePage.goToPageStatistics(context);
              break;

            case 3:
              NavigatePage.goToPageSettings(context);
              
          break;
        }
      },
    );
  }

  Future _deleteSelectAllDialog(int count) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          title: ValueListenableBuilder<String>(
            valueListenable: appBarTitle,
            builder: (BuildContext context, String value, Widget? child) {
              return Text(
                value,
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                ),
              );
            }
          ),
          content: const Text(
            'Delete these items? Action is permanent.',
            style: TextStyle(color: ThemeColor.secondaryWhite),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: () async {

                final loadingDialog = SingleTextLoading();

                loadingDialog.startLoading(title: "Deleting...",context: context);
                await _processDeletingAllItems(count: count);
                loadingDialog.stopLoading();

                Navigator.pop(context);

              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectAll() {
    return IconButton(
      icon: editAllIsPressed ? const Icon(Icons.check) : const Icon(Icons.check_box_outlined,size: 26),
      onPressed: () {
        checkedItemsName.clear();
        _editAllOnPressed();
      },
    );
  }

  Future _buildBottomSelectedItems() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: appBarTitle,
                      builder: (BuildContext context, String value, Widget? child) {
                        return Text(
                          value,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                    )
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _selectDirectoryMultipleSave(checkedItemsName.length);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 10.0),
                  Text(
                    'Save to device',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processSaveOfflineFileSelectAll(count: checkedItemsName.length);
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded),
                  SizedBox(width: 10.0),
                  Text(
                    'Make available offline',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                Navigator.pop(context);
                await _deleteSelectAllDialog(checkedItemsName.length);

              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.delete,color: ThemeColor.darkRed),
                  SizedBox(width: 10.0),
                  Text('Delete',
                    style: TextStyle(
                      color: ThemeColor.darkRed,
                      fontSize: 17,
                    )
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }

  /// <summary>
  /// 
  /// When the user selected (checkbox) more than or one item
  /// then make this button visible and do otherwise if no
  /// item is selected.
  /// 
  /// itemIsChecked: true if at least one item is selected 
  /// otherwise false.
  /// 
  /// </summary>

  Widget _buildMoreOptionsOnSelect() {
    return Visibility(
      visible: itemIsChecked,
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          _buildBottomSelectedItems();
        }
      ),
    );
  }

  /// <summary>
  /// 
  /// Setup greeting on the AppBar text 
  /// based on the current day period
  /// 
  /// </summary>

  String _setupGreetingTime() {

    var timeNow = DateTime.now().hour;

    if (timeNow <= 12) {
      return 'Good morning ';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
    return 'Good afternoon ';
    } else if ((timeNow > 16) && (timeNow < 20)) {
    return 'Good evening ';
    } else {
    return 'Good night ';
    }

  }

  /// <summary>
  /// 
  /// Setup customized appbar which 
  /// included greeting and username
  /// 
  /// </summary>

  PreferredSizeWidget _buildCustomAppBar() {

    final getGreeting = _setupGreetingTime();
    final setupGreeting = "$getGreeting${Globals.custUsername}";
    
    String setupTitle = appBarTitle.value == '' ? setupGreeting : appBarTitle.value;

    return PreferredSize(
      preferredSize: const Size.fromHeight(58),
      child: AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(setupTitle,
          style: GlobalsStyle.appBarTextStyle,
        ),
        actions: [_buildSelectAll(),_buildMoreOptionsOnSelect()],
        leading: IconButton(
          icon: const Icon(Icons.menu,size: 24),
          onPressed: () {
            sidebarMenuScaffoldKey.currentState?.openDrawer();
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: ThemeColor.darkBlack,
      ),
    );
  }

  Widget _buildEmptyBody(BuildContext context) {
    return RefreshIndicator(
      color: ThemeColor.darkPurple,
      onRefresh: () async {
        await _refreshListView();
      },
      child: SizedBox(
        child: ListView(
          shrinkWrap: true,
          children: [

            Visibility(
              visible: Globals.fileValues.isEmpty,
              child: SizedBox(
                height: MediaQuery.of(context).size.height-325,
                child: const Center(
                  child: Text(
                    "It's empty here..",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(248, 94, 93, 93),
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _onTextChanged('');
  }

  @override 
  void dispose() {
    _debounceSearch = null;
    _focusNode.dispose();
    _searchController.dispose();
    _renameController.dispose();
    searchControllerRedudane.dispose();
    focusNodeRedudane.dispose();
    directoryCreateController.dispose();
    shareController.dispose();
    commentController.dispose();
    folderRenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _focusNode.unfocus,
      child: Scaffold(
        key: sidebarMenuScaffoldKey,
        backgroundColor: ThemeColor.darkBlack,
        drawer: _buildSidebarMenu(),
        appBar: _buildCustomAppBar(),
        body: Globals.fileValues.isEmpty 

        ? Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildEmptyBody(context)]) 
        : Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildHomeBody(context)]),

        bottomNavigationBar: _buildCustomBottomBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: floatingActionButtonVisible,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(
              visible: value,
              child: FloatingActionButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                backgroundColor: ThemeColor.darkPurple,
                onPressed: _buildAddItemBottom,
                child: const Icon(Icons.add, color: ThemeColor.darkBlack, size: 30),
              ),
            );
          },
        ),
      ),
    );
  }

}