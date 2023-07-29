
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/directory_query/save_directory.dart';
import 'package:flowstorage_fsc/folder_query/save_folder.dart';
import 'package:flowstorage_fsc/global/global_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/scanner_pdf.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/sharing/share_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/delete_dialog.dart';
import 'package:flowstorage_fsc/public_storage/ps_comment_dialog.dart';
import 'package:flowstorage_fsc/widgets/rename_dialog.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import 'package:flowstorage_fsc/directory_query/count_directory.dart';
import 'package:flowstorage_fsc/directory_query/delete_directory.dart';
import 'package:flowstorage_fsc/directory_query/rename_directory.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/helper/gallery_picker.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/folder_query/delete_folder.dart';
import 'package:flowstorage_fsc/folder_query/rename_folder.dart';
import 'package:flowstorage_fsc/authentication/sign_up_page.dart';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';

import 'package:flowstorage_fsc/folder_query/create_folder.dart';
import 'package:flowstorage_fsc/directory_query/create_directory.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/extra_query/delete.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/extra_query/rename.dart';

import 'splash_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() async {
  runApp(const MainRun());
}

class MainRun extends StatelessWidget {
  const MainRun({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: ThemeColor.darkBlack,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: ThemeColor.darkPurple,
          ), 
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

void homePage() => runApp(
  const MaterialApp(
  home: CakeSignUpPage(),
));

class Mainboard extends StatefulWidget {
  
  const Mainboard({super.key});
  @override
  State<Mainboard> createState() => CakeHomeState();

}

class CakeHomeState extends State<Mainboard> { 

  final GlobalKey<ScaffoldState> sidebarMenuScaffoldKey = GlobalKey<ScaffoldState>();

  final searchBarFocusNode = FocusNode();
  final searchBarController = TextEditingController();

  final focusNodeRedudane = FocusNode();
  final searchControllerRedudane = TextEditingController();

  final folderRenameController = TextEditingController();
  final directoryCreateController = TextEditingController();
  final shareController = TextEditingController();
  final commentController = TextEditingController();

  ValueNotifier<String> appBarTitle  = ValueNotifier<String>('');
  ValueNotifier<String> sortingText  = ValueNotifier<String>('Default');

  ValueNotifier<bool> navDirectoryButtonVisible = ValueNotifier<bool>(true);
  ValueNotifier<bool> floatingActionButtonVisible = ValueNotifier<bool>(true);
  ValueNotifier<bool> homeButtonVisible = ValueNotifier<bool>(false);
  ValueNotifier<bool> staggeredListViewSelected = ValueNotifier<bool>(false);

  ValueNotifier<bool> selectAllItemsIsPressedNotifier = ValueNotifier<bool>(false);
  ValueNotifier<IconData> selectAllItemsIconNotifier = ValueNotifier<IconData>(Icons.check_box_outline_blank);

  ValueNotifier<IconData> ascendingDescendingIconNotifier = ValueNotifier<IconData>(Icons.expand_more);

  bool editAllIsPressed = false;
  bool itemIsChecked = false;

  List<bool> checkedList = List.generate(Globals.filteredSearchedFiles.length, (index) => false);
  List<String> checkedItemsName = [];

  bool isFromUpload = false;
  File? fileToDisplay;

  dynamic leadingImageSearchedValue;
  dynamic fileTitleSearchedValue;

  bool isAscendingItemName = false;
  bool isAscendingUploadDate = false;

  bool isImageBottomTrailingVisible = false;

  Timer? debounceSearchingTimer;
  String fileExtension = '';

  final fileNameGetterHome = NameGetter();
  final dataGetterHome = DataRetriever();
  final dateGetterHome = DateGetter();
  final retrieveData = RetrieveData();
  final insertData = InsertData();
  final dataCaller = DataCaller();

  final crud = Crud();
  final logger = Logger();

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
    dynamic thumbnailBytes,
  }) async {

    final List<File> newImageValues = [];
    final List<File> newFilteredSearchedImage = [];
    final List<Uint8List> newImageByteValues = [];
    final List<Uint8List> newFilteredSearchedBytes = [];

    final isHomeImageOrPsImage = tableName == GlobalsTable.homeImage || tableName == GlobalsTable.psImage;
    final fileToDisplay = newFileToDisplay;

    if (isHomeImageOrPsImage) {
      newImageByteValues.add(File(filePathVal).readAsBytesSync());
      newFilteredSearchedBytes.add(File(filePathVal).readAsBytesSync());
    } else {
      newImageByteValues.add(fileToDisplay!.readAsBytesSync());
      newFilteredSearchedBytes.add(fileToDisplay.readAsBytesSync());
    }

    final verifyTableName = Globals.fileOrigin == "dirFiles" ? GlobalsTable.directoryUploadTable : tableName;

    if (Globals.fileOrigin != "offlineFiles") {
      await _insertUserFile(table: verifyTableName, filePath: selectedFileName, fileValue: fileBase64Encoded, vidThumbnail: thumbnailBytes);
    } else {
      final fileByteData = base64.decode(fileBase64Encoded);
      await OfflineMode().processSaveOfflineFile(fileName: selectedFileName, fileData: fileByteData, context: context);
    }

    final homeImageData = GlobalsData.homeImageData;
    final homeThumbnailData = GlobalsData.homeThumbnailData;

    if (verifyTableName == GlobalsTable.homeImage) {
      homeImageData.addAll(newFilteredSearchedBytes);
    } else if (verifyTableName == GlobalsTable.homeVideo) {
      homeThumbnailData.add(thumbnailBytes);
    } else if (verifyTableName == GlobalsTable.psImage) {
      GlobalsData.psImageData.addAll(newFilteredSearchedBytes);
    } else if (verifyTableName == GlobalsTable.psVideo) {
      GlobalsData.psThumbnailData.add(thumbnailBytes);
    }

    setState(() {});

    Globals.imageValues.addAll(newImageValues);
    Globals.filteredSearchedImage.addAll(newFilteredSearchedImage);
    Globals.imageByteValues.addAll(newImageByteValues);
    Globals.filteredSearchedBytes.addAll(newFilteredSearchedBytes);
  }

  String _getCurrentPageName() {
    final getPageName = appBarTitle.value == "" ? "homeFiles" : appBarTitle.value;
    return getPageName;
  }

  void _clearGlobalData() {
    Globals.fileValues.clear();
    Globals.filteredSearchedFiles.clear();
    Globals.setDateValues.clear();
    Globals.filteredSearchedBytes.clear();
    Globals.filteredSearchedImage.clear();
    Globals.imageValues.clear();
    Globals.imageByteValues.clear();
  }

  void _openPsCommentDialog({
    required String filePathVal,
    required String fileName,
    required String tableName,
    required String base64Encoded,
    File? newFileToDisplay,
    dynamic thumbnail,
  }) async {

    await NotificationApi.stopNotification(0);

    if(!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await PsCommentDialog().buildPsCommentDialog(
      fileName: fileName,
      onUploadPressed: () async { 
        
        SnakeAlert.uploadingSnake(
          snackState: scaffoldMessenger, 
          message: "Uploading ${ShortenText().cutText(fileName)}"
        );

        await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress");

        await _processUploadListView(filePathVal: filePathVal, selectedFileName: fileName,tableName: tableName, fileBase64Encoded: base64Encoded, newFileToDisplay: newFileToDisplay, thumbnailBytes: thumbnail);

        GlobalsData.psTagsValuesData.add(Globals.psTagValue);

        scaffoldMessenger.hideCurrentSnackBar();

        _addItemToListView(fileName: fileName);
        Globals.psUploadPassed = true;

      },
      context: context
    );

    await NotificationApi.stopNotification(0);
    Globals.psUploadPassed == true ? SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${ShortenText().cutText(fileName)} Has been added") : null;
    Globals.psUploadPassed == true ? await CallNotify().uploadedNotification(title: "Upload Finished", count: 1) : null;
    Globals.psUploadPassed = false;

  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog( 
      fileName: fileName, 
      onDeletePressed:() async => await _deleteFile(fileName, Globals.fileValues, Globals.filteredSearchedFiles, Globals.imageByteValues, Globals.imageValues, Globals.fromLogin, _onTextChanged),
      context: context
    );
  }

  void _openRenameDialog(String fileName) {
     RenameDialog().buildRenameFileDialog(
      fileName: fileName, 
      onRenamePressed: () => _onRenamePressed(fileName), 
      context: context
    );
  }

  void _openSharingDialog(String fileName) {
    SharingDialog().buildSharingDialog(
      fileName: fileName, 
      shareToController: shareController,
      commentController: commentController,
      context: context
    );
  }

  void _clearSelectAll() {
    appBarTitle.value = Globals.originToName[Globals.fileOrigin]!;
    setState(() {
      itemIsChecked = false;
      editAllIsPressed = false;
    });
    selectAllItemsIsPressedNotifier.value = false;
    checkedItemsName.clear();
  }

  Future<void> _selectDirectoryMultipleSave(int count) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      await _callMultipleFilesDownload(count: count, directoryPath: directoryPath);
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

        late Uint8List getBytes;

        final fileType = checkedItemsName[i].split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        if(Globals.imageType.contains(fileType)) {
          final fileIndex = Globals.filteredSearchedFiles.indexOf(checkedItemsName[i]);
          getBytes = Globals.filteredSearchedBytes.elementAt(fileIndex)!;
        } else {
          getBytes = await _callData(checkedItemsName[i],tableName!);
        }

        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: checkedItemsName[i], fileData: getBytes);

      }

      loadingDialog.stopLoading();

      if(!mounted) return;
      SnakeAlert.okSnake(message: "$count item(s) has been saved.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save files.",context);
    }

  }

  Future<void> _processSaveOfflineFileSelectAll({required int count}) async {

    try {

      final offlineMode = OfflineMode();

      final singleLoading = SingleTextLoading();
      singleLoading.startLoading(title: "Preparing...", context: context);

      for(int i=0; i<count; i++) {
        
        late final Uint8List fileData;

        final fileType = checkedItemsName[i].split('.').last;

        if(Globals.supportedFileTypes.contains(fileType)) {

          final tableName = Globals.fileTypesToTableNames[fileType]!;

          if(Globals.imageType.contains(fileType)) {
            fileData = Globals.filteredSearchedBytes[Globals.fileValues.indexOf(checkedItemsName[i])]!;
          } else {
            fileData = await _callData(checkedItemsName[i],tableName);
          }

          await offlineMode.saveOfflineFile(fileName: checkedItemsName[i],fileData: fileData);

        } 

      }

      singleLoading.stopLoading();

      if(!mounted) return;
      SnakeAlert.okSnake(message: "${appBarTitle.value} now available offline.",icon: Icons.check,context: context);

      _clearSelectAll();

    } catch (err) {
      SnakeAlert.errorSnake("An error occurred.",context);
    }
  }

  DateTime _parseDate(String dateString) {

    DateTime now = DateTime.now();

    if(dateString == "Directory") {
      return now;
    }
    
    if (dateString.contains('days ago')) {

      int daysAgo = int.parse(dateString.split(' ')[0]);
      
      return now.subtract(Duration(days: daysAgo));

    } else {
      return DateFormat('MMM dd yyyy').parse(dateString);
    }
    
  }

  String _formatDateTime(DateTime dateTime) {

    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    final adjustedDateTime = difference.isNegative ? dateTime.add(const Duration(days: 1)) : dateTime;
    final adjustedDifference = adjustedDateTime.difference(now).inDays.abs();

    if (adjustedDifference == 0) {
      return '0 days ago ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    } else {
      final daysAgoText = '$adjustedDifference days ago';
      return '$daysAgoText ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    }
  }

  void _sortUploadDate() {
    isAscendingUploadDate = !isAscendingUploadDate;
    ascendingDescendingIconNotifier.value = isAscendingUploadDate ? Icons.expand_less : Icons.expand_more;
    sortingText.value = "Upload Date";
    _processUploadDateSorting();
  }

  void _sortItemName() {
    isAscendingItemName = !isAscendingItemName;
    ascendingDescendingIconNotifier.value = isAscendingItemName ? Icons.expand_less : Icons.expand_more;
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
      for (var item in itemList) {
        Globals.filteredSearchedFiles.add(item['file_name']);
        Globals.filteredSearchedBytes.add(item['image_byte']);
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
    isFromUpload = true;
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

      Globals.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress") : null;

      for(var images in imagePath!) {

        File compressedDocImage = await _processImageCompression(path: images,quality: 65); 
        await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
        
      }

      if(!mounted) return;
      await scannerPdf.savePdf(fileName: generateFileName,context: context);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$generateFileName.pdf');

      final toBase64Encoded = base64.encode(file.readAsBytesSync());
      final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.png");

      if(Globals.fileOrigin == "psFiles") {
        _openPsCommentDialog(filePathVal: file.path, fileName: "$generateFileName.pdf",tableName: GlobalsTable.psImage, base64Encoded: toBase64Encoded, newFileToDisplay: newFileToDisplay);
        return;
      } else {
        await _processUploadListView(filePathVal: file.path,selectedFileName: "$generateFileName.pdf",tableName: "file_info_pdf", fileBase64Encoded: toBase64Encoded,newFileToDisplay: newFileToDisplay);
      }

      _addItemToListView(fileName: "$generateFileName.pdf");

      await file.delete();

      await NotificationApi.stopNotification(0);

      if(!mounted) return;
      SnakeAlert.okSnake(message: "$generateFileName.pdf Has been added",icon: Icons.check,context: context);

      await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

    } catch (err, st) {
      logger.e('Exception from _initializeCameraScanner {main}',err, st);
      SnakeAlert.errorSnake("Failed to start scanner.",context);
    }
  }

  /// <summary>
  /// 
  /// Delete all the selected items on checkboxes check
  /// 
  /// </summary>
  
  Future<void> _deleteOfflineFilesSelectAll(String fileName) async {

    final offlineDirPath = await OfflineMode().returnOfflinePath();
    final file = File('${offlineDirPath.path}/$fileName');
    file.deleteSync();

  }

  Future<void> _deleteAllSelectedItems({
    required int count
  }) async {

    late String? query;
    late Map<String,String> params;

    for(int i=0; i<count; i++) {

      if(Globals.fileOrigin == "homeFiles") {

        GlobalsData.homeImageData.clear();
        GlobalsData.homeThumbnailData.clear();

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

      if(!mounted) return;
      SnakeAlert.okSnake(message: "$count item(s) has been deleted.", icon: Icons.check, context: context);

    } catch (err, st) {
      logger.e('Exception from _processDeletingAllItems {main}',err,st);
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
      itemIsChecked = checkedList.where((item) => item == true).isNotEmpty ? true : false;
      value == true ? checkedItemsName.add(Globals.filteredSearchedFiles[index]) : checkedItemsName.removeWhere((item) => item == Globals.filteredSearchedFiles[index]);
    });
    appBarTitle.value = "${(checkedList.where((item) => item == true).length).toString()} item(s) selected";
  }

  /// <summary>
  /// 
  /// File searching functionality implemented
  /// on this function
  /// 
  /// </summary>
  
  void _onTextChanged(String value) {
    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 280), () {
      final searchTerms =
          value.split(",").map((term) => term.trim().toLowerCase()).toList();

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
          leadingImageSearchedValue = Globals.fromLogin == false &&
                  filteredImageValues.isNotEmpty &&
                  filteredImageValues.length > index
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

    } catch (err, st) {
      Globals.accountType = "Basic";
      logger.e('Exception on _getUsageProgressBar (main)',err, st);
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
  
  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(Globals.custUsername, selectedFilename, tableName,Globals.fileOrigin);
  }

  Future<void> _deleteFolder(String folderName) async {
    
    try {

      final deleteClass = DeleteFolder();

      await deleteClass.deletionParams();

      setState(() {
        Globals.foldValues.remove(folderName);
        Globals.fileOrigin = 'homeFiles';
      });

      if(!mounted) return;
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

      if(!mounted) return;
      SnakeAlert.okSnake(message: "`$oldFolderName` Has been renamed to `$newFolderName`", context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to rename this folder.", context);
    }

  }

  Future<void> _callHomeData() async {
    await dataCaller.homeData();
    _navHomeButtonVisibility(false);
  }

  Future<void> _callOfflineData() async {

    await dataCaller.offlineData();
    setState(() {});

    appBarTitle.value = "Offline";
    _clearSelectAll(); 

    _navHomeButtonVisibility(true);
    _navDirectoryButtonVisibility(false);
    _floatingButtonVisiblity(true);
 
  }

  Future<void> _callDirectoryData() async {

    _clearGlobalData();

    await dataCaller.directoryData(directoryName: appBarTitle.value);

    _onTextChanged('');
    searchBarController.text = '';
    _navHomeButtonVisibility(true);

  }

  Future<void> _callSharingData(String originFrom) async {

    _clearGlobalData();

    await dataCaller.sharingData(originFrom);

    _onTextChanged('');
    _navHomeButtonVisibility(true);

  }

  Future<void> _callPublicStorageData() async {

    _clearGlobalData();

    await dataCaller.publicStorageData(context: context);

    appBarTitle.value = "Public Storage";

    _onTextChanged('');
    searchBarController.text = '';

    _navHomeButtonVisibility(true);
    _navDirectoryButtonVisibility(false);
    
  }

  Future<void> _callFolderData(String folderTitle) async {

    _clearGlobalData();

    await dataCaller.folderData(folderName: folderTitle);

    _onTextChanged('');
    searchBarController.text = '';
    _navHomeButtonVisibility(true);

  }

  Future<void> _refreshListView() async {

    _clearGlobalData();

    if(Globals.fileOrigin == "homeFiles") {
      await _callHomeData();
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
    } else if (Globals.fileOrigin == "psFiles") {
      await _callPublicStorageData();
    }
  
    _onTextChanged('');
    searchBarController.text = '';
    sortingText.value = "Default";
    ascendingDescendingIconNotifier.value = Icons.expand_more;

    if(Globals.fileValues.isEmpty) {
      if(!mounted) return;
      _buildEmptyBody(context);
    }

  }

  Future<void> _buildDirectory(String directoryName) async {

    try {

      await DirectoryClass().createDirectory(directoryName, Globals.custUsername);

      final directoryImage = await GetAssets().loadAssetsFile('dir0.png');

      setState(() {

        isFromUpload = true;
        Globals.setDateValues.add("Directory");
        Globals.filteredSearchedImage.add(directoryImage);
        Globals.imageByteValues.add(directoryImage.readAsBytesSync());
        Globals.filteredSearchedBytes.add(directoryImage.readAsBytesSync());
        Globals.imageValues.add(directoryImage);

      });

      GlobalsData.directoryImageData.clear();
      Globals.filteredSearchedFiles.add(directoryName);
      Globals.fileValues.add(directoryName);

      if (!mounted) return;
      SnakeAlert.okSnake(message: "Directory $directoryName has been created.", icon: Icons.check, context: context);

    } catch (err, st) {
      logger.e('Exception from _buildDirectory {main}',err,st);
      CustomAlertDialog.alertDialog('Failed to create directory.', context);
    }
  }
  

  Future<void> _deletionDirectory(String directoryName) async {

    try {

      await DeleteDirectory.deleteDirectory(directoryName: directoryName);
    
      GlobalsData.directoryImageData.clear();

      if(!mounted) return;
      SnakeAlert.okSnake(message: "Directory `$directoryName` has been deleted.",context: context);

    } catch (err, st) {
      logger.e('Exception from _deletionDirectory {main}',err,st);
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
    
    Globals.fileOrigin == "homeFiles" ? GlobalsData.homeImageData.clear() : null;
    Globals.fileOrigin == "homeFiles" ? GlobalsData.homeThumbnailData.clear() : null;
    
    _removeFileFromListView(fileName: fileName, isFromSelectAll: false, onTextChanged: onTextChanged);

  }

  // TODO: Open the user camera and 
  // retrieve photo data, encrypt the byte value

  Future<void> _initializeCamera() async {

    try {

      final takenPhoto = await GalleryImagePicker.pickerImage(source: ImageSource.camera);

      if (takenPhoto == null) {
        return;
      }

      final imageName = takenPhoto.name;
      final imagePath = takenPhoto.path;

      List<int> bytes = await _compressedByteImage(path: imagePath,quality: 56);
      
      final imageBase64Encoded = base64.encode(bytes); 

      if(Globals.fileValues.contains(imageName)) {
        if(!mounted) return;
        CustomFormDialog.startDialog("Upload Failed", "$imageName already exists.",context);
        return;
      }

      if(Globals.fileOrigin == "psFiles") {
        
        _openPsCommentDialog(filePathVal: imagePath, fileName: imageName, tableName: "ps_home_image", base64Encoded: imageBase64Encoded);
        return;

      } else if (Globals.fileOrigin == "offlineFiles") {

        final decodeToBytes = base64.decode(imageBase64Encoded);
        final imageBytes = Uint8List.fromList(decodeToBytes);
        await OfflineMode().saveOfflineFile(fileName: imageName, fileData: imageBytes);

        Globals.filteredSearchedBytes.add(decodeToBytes);
        Globals.imageByteValues.add(decodeToBytes);

      } else {

        await _processUploadListView(
          filePathVal: imagePath, 
          selectedFileName: imageName, 
          tableName: GlobalsTable.homeImage, 
          fileBase64Encoded: imageBase64Encoded
        );
        
      }

      _addItemToListView(fileName: imageName);

      await CallNotify().uploadedNotification(title: "Upload Finished",count: 1);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to start the camera.",context);
    }

  }

  Future<void> _makeAvailableOffline({
    required String fileName
  }) async {

    final offlineMode = OfflineMode();
    final singleLoading = SingleTextLoading();

    final fileType = fileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    const Set<String> unsupportedOfflineModeTypes = {"docx","doc","pptx","ptx","xlsx","xls","mp4","wmv"};

    if(unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.", context);
      return;
    } 

    late final Uint8List fileData;
    final indexFile = Globals.fileValues.indexOf(fileName);

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      fileData = Globals.filteredSearchedBytes[indexFile]!;
    } else {
      fileData = await _callData(fileName,tableName);
    }
    
    if(!mounted) return;
    await offlineMode.processSaveOfflineFile(fileName: fileName,fileData: fileData, context: context);

    singleLoading.stopLoading();
    _clearSelectAll();

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = Globals.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileType] : Globals.fileTypesToTableNames[fileType];

      if(fileType == fileName) {
        await SaveDirectory().selectDirectoryUserDirectory(directoryName: fileName, context: context);
        return;
      }

      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: "File name  $fileName", context: context);

      if(Globals.fileOrigin != "offlineFiles") {

        late Uint8List getBytes;

        if(Globals.imageType.contains(fileType)) {
          int findIndexImage = Globals.filteredSearchedFiles.indexOf(fileName);
          getBytes = Globals.filteredSearchedBytes[findIndexImage]!;
        } else {
          getBytes = await _callData(fileName,tableName!);
        }

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName!,
          fileData: getBytes
        ).downloadFile();

      } else {
        await OfflineMode().downloadFile(fileName);
      } 

      loadingDialog.stopLoading();

      if(!mounted) return;
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

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    setState(() {
      Globals.fileValues[indexOldFile] = newFileName;
      Globals.filteredSearchedFiles[indexOldFileSearched] = newFileName;
    });
  }

  Future<void> _renameFile(String oldFileName, String newFileName) async {
    
    String fileType = oldFileName.split('.').last;
    String tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      Globals.fileOrigin != "offlineFiles" ? await Rename().renameParams(oldFileName, newFileName, tableName) : await OfflineMode().renameFile(oldFileName,newFileName);
      int indexOldFile = Globals.fileValues.indexOf(oldFileName);
      int indexOldFileSearched = Globals.filteredSearchedFiles.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {
        _updateRenameFile(newFileName,indexOldFile,indexOldFileSearched);

        if(!mounted) return;
        SnakeAlert.okSnake(message: "`${ShortenText().cutText(oldFileName)}` Renamed to `${ShortenText().cutText(newFileName)}`.",context: context);
      }

    } catch (err, st) {
      logger.e('Exception from _renameFile {main}',err,st);
      SnakeAlert.errorSnake("Failed to rename this file.",context);
    }
  }

  void _onRenamePressed(String fileName) async {

    try {

      String verifyItemType = fileName.split('.').last;
      String newItemValue = RenameDialog.renameController.text;

      if(verifyItemType == fileName) {

        await _renameDirectory(oldDirName: fileName,newDirName: newItemValue);

        int indexOldFile = Globals.fileValues.indexOf(fileName);
        int indexOldFileSearched = Globals.filteredSearchedFiles.indexOf(fileName);

        _updateRenameFile(newItemValue, indexOldFile, indexOldFileSearched);
        
        return;
      }

      String newRenameValue = "$newItemValue.${fileName.split('.').last}";

      if (Globals.fileValues.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.", context);
      } else {
        await _renameFile(fileName, newRenameValue);
      }
      
    } catch (err, st) {
      logger.e('Exception from _onRenamedPressed {main}',err,st);
    }
  }

  Future<void> _renameDirectory({
    required String oldDirName, 
    required String newDirName
  }) async {

    await RenameDirectory.renameDirectory(oldDirName,newDirName);

    if(!mounted) return;
    SnakeAlert.okSnake(message: "Directory `$oldDirName` renamed to `$newDirName`.",context: context);
  }

  Future<void> _deletionFile(String username, String fileName, String tableName) async {

    try {

      if(Globals.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().Encrypt(fileName);
        await Delete().deletionParams(username: username, fileName: encryptVals, tableName: tableName);

        if(!mounted) return;
        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted",context: context);

      } else {

        await OfflineMode().deleteFile(fileName);

        if(!mounted) return;
        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted",context: context);

      }

    } catch (err, st) {
      logger.e('Exception from _deletionFile {main}',err,st);
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}",context);
    }

  }

  /// <summary>
  /// 
  /// Open user gallery (Video)
  /// 
  /// </summary>
  
  Future<void> _openGalleryVideo() async {
    
    try {

      final shortenText = ShortenText();
      final XFile? pickedVideo = await GalleryImagePicker.pickerVideo(source: ImageSource.gallery);

      if (pickedVideo == null) {
        return;
      }

      File? newFileToDisplay;

      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final selectedFileName = pickedVideo.name;
      fileExtension = selectedFileName.split('.').last;

      if (!Globals.videoType.contains(fileExtension)) {
        if(!mounted) return;
        CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported. Try to use Upload Files instead.",context);
        return;
      }

      if (Globals.fileValues.contains(selectedFileName)) {
        if(!mounted) return;
        CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.",context);
        return;
      } 

      Globals.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...", subMesssage: "1 File(s) in progress") : null;

      Globals.fileOrigin != "psFiles" 
      ? SnakeAlert.uploadingSnake(snackState: scaffoldMessenger, message: "Uploading ${shortenText.cutText(selectedFileName)}") 
      : null;
  
      final filePathVal = pickedVideo.path.toString(); 

      String bodyBytes;
      bodyBytes = base64.encode(File(filePathVal).readAsBytesSync());

      if (Globals.videoType.contains(fileExtension)) {

        String setupThumbnailName = selectedFileName.replaceRange(selectedFileName.lastIndexOf("."), selectedFileName.length, ".jpeg");

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

        Directory tempDir = await getTemporaryDirectory();
        String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

        File thumbnailFile = File(tempThumbnailPath);
        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: filePathVal,
          imageFormat: ImageFormat.JPEG,
          quality: 40,
        );

        await thumbnailFile.writeAsBytes(thumbnailBytes!);

        await thumbnailFile.copy(thumbnailPath);

        newFileToDisplay = thumbnailFile;

        final verifyOrigin = Globals.nameToOrigin[_getCurrentPageName()];

        if(verifyOrigin == "psFiles") {
          _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName,tableName: GlobalsTable.psVideo, base64Encoded: bodyBytes, newFileToDisplay: newFileToDisplay, thumbnail: thumbnailBytes);
          return;
        } else {

          await _processUploadListView(
            filePathVal: filePathVal,
            selectedFileName: selectedFileName,
            tableName: GlobalsTable.homeVideo,
            fileBase64Encoded: bodyBytes,
            newFileToDisplay: newFileToDisplay,
            thumbnailBytes: thumbnailBytes
          );

        }

        await thumbnailFile.delete();

      } 
      
      _addItemToListView(fileName: selectedFileName);

      scaffoldMessenger.hideCurrentSnackBar();
      SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(selectedFileName)} Has been added.");

      await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

    } catch (err, st) {
      logger.e('Exception from _openGalleryVideo {main}',err,st);
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
        final List<XFile>? pickedImages = await GalleryImagePicker.pickMultiImage();

        if (!mounted) return; 
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        int countSelectedFiles = pickedImages!.length;

        if (countSelectedFiles == 0) {
          return;
        }

        if(Globals.fileValues.length + countSelectedFiles > AccountPlan.mapFilesUpload[Globals.accountType]!) {
          _upgradeDialog("It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.");
          return;
        }

        Globals.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...", subMesssage: "$countSelectedFiles File(s) in progress") : null;

        if(countSelectedFiles > 2) {
          SnakeAlert.uploadingSnake(snackState: scaffoldMessenger, message: "Uploading $countSelectedFiles item(s)...");
        }

        for (final pickedFile in pickedImages) {

          final selectedFileName = pickedFile.name;
          fileExtension = selectedFileName.split('.').last;

          if (!Globals.imageType.contains(fileExtension)) {
            if(!mounted) return;
            CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported. Try to use Upload Files instead.",context);
            await NotificationApi.stopNotification(0);
            continue;
          }

          if (Globals.fileValues.contains(selectedFileName)) {
            if(!mounted) return;
            CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.",context);
            await NotificationApi.stopNotification(0);
            continue;
          } 

          if(countSelectedFiles < 2) {
            Globals.fileOrigin != "psFiles" 
            ? SnakeAlert.uploadingSnake(snackState: scaffoldMessenger, message: "Uploading ${shortenText.cutText(selectedFileName)}") 
            : null;
          }

          final filePathVal = pickedFile.path.toString();

          List<int> bytes = await _compressedByteImage(path: filePathVal,quality: 85);
          String bodyBytes = base64.encode(bytes);

          if (Globals.imageType.contains(fileExtension)) {

            final verifyOrigin = Globals.nameToOrigin[_getCurrentPageName()];

            if(verifyOrigin == "psFiles") {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: GlobalsTable.psImage, base64Encoded: bodyBytes);
              return;
            } else {
              await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: bodyBytes);
            }

        }
        
        _addItemToListView(fileName: selectedFileName);
        
        scaffoldMessenger.hideCurrentSnackBar();

        if(countSelectedFiles < 2) {

          SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(selectedFileName)} Has been added.");
          countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

        }

      }

      await NotificationApi.stopNotification(0);

      if(countSelectedFiles >= 2) {

        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${countSelectedFiles.toString()} Items has been added");
        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

      }

    } catch (err, st) {
      logger.e('Exception from _openGalleryImage {main}',err,st);
      SnakeAlert.errorSnake("Upload failed.",context);
    }
  }

  Future<void> _openDialogFile() async {

    try {

        final shortenText = ShortenText();

        const List<String> nonOfflineFileTypes = [...Globals.imageType,...Globals.videoType,...Globals.excelType,...Globals.textType,...Globals.wordType,"pdf","exe","ptx","pptx"];
        const List<String> offlineFileTypes = [...Globals.audioType,...Globals.excelType,...Globals.textType,...Globals.wordType,"pdf","exe","ptx","pptx"];

        final resultPicker = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: Globals.fileOrigin == "offlineFiles" ? offlineFileTypes : nonOfflineFileTypes,
          allowMultiple: Globals.fileOrigin == "psFiles" ? false : true
        );

        if (resultPicker == null) {
          return;
        }

        if(!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        int countSelectedFiles = resultPicker.files.length;

        if(Globals.fileValues.length + countSelectedFiles > AccountPlan.mapFilesUpload[Globals.accountType]!) {
          _upgradeDialog("It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.");
          return;
        }

        Globals.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...", subMesssage: "$countSelectedFiles File(s) in progress") : null;

        if(countSelectedFiles > 2) {
          SnakeAlert.uploadingSnake(
            snackState: scaffoldMessenger, 
            message: "Uploading $countSelectedFiles item(s)..."
          );
        }

        File? newFileToDisplay;

        for (final pickedFile in resultPicker.files) {

          final selectedFileName = pickedFile.name;
          fileExtension = selectedFileName.split('.').last;

          if (!Globals.supportedFileTypes.contains(fileExtension)) {
            if(!mounted) return;
            CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported.",context);
            await NotificationApi.stopNotification(0);
            continue;
          }

          if (Globals.fileValues.contains(selectedFileName)) {
            if(!mounted) return;
            CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.",context);
            await NotificationApi.stopNotification(0);
            continue;
          }

          if(countSelectedFiles < 2) {

            Globals.fileOrigin != "psFiles" 
            ? SnakeAlert.uploadingSnake(
              snackState: scaffoldMessenger, 
              message: "Uploading ${shortenText.cutText(selectedFileName)}"
            ) 
            : null;
          }

          final filePathVal = pickedFile.path.toString();

          String? bodyBytes;

          final verifyOrigin = Globals.nameToOrigin[_getCurrentPageName()];

          if (!(Globals.imageType.contains(fileExtension))) {
            bodyBytes = base64.encode(File(filePathVal).readAsBytesSync());
          }

          if (Globals.imageType.contains(fileExtension)) {

            List<int> bytes = await _compressedByteImage(path: filePathVal,quality: 85);
            String compressedImageBase64Encoded = base64.encode(bytes);

            if(verifyOrigin == "psFiles") {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: GlobalsTable.psImage, base64Encoded: compressedImageBase64Encoded);
              return;
            }

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

          } else if (Globals.videoType.contains(fileExtension)) {

            String setupThumbnailName = selectedFileName.replaceRange(selectedFileName.lastIndexOf("."), selectedFileName.length, ".jpeg");

            Directory appDocDir = await getApplicationDocumentsDirectory();
            String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

            Directory tempDir = await getTemporaryDirectory();
            String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

            File thumbnailFile = File(tempThumbnailPath);
            final thumbnailBytes = await VideoThumbnail.thumbnailData(
              video: filePathVal,
              imageFormat: ImageFormat.JPEG,
              quality: 40,
            );

            await thumbnailFile.writeAsBytes(thumbnailBytes!);

            await thumbnailFile.copy(thumbnailPath);

            newFileToDisplay = thumbnailFile;

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: "file_info_vid",fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay,thumbnailBytes: thumbnailBytes);

          } else {

            final getFileTable = Globals.fileOrigin == "homeFiles" ? Globals.fileTypesToTableNames[fileExtension]! : Globals.fileTypesToTableNamesPs[fileExtension]!;
            newFileToDisplay = await GetAssets().loadAssetsFile(Globals.fileTypeToAssets[fileExtension]!);

            if(verifyOrigin == "psFiles") {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: getFileTable, base64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);
              return;
            }
            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: getFileTable,fileBase64Encoded: bodyBytes!,newFileToDisplay: newFileToDisplay);
          }

          _addItemToListView(fileName: selectedFileName);

          scaffoldMessenger.hideCurrentSnackBar();

          if(countSelectedFiles < 2) {
            SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(selectedFileName)} Has been added");
          }

        }

      if(countSelectedFiles > 2) {
        SnakeAlert.temporarySnake(
          snackState: scaffoldMessenger, 
          message: "${countSelectedFiles.toString()} Items has been added"
        );
      }

      await NotificationApi.stopNotification(0);

      countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished",count: countSelectedFiles) : null;

    } catch (err, st) {
      logger.e('Exception from _openDialogFile {main}',err,st);
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
      imageFormat: ImageFormat.JPEG,
      quality: 40,
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
        if(!mounted) return;
        CustomFormDialog.startDialog("Upload Failed", "$folderName already exists.",context);
        return;
      }

      await CallNotify().customNotification(title: "Uploading folder...", subMesssage: "${ShortenText().cutText(folderName)} In progress");

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Uploading $folderName folder..."),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      await _uploadFolder(folderPath: result, folderName: folderName);

      await NotificationApi.stopNotification(0);

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Folder $folderName has been added"),
          duration: const Duration(seconds: 2),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      await CallNotify().customNotification(title: "Folder Uploaded", subMesssage: "$folderName Has been added");

    } catch (err, st) {
      logger.e('Exception from _openDialogFolder {main}',err,st);
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

    if(files.length == AccountPlan.mapFilesUpload[Globals.accountType]) {
      CustomFormDialog.startDialog("Couldn't upload $folderName", "It looks like the number of files in this folder exceeded the number of file you can upload. Please upgrade your account plan.", context);
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
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: ThemeColor.secondaryWhite,
        child: Ink(
          color: ThemeColor.darkBlack,
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

              const Divider(color: ThemeColor.lightGrey),

              Expanded(
                child: ListView(
                  children: [

                    _buildSidebarButtons(
                      title: "Shared to me",
                      icon: Icons.inbox_outlined,
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
                      icon: Icons.key_outlined,
                      onPressed: () {
                        NavigatePage.goToPageBackupRecovery(context);
                      }
                    ),

                    _buildSidebarButtons(
                      title: "Offline",
                      icon: Icons.offline_bolt_outlined,
                      onPressed: () async {
                        Navigator.pop(context);
                        await _callOfflineData();
                      }
                    ),

                    _buildSidebarButtons(
                      title: "Feedback",
                      icon: Icons.feedback_outlined,
                      onPressed: () async {
                        Navigator.pop(context);
                        NavigatePage.goToPageFeedback(context);
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

  Future _upgradeDialog(String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          title: const Text('Upgrade Account',
          style: TextStyle(
              color: Colors.white
          )),
          content: Text(message,
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
  
  Future _callBottomTrailling(int index) {

    final fileName = Globals.filteredSearchedFiles[index];

    return BottomTrailing().buildBottomTrailing(
        fileName: fileName, 
        onRenamePressed: () {
          Navigator.pop(context);
          _openRenameDialog(fileName);
        }, 
        onDownloadPressed: () async {
          Navigator.pop(context);
          await _callFileDownload(fileName: fileName);
        }, 
        onDeletePressed: () {
          _openDeleteDialog(fileName);
        },
        onSharingPressed: () {
          Navigator.pop(context);
          _openSharingDialog(fileName);
        }, 
        onAOPressed: () async {
          Navigator.pop(context);
          await _makeAvailableOffline(fileName: fileName);
        }, 
        context: context
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
              
                        _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg'),
              
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
                  Icon(Icons.chevron_left),
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
                  Icon(Icons.chevron_right),
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
                ascendingDescendingIconNotifier.value = Icons.expand_more;

                await _refreshListView();
                if(!mounted) return;
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
                              CustomAlertDialog.alertDialog("Directory with this name already exists.",context);
                              return;
                            }

                            await _buildDirectory(getDirectoryTitle);
                            directoryCreateController.clear();
                            if(!mounted) return;
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
                if(!mounted) return;
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
                              CustomAlertDialog.alertDialog('Folder name cannot be empty.', context);
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
                if(Globals.accountType == "Basic") {
                  _upgradeDialog("Upgrade your account to any paid plan to download folder.");
                } else {
                  await SaveFolder().selectDirectoryUserFolder(folderName: folderName, context: context);
                }
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

                        if(!mounted) return;
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
                if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
                  await _initializeCameraScanner();
                } else {
                  _upgradeDialog(
                    "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                  );
                }
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
                    onPressed: () async {
                      final countDirectory = await CountDirectory.countTotalDirectory(Globals.custUsername);
                      if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
                        if(countDirectory != AccountPlan.mapDirectoryUpload[Globals.accountType]!) {
                          _buildCreateDirectoryDialog();
                        } else {
                          _upgradeDialog("You're currently limited to ${AccountPlan.mapDirectoryUpload[Globals.accountType]} directory uploads. Upgrade your account to upload more directory.");
                        }
                      } else {
                        _upgradeDialog(
                          "You're currently limited to ${AccountPlan.mapFilesUpload[Globals.accountType]} uploads. Upgrade your account to upload more."
                        );
                      }
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: ascendingDescendingIconNotifier, 
                        builder: (BuildContext context, IconData value, Widget? child) {
                          return Icon(value, color: Colors.white);
                        }
                      ),
                    ],
                  );
                }
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                staggeredListViewSelected.value = !staggeredListViewSelected.value;
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ThemeColor.darkBlack,
              ),
              child: Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: staggeredListViewSelected,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return value == false ? const Icon(Icons.grid_view,size: 23) : const Icon(Icons.format_list_bulleted_outlined,size: 25);
                    }
                  ),
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
        searchBarFocusNode.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: ThemeColor.mediumGrey,
        ),
        height: 48,
        child: FractionallySizedBox(
          widthFactor: 0.94, 
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    if (value.isEmpty) {
                      searchBarFocusNode.unfocus();
                    }
                    _onTextChanged(value);
                  },
                  controller: searchBarController,
                  focusNode: searchBarFocusNode,
                  style: const TextStyle(
                    color: Color.fromARGB(230, 255, 255, 255)
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                        color: ThemeColor.mediumGrey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ThemeColor.mediumGrey),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    hintText: 'Search in Flowstorage',
                    hintStyle: const TextStyle(color: Color.fromARGB(255, 200,200,200), fontSize: 16),
                    prefixIcon: const Icon(Icons.search,color: Color.fromARGB(255, 200, 200,200),size: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    _buildFilterType();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.only(left: 6, right: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)
                    ),
                  ).copyWith(
                    fixedSize: MaterialStateProperty.all<Size>(const Size(36, 36)),
                  ),
                  child: const Icon(Icons.filter_list_outlined, size: 25),
                ),
              ),
            ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    Globals.fileOrigin != "psFiles" ? "Add item to Flowstorage" : "Upload to Public Storage",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
    
            Visibility(
              visible: VisibilityChecker.setNotVisibleList(["offlineFiles","psFiles"]),
              child: ElevatedButton(
                onPressed: () async {
                  if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
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
            ),

            ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
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
              visible: VisibilityChecker.setNotVisibleList(["offlineFiles","psFiles","dirFiles","folderFiles"]),
              child: ElevatedButton(
              onPressed: () async {

                if(Globals.foldValues.length != AccountPlan.mapFoldersUpload[Globals.accountType]!) {
                  await _openDialogFolder();
                  
                  if(!mounted) return;
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
              if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
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

          Visibility(
            visible: VisibilityChecker.setNotVisible("offlineFiles"),
            child: ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
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
          ),

          const Divider(color: ThemeColor.thirdWhite),

          Visibility(
            visible: VisibilityChecker.setNotVisible("psFiles"),
            child: ElevatedButton(
              onPressed: () async {
                if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
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
            ),
        
            Visibility(
              visible: VisibilityChecker.setNotVisibleList(["psFiles","dirFiles","folderFiles","offlineFiles"]),
              child: ElevatedButton(
              onPressed: () async {
                final countDirectory = await CountDirectory.countTotalDirectory(Globals.custUsername);
                if(Globals.fileValues.length < AccountPlan.mapFilesUpload[Globals.accountType]!) {
                  if(countDirectory != AccountPlan.mapDirectoryUpload[Globals.accountType]!) {

                    if(!mounted) return;
                    Navigator.pop(context);

                    _buildCreateDirectoryDialog();
                    
                  } else {
                    _upgradeDialog("Upgrade your account to upload more directory.");
                  }
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: "Folders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.share_outlined),
            label: "Share",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 25, 
              height: 25,
              child: Image.asset('assets/nice/public_icon.png'),
            ),
            label: "Public",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
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
              await _callPublicStorageData();
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

                final countSelectedItems = checkedList.where((item) => item == true).length;

                final loadingDialog = SingleTextLoading();

                loadingDialog.startLoading(title: "Deleting...",context: context);
                await _processDeletingAllItems(count: countSelectedItems);
                loadingDialog.stopLoading();

                if(!mounted) return;
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
    return Row(
      children: [
        IconButton(
          icon: editAllIsPressed ? const Icon(Icons.check) : const Icon(Icons.check_box_outlined,size: 26),
          onPressed: () {
            checkedItemsName.clear();
            selectAllItemsIconNotifier.value = Icons.check_box_outline_blank;
            editAllIsPressed ? selectAllItemsIsPressedNotifier.value = false : selectAllItemsIsPressedNotifier.value = true;
            _editAllOnPressed();
          },
        ),
        Visibility(
          visible: selectAllItemsIsPressedNotifier.value,
          child: IconButton(
            icon: Icon(selectAllItemsIconNotifier.value, size: 26),
            onPressed: _onSelectAllItemsPressed,
          ),
        ),
      ],
    );
  }

  void _onSelectAllItemsPressed() {
    checkedItemsName.clear();
    for (int i = 0; i < Globals.filteredSearchedFiles.length; i++) {
      final itemsName = Globals.filteredSearchedFiles[i];
      if(itemsName.split('.').last != itemsName) {
        _buildCheckboxItem(i);
        _updateCheckboxState(i, true);
      }
    }
    checkedItemsName.addAll(Globals.filteredSearchedFiles);
    selectAllItemsIsPressedNotifier.value = !selectAllItemsIsPressedNotifier.value;
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
                  Icon(Icons.download_rounded),
                  SizedBox(width: 10.0),
                  Text(
                    'Save to device',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("offlineFiles"),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _processSaveOfflineFileSelectAll(count: checkedItemsName.length);
                },
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt_rounded),
                    SizedBox(width: 10.0),
                    Text(
                      'Make available offline',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
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
      return 'Good morning, ';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
    return 'Good afternoon, ';
    } else if ((timeNow > 16) && (timeNow < 20)) {
    return 'Good evening, ';
    } else {
    return 'Good night, ';
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
      preferredSize: const Size.fromHeight(65),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AppBar(
          titleSpacing: 5,
          elevation: 0,
          centerTitle: false,
          title: Text(setupTitle,
            style: GlobalsStyle.greetingAppBarTextStyle,
          ),
          actions: [
            Visibility(
              visible: VisibilityChecker.setNotVisible("psFiles"),
              child: _buildSelectAll()
            ),
            _buildMoreOptionsOnSelect()
          ],
          leading: IconButton(
            icon: const Icon(Icons.menu,size: 28),
            onPressed: () {
              sidebarMenuScaffoldKey.currentState?.openDrawer();
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: ThemeColor.darkBlack,
        ),
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

  /// <summary>
  /// 
  /// Main page for listView item when the user added/loaded
  /// files
  /// 
  /// </summary>

  void _openFileInExternalApp(Uint8List bytes, String fileName) async {

    try {

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File tempFile = File('$tempPath/$fileName');
      
      await tempFile.writeAsBytes(bytes, flush: true);

      String filePath = tempFile.path;
      final OpenResult result = await OpenFile.open(filePath);

      if(result.type != ResultType.done) {

        if(!mounted) return;
        
        CustomFormDialog.startDialog(
          "Couldn't open ${Globals.selectedFileName}",
          "No default app to open this file found.",
          context,
        );

      }

    } catch (err, st) {
      logger.e(err, st);
    }

  }

  Future<void> _navigateToPreviewFile(int index) async {
    
    const Set<String> externalFileTypes = {"xlsx","xls","docx","doc","ptx","pptx"};

    Globals.selectedFileName = Globals.filteredSearchedFiles[index];
    fileExtension = Globals.selectedFileName.split('.').last;

    if (Globals.supportedFileTypes.contains(fileExtension) && 
      !(externalFileTypes.contains(fileExtension))) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CakePreviewFile(
            custUsername: Globals.custUsername,
            fileValues: Globals.fileValues,
            selectedFilename: Globals.selectedFileName,
            originFrom: Globals.fileOrigin,
            fileType: fileExtension,
            tappedIndex: index
          ),
        ),
      );

    } else if (fileExtension == Globals.selectedFileName && !Globals.supportedFileTypes.contains(fileExtension)) {
      
      Globals.fileOrigin = "dirFiles";
      Globals.directoryTitleValue = Globals.selectedFileName;
      appBarTitle.value = Globals.selectedFileName;

      _navDirectoryButtonVisibility(false);
      
      final loadingDialog = MultipleTextLoading();

      loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${Globals.directoryTitleValue} files.",context: context);
      await _callDirectoryData();

      loadingDialog.stopLoading();

      return;

    } else if (externalFileTypes.contains(fileExtension)) {

      late Uint8List fileData;

      final fileTable = Globals.fileTypesToTableNames[fileExtension]!;

      if(Globals.fileOrigin != "offlineFiles") {
        fileData = await _callData(Globals.selectedFileName, fileTable);
      } else {
        fileData = await OfflineMode().loadOfflineFileByte(Globals.selectedFileName);
      }

      _openFileInExternalApp(fileData, Globals.selectedFileName);

      return;

    } else {

      CustomFormDialog.startDialog(
        "Couldn't open ${Globals.selectedFileName}",
        "It looks like you're trying to open a file which is not supported by Flowstorage",
        context,
      );

    }
  }

  Widget _buildListView() {

    const double itemExtentValue = 58.0;
    const double bottomExtraSpacesHeight = 89.0;

    return RawScrollbar(
      radius: const Radius.circular(38),
      thumbColor: ThemeColor.lightGrey,
      minThumbLength: 5,
      thickness: 3,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
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
              _callBottomTrailling(index);
            },
            onTap: () async {
              await _navigateToPreviewFile(index);
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
                    _callBottomTrailling(index);
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
                  Globals.setDateValues[index],
                  style: TextStyle(
                    color: Globals.fileOrigin != "psFiles" ? ThemeColor.secondaryWhite : GlobalsStyle.psTagsToColor[GlobalsData.psTagsValuesData[index]],
                    fontSize: 12.8,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaggeredItems(int index) {
    Uint8List imageBytes = Globals.filteredSearchedBytes[index]!;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onLongPress: () {
          _callBottomTrailling(index);
        },
        onTap: () async {
          await _navigateToPreviewFile(index);
        },
        child: IntrinsicHeight(
          child: Column(
            children: [
             Expanded(
               child: Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
             ),
              const SizedBox(height: 10),
              Text(
                ShortenText().cutText(Globals.filteredSearchedFiles[index], customLength: 11),
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              if (VisibilityChecker.setNotVisibleList(["homeFiles","sharedToMe","sharedFiles","offlineFiles","folderFiles","dirFiles"]))
              Visibility(
                visible: VisibilityChecker.setNotVisibleList(["homeFiles","sharedToMe","sharedFiles","offlineFiles","folderFiles","dirFiles"]),
                child: Text(
                  GlobalsData.psTagsValuesData[index],
                  style: TextStyle(
                    color: GlobalsStyle.psTagsToColor[GlobalsData.psTagsValuesData[index]],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0,left: 8.0, right: 8.0, bottom: 8.0),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        shrinkWrap: true,
        itemCount: Globals.filteredSearchedFiles.length,
        itemBuilder: (BuildContext context, int index) => _buildStaggeredItems(index),
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
        mainAxisSpacing: 6.5,
        crossAxisSpacing: 6.5,
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {

    final double mediaHeight = MediaQuery.of(context).size.height - 310;

    return RefreshIndicator(
      color: ThemeColor.darkPurple,
      onRefresh: () async {

        if(Globals.fileOrigin == "homeFiles") {
          GlobalsData.homeImageData.clear();
          GlobalsData.homeThumbnailData.clear();
        }
        
        await _refreshListView();
      },
      child: SizedBox(
        height: mediaHeight,
        child: ValueListenableBuilder<bool>(
          valueListenable: staggeredListViewSelected,
          builder: (BuildContext context, bool value, Widget? child) {
            return value == false ? _buildListView() : _buildStaggeredListView();
          }
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
    debounceSearchingTimer!.cancel();
    searchBarFocusNode.dispose();
    searchBarController.dispose();
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
      onTap: searchBarFocusNode.unfocus,
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