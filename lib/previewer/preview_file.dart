
/// <summary>
/// 
/// Class to preview user selected file and pass its file name
/// from main.dart
/// 
/// </summary>

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/extra_query/rename.dart';
import 'package:flowstorage_fsc/global/global_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/previewer/preview_audio.dart';
import 'package:flowstorage_fsc/previewer/preview_excel.dart';
import 'package:flowstorage_fsc/previewer/preview_image.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/previewer/preview_text.dart';
import 'package:flowstorage_fsc/previewer/preview_video.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
import 'package:flowstorage_fsc/sharing/share_dialog.dart';
import 'package:flowstorage_fsc/sharing/sharing_username.dart';
import 'package:flowstorage_fsc/models/comment_page.dart';
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
import 'package:flowstorage_fsc/widgets/delete_dialog.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/rename_dialog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
  String fileType = '';

  final double appBarHeight = 55.0;
  late String currentTable;

  final TextEditingController shareToController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController textController = TextEditingController();

  final ValueNotifier<String> appBarTitleNotifier = ValueNotifier<String>(Globals.selectedFileName);
  final ValueNotifier<String> fileSizeNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> fileResolutionNotifier = ValueNotifier<String>('');

  static ValueNotifier<bool> bottomBarVisibleNotifier = ValueNotifier<bool>(true);

  final Set<String> filesWithCustomHeader = {GlobalsTable.homeTextTable, GlobalsTable.homeAudioTable, "ps_info_audio", "ps_info_text"};
  final Set<String> filesInfrontAppBar = {GlobalsTable.homeTextTable, GlobalsTable.homeExcelTable, GlobalsTable.homePdfTable, "ps_info_text", "ps_info_excel", "ps_info_pdf"};

  @override
  void initState() {
    super.initState();
    fileType = widget.fileType;
    currentTable = ""; 
  }

  @override
  void dispose() {
    shareToController.dispose();
    commentController.dispose();
    textController.dispose();
    fileResolutionNotifier.value = "";
    fileSizeNotifier.value = "";

    super.dispose();
  }

  void _deleteFile(String fileName) async {

    String fileExtension = fileName.split('.').last;

    await _deletionFile(Globals.custUsername,fileName,Globals.fileTypesToTableNames[fileExtension]!,context);
    _removeFileFromListView(fileName);

  }

   Future<void> _deletionFile(String username, String fileName, String tableName, BuildContext context) async {

    try {   

      if(Globals.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().Encrypt(fileName);
        await Delete().deletionParams(username: username, fileName: encryptVals, tableName: tableName);

        Globals.fileOrigin == "homeFiles" ? GlobalsData.homeFilesNameData.remove(fileName) : null;
        GlobalsData.homeImageData.clear();
        GlobalsData.homeThumbnailData.clear();

      } else {

        final offlineDirPath = await OfflineMode().returnOfflinePath();

        final file = File('${offlineDirPath.path}/$fileName');
        file.deleteSync();
      }

      if(!mounted) return;

      SnakeAlert.okSnake(message: "`$fileName` Has been deleted",context: context);
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

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    Globals.fileValues[indexOldFile] = newFileName;
    Globals.filteredSearchedFiles[indexOldFileSearched] = newFileName;
    Globals.selectedFileName = newFileName;
    appBarTitleNotifier.value = newFileName;
  }

  Future<void> _renameFile(String oldFileName, String newFileName) async {
    
    final fileType = oldFileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      Globals.fileOrigin != "offlineFiles" ? await Rename().renameParams(oldFileName, newFileName, tableName) : await OfflineMode().renameFile(oldFileName,newFileName);
      int indexOldFile = Globals.fileValues.indexOf(oldFileName);
      int indexOldFileSearched = Globals.filteredSearchedFiles.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {

        _updateRenameFile(newFileName,indexOldFile,indexOldFileSearched);

        if (!mounted) return;
        SnakeAlert.okSnake(message: "`${ShortenText().cutText(oldFileName)}` Renamed to `$newFileName`.",context: context);
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

      if (Globals.fileValues.contains(newRenameValue)) {
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

      'png': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'jpeg': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'jpg': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'webp': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'gif': () => PreviewImage(onPageChanged: _updateAppBarTitle),

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
      previewWidget = FailedLoad.buildFailedLoad();
    }

    return previewWidget;
  }

  Widget _buildHeaderTitle() {
    return currentTable == "file_info_expand" || currentTable == "ps_info_text" ? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            Globals.selectedFileName.length > 28 ? "${Globals.selectedFileName.substring(0,28)}..." : Globals.selectedFileName,
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
      Globals.custUsername,
      widget.selectedFilename,
      currentTable,
      widget.originFrom
    );
  }

  void _removeFileFromListView(String fileName) {

    try {

      int indexOfFile = Globals.filteredSearchedFiles.indexOf(fileName);

      setState(() {
        Globals.fromLogin = true;
        if (indexOfFile >= 0 && indexOfFile < Globals.fileValues.length) {
          Globals.fileValues.removeAt(indexOfFile);
          Globals.filteredSearchedFiles.removeAt(indexOfFile);
          Globals.imageByteValues.removeAt(indexOfFile);
          Globals.filteredSearchedBytes.removeAt(indexOfFile);
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

  Future<void> _saveExcelChanges(List<int>? newValuesBytes, BuildContext context) async {

    try {

      /*String jsonString = jsonEncode(await _getExcelDataSources());
      List<int> byteList = utf8.encode(jsonString);
      Uint8List byteData = Uint8List.fromList(byteList);*/

      final base64Encoded = base64.encode(newValuesBytes!);
      await UpdateValues().insertValueParams(
        tableName: currentTable, 
        filePath: Globals.selectedFileName, 
        userName: Globals.custUsername, 
        newValue: base64Encoded,
        columnName: "null",
      );

      if(!mounted) return;
      SnakeAlert.okSnake(message: "Changes saved.", icon: Icons.check,context: context);

    } catch (err, st) { 
      Logger().e("Exception from _saveExcelChanges {PreviewFile}", err, st);
      SnakeAlert.errorSnake("Failed to save changes.",context);

    }
  }

  Future<void> _updateTextChanges(String changesUpdate,BuildContext context) async {

    try {


      if(Globals.fileOrigin != "offlineFiles") {

        await UpdateValues().insertValueParams(
          tableName: currentTable, 
          filePath: Globals.selectedFileName, 
          userName: Globals.custUsername, 
          newValue: changesUpdate,
          columnName: "null",
        );

      } else {

        OfflineMode().saveOfflineTextFile(
          inputValue: changesUpdate, 
          fileName: Globals.selectedFileName, 
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

    const Set<String> unsupportedOfflineModeTypes = {"docx","doc","pptx","ptx","xlsx","xls","mp4","wmv"};

    if(unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.", context);
      return;
    } 

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      fileData = Globals.filteredSearchedBytes[widget.tappedIndex]!;
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
      final tableName = Globals.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileType]! : Globals.fileTypesToTableNames[fileType];
      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: fileName, context: context);

      late Uint8List fileData;

      if(Globals.fileOrigin != "offlineFiles") {

        if(Globals.imageType.contains(fileType)) {
          fileData = Globals.filteredSearchedBytes[Globals.fileValues.indexOf(fileName)]!;
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

              await _callFileDownload(fileName: Globals.selectedFileName);

            } else if (originFrom == "comment") {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => CommentPage(fileName: widget.selectedFilename)),
              );
            } else if (originFrom == "share") {

              SharingDialog().buildSharingDialog(fileName: Globals.selectedFileName, shareToController: shareToController,commentController: commentController,context: context);

            } else if (originFrom == "save") {
              
              final textValue = textController.text;

              if(textValue.isNotEmpty && currentTable == GlobalsTable.homeTextTable || currentTable == "ps_info_text" && Globals.fileOrigin == "offlineFiles") {

                await _updateTextChanges(textValue,context);
                return;
              } 

              if(currentTable == GlobalsTable.homeExcelTable) {
                final updatedValues = PreviewExcel.excelUpdatedBytes;
                await _saveExcelChanges(updatedValues,context);
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

  Future<String> uploaderName() async {
    
    const localOriginFrom = {"homeFiles","folderFiles","dirFiles"};
    const sharingOriginFrom = {"sharedFiles","sharedToMe"};

    late String returnedUploaderName;

    if(localOriginFrom.contains(widget.originFrom)) {
      
      returnedUploaderName = Globals.custUsername;

    } else if (sharingOriginFrom.contains(widget.originFrom)) {

      returnedUploaderName = widget.originFrom == "sharedFiles" 
      ? await SharingName().shareToOtherName(usernameIndex: widget.tappedIndex) 
      : await SharingName().sharerName();

    } else if (widget.originFrom == "psFiles") {

      final uploaderUsername = 
      await UploaderName().getUploaderName(
        tableName: Globals.fileTypesToTableNamesPs[fileType]!,
        fileValues: {fileType}
      );

      returnedUploaderName = uploaderUsername;

    } else {

      returnedUploaderName = Globals.custUsername;

    }

    return "  $returnedUploaderName";

  }

  Widget uploadedByText() {
    return Text(
      widget.originFrom == "homeFiles" 
      || widget.originFrom == "sharedToMe" 
      || widget.originFrom == "folderFiles" 
      || widget.originFrom == "dirFiles" 
      || widget.originFrom == "psFiles" 
      || widget.originFrom == "offlineFiles" ? '   Uploaded By' : "   Shared To",
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
                child: uploadedByText()
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 6, top: 12),
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<String>(
                  future: uploaderName(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return const Text('');
                    } else {
                      return Text(
                        snapshot.data ?? '(Unknown)',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
    
            const Spacer(),
    
            Row(
              
              children: [
    
                const SizedBox(width: 5),
    
                _buildBottomButtons(const Icon(Icons.comment, size: 22), ThemeColor.darkGrey, 60, 45,"comment",context),
    
                const Spacer(),
    
                Visibility(
                  visible: true,
                  child: currentTable == GlobalsTable.homeTextTable || currentTable == GlobalsTable.homeExcelTable || currentTable == "ps_info_text" && Globals.fileOrigin == "offlineFiles" ? _buildBottomButtons(const Icon(Icons.save, size: 22), ThemeColor.darkPurple, 60, 45,"save",context) : const Text(''),
                ),
    
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
    return await retrieveData.retrieveDataParams(Globals.custUsername, Globals.selectedFileName, currentTable, widget.originFrom);
  }

  Future<String> _getFileSize() async {

    final getFileByte = await _callFileSize();
    double getSizeMB = getFileByte.lengthInBytes/(1024*1024);
    return getSizeMB.toDouble().toStringAsFixed(2);
    
  }

  Future<String> _returnImageSize() async {

    final imageSize = await _getImageResolution(await _callFileSize());
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
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(ShortenText().cutText(subHeader, customLength: 30),
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: ThemeColor.secondaryWhite,
              fontSize: 16,
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
    
    late Future<String> imageResolutionFuture;
    late Future<String> fileSizeFuture;

    if (currentTable == GlobalsTable.homeImageTable || currentTable == "ps_info_image") {
      imageResolutionFuture = _returnImageSize();
    } else {
      imageResolutionFuture = Future.value('N/A');
    }

    fileSizeFuture = _getFileSize();

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
                  _buildFileInfoHeader("File Name", Globals.selectedFileName),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: imageResolutionFuture,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      final String fileResolution = snapshot.data ?? 'N/A';

                      return _buildFileInfoHeader("File Resolution", fileResolution);
                    },
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: fileSizeFuture,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      final String fileSize = snapshot.data ?? 'N/A';

                      return _buildFileInfoHeader("File Size", '$fileSize Mb');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        SharingDialog().buildSharingDialog(fileName: Globals.selectedFileName, shareToController: shareToController, commentController: commentController,context: context);
      }, 
      onAOPressed: () async {
        Navigator.pop(context);
        await _makeAvailableOffline(fileName: Globals.selectedFileName);
      }, 
      context: context
    );
  }

  void _updateAppBarTitle() {
    appBarTitleNotifier.value = Globals.selectedFileName;
  }

  Widget buildFileOnCondition() {
    
    const textTables = {GlobalsTable.homeTextTable, "ps_info_text"};
    const audioTables = {GlobalsTable.homeAudioTable, "ps_info_audio"};
    const excelTables = {GlobalsTable.homeExcelTable, "ps_info_excel"};

    if(textTables.contains(currentTable)) {
      return PreviewText(controller: textController);
    } else if (excelTables.contains(currentTable)) {
      return const PreviewExcel();
    } else if (audioTables.contains(currentTable)) {
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
        SnakeAlert.okSnake(message: "Copied to clipboard", context: context);
      },
      icon: const Icon(Icons.copy),
    );
  }

  void _copyAppBarTitle() {
    Clipboard.setData(ClipboardData(text: Globals.selectedFileName));
    SnakeAlert.okSnake(message: "Copied to clipboard", context: context);
  }

  @override
  Widget build(BuildContext context) {

    currentTable = Globals.fileOrigin != "homeFiles" ? Globals.fileTypesToTableNamesPs[fileType]! : Globals.fileTypesToTableNames[fileType]!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: filesInfrontAppBar.contains(currentTable) ? false : true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: GestureDetector(
          onTap: () {
            _copyAppBarTitle();
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: bottomBarVisibleNotifier,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: currentTable == GlobalsTable.homeImageTable || currentTable == "ps_info_image" ? bottomBarVisibleNotifier.value : true,
                child: AppBar(
                  backgroundColor: filesInfrontAppBar.contains(currentTable) ? ThemeColor.darkBlack : const Color(0x44000000),
                  actions: <Widget>[
                    Visibility(
                      visible: currentTable == GlobalsTable.homeTextTable || currentTable == "ps_info_text",
                      child: _buildCopyTextIconButton(),
                    ),
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
        decoration: BoxDecoration(
          gradient: currentTable == "file_info_audi" || currentTable == "ps_info_audio"
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeColor.secondaryPurple,
                ThemeColor.darkPurple,
              ],
            )
          : null,
          color: currentTable == "file_info_audi" || currentTable == "ps_info_audio" ? null : ThemeColor.darkBlack,
        ),
        child: Column(
          children: [
            _buildHeaderTitle(),
            Expanded(
              child: buildFileOnCondition(),
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