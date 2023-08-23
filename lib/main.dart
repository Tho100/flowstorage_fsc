
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/directory_query/save_directory.dart';
import 'package:flowstorage_fsc/folder_query/save_folder.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/helper/date_parser.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/scanner_pdf.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/interact_dialog/upgrade_dialog.dart';
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing/share_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_add_item.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/public_storage/ps_comment_dialog.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_filter.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_shared.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_sorting.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flowstorage_fsc/widgets/navigation_bar.dart';
import 'package:flowstorage_fsc/widgets/sidebar_menu.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:flowstorage_fsc/interact_dialog/folder_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import 'package:flowstorage_fsc/directory_query/delete_directory.dart';
import 'package:flowstorage_fsc/directory_query/rename_directory.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
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
import 'package:get_it/get_it.dart';

void setupLocator() {
  final locator = GetIt.instance;
  locator.registerLazySingleton<UserDataProvider>(() => UserDataProvider());
  locator.registerLazySingleton<StorageDataProvider>(() => StorageDataProvider());
  locator.registerLazySingleton<PsUploadDataProvider>(() => PsUploadDataProvider());
  locator.registerLazySingleton<TempDataProvider>(() => TempDataProvider());
  locator.registerLazySingleton<PsStorageDataProvider>(() => PsStorageDataProvider());
}

void main() async {
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GetIt.instance<UserDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<StorageDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<PsUploadDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<TempDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<PsStorageDataProvider>())
      ],
      child: const MainRun(),
    ),
  );
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

class CakeHomeState extends State<Mainboard> with AutomaticKeepAliveClientMixin { 

  final _locator = GetIt.instance;

  late final UserDataProvider userData;
  late final StorageDataProvider storageData;
  late final PsStorageDataProvider psStorageData;
  late final PsUploadDataProvider psUploadData;
  late final TempDataProvider tempData;

  final fileNameGetterHome = NameGetter();
  final dataGetterHome = DataRetriever();
  final dateGetterHome = DateGetter();
  final retrieveData = RetrieveData();
  final insertData = InsertData();
  final dataCaller = DataCaller();

  final crud = Crud();
  final logger = Logger();

  final sidebarMenuScaffoldKey = GlobalKey<ScaffoldState>();

  final scrollListViewController = ScrollController();

  final searchBarFocusNode = FocusNode();
  final searchBarController = TextEditingController();

  final focusNodeRedudane = FocusNode();
  final searchControllerRedudane = TextEditingController();

  final folderRenameController = TextEditingController();
  final directoryCreateController = TextEditingController();
  final shareController = TextEditingController();
  final commentController = TextEditingController();

  final appBarTitle = ValueNotifier<String>('');
  final sortingText = ValueNotifier<String>('Default');
  final searchHintText = ValueNotifier<String>('Search in Flowstorage');

  final psButtonTextNotifier = ValueNotifier<String>('My Files');

  final navDirectoryButtonVisible = ValueNotifier<bool>(true);
  final floatingActionButtonVisible = ValueNotifier<bool>(true);

  final staggeredListViewSelected = ValueNotifier<bool>(false);
  final selectAllItemsIsPressedNotifier = ValueNotifier<bool>(false);

  final selectAllItemsIconNotifier = ValueNotifier<IconData>(
                                      Icons.check_box_outline_blank);
  final ascendingDescendingIconNotifier = ValueNotifier<IconData>(
                                      Icons.expand_more);

  final searchBarVisibileNotifier = ValueNotifier<bool>(true);

  bool togglePhotosPressed = false;
  bool editAllIsPressed = false;
  bool itemIsChecked = false;

  late List<bool> checkedList = [];

  Set<String> checkedItemsName = {};

  dynamic leadingImageSearchedValue;
  dynamic fileTitleSearchedValue;

  bool isAscendingItemName = false;
  bool isAscendingUploadDate = false;

  bool isImageBottomTrailingVisible = false;

  Timer? debounceSearchingTimer;

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
      userName: userData.username,
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

    final verifyTableName = tempData.fileOrigin == "dirFiles" ? GlobalsTable.directoryUploadTable : tableName;
    if (tempData.fileOrigin != "offlineFiles") {
      await _insertUserFile(table: verifyTableName, filePath: selectedFileName, fileValue: fileBase64Encoded, vidThumbnail: thumbnailBytes);
    } else {
      final fileByteData = base64.decode(fileBase64Encoded);
      await OfflineMode().processSaveOfflineFile(fileName: selectedFileName, fileData: fileByteData, context: context);
    }

    final homeImageData = storageData.homeImageBytesList;
    final homeThumbnailData = storageData.homeThumbnailBytesList;

    if (verifyTableName == GlobalsTable.homeImage) {
      homeImageData.addAll(newFilteredSearchedBytes);
      
    } else if (verifyTableName == GlobalsTable.homeVideo) {
      homeThumbnailData.add(thumbnailBytes);

    } else if (verifyTableName == GlobalsTable.psImage) {
      psStorageData.psImageBytesList.addAll(newFilteredSearchedBytes);
      psStorageData.myPsImageBytesList.addAll(newFilteredSearchedBytes);

    } else if (verifyTableName == GlobalsTable.psVideo) {
      psStorageData.psThumbnailBytesList.add(thumbnailBytes);
      psStorageData.myPsThumbnailBytesList.add(thumbnailBytes);

    }

    setState(() {});

    storageData.imageBytesList.addAll(newImageByteValues);
    storageData.imageBytesFilteredList.addAll(newFilteredSearchedBytes);

  }

  void _addItemToListView({required String fileName}) {
    storageData.fileDateList.add("Just now");
    storageData.fileNamesList.add(fileName);
    storageData.fileNamesFilteredList.add(fileName);
  }

  String _getCurrentPageName() {
    final getPageName = appBarTitle.value == "" ? "homeFiles" : appBarTitle.value;
    return getPageName;
  }

  void _clearPublicStorageData({required bool clearImage}) {
    if(clearImage) {
      psStorageData.psImageBytesList.clear();
      psStorageData.psThumbnailBytesList.clear();
    }
    psStorageData.psUploaderList.clear();
    psStorageData.psTagsList.clear();
    psStorageData.psTagsColorList.clear();
  }

  void _clearGlobalData() {
    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.imageBytesFilteredList.clear();
    storageData.imageBytesList.clear();
  }

  void _togglePhotos() async {

    togglePhotosPressed = !togglePhotosPressed;

    if(togglePhotosPressed) {

      appBarTitle.value = "Photos";
      searchBarVisibileNotifier.value = false;
      staggeredListViewSelected.value = true;

      _navDirectoryButtonVisibility(false);
      _floatingButtonVisiblity(true);

      _onTextChanged('.png,.jpg,.jpeg,.mp4,.mov,.wmv');

    } else {

      appBarTitle.value = Globals.originToName[tempData.fileOrigin]!;
      searchBarVisibileNotifier.value = true;
      staggeredListViewSelected.value = false;

      if(tempData.fileOrigin == "homeFiles" || tempData.fileOrigin == "dirFiles") {
        _navDirectoryButtonVisibility(true);
      }

      _onTextChanged('');

    }

    if(tempData.fileOrigin == "psFiles") {

      _clearPublicStorageData(clearImage: true);
      await _callHomeData();

      _returnBackHomeFiles();
      await _refreshListView();
      
    }

  }

  void _togglePublicStorage() async {
    
    if(tempData.fileOrigin == "psFiles") {
      return;
    }

    if(togglePhotosPressed) {
      togglePhotosPressed = false;
    }

    await _refreshPublicStorage();
  
  }

  void _toggleHome() async {

    if (tempData.fileOrigin == "homeFiles" && !togglePhotosPressed) {
      return;
    }

    if (tempData.fileOrigin == "psFiles") {
      _clearPublicStorageData(clearImage: false);
    }

    if (tempData.fileOrigin == "homeFiles" && togglePhotosPressed) {
      _returnBackHomeFiles();
    } else {
      await _callHomeData();
      _returnBackHomeFiles();
      await _refreshListView();
    }

    _navDirectoryButtonVisibility(true);
    _floatingButtonVisiblity(true);

    togglePhotosPressed = false;
    searchBarVisibileNotifier.value = true;
    staggeredListViewSelected.value = false;

    appBarTitle.value = "Home";
    searchHintText.value = "Search in Flowstorage";

    tempData.fileOrigin == "Home";
    _onTextChanged('');

  }


  Future<void> _refreshPublicStorage() async {
    await _callPublicStorageData(); 
    await Future.delayed(const Duration(milliseconds: 299));
    _sortUploadDate();
    _sortUploadDate();
    _floatingButtonVisiblity(true);
    tempData.setOrigin("psFiles");
  }

  void _scrollEndListView() {
    scrollListViewController.animateTo(
      scrollListViewController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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

    late String? imagePreview = "";

    final fileType = fileName.split('.').last;
    if(Globals.imageType.contains(fileType)) {
      imagePreview = base64Encoded;
    } else if (Globals.videoType.contains(fileType)) {
      imagePreview = base64.encode(thumbnail);
    } 

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

        psStorageData.psTagsList.add(psUploadData.psTagValue);
        psStorageData.psUploaderList.add(userData.username);

        scaffoldMessenger.hideCurrentSnackBar();

        _addItemToListView(fileName: fileName);
        _scrollEndListView();

        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${ShortenText().cutText(fileName)} Has been added");
        await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

      },
      context: context,
      imageBase64Encoded: imagePreview
    );

    await NotificationApi.stopNotification(0);

  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog( 
      fileName: fileName, 
      onDeletePressed:() async => await _deleteFile(fileName, storageData.fileNamesList, storageData.fileNamesFilteredList, storageData.imageBytesList, _onTextChanged),
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
    appBarTitle.value = Globals.originToName[tempData.fileOrigin]!;
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

        final fileType = checkedItemsName.elementAt(i).split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        if(Globals.imageType.contains(fileType)) {
          final fileIndex = storageData.fileNamesFilteredList.indexOf(checkedItemsName.elementAt(i));
          getBytes = storageData.imageBytesFilteredList.elementAt(fileIndex)!;
        } else {
          getBytes = await _callData(checkedItemsName.elementAt(i),tableName!);
        }

        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: checkedItemsName.elementAt(i), fileData: getBytes);

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

        final fileType = checkedItemsName.elementAt(i).split('.').last;

        if(Globals.supportedFileTypes.contains(fileType)) {

          final tableName = Globals.fileTypesToTableNames[fileType]!;

          if(Globals.imageType.contains(fileType)) {
            fileData = storageData.imageBytesFilteredList[storageData.fileNamesList.indexOf(checkedItemsName.elementAt(i))]!;
          } else {
            fileData = await _callData(checkedItemsName.elementAt(i),tableName);
          }

          await offlineMode.saveOfflineFile(fileName: checkedItemsName.elementAt(i),fileData: fileData);

        } 

      }

      singleLoading.stopLoading();

      final countSelectedItems = checkedList.where((item) => item == true).length;

      if(!mounted) return;
      SnakeAlert.okSnake(message: "$countSelectedItems Item(s) now available offline.",icon: Icons.check,context: context);

      _clearSelectAll();

    } catch (err) {
      SnakeAlert.errorSnake("An error occurred.",context);
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
    sortingText.value = tempData.fileOrigin == "psFiles" ? "Default" : "Upload Date";
    _processUploadDateSorting();
  }

  void _sortItemName() {
    isAscendingItemName = !isAscendingItemName;
    ascendingDescendingIconNotifier.value = isAscendingItemName ? Icons.expand_less : Icons.expand_more;
    sortingText.value = "Item Name";
    _processfileNameSorting();
  }

  void _sortDefault() async {
    sortingText.value = "Default";
    isAscendingItemName = false;
    isAscendingUploadDate = false;
    ascendingDescendingIconNotifier.value = Icons.expand_more;
    await _refreshListView();
  }

  void _processUploadDateSorting() {

    final dateParser = DateParser();

    List<Map<String, dynamic>> itemList = [];

    if(tempData.fileOrigin != "psFiles") {

      for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
        itemList.add({
          'file_name': storageData.fileNamesFilteredList[i],
          'image_byte': storageData.imageBytesFilteredList[i],
          'upload_date': dateParser.parseDate(storageData.fileDateList[i]),
        });
      }

    } else {

      for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
        itemList.add({
          'file_name': storageData.fileNamesFilteredList[i],
          'image_byte': storageData.imageBytesFilteredList[i],
          'upload_date': dateParser.parseDate(storageData.fileDateList[i]),
          'tag_value': psStorageData.psTagsList[i],
          'uploader_name': psStorageData.psUploaderList[i]
        });
      }

      psStorageData.psTagsList.clear();
      psStorageData.psUploaderList.clear();

    }

    isAscendingUploadDate 
    ? itemList.sort((a, b) => a['upload_date'].compareTo(b['upload_date']))
    : itemList.sort((a, b) => b['upload_date'].compareTo(a['upload_date']));

    setState(() {

      storageData.fileDateList.clear();
      storageData.fileNamesFilteredList.clear();
      storageData.imageBytesFilteredList.clear();

      for (var item in itemList) {

        storageData.fileNamesFilteredList.add(item['file_name']);
        storageData.imageBytesFilteredList.add(item['image_byte']);
        storageData.fileDateList.add(_formatDateTime(item['upload_date']));

        if(tempData.fileOrigin == "psFiles") {
          psStorageData.psTagsList.add(item['tag_value']);
          psStorageData.psUploaderList.add(item['uploader_name']);
        }

      }
    });

    itemList.clear();

  }

  void _processfileNameSorting() {

   List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      itemList.add({
        'file_name': storageData.fileNamesFilteredList[i],
        'image_byte': storageData.imageBytesFilteredList[i],
      });
    }

    isAscendingItemName 
    ? itemList.sort((a, b) => a['file_name'].compareTo(b['file_name']))
    : itemList.sort((a, b) => b['file_name'].compareTo(a['file_name']));

    setState(() {
      storageData.fileNamesFilteredList.clear();
      storageData.imageBytesFilteredList.clear();
      for (var item in itemList) {
        storageData.fileNamesFilteredList.add(item['file_name']);
        storageData.imageBytesFilteredList.add(item['image_byte']);
      }
    });

    itemList.clear();

  }

  Future<void> _initializeCameraScanner() async {

    try {

      final scannerPdf = ScannerPdf();

      final imagePath = await CunningDocumentScanner.getPictures();
      final generateFileName = Generator.generateRandomString(Generator.generateRandomInt(5,15));

      tempData.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress") : null;

      for(var images in imagePath!) {

        File compressedDocImage = await CompressorApi.processImageCompression(path: images,quality: 65); 
        await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
        
      }

      if(!mounted) return;
      await scannerPdf.savePdf(fileName: generateFileName,context: context);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$generateFileName.pdf');

      final toBase64Encoded = base64.encode(file.readAsBytesSync());
      final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.png");

      if(tempData.fileOrigin == "psFiles") {
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

      final encryptedFileNames = EncryptionClass().encrypt(checkedItemsName.elementAt(i));

      if(tempData.fileOrigin == "homeFiles") {

        storageData.homeImageBytesList.clear();
        storageData.homeThumbnailBytesList.clear();

        final fileType = checkedItemsName.elementAt(i).split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileNames};

      } else if (tempData.fileOrigin == "dirFiles") {

        query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
        params = {'username': userData.username, 'filename': encryptedFileNames,'dirname': EncryptionClass().encrypt(tempData.directoryName)};

      } else if (tempData.fileOrigin == "folderFiles") {
        
        query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
        params = {'username': userData.username, 'filename': encryptedFileNames,'foldname': EncryptionClass().encrypt(tempData.folderName)};

      } else if (tempData.fileOrigin == "sharedToMe") {
      
        query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileNames};

      } else if (tempData.fileOrigin == "sharedFiles") {
        query = "DELETE FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileNames};
      } else if (tempData.fileOrigin == "offlineFiles") {
        query = "";
        params = {};
        _deleteOfflineFilesSelectAll(checkedItemsName.elementAt(i));
      }

      tempData.fileOrigin != "offlineFiles" ? await crud.delete(query: query, params: params) : null;
      await Future.delayed(const Duration(milliseconds: 855));

      _removeFileFromListView(fileName: checkedItemsName.elementAt(i),isFromSelectAll: true, onTextChanged: _onTextChanged);

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
      checkedList = List.generate(storageData.fileNamesFilteredList.length, (index) => false);
    }
    if(!editAllIsPressed) {
      appBarTitle.value = Globals.originToName[tempData.fileOrigin]!;
      setState(() {
        itemIsChecked = false;
      });
    }
  }

  void _updateCheckboxState(int index, bool value) {
    setState(() {
      checkedList[index] = value;
      itemIsChecked = checkedList.where((item) => item == true).isNotEmpty ? true : false;
      value == true ? checkedItemsName.add(storageData.fileNamesFilteredList[index]) : checkedItemsName.removeWhere((item) => item == storageData.fileNamesFilteredList[index]);
    });
    appBarTitle.value = "${(checkedList.where((item) => item == true).length).toString()} item(s) selected";
  }

  /// <summary>
  /// 
  /// File searching functionality implemented
  /// on this function
  /// 
  /// </summary>
  
  void _onTextChanged(String value) async {

    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 299), () {
      final searchTerms =
          value.split(",").map((term) => term.trim().toLowerCase()).toList();

      final filteredFiles = storageData.fileNamesList.where((file) {
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredByteValues = storageData.imageBytesList.where((bytes) {
        final index = storageData.imageBytesList.indexOf(bytes);
        final file = storageData.fileNamesList[index];
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      setState(() {

        storageData.setFilteredFilesName(filteredFiles);
        storageData.setFilteredImageBytes(filteredByteValues);

        if (filteredFiles.isNotEmpty) {
          final index = storageData.fileNamesList.indexOf(filteredFiles.first);
          leadingImageSearchedValue = 
            filteredByteValues.isNotEmpty && filteredByteValues.length > index
            ? Image.memory(filteredByteValues[index]!)
            : null;

        } else {
          leadingImageSearchedValue = null;
        }
      });
    });

  }

  void _filterTypePublicStorage(String value) async {
    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 299), () {
      final searchTerms =
          value.split(",").map((term) => term.trim().toLowerCase()).toList();

      final filteredFiles = storageData.fileNamesFilteredList.where((file) {
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredByteValues = storageData.imageBytesList.where((bytes) {
        final index = storageData.imageBytesList.indexOf(bytes);
        final file = storageData.fileNamesList[index];
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      setState(() {

        storageData.setFilesName(filteredFiles);
        storageData.setFilteredImageBytes(filteredByteValues);
        
        if (filteredFiles.isNotEmpty) {
          final index = storageData.fileNamesList.indexOf(filteredFiles.first);
          leadingImageSearchedValue = 
            filteredByteValues.isNotEmpty && filteredByteValues.length > index
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

      final int maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;
      final int percentage = ((storageData.fileNamesList.length/maxValue) * 100).toInt();

      return percentage;

    } catch (err, st) {
      userData.setAccountType("Basic");
      logger.e('Exception on _getUsageProgressBar (main)',err, st);
      return 0;
    }

  }

  void _floatingButtonVisiblity(bool visible) {
    floatingActionButtonVisible.value = visible;
  }

  void _navDirectoryButtonVisibility(bool visible) {
    navDirectoryButtonVisible.value = visible;
  }

  void _returnBackHomeFiles() {
    setState(() { 
      tempData.setOrigin("homeFiles");
      tempData.setCurrentFolder('');
      tempData.setCurrentDirectory('');
    });
  }
  
  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(userData.username, selectedFilename, tableName,tempData.fileOrigin);
  }

  Future<void> _deleteFolder(String folderName) async {
    
    try {

      final deleteClass = DeleteFolder();

      await deleteClass.deletionParams(folderName: folderName);

      setState(() {
        storageData.foldersNameList.remove(folderName);
        tempData.setOrigin("homeFiles");
      });

      await _refreshListView();
      _navDirectoryButtonVisibility(true);
      _floatingButtonVisiblity(true);

      if(!mounted) return;
      Navigator.pop(context);
      SnakeAlert.okSnake(message: "$folderName Folder has been deleted.",icon: Icons.check,context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to delete this folder.",context);
    }

  }

  Future<void> _renameFolder(String oldFolderName, String newFolderName) async {

    try {

      final renameClass = RenameFolder();
      await renameClass.renameParams(oldFolderTitle: oldFolderName, newFolderTitle: newFolderName);

      int indexOldFolder = storageData.foldersNameList.indexWhere((name) => name == oldFolderName);
      if(indexOldFolder != -1) {
        setState(() {
          storageData.foldersNameList[indexOldFolder] = newFolderName;
        });
      }

      if(!mounted) return;
      SnakeAlert.okSnake(message: "`$oldFolderName` Has been renamed to `$newFolderName`", context: context);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to rename this folder.", context);
    }

  }

  Future<void> _callHomeData() async {

    _clearGlobalData();

    await dataCaller.homeData();
    appBarTitle.value = "Home";
  }

  Future<void> _callOfflineData() async {

    _clearGlobalData();

    await dataCaller.offlineData();
    setState(() {});

    appBarTitle.value = "Offline";
    searchBarVisibileNotifier.value = true;

    _clearSelectAll(); 

    _navDirectoryButtonVisibility(false);
    _floatingButtonVisiblity(true);
 
  }

  Future<void> _callDirectoryData() async {

    _clearGlobalData();

    await dataCaller.directoryData(directoryName: appBarTitle.value);

    _onTextChanged('');
    searchBarController.text = '';
    searchHintText.value = "Search in ${appBarTitle.value}";

  }

  Future<void> _callSharingData(String originFrom) async {

    _clearGlobalData();

    await dataCaller.sharingData(originFrom);

    _onTextChanged('');

  }

  Future<void> _callPublicStorageData() async {

    _clearGlobalData();

    await dataCaller.publicStorageData(context: context);

    appBarTitle.value = "Public Storage";
    psButtonTextNotifier.value = "My Files";

    searchBarVisibileNotifier.value = false;
    staggeredListViewSelected.value = true;

    _onTextChanged('');
    searchBarController.text = '';

    _navDirectoryButtonVisibility(false);
    _floatingButtonVisiblity(true);

  }

  Future<void> _callMyPublicStorageData() async {

    _clearGlobalData();
    _clearPublicStorageData(clearImage: true);

    await dataCaller.myPublicStorageData(context: context);

    appBarTitle.value = "My Public Storage";
    psButtonTextNotifier.value = "Back";
    
    _onTextChanged('');
    searchBarController.text = '';

    _floatingButtonVisiblity(false);

  }

  Future<void> _callFolderData(String folderTitle) async {

    if(appBarTitle.value == folderTitle) {
      return;
    }

    _clearGlobalData();

    await dataCaller.folderData(folderName: folderTitle);
    
    _onTextChanged('');

    _floatingButtonVisiblity(false);
    _navDirectoryButtonVisibility(false);
    
    appBarTitle.value = tempData.folderName;

    searchBarController.text = '';
    searchBarVisibileNotifier.value = true;

  }

  Future<void> _refreshListView() async {

    if(tempData.fileOrigin == "homeFiles") {
      await _callHomeData();
    } else if (tempData.fileOrigin == "sharedFiles") {
      await _callSharingData("sharedFiles");
    } else if (tempData.fileOrigin == "sharedToMe") {
      await _callSharingData("sharedToMe");
    } else if (tempData.fileOrigin == "folderFiles") {
      await _callFolderData(tempData.folderName);
    } else if (tempData.fileOrigin == "dirFiles") {
      await _callDirectoryData();
    } else if (tempData.fileOrigin == "offlineFiles") {
      await _callOfflineData();
    } else if (tempData.fileOrigin == "psFiles") {

      appBarTitle.value == "Public Storage" 
      ? await _refreshPublicStorage()
      : await _callMyPublicStorageData();

    }

    if(tempData.fileOrigin != "psFiles") {

      _onTextChanged('');
      searchBarController.text = '';

      sortingText.value = "Default";
      ascendingDescendingIconNotifier.value = Icons.expand_more;

    }

    if(tempData.fileOrigin == "homeFiles" && togglePhotosPressed) {
      _togglePhotos();
    }

    if(storageData.fileNamesList.isEmpty) {
      if(!mounted) return;
      _buildEmptyBody(context);
    }

  }

  Future<void> _buildDirectory(String directoryName) async {

    try {

      await DirectoryClass().createDirectory(directoryName, userData.username);

      final directoryImage = await GetAssets().loadAssetsFile('dir1.png');

      setState(() {

        storageData.fileDateList.add("Directory");
        storageData.imageBytesList.add(directoryImage.readAsBytesSync());
        storageData.imageBytesFilteredList.add(directoryImage.readAsBytesSync());

      });

      storageData.directoryImageBytesList.clear();
      storageData.fileNamesFilteredList.add(directoryName);
      storageData.fileNamesList.add(directoryName);

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
    
      storageData.directoryImageBytesList.clear();

      if(!mounted) return;
      SnakeAlert.okSnake(message: "Directory `$directoryName` has been deleted.",context: context);

    } catch (err, st) {
      logger.e('Exception from _deletionDirectory {main}',err,st);
      SnakeAlert.errorSnake("Failed to delete $directoryName",context);
    }

  }

  Future<void> _deleteFile(String fileName, List<String> fileValues, List<String> filteredSearchedFiles, List<Uint8List?> imageByteValues, Function onTextChanged) async {

    String extension = fileName.split('.').last;

    if(extension == fileName) {
      await _deletionDirectory(fileName);
    } else {
      await _deletionFile(userData.username,fileName,Globals.fileTypesToTableNames[extension]!);
    }
    
    tempData.fileOrigin == "homeFiles" ? storageData.homeImageBytesList.clear() : null;
    tempData.fileOrigin == "homeFiles" ? storageData.homeImageBytesList.clear() : null;
    
    _removeFileFromListView(fileName: fileName, isFromSelectAll: false, onTextChanged: onTextChanged);

  }

  Future<void> _initializeCamera() async {

    try {

      ImagePickerPlus picker = ImagePickerPlus(context);
      SelectedImagesDetails? details = await picker.pickImage(
        source: ImageSource.camera,
        galleryDisplaySettings: GalleryDisplaySettings(
          maximumSelection: 1,
          appTheme: AppTheme(
            focusColor: Colors.white, 
            primaryColor: ThemeColor.darkBlack,
          ),
        ),
      );

      if (details!.selectedFiles.isEmpty) {
        return;
      }

      for(var photoTaken in details.selectedFiles) {

        final imagePath = photoTaken.selectedFile.toString()
                          .split(" ").last.replaceAll("'", "");

        final imageName = imagePath.split("/").last.replaceAll("'", "");
        final fileExtension = imageName.split('.').last;

        if(!(Globals.imageType.contains(fileExtension))) {
          if(!mounted) return;
          CustomFormDialog.startDialog("Couldn't upload photo","File type is not supported.",context);
          return;
        }

        List<int> bytes = await CompressorApi.compressedByteImage(path: imagePath, quality: 56);
      
        final imageBase64Encoded = base64.encode(bytes); 

        if(storageData.fileNamesList.contains(imageName)) {
          if(!mounted) return;
          CustomFormDialog.startDialog("Upload Failed", "$imageName already exists.",context);
          return;
        }

        if(tempData.fileOrigin == "psFiles") {
          
          _openPsCommentDialog(filePathVal: imagePath, fileName: imageName, tableName: GlobalsTable.psImage, base64Encoded: imageBase64Encoded);
          return;

        } else if (tempData.fileOrigin == "offlineFiles") {

          final decodeToBytes = base64.decode(imageBase64Encoded);
          final imageBytes = Uint8List.fromList(decodeToBytes);
          await OfflineMode().saveOfflineFile(fileName: imageName, fileData: imageBytes);

          storageData.imageBytesFilteredList.add(decodeToBytes);
          storageData.imageBytesList.add(decodeToBytes);

        } else {

          await _processUploadListView(
            filePathVal: imagePath, 
            selectedFileName: imageName, 
            tableName: GlobalsTable.homeImage, 
            fileBase64Encoded: imageBase64Encoded
          );
          
        }

        _addItemToListView(fileName: imageName);

        await File(imagePath).delete();

      }
      
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

    if(Globals.unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.", context);
      return;
    } 

    late final Uint8List fileData;
    final indexFile = storageData.fileNamesList.indexOf(fileName);

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      fileData = storageData.imageBytesFilteredList[indexFile]!;
    } else {
      fileData = await _callData(fileName, tableName);
    }
    
    if(!mounted) return;
    await offlineMode.processSaveOfflineFile(fileName: fileName,fileData: fileData, context: context);

    singleLoading.stopLoading();
    _clearSelectAll();

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = tempData.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileType] : Globals.fileTypesToTableNames[fileType];

      if(fileType == fileName) {
        await SaveDirectory().selectDirectoryUserDirectory(directoryName: fileName, context: context);
        return;
      }

      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: "File name  $fileName", context: context);

      if(tempData.fileOrigin != "offlineFiles") {

        late Uint8List getBytes;

        if(Globals.imageType.contains(fileType)) {
          int findIndexImage = storageData.fileNamesFilteredList.indexOf(fileName);
          getBytes = storageData.imageBytesFilteredList[findIndexImage]!;
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

  void _removeFileFromListView({
    required String fileName, 
    required bool isFromSelectAll, 
    required Function onTextChanged
  }) {

    int indexOfFile = storageData.fileNamesFilteredList.indexOf(fileName);

    isFromSelectAll == true 
    ? setState(() {
      if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
        storageData.fileNamesList.removeAt(indexOfFile);
        storageData.fileNamesFilteredList.removeAt(indexOfFile);
        storageData.imageBytesList.removeAt(indexOfFile);
        storageData.imageBytesFilteredList.removeAt(indexOfFile);
        leadingImageSearchedValue = null;
        fileTitleSearchedValue = null;  
      }         
    }) 
    
    : setState(() {
      if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
        storageData.fileNamesList.removeAt(indexOfFile);
        storageData.fileNamesFilteredList.removeAt(indexOfFile);
        storageData.imageBytesList.removeAt(indexOfFile);
        storageData.imageBytesFilteredList.removeAt(indexOfFile);
        leadingImageSearchedValue = null;
        fileTitleSearchedValue = null;  
      }
      Navigator.pop(context);
    });

    onTextChanged('');

  }

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    setState(() {
      storageData.fileNamesList[indexOldFile] = newFileName;
      storageData.fileNamesFilteredList[indexOldFileSearched] = newFileName;
    });
  }

  Future<void> _renameFile(String oldFileName, String newFileName) async {
    
    String fileType = oldFileName.split('.').last;
    String tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      tempData.fileOrigin != "offlineFiles" ? await Rename().renameParams(oldFileName, newFileName, tableName) : await OfflineMode().renameFile(oldFileName,newFileName);
      int indexOldFile = storageData.fileNamesList.indexOf(oldFileName);
      int indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(oldFileName);

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

        int indexOldFile = storageData.fileNamesList.indexOf(fileName);
        int indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(fileName);

        _updateRenameFile(newItemValue, indexOldFile, indexOldFileSearched);
        
        return;
      }

      String newRenameValue = "$newItemValue.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
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

      if(tempData.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().encrypt(fileName);
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
  /// Open user gallery dialog for photo and video
  /// 
  /// </summary>
  
  Future<void> _openDialogGallery() async {

    try {

      late String? fileBase64Encoded;

      final shortenText = ShortenText();

      ImagePickerPlus picker = ImagePickerPlus(context);
      SelectedImagesDetails? details = await picker.pickBoth(
        source: ImageSource.both,
        multiSelection: true,
        galleryDisplaySettings: GalleryDisplaySettings(
          maximumSelection: 100,
          appTheme: AppTheme(
            focusColor: Colors.white, 
            primaryColor: ThemeColor.darkBlack,
          ),
        ),
      );
      
      int countSelectedFiles = details!.selectedFiles.length;

      if (countSelectedFiles == 0) {
        return;
      }

      if (!mounted) return; 
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      if(storageData.fileNamesList.length + countSelectedFiles > AccountPlan.mapFilesUpload[userData.accountType]!) {
        UpgradeDialog.buildUpgradeDialog(
            message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.", 
            context: context);

        return;
      }

      tempData.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...", subMesssage: "$countSelectedFiles File(s) in progress") : null;

      if(countSelectedFiles > 2) {
        SnakeAlert.uploadingSnake(snackState: scaffoldMessenger, message: "Uploading $countSelectedFiles item(s)...");
      }

      for(var filesPath in details.selectedFiles) {

        final pathToString = filesPath.selectedFile.toString().
                              split(" ").last.replaceAll("'", "");
        
        final filesName = pathToString.split("/").last.replaceAll("'", "");
        final fileExtension = filesName.split('.').last;

        if(!mounted) return;

        if (!Globals.supportedFileTypes.contains(fileExtension)) {
          CustomFormDialog.startDialog("Couldn't upload $filesName","File type is not supported.",context);
          await NotificationApi.stopNotification(0);
          continue;
        }

        if (storageData.fileNamesList.contains(filesName)) {
          CustomFormDialog.startDialog("Upload Failed", "$filesName already exists.",context);
          await NotificationApi.stopNotification(0);
          continue;
        } 

        if(countSelectedFiles < 2) {
          tempData.fileOrigin != "psFiles" 
          ? SnakeAlert.uploadingSnake(snackState: scaffoldMessenger, message: "Uploading ${shortenText.cutText(filesName)}") 
          : null;
        }

        if (!(Globals.imageType.contains(fileExtension))) {
          fileBase64Encoded = base64.encode(File(pathToString).readAsBytesSync());
        } else {
          final filesBytes = File(pathToString).readAsBytesSync();
          fileBase64Encoded = base64.encode(filesBytes);
        }

        final verifyOrigin = Globals.nameToOrigin[_getCurrentPageName()];

        if (Globals.imageType.contains(fileExtension)) {

          List<int> bytes = await CompressorApi.compressedByteImage(path: pathToString, quality: 85);
          String compressedImageBase64Encoded = base64.encode(bytes);

          if(verifyOrigin == "psFiles") {
            _openPsCommentDialog(filePathVal: pathToString, fileName: filesName, tableName: GlobalsTable.psImage, base64Encoded: fileBase64Encoded);
            return;
          }

          await _processUploadListView(filePathVal: pathToString, selectedFileName: filesName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

        } else if (Globals.videoType.contains(fileExtension)) {

          String setupThumbnailName = filesName.replaceRange(filesName.lastIndexOf("."), filesName.length, ".jpeg");

          Directory appDocDir = await getApplicationDocumentsDirectory();
          String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

          Directory tempDir = await getTemporaryDirectory();
          String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

          File thumbnailFile = File(tempThumbnailPath);
          final thumbnailBytes = await VideoThumbnail.thumbnailData(
            video: pathToString,
            imageFormat: ImageFormat.JPEG,
            quality: 40,
          );

          await thumbnailFile.writeAsBytes(thumbnailBytes!);

          await thumbnailFile.copy(thumbnailPath);

          if(verifyOrigin == "psFiles") {

            _openPsCommentDialog(
              filePathVal: pathToString, fileName: filesName, 
              tableName: GlobalsTable.psVideo, base64Encoded: fileBase64Encoded,
              thumbnail: thumbnailBytes
            );

            return;
          } 

          await _processUploadListView(
            filePathVal: pathToString, 
            selectedFileName: filesName, 
            tableName: GlobalsTable.homeVideo, 
            fileBase64Encoded: fileBase64Encoded,
            newFileToDisplay: thumbnailFile,
            thumbnailBytes: thumbnailBytes
          );

          await thumbnailFile.delete();

        }

        _addItemToListView(fileName: filesName);

        scaffoldMessenger.hideCurrentSnackBar();

        if(countSelectedFiles < 2) {

          SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(filesName)} Has been added.");
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

        late String? fileBase64;
        late File? newFileToDisplayPath;

        final verifyOrigin = Globals.nameToOrigin[_getCurrentPageName()];
        final shortenText = ShortenText();

        const List<String> nonOfflineFileTypes = [...Globals.imageType, ...Globals.audioType, ...Globals.videoType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];
        const List<String> offlineFileTypes = [...Globals.audioType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];

        final resultPicker = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: tempData.fileOrigin == "offlineFiles" ? offlineFileTypes : nonOfflineFileTypes,
          allowMultiple: tempData.fileOrigin == "psFiles" ? false : true
        );

        if (resultPicker == null) {
          return;
        }

        if(!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        int countSelectedFiles = resultPicker.files.length;

        final uploadedPsFilesCount = psStorageData.psUploaderList.where((name) => name == userData.username).length;
        final allowedFileUploads = AccountPlan.mapFilesUpload[userData.accountType]!;

        if (tempData.fileOrigin == "psFiles" && uploadedPsFilesCount > allowedFileUploads) {
          UpgradeDialog.buildUpgradeDialog(
            message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.",
            context: context,
          ); return;
        } else if (tempData.fileOrigin != "psFiles" && storageData.fileNamesList.length + countSelectedFiles > allowedFileUploads) {
          UpgradeDialog.buildUpgradeDialog(
            message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.",
            context: context,
          ); return;
        }

        tempData.fileOrigin != "psFiles" ? await CallNotify().customNotification(title: "Uploading...", subMesssage: "$countSelectedFiles File(s) in progress") : null;

        if(countSelectedFiles > 2) {
          SnakeAlert.uploadingSnake(
            snackState: scaffoldMessenger, 
            message: "Uploading $countSelectedFiles item(s)..."
          );
        }

        for (final pickedFile in resultPicker.files) {

          final selectedFileName = pickedFile.name;
          final fileExtension = selectedFileName.split('.').last;

          if(!mounted) return;

          if (!Globals.supportedFileTypes.contains(fileExtension)) {
            CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported.",context);
            await NotificationApi.stopNotification(0);
            continue;
          }

          if (storageData.fileNamesList.contains(selectedFileName)) {
            CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.",context);
            await NotificationApi.stopNotification(0);
            continue;
          }

          if(countSelectedFiles < 2) {

            tempData.fileOrigin != "psFiles" 
            ? SnakeAlert.uploadingSnake(
              snackState: scaffoldMessenger, 
              message: "Uploading ${shortenText.cutText(selectedFileName)}"
            ) 
            : null;
          }

          final filePathVal = pickedFile.path.toString();

          if (!(Globals.imageType.contains(fileExtension))) {
            fileBase64 = base64.encode(File(filePathVal).readAsBytesSync());
          }

          if (Globals.imageType.contains(fileExtension)) {

            List<int> bytes = await CompressorApi.compressedByteImage(path: filePathVal,quality: 85);
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

            newFileToDisplayPath = thumbnailFile;

            if(verifyOrigin == "psFiles") {

              _openPsCommentDialog(
                filePathVal: filePathVal, fileName: selectedFileName, 
                tableName: GlobalsTable.psVideo, base64Encoded: fileBase64!,
                newFileToDisplay: newFileToDisplayPath, thumbnail: thumbnailBytes
              );

              return;

            }

            await _processUploadListView(
              filePathVal: filePathVal, selectedFileName: selectedFileName, 
              tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64!, 
              newFileToDisplay: newFileToDisplayPath, thumbnailBytes: thumbnailBytes
            );

            await thumbnailFile.delete();

          } else {

            final getFileTable = tempData.fileOrigin == "homeFiles" ? Globals.fileTypesToTableNames[fileExtension]! : Globals.fileTypesToTableNamesPs[fileExtension]!;
            newFileToDisplayPath = await GetAssets().loadAssetsFile(Globals.fileTypeToAssets[fileExtension]!);

            if(verifyOrigin == "psFiles") {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: getFileTable, base64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
              return;
            }

            await _processUploadListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: getFileTable,fileBase64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
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
      if(!mounted) return;
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

      if (storageData.foldersNameList.contains(folderName)) {
        if(!mounted) return;
        CustomFormDialog.startDialog("Upload Failed", "$folderName already exists.",context);
        return;
      }

      await CallNotify().customNotification(title: "Uploading folder...", subMesssage: "${ShortenText().cutText(folderName)} In progress");

      if(!mounted) return;
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

    if(files.length == AccountPlan.mapFilesUpload[userData.accountType]) {
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

        final compressedImage = await CompressorApi.compressedByteImage(
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
    
    final formattedDate = 
      DateFormat('dd/MM/yyyy').format(DateTime.now()); 

    await CreateFolder(EncryptionClass(), formattedDate).insertParams(
      titleFolder: folderName,
      fileValues: fileValues,
      fileNames: fileNames,
      fileTypes: fileTypes,
      videoThumbnail: videoThumbnails,
    );

    setState(() {
      storageData.foldersNameList.add(folderName);
    });
  }

  Future _callBottomTrailling(int index) {

    final fileName = storageData.fileNamesFilteredList[index];

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

  Future _callBottomTrailingAddItem() {

    late String headerText = "";

    if(tempData.fileOrigin == "psFiles") {
      headerText = "Upload to Public Storage";
    } else if (tempData.fileOrigin == "dirFiles") {
      headerText = "Add item to ${appBarTitle.value}";
    } else {
      headerText = "Add item to Flowstorage";
    }
    
    final limitUpload = AccountPlan.mapFilesUpload[userData.accountType]!;

    final bottomTrailingAddItem = BottomTrailingAddItem();
    return bottomTrailingAddItem.buildTrailing(
      headerText: headerText, 
      galleryOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          await _openDialogGallery();
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
            context: context
          );
        }

      }, 
      fileOnPressed: () async {

        if (tempData.fileOrigin == "psFiles") {

          int count = psStorageData.psUploaderList
              .where((uploader) => uploader == userData.username)
              .length;

          if (count < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
              context: context
            );
          } 

        } else {

          if(storageData.fileNamesList.length < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
              context: context
            );
          }
        }

      }, 
      folderOnPressed: () async {

        if(storageData.foldersNameList.length != AccountPlan.mapFoldersUpload[userData.accountType]!) {
          await _openDialogFolder();
          
          if(!mounted) return;
          Navigator.pop(context);

        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFoldersUpload[userData.accountType]} folders upload. Upgrade your account plan to upload more folder.",
            context: context
          );
        }

      }, 
      photoOnPressed: () async {

        if (tempData.fileOrigin == "psFiles") {

          int count = psStorageData.psUploaderList
              .where((uploader) => uploader == userData.username)
              .length;

          if (count < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
              context: context
            );
          }

        } else {

          if (storageData.fileNamesList.length < limitUpload) {
            Navigator.pop(context);
            await _initializeCamera();
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
              context: context
            );
          }

        }

      }, 
      scannerOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          await _initializeCameraScanner();
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
            context: context
          );
        }

      }, 
      textOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          NavigatePage.goToPageCreateText(context);
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to $limitUpload uploads. Upgrade your account to upload more.",
            context: context
          );
        }

      }, 
      directoryOnPressed: () async {

        final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
        if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
          if(countDirectory != AccountPlan.mapDirectoryUpload[userData.accountType]!) {

            if(!mounted) return;
            Navigator.pop(context);

            _buildCreateDirectoryDialog();
            
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "Upgrade your account to upload more directory.",
              context: context
            );
          }
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
            context: context
          );
        }

      }, 
      context: context
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

  Future _callBottomTrailingShared() {
    final bottomTrailingShared = BottomTrailingShared();
    return bottomTrailingShared.buildTrailing(
      context: context, 
      sharedToMeOnPressed: () async {

        tempData.setOrigin("sharedToMe");
        appBarTitle.value = "Shared to me";
        _floatingButtonVisiblity(false);
        _navDirectoryButtonVisibility(false);
        Navigator.pop(context);

        await _callSharingData("sharedToMe");
      }, 
      sharedToOthersOnPressed: () async {
        tempData.setOrigin("sharedFiles");
        appBarTitle.value = "Shared files";
        
        _floatingButtonVisiblity(false);
        _navDirectoryButtonVisibility(false);
        Navigator.pop(context);

        await _callSharingData("sharedFiles");
      }
    );
  }

  Future _callBottomTrailingSorting() {
    final sortingBottomTrailing = BottomTrailingSorting();
    return sortingBottomTrailing.buildTrailing(
      context: context, 
      sortUploadDateOnPressed: () {
        _sortUploadDate();
        Navigator.pop(context);
      },
      sortItemNameOnPressed: () {
        _sortItemName();
        Navigator.pop(context);
      }, 
      sortDefaultOnPressed: () {
        _sortDefault();
        Navigator.pop(context);
      }
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
                      "Create new Directory",
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
                      child: MainDialogButton(
                        text: "Cancel",
                        onPressed: () {
                          directoryCreateController.clear();
                          Navigator.pop(context);
                        },
                        isButtonClose: true,
                      )
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MainDialogButton(
                        text: "Create",
                        onPressed: () async {

                          final getDirectoryTitle = directoryCreateController.text.trim();

                          if(getDirectoryTitle.isEmpty) {
                            return;
                          }

                          if(storageData.fileNamesList.contains(getDirectoryTitle)) {
                            CustomAlertDialog.alertDialog("Directory with this name already exists.",context);
                            return;
                          }

                          await _buildDirectory(getDirectoryTitle);
                          directoryCreateController.clear();
                          if(!mounted) return;
                          Navigator.pop(context);

                        },
                        isButtonClose: false,
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

                          if (storageData.foldersNameList.contains(newFolderName)) {
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
                              await _renameFolder(folderName, newFolderName);
                            } else {
                              CustomAlertDialog.alertDialog('Folder name cannot be empty.', context);
                            }
                          }

                          if(!mounted) return;
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
                if(userData.accountType == "Basic") {
                  UpgradeDialog.buildUpgradeDialog(
                    message: "Upgrade your account to any paid plan to download folder.",
                    context: context
                  );
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

    final folderDialog = FolderDialog();
    folderDialog.buildFolderDialog(
      folderOnPressed: (int index) async {
        
        final loadingDialog = MultipleTextLoading();

        tempData.setCurrentFolder(storageData.foldersNameList[index]);

        loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${tempData.folderName} files.",context: context);
        await _callFolderData(storageData.foldersNameList[index]);

        loadingDialog.stopLoading();

        if(!mounted) return;
        Navigator.pop(context);

      },
      trailingOnPressed: (int index) {
        _buildFolderBottomTrailing(storageData.foldersNameList[index]);
      }, 
      context: context
    );

  }

  Widget _buildNavigationButtons() {
    return Visibility(
      visible: !togglePhotosPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
    
          tempData.fileOrigin == "psFiles" 
          ? const SizedBox(height: 0)
          : const SizedBox(height: 8),
    
          if(tempData.fileOrigin != "psFiles") ... [
            Row(
            
              children: [
          
                const SizedBox(width: 16),
          
                ElevatedButton(
                  onPressed: () {
                    _callBottomTrailingShared();
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
                    if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
                      await _initializeCameraScanner();
                    } else {
                      UpgradeDialog.buildUpgradeDialog(
                        message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
                        context: context
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
                          final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
                          if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
                            if(countDirectory != AccountPlan.mapDirectoryUpload[userData.accountType]!) {
                              _buildCreateDirectoryDialog();
                            } else {
                              UpgradeDialog.buildUpgradeDialog(
                                message: "You're currently limited to ${AccountPlan.mapDirectoryUpload[userData.accountType]} directory uploads. Upgrade your account to upload more directory.",
                                context: context
                              );
                            }
                          } else {
                            UpgradeDialog.buildUpgradeDialog(
                              message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
                              context: context
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
          
              ],
            ),
          ],
    
          tempData.fileOrigin == "psFiles" 
          ? const SizedBox(height: 0)
          : const SizedBox(height: 8),
    
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _callBottomTrailingSorting();
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
    
              if(tempData.fileOrigin == "psFiles")
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    final bottomTrailingFilter = BottomTrailingFilter();
                    bottomTrailingFilter.buildFilterTypeAll(
                      filterTypePublicStorage: _filterTypePublicStorage, 
                      filterTypeNormal: _onTextChanged, 
                      context: context
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.only(left: 6, right: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)
                    ),
                  ).copyWith(
                    fixedSize: MaterialStateProperty.all<Size>(const Size(36, 36)),
                  ),
                  child: const Icon(Icons.filter_list_outlined, size: 27),
                ),
              ),
    
              if(tempData.fileOrigin != "psFiles")
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
    
          const Divider(color: ThemeColor.thirdWhite, height: 0),
          
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ValueListenableBuilder(
      valueListenable: searchBarVisibileNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: GestureDetector(
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
                          hintText: tempData.fileOrigin != "psFiles" 
                            ? searchHintText.value 
                            : "Search in Public Storage",
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 200,200,200), fontSize: 16),
                          prefixIcon: const Icon(Icons.search,color: Color.fromARGB(255, 200, 200,200),size: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final bottomTrailingFilter = BottomTrailingFilter();
                          bottomTrailingFilter.buildFilterTypeAll(
                            filterTypePublicStorage: _filterTypePublicStorage, 
                            filterTypeNormal: _onTextChanged, 
                            context: context
                          );
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
          ),
        );
      }
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
    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      final itemsName = storageData.fileNamesFilteredList[i];
      if(itemsName.split('.').last != itemsName) {
        _buildCheckboxItem(i);
        _updateCheckboxState(i, true);
      }
    }
    checkedItemsName.addAll(storageData.fileNamesFilteredList);
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

  Widget _buildTunePhotosType() {
    return IconButton(
      onPressed: () {
        final bottomTrailingFilter = BottomTrailingFilter();
        bottomTrailingFilter.buildFilterTypePhotos(
          filterTypePublicStorage: _filterTypePublicStorage, 
          filterTypeNormal: _onTextChanged, 
          context: context
        );
      },
      icon: const Icon(Icons.tune_outlined, 
        color: Colors.white, size: 26),
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
    final setupGreeting = "$getGreeting${userData.username}";

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

            if(tempData.fileOrigin != "psFiles" && togglePhotosPressed == false)
            _buildSelectAll(),

            _buildMoreOptionsOnSelect(),

            if(togglePhotosPressed)
            _buildTunePhotosType(),

            if(tempData.fileOrigin == "psFiles") 
            _buildMyPsFilesButton()

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
              visible: storageData.fileNamesList.isEmpty,
              child: SizedBox(
                height: MediaQuery.of(context).size.height-375,
                child: const Center(
                  child: Text(
                    "It's empty here...",
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

  Future<void> _navigateToPreviewFile(int index) async {

    const Set<String> externalFileTypes = {
    ...Globals.wordType, ...Globals.excelType, ...Globals.ptxType};

    tempData.setCurrentFileName(storageData.fileNamesFilteredList[index]);
    final fileExtension = tempData.selectedFileName.split('.').last;

    if (Globals.supportedFileTypes.contains(fileExtension) && 
      !(externalFileTypes.contains(fileExtension))) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CakePreviewFile(
            custUsername: userData.username,
            fileValues: storageData.fileNamesList,
            selectedFilename: tempData.selectedFileName,
            originFrom: tempData.fileOrigin,
            fileType: fileExtension,
            tappedIndex: index
          ),
        ),
      );

    } else if (fileExtension == tempData.selectedFileName && !Globals.supportedFileTypes.contains(fileExtension)) {
      
      tempData.setOrigin("dirFiles");
      tempData.setCurrentDirectory(tempData.selectedFileName);
      appBarTitle.value = tempData.selectedFileName;

      _navDirectoryButtonVisibility(false);
      
      final loadingDialog = MultipleTextLoading();

      loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${tempData.directoryName} files.",context: context);
      await _callDirectoryData();

      loadingDialog.stopLoading();

      return;

    } else if (externalFileTypes.contains(fileExtension)) {

      late Uint8List fileData;

      final fileTable = Globals.fileTypesToTableNames[fileExtension]!;

      if(tempData.fileOrigin != "offlineFiles") {
        fileData = await _callData(tempData.selectedFileName, fileTable);
      } else {
        fileData = await OfflineMode().loadOfflineFileByte(tempData.selectedFileName);
      }

      final result = await ExternalApp.openFileInExternalApp(
        bytes: fileData, 
        fileName: tempData.selectedFileName
      );

      if(result.type != ResultType.done) {
        
        if(!mounted) return;
        CustomFormDialog.startDialog(
          "Couldn't open ${tempData.selectedFileName}",
          "No default app to open this file found.",
          context,
        );

      }

      return;

    } else {

      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
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
      thumbColor: ThemeColor.darkWhite,
      minThumbLength: 2,
      thickness: 2,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
        itemExtent: itemExtentValue,
        itemCount: storageData.fileNamesFilteredList.length,
        itemBuilder: (BuildContext context, int index) {
          
          String originalDateValues = storageData.fileDateList[index];
          String psFilesCategoryTags = originalDateValues.split(' ').sublist(0, originalDateValues.split(' ').length - 1).join(' ');

          final fileTitleSearchedValue = storageData.fileNamesFilteredList[index];
          final setLeadingImage = 
          storageData.imageBytesFilteredList.isNotEmpty 
          ? Image.memory(storageData.imageBytesFilteredList[index]!) 
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
                leading: setLeadingImage != null
                  ? Image(
                      image: setLeadingImage.image,
                      fit: BoxFit.cover,
                      height: 31,
                      width: 31,
                    )
                  : const SizedBox(),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(tempData.fileOrigin == "offlineFiles")
                    const Icon(Icons.offline_bolt_rounded, color: Colors.white, size: 21),

                    if(tempData.fileOrigin == "offlineFiles")
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () {
                        _callBottomTrailling(index);
                      },
                      child: editAllIsPressed
                        ? _buildCheckboxItem(index)
                        : const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
                title: Text(
                  fileTitleSearchedValue,
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [

                      TextSpan(
                        text: tempData.fileOrigin == "psFiles" ? psFilesCategoryTags : storageData.fileDateList[index],
                        style: const TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontSize: 12.8,
                        ),
                      ),

                      if(tempData.fileOrigin == "psFiles") 
                      
                      TextSpan(
                        text: " ${psStorageData.psTagsList[index]}",
                        style: TextStyle(
                          color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                          fontWeight: FontWeight.w500,
                          fontSize: 12.8,
                        ),
                    
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecentPsFiles(Uint8List imageBytes, int index, String uploader) {
    
    final fileName = storageData.fileNamesFilteredList[index];
    final fileType = fileName.split('.').last;

    return GestureDetector(
      onTap: () async {
        await _navigateToPreviewFile(index);
      },
      onLongPress: () {
        _callBottomTrailling(index);
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ThemeColor.lightGrey,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),

              if(Globals.videoType.contains(fileType))
              Padding(
                padding: const EdgeInsets.only(top: 14.0, left: 16.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColor.mediumGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                ),
              ),

            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ShortenText().cutText(fileName, customLength: 15),
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ShortenText().cutText(psStorageData.psUploaderList[index], customLength: 12),
                style: const TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 23,
                decoration: BoxDecoration(
                  color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    psStorageData.psTagsList[index],
                    style: const TextStyle(
                      color: ThemeColor.justWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredItems(int index) {

    final imageBytes = storageData.imageBytesFilteredList[index]!;

    String uploaderNamePs = "";
    bool isRecentPs = false;

    if (tempData.fileOrigin == "psFiles") {

      uploaderNamePs = psStorageData.psUploaderList[index];
      if (uploaderNamePs == userData.username) {
        uploaderNamePs = "${userData.username} (You)";
      }

      isRecentPs = index == 0 || index == 1 || index == 2; 

    }

    return Padding(
      padding: EdgeInsets.all(tempData.fileOrigin == "psFiles" ? 0.0 : 2.0),
      child: GestureDetector(
        onLongPress: () {
          if(!isRecentPs) {
            _callBottomTrailling(index);
          }
        },
        onTap: () async {
          if(!isRecentPs) {
            await _navigateToPreviewFile(index);
          }
        },
        child: Column(
          children: [
    
            if (isRecentPs && tempData.fileOrigin == "psFiles" && index == 0) ... [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0, top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: ThemeColor.justWhite, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Recent",
                        style: TextStyle(
                          fontSize: 23,
                          color: ThemeColor.justWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    
              const SizedBox(height: 16),
    
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
    
                    const SizedBox(width: 10),
                    _buildRecentPsFiles(storageData.imageBytesFilteredList[0]!, 0, uploaderNamePs),
                                      
                    if (storageData.imageBytesFilteredList.length > 1) ... [
                      const SizedBox(width: 12),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[1]!, 1, uploaderNamePs),
                    ],
                    
                    if (storageData.imageBytesFilteredList.length > 2) ... [
                      const SizedBox(width: 12),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[2]!, 2, uploaderNamePs),
                    ],
                              
                  ],
                ),
              ),
    
              const SizedBox(height: 8),
              const Divider(color: ThemeColor.whiteGrey),
              
            ],
    
            if(tempData.fileOrigin == "psFiles" && !isRecentPs) ... [
    
              if(index == 3)
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Row(
                    children: [
                      Icon(Icons.explore_outlined, color: ThemeColor.justWhite, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Discover",
                        style: TextStyle(
                          fontSize: 23,
                          color: ThemeColor.justWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              IntrinsicHeight(
                child: _buildPsStaggeredListView(imageBytes, index, uploaderNamePs)
              ),
    
            ],
    
            if(tempData.fileOrigin != "psFiles" && togglePhotosPressed == false)
            IntrinsicHeight(
              child: _buildNormalStaggeredListView(imageBytes, index),
            ),
            
            if(tempData.fileOrigin != "psFiles" && togglePhotosPressed == true)
            IntrinsicHeight(
              child: _buildPhotosStaggeredItems(index),
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _buildPsStaggeredListView(Uint8List imageBytes, int index, String uploaderName) {

    final mediaQuery = MediaQuery.of(context).size;
    const generalFileType = {
      ...Globals.audioType, 
      ...Globals.wordType, ...Globals.textType, 
      ...Globals.ptxType, ...Globals.excelType, "apk","exe", "pdf"
    };

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final originalDateValues = storageData.fileDateList[index];

    return Container(
      width: mediaQuery.width,
      color: ThemeColor.darkBlack,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$uploaderName ${GlobalsStyle.dotSeperator} $originalDateValues",
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.center
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  _callBottomTrailling(index);
                },
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 25),
              ),
            
            ],
          ),
        
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ShortenText().cutText(storageData.fileNamesFilteredList[index], customLength: 37),
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
          ),
    
          const SizedBox(height: 10),
    
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 108,
                    height: 25,
                    decoration: BoxDecoration(
                      color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        psStorageData.psTagsList[index],
                        style: const TextStyle(
                          color: ThemeColor.justWhite,
                          fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
              
          const SizedBox(height: 15),
    
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: generalFileType.contains(fileType) ? 72 : mediaQuery.width - 35,
                  height: generalFileType.contains(fileType) ? 72 : mediaQuery.height - 495,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeColor.lightGrey,
                      width: 2,
                    )
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Image.memory(imageBytes, fit: BoxFit.cover),
                  ),
                ),
    
                if(Globals.videoType.contains(fileType))
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ThemeColor.mediumGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 30)
                  )
                ),
    
              ],
            ),
          ),
    
          const SizedBox(height: 12),
    
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 132,
                height: 38,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(ThemeColor.darkBlack), 
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), 
                        side: const BorderSide(color: ThemeColor.lightGrey, width: 1),
                      ),
                    ),
                  ),
                  onPressed: () {
                    final fileName = storageData.fileNamesFilteredList[index];
                    tempData.setCurrentFileName(fileName);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => CommentPage(fileName: fileName)),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.comment_outlined, 
                      color: ThemeColor.justWhite, size: 21),
                      SizedBox(width: 8),
                      Text("Comments")
                    ]
                  )
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(color: ThemeColor.whiteGrey),
        ],
      ),
    );
    
  }

  Widget _buildNormalStaggeredListView(Uint8List imageBytes, int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
              width: 89,
              height: 89,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
              
              if(Globals.videoType.contains(fileType))
              const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 26),
            
            ],
          ),
        ),

        const SizedBox(height: 10),
        
        Text(
          ShortenText().cutText(storageData.fileNamesFilteredList[index], customLength: 11),
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 10) 

      ],
    );
  }

  Widget _buildPhotosStaggeredItems(int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final imageBytes = storageData.imageBytesFilteredList[index]!;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: 335,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeColor.lightGrey,
                    width: 1,
                  )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageBytes, fit: BoxFit.cover)
                ),
              ),
          
              if(Globals.videoType.contains(fileType))
              const Padding(
                padding: EdgeInsets.only(left: 6.0, top: 4.0),
                child: Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 26),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildStaggeredListView() {

    int fitSize = tempData.fileOrigin == "psFiles" ? 5 : 1;

    EdgeInsetsGeometry paddingValue = tempData.fileOrigin == "psFiles" 
    ? const EdgeInsets.only(top: 2.0,left: 0.0, right: 0.0, bottom: 8.0) 
    : const EdgeInsets.only(top: 12.0,left: 8.0, right: 8.0, bottom: 8.0);

    return Padding(
      padding: paddingValue,
      child: StaggeredGridView.countBuilder(
        controller: scrollListViewController,
        shrinkWrap: true,
        itemCount: storageData.fileNamesFilteredList.length,
        itemBuilder: (BuildContext context, int index) => _buildStaggeredItems(index),
        staggeredTileBuilder: (int index) => StaggeredTile.fit(fitSize),
        crossAxisCount: togglePhotosPressed ? 2 : 4,
        mainAxisSpacing: togglePhotosPressed ? 8 : 6.5,
        crossAxisSpacing: togglePhotosPressed ? 8 : 6.5,
      
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {

    late double mediaHeight;

    if(tempData.fileOrigin == "psFiles") {
      mediaHeight = MediaQuery.of(context).size.height - 194;
    } else if (tempData.fileOrigin != "psFiles" && !togglePhotosPressed) {
      mediaHeight = MediaQuery.of(context).size.height - 310;
    } else if (tempData.fileOrigin != "psFiles" && togglePhotosPressed) {
      mediaHeight = MediaQuery.of(context).size.height - 148;
    }

    return RefreshIndicator(
      color: ThemeColor.darkPurple,
      onRefresh: () async {

        if(tempData.fileOrigin == "homeFiles") {
          storageData.homeImageBytesList.clear();
          storageData.homeImageBytesList.clear();
        }

        if(tempData.fileOrigin == "psFiles") {
          _clearPublicStorageData(clearImage: true);
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

  Widget _buildMyPsFilesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 8.0),
      child: ElevatedButton(
        onPressed: () async {

          if(psButtonTextNotifier.value == "Back") {
            _clearPublicStorageData(clearImage: true);
          }

          if(psButtonTextNotifier.value == "My Files") {
            await Future.delayed(const Duration(milliseconds: 299));
            _sortUploadDate();
            _sortUploadDate();
          }

          psButtonTextNotifier.value == "Back" 
          ? await _refreshPublicStorage()
          : await _callMyPublicStorageData();

        },
        style: GlobalsStyle.btnNavigationBarStyle,
        child: ValueListenableBuilder(
          valueListenable: psButtonTextNotifier,
          builder: (BuildContext context, String value, Widget? child) {
            return Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userData = _locator<UserDataProvider>();
    storageData = _locator<StorageDataProvider>();
    psUploadData = _locator<PsUploadDataProvider>();
    tempData = _locator<TempDataProvider>();
    psStorageData = _locator<PsStorageDataProvider>();

    checkedList = List.generate(
        storageData.fileNamesFilteredList.length, (index) => false);

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
    scrollListViewController.dispose();
    psButtonTextNotifier.dispose();

    staggeredListViewSelected.dispose();
    floatingActionButtonVisible.dispose();
    navDirectoryButtonVisible.dispose();
    selectAllItemsIconNotifier.dispose();
    selectAllItemsIconNotifier.dispose();
    ascendingDescendingIconNotifier.dispose();
    searchBarVisibileNotifier.dispose();
    searchHintText.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: searchBarFocusNode.unfocus,
      child: Scaffold(
        key: sidebarMenuScaffoldKey,
        backgroundColor: ThemeColor.darkBlack,
        drawer: CustomSideBarMenu(
          context: context,
          usageProgress: _getUsageProgressBar(),
          offlinePageOnPressed: () async { _callOfflineData(); }
        ).buildSidebarMenu(),
        appBar: _buildCustomAppBar(),
        body: storageData.fileNamesList.isEmpty 

        ? Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildEmptyBody(context)]) 
        : Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildHomeBody(context)]),

        bottomNavigationBar: CustomNavigationBar(
          openFolderDialog: _buildFoldersDialog, 
          toggleHome: _toggleHome,
          togglePhotos: _togglePhotos,
          togglePublicStorage: _togglePublicStorage, 
          context: context
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: floatingActionButtonVisible,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: FloatingActionButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                backgroundColor: ThemeColor.darkPurple,
                onPressed: _callBottomTrailingAddItem,
                child: const Icon(Icons.add, color: ThemeColor.darkBlack, size: 30),
              ),
            );
          },
        ),
      ),
    );
  }

}