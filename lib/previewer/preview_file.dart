import 'dart:async';
import 'dart:io';

import 'package:flowstorage_fsc/extra_query/rename.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/previewer/preview_audio.dart';
import 'package:flowstorage_fsc/previewer/preview_image.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/previewer/preview_text.dart';
import 'package:flowstorage_fsc/previewer/preview_video.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/interact_dialog/share_dialog.dart';
import 'package:flowstorage_fsc/sharing/sharing_username.dart';
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/data_classes/update_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/extra_query/delete.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class CakePreviewFile extends StatefulWidget {

  final String custUsername;
  final List<String> fileValues;
  final String selectedFilename;
  final String originFrom;
  final String fileType;
  final int tappedIndex;

  const CakePreviewFile({
    Key? key,
    required this.custUsername,
    required this.fileValues,
    required this.selectedFilename,
    required this.originFrom,
    required this.fileType,
    required this.tappedIndex
  }) : super(key: key);

  @override
  CakePreviewFileState createState() => CakePreviewFileState();
}

class CakePreviewFileState extends State<CakePreviewFile> {

  final retrieveData = RetrieveData();

  late String fileType;
  late String currentTable;

  static final tempData = GetIt.instance<TempDataProvider>();

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  
  final textController = TextEditingController();

  static final bottomBarVisibleNotifier = ValueNotifier<bool>(true);

  final uploaderNameNotifer = ValueNotifier<String>('');

  final appBarTitleNotifier = ValueNotifier<String>(
                                tempData.selectedFileName);

  final fileSizeNotifier = ValueNotifier<String>('');
  final fileResolutionNotifier = ValueNotifier<String>('');

  final filesWithCustomHeader = {
    GlobalsTable.homeText, GlobalsTable.homeAudio, 
    GlobalsTable.psAudio, GlobalsTable.psText};

  final filesInfrontAppBar = {
    GlobalsTable.homeText, GlobalsTable.homePdf, 
    GlobalsTable.psText, GlobalsTable.psPdf};

  @override
  void initState() {
    super.initState();
    fileType = widget.fileType;
    _initializeTableName();
    _initializeUploaderName();
  }

  @override
  void dispose() {
    textController.dispose();
    appBarTitleNotifier.dispose();
    uploaderNameNotifer.dispose();
    fileResolutionNotifier.dispose();
    fileSizeNotifier.dispose();
    super.dispose();
  }

  void _initializeTableName() {
    currentTable = tempData.fileOrigin != "homeFiles" 
    ? Globals.fileTypesToTableNamesPs[fileType]! 
    : Globals.fileTypesToTableNames[fileType]!;
  }

  void _onSlidingUpdate() async {

    final selectedFileName = tempData.selectedFileName;
    appBarTitleNotifier.value = selectedFileName;

    final fileType = selectedFileName.split('.').last;
    final fileIndex = storageData.fileNamesFilteredList.indexOf(selectedFileName);

    if (Globals.videoType.contains(fileType) || Globals.audioType.contains(fileType) || Globals.textType.contains(fileType) || Globals.excelType.contains(fileType) || Globals.wordType.contains(fileType) || Globals.excelType.contains("pdf")) {
      _navigateToPreviewFile(selectedFileName, fileType, fileIndex);
    }

    if (tempData.fileOrigin == "homeFiles") {
      currentTable = Globals.fileTypesToTableNames[fileType]!;
    } else {
      currentTable = Globals.fileTypesToTableNamesPs[fileType]!;
    }

    fileSizeNotifier.value = "";
    fileResolutionNotifier.value = "";

    if (tempData.fileOrigin == "psFiles") {
      _initializeUploaderName();
    }
  }

  void _navigateToPreviewFile(String selectedFileName, String fileType, int fileIndex) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CakePreviewFile(
          custUsername: userData.username,
          fileValues: storageData.fileNamesList,
          selectedFilename: selectedFileName,
          originFrom: tempData.fileOrigin,
          fileType: fileType,
          tappedIndex: fileIndex,
        ),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
  }

  void _deleteFile(String fileName) async {

    String fileExtension = fileName.split('.').last;

    await _deletionFile(userData.username,fileName,Globals.fileTypesToTableNames[fileExtension]!,context);
    _removeFileFromListView(fileName);

  }

   Future<void> _deletionFile(String username, String fileName, String tableName, BuildContext context) async {

    try {   

      if(tempData.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().encrypt(fileName);
        await Delete().deletionParams(username: username, fileName: encryptVals, tableName: tableName);

        storageData.homeImageBytesList.clear();
        storageData.homeThumbnailBytesList.clear();

      } else {

        final offlineDirPath = await OfflineMode().returnOfflinePath();

        final file = File('${offlineDirPath.path}/$fileName');
        file.deleteSync();
      }

      if(!mounted) return;

      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted",context: context);
      NavigatePage.permanentPageMainboard(context);

    } catch (err, st) {
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}",context);
      Logger().e("Exception from _deletionFile {PreviewFile}", err, st);
    }
    
  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog(
      fileName: fileName, 
      onDeletePressed: () => _deleteFile(fileName), 
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

  Future _callBottomTrailling() {
  
    final fileName = appBarTitleNotifier.value;

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
        SharingDialog().buildSharingDialog(fileName: tempData.selectedFileName, context: context);
      }, 
      onAOPressed: () async {
        Navigator.pop(context);
        await _makeAvailableOffline(fileName: tempData.selectedFileName);
      }, 
      context: context
    );
  }

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    storageData.fileNamesList[indexOldFile] = newFileName;
    storageData.fileNamesFilteredList[indexOldFileSearched] = newFileName;
    tempData.setCurrentFileName(newFileName);
    appBarTitleNotifier.value = newFileName;
  }

  Future<void> _renameFile(String oldFileName, String newFileName) async {
    
    final fileType = oldFileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      tempData.fileOrigin != "offlineFiles" ? await Rename().renameParams(oldFileName, newFileName, tableName) : await OfflineMode().renameFile(oldFileName,newFileName);
      int indexOldFile = storageData.fileNamesList.indexOf(oldFileName);
      int indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {

        _updateRenameFile(newFileName,indexOldFile,indexOldFileSearched);

        if (!mounted) return;
        SnakeAlert.okSnake(message: "`${ShortenText().cutText(oldFileName)}` Renamed to `${ShortenText().cutText(newFileName)}`.",context: context);
      }

    } catch (err, st) {
      SnakeAlert.errorSnake("Failed to rename this file.",context);
      Logger().e("Exception from _renameFile {main}", err, st);
    }
  }

  void _onRenamePressed(String fileName) async {

    try {

      String newItemValue = RenameDialog.renameController.text;
      String newRenameValue = "$newItemValue.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.", context);
      } else {
        await _renameFile(fileName, newRenameValue);
      }
      
    } catch (err, st) {
      Logger().e("Exception from _onRenamePressed {main}", err, st);
    }
  }

  Widget _buildFileDataWidget() {

    Widget previewWidget;

    Map<String, Widget Function()> previewMap = {

      'png': () => PreviewImage(onPageChanged: _onSlidingUpdate),
      'jpeg': () => PreviewImage(onPageChanged: _onSlidingUpdate),
      'jpg': () => PreviewImage(onPageChanged: _onSlidingUpdate),
      'webp': () => PreviewImage(onPageChanged: _onSlidingUpdate),
      'gif': () => PreviewImage(onPageChanged: _onSlidingUpdate),

      'pdf': () => const PreviewPdf(),
      'ppt': () => const PreviewPdf(),
      'pptx': () => const PreviewPdf(),
      'docx': () => const PreviewPdf(),
      'doc': () => const PreviewPdf(),

      'mp4': () => const PreviewVideo(),
      'mov': () => const PreviewVideo(),
      'wmv': () => const PreviewVideo(),
      'avi': () => const PreviewVideo(),
    };

    if (previewMap.containsKey(fileType)) {
      previewWidget = previewMap[fileType]!();
    } else {
      previewWidget = _buildPreviewerUnavailable();
    }

    return previewWidget;
  }

  Widget _buildPreviewerUnavailable() {
    return const Center(
      child: Text(
        "(Preview is not available)",
        style: TextStyle(
          color: ThemeColor.secondaryWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return currentTable == GlobalsTable.homeText || currentTable == GlobalsTable.psText ? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            tempData.selectedFileName.length > 28 ? "${tempData.selectedFileName.substring(0,28)}..." : tempData.selectedFileName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            )),
        ),
      ],
    ) : const SizedBox();
  }

  Future<Uint8List> _callDataDownload() async {

    return await retrieveData.retrieveDataParams(
      userData.username,
      widget.selectedFilename,
      currentTable,
      widget.originFrom
    );
  }

  void _removeFileFromListView(String fileName) {

    try {

      int indexOfFile = storageData.fileNamesFilteredList.indexOf(fileName);

      setState(() {
        if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
          storageData.fileNamesList.removeAt(indexOfFile);
          storageData.fileNamesFilteredList.removeAt(indexOfFile);
          storageData.imageBytesList.removeAt(indexOfFile);
          storageData.fileDateList.removeAt(indexOfFile);
          storageData.imageBytesFilteredList.removeAt(indexOfFile);
        }
      });

    } catch (err, st) {
      Logger().e("Exception on _removeFileFromListView {PreviewFile}", err, st);
    }

  }

  Widget _buildFilePreview() {
    return GestureDetector(
      onTap: () {
        bottomBarVisibleNotifier.value = !bottomBarVisibleNotifier.value;
      },
      child: _buildFileDataWidget(),
    );
  }

  Future<void> _updateTextChanges(String changesUpdate,BuildContext context) async {

    try {


      if(tempData.fileOrigin != "offlineFiles") {

        await UpdateValues().insertValueParams(
          tableName: currentTable, 
          filePath: tempData.selectedFileName, 
          userName: userData.username, 
          newValue: changesUpdate,
          columnName: "null",
        );

      } else {

        OfflineMode().saveOfflineTextFile(
          inputValue: changesUpdate, 
          fileName: tempData.selectedFileName, 
          isFromCreateTxt: false
        );
        
      } 

      if(!mounted) return;
      SnakeAlert.okSnake(message: "Changes saved.", icon: Icons.check,context: context);

    } catch (err) {

      SnakeAlert.errorSnake("Failed to save changes.",context);

    }
  }

  Future<void> _makeAvailableOffline({
    required String fileName
  }) async {

    final offlineMode = OfflineMode();
    final singleLoading = SingleTextLoading();

    late final Uint8List fileData;
    final fileType = fileName.split('.').last;

    if(Globals.unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.", context);
      return;
    } 

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      final imageIndex = storageData.fileNamesFilteredList.indexOf(fileName);
      fileData = storageData.imageBytesFilteredList[imageIndex]!;
    } else {
      fileData = await _callDataDownload();
    }
    
    if(!mounted) return;
    await offlineMode.processSaveOfflineFile(fileName: fileName,fileData: fileData, context: context);

    singleLoading.stopLoading();

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = tempData.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileType]! : Globals.fileTypesToTableNames[fileType];
      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: fileName, context: context);

      late Uint8List fileData;

      if(tempData.fileOrigin != "offlineFiles") {

        if(Globals.imageType.contains(fileType)) {
          fileData = storageData.imageBytesFilteredList[storageData.fileNamesList.indexOf(fileName)]!;
        } else {
          fileData = await _callDataDownload();
        }

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName!,
          fileData: fileData
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

  Widget _buildBottomButtons(Widget textStyle, Color color,double? width, double? height,String originFrom,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width, 
        height: height, 
        child: ElevatedButton(
          onPressed: () async {
            
            if(originFrom == "download") {

              await _callFileDownload(fileName: tempData.selectedFileName);

            } else if (originFrom == "comment") {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => CommentPage(fileName: widget.selectedFilename)),
              );
            } else if (originFrom == "share") {

              SharingDialog().buildSharingDialog(fileName: tempData.selectedFileName, context: context);

            } else if (originFrom == "save") {
              
              final textValue = textController.text;

              if(textValue.isNotEmpty && currentTable == GlobalsTable.homeText || currentTable == GlobalsTable.psText && tempData.fileOrigin == "offlineFiles") {

                await _updateTextChanges(textValue,context);
                return;
              } 

            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: textStyle,
        ),
      ),
    );
  }
  
  void _initializeUploaderName() async {
    
    const localOriginFrom = {"homeFiles","folderFiles","dirFiles"};
    const sharingOriginFrom = {"sharedFiles","sharedToMe"};

    if(localOriginFrom.contains(widget.originFrom)) {
      
      uploaderNameNotifer.value = userData.username;

    } else if (sharingOriginFrom.contains(widget.originFrom)) {
      uploaderNameNotifer.value = widget.originFrom == "sharedFiles" 
      ? await SharingName().shareToOtherName(usernameIndex: widget.tappedIndex) 
      : await SharingName().sharerName();

    } else if (widget.originFrom == "psFiles") {

      final uploaderNameIndex = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
      uploaderNameNotifer.value = psStorageData.psUploaderList[uploaderNameIndex];

    } else {

      uploaderNameNotifer.value = userData.username;

    }

  }

  Widget _uploadedByText() {

    const generalOrigin = {
      "homeFiles", "sharedToMe", "folderFiles", 
      "dirFiles", "psFiles", "offlineFiles"
    };

    return Text(
      generalOrigin.contains(widget.originFrom) 
      ? "   Uploaded By" : "   Shared To",
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 12,
        color: Color.fromARGB(255, 136, 136, 136),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<Widget> _buildBottomBar(BuildContext context) async {
    return Container(
      height: 138,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColor.darkBlack,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
  
          const SizedBox(height: 2),

          Padding(
            padding: const EdgeInsets.only(left: 6, top: 10), 
            child: SizedBox(
              width: double.infinity,
              child: _uploadedByText()
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15, top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder(
                valueListenable: uploaderNameNotifer,
                builder: (BuildContext context, String value, Widget? child) {
                  return Text(
                    value,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
              ),
            ),
          ),
  
          const Spacer(),
  
          Row(
            
            children: [
  
              const SizedBox(width: 5),
  
              _buildBottomButtons(const Icon(Icons.comment, size: 22), ThemeColor.darkGrey, 60, 45,"comment",context),
  
              const Spacer(),
  
              currentTable == 
              GlobalsTable.homeText 
              || currentTable == GlobalsTable.psText && tempData.fileOrigin == "offlineFiles" ? _buildBottomButtons(const Icon(Icons.save, size: 22), ThemeColor.darkPurple, 60, 45,"save",context) : const Text(''),
  
              _buildBottomButtons(const Icon(Icons.download, size: 22), ThemeColor.darkPurple, 60, 45,"download",context),
  
              _buildBottomButtons(const Text('SHARE',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                ThemeColor.darkPurple,
                105,
                45,
                "share",
                context
              ),
  
              const SizedBox(width: 5),
  
            ],
          ),
        ],
      ),
    );
  }

  Future<Size> _getImageResolution(Uint8List imageBytes) async {
    final image = await decodeImageFromList(imageBytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<Uint8List> _callFileSize() async {
    return await retrieveData.retrieveDataParams(userData.username, tempData.selectedFileName, currentTable, widget.originFrom);
  }

  Future<String> _getFileSize() async {

    final fileType = tempData.selectedFileName.split('.').last;

    final fileIndex = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    final getFileByte = Globals.imageType.contains(fileType) 
      ? storageData.imageBytesFilteredList[fileIndex] 
      : await _callFileSize();

    double getSizeMB = getFileByte!.lengthInBytes/(1024*1024);
    return getSizeMB.toDouble().toStringAsFixed(2);
    
  }

  Future<String> _returnImageSize() async {

    final indexImage = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    final imageBytes = storageData.imageBytesFilteredList.elementAt(indexImage);

    final imageSize = await _getImageResolution(imageBytes!);
    final imageWidth = imageSize.width.toInt();
    final imageHeight = imageSize.height.toInt();

    final imageResolution = "${imageWidth}x$imageHeight";

    return imageResolution;
  }

  Widget _buildFileInfoHeader(String headerText, String subHeader) {
    return Padding(
      padding: const EdgeInsets.only(left: 120.0),
      child: Row(
    
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
    
        children: [
          Text(headerText,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(ShortenText().cutText(subHeader, customLength: 30),
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: ThemeColor.secondaryWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ]
      ),
    );
  }

  Future _buildBottomInfo() async {

    final mediaQuery = MediaQuery.of(context);
    
    if(fileResolutionNotifier.value.isEmpty) {

      final fileType = tempData.selectedFileName.split('.').last;

      if (Globals.videoType.contains(fileType) || Globals.imageType.contains(fileType)) {
        fileResolutionNotifier.value = await _returnImageSize();
      } else {
        fileResolutionNotifier.value = "N/A";
      } 

    } 

    if(fileSizeNotifier.value.isEmpty) {
      fileSizeNotifier.value = await _getFileSize();
    }

    if(!mounted) return;

    return showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: SizedBox(
            height: 150,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 45,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFileInfoHeader("File Name", tempData.selectedFileName),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: fileResolutionNotifier, 
                    builder: (BuildContext context, String value, Widget? child) {
                      return _buildFileInfoHeader("File Resolution", value);
                    }
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: fileSizeNotifier,
                    builder: (BuildContext context, String value, Widget? child) {
                      return _buildFileInfoHeader("File Size", "$value Mb");
                    }
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileOnCondition() {
    
    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};
    const audioTables = {GlobalsTable.homeAudio, GlobalsTable.psAudio};

    if(textTables.contains(currentTable)) {
      return PreviewText(controller: textController);
    } else if (audioTables.contains(currentTable)) {
      bottomBarVisibleNotifier.value = false;
      return const PreviewAudio();
    } else {
      return _buildFilePreview();
    }

  }

  Widget _buildCopyTextIconButton() {
    return IconButton(
      onPressed: () {
        final textValue = textController.text;
        Clipboard.setData(ClipboardData(text: textValue));
        CallToast.call(message: "Copied to clipboard");
      },
      icon: const Icon(Icons.copy),
    );
  }

  Widget _buildCommentIconButtonAudio() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => CommentPage(fileName: widget.selectedFilename)),
        );
      },
      icon: const Icon(Icons.comment),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColor.secondaryPurple,
            ThemeColor.darkPurple,
          ],
        )
      : null,
      color: currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio ? null : ThemeColor.darkBlack,
    );
  }

  void _copyAppBarTitle() {
    Clipboard.setData(ClipboardData(text: tempData.selectedFileName));
    CallToast.call(message: "Copied to clipboard");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: filesInfrontAppBar.contains(currentTable) ? false : true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55.0),
        child: GestureDetector(
          onTap: () { _copyAppBarTitle(); },
          child: ValueListenableBuilder<bool>(
            valueListenable: bottomBarVisibleNotifier,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: currentTable == GlobalsTable.homeImage || currentTable == GlobalsTable.psImage ? bottomBarVisibleNotifier.value : true,
                child: AppBar(
                  backgroundColor: filesInfrontAppBar.contains(currentTable) ? ThemeColor.darkBlack : const Color(0x44000000),
                  actions: <Widget>[ 

                    if(currentTable == GlobalsTable.homeText || currentTable == GlobalsTable.psText)
                    _buildCopyTextIconButton(),
                    if(currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio)
                    _buildCommentIconButtonAudio(),
   
                    IconButton(
                      onPressed: _buildBottomInfo,
                      icon: const Icon(Icons.info_outlined),
                    ),
                    IconButton(
                      onPressed: () async {
                        _callBottomTrailling();
                      },
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                  titleSpacing: 0,
                  elevation: 0,
                  centerTitle: false,
                  title: filesWithCustomHeader.contains(currentTable)
                  ? const SizedBox()
                  : ValueListenableBuilder<String>(
                    valueListenable: appBarTitleNotifier,
                    builder: (BuildContext context, String value, Widget? child) {
                      return Text(value, style: GlobalsStyle.appBarTextStyle);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),

      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Column(
          children: [
            _buildHeaderTitle(),
            Expanded(
              child: _buildFileOnCondition(),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: bottomBarVisibleNotifier,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: value,
                  child: FutureBuilder<Widget>(
                    future: _buildBottomBar(context),
                    builder: (context, snapshot) {
                      return snapshot.hasData ? snapshot.data! : Container();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}