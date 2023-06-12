
/// <summary>
/// 
/// Class to preview user selected file and pass its file name
/// from main.dart
/// 
/// </summary>

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/SimplifyDownload.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/previewer/preview_excel.dart';
import 'package:flowstorage_fsc/previewer/preview_image.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/previewer/preview_text.dart';
import 'package:flowstorage_fsc/previewer/preview_video.dart';
import 'package:flowstorage_fsc/sharing/share_dialog.dart';
import 'package:flowstorage_fsc/sharing/sharing_username.dart';
import 'package:flowstorage_fsc/models/comment_page.dart';
import 'package:flowstorage_fsc/players/ajbyte_source.dart';
import 'package:flowstorage_fsc/data_classes/update_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/extra_query/delete.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/MultipleText.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CakePreviewFile extends StatefulWidget {

  final String custUsername;
  final List<String> fileValues;
  final String selectedFilename;
  final String originFrom;
  final String fileType;

  const CakePreviewFile({
    Key? key,
    required this.custUsername,
    required this.fileValues,
    required this.selectedFilename,
    required this.originFrom,
    required this.fileType,
  }) : super(key: key);

  @override
  _CakePreviewFileState createState() => _CakePreviewFileState();
}

class _CakePreviewFileState extends State<CakePreviewFile> {

  ValueNotifier<String> appBarTitleNotifier = ValueNotifier<String>(Globals.selectedFileName);

  final retrieveData = RetrieveData();

  String _fileType = '';

  final double _appBarHeight = 55.0;
  late String _currentTable;

  final StreamController<double> _sliderValueController = StreamController<double>();

  final TextEditingController _shareToController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final AudioPlayer _audioPlayerController = AudioPlayer();

  late VideoPlayerController _videoPlayerController;

  final ValueNotifier<bool> _videoIsPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _videoIsLoading = ValueNotifier<bool>(false);

  final ValueNotifier<String> _fileSize = ValueNotifier<String>('');  
  final ValueNotifier<String> _fileResolution = ValueNotifier<String>('');

  final TextEditingController _textController = TextEditingController();
  ValueNotifier<bool> bottomBarVisible = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _fileType = widget.fileType;
    _currentTable = ""; 
    _videoPlayerController = VideoPlayerController.network('');
  }

  @override
  void dispose() {
    _sliderValueController.close();
    _shareToController.dispose();
    _commentController.dispose();
    _audioPlayerController.dispose();
    _videoPlayerController.dispose();
    _videoIsPlaying.dispose();
    _textController.dispose();
    _videoIsLoading.dispose();
    _fileResolution.value = "";
    _fileSize.value = "";

    super.dispose();
  }

  Future<Uint8List> _retrieveAudio() async {

    final byteAudio = await retrieveData.retrieveDataParams(Globals.custUsername, widget.selectedFilename, "file_info_audi", widget.originFrom);
    return byteAudio;

  }

  Future<void> _playAudio(Uint8List byteAudio) async {

    String? audioContentType;

    if(_fileType == "wav") {
      audioContentType = 'audio/wav';
    } else if (_fileType == "mp3") {
      audioContentType = 'audio/mpeg';
    }

    await _audioPlayerController.setAudioSource(MyJABytesSource(byteAudio,audioContentType!));
    
    _audioPlayerController.play();
  }

  Widget _previewAudio() {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Spacer(),

          Image.asset('assets/nice/music0.png'),

          const Spacer(),

          StreamBuilder<double>(
            stream: _sliderValueController.stream,
            initialData: 0.0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              return Slider(
                value: snapshot.data ?? 0.0,
                min: 0,
                max: 100,
                thumbColor: ThemeColor.darkPurple,
                inactiveColor: ThemeColor.darkGrey,
                onChanged: (double value) {
                  _sliderValueController.add(value);
                }
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ThemeColor.darkBlack,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () async {
  
                  final byteAudio = await _retrieveAudio();
                  await _playAudio(byteAudio);

                },
                child: const Icon(Icons.play_arrow_rounded,color: ThemeColor.secondaryWhite,size: 52)
              ),
            ],
          ),
        ],
      ),
    );

  }

  Future<void> _deletionFile(String username, String fileName, String tableName, BuildContext context) async {

    try {   

      if(Globals.fileOrigin != "offlineFiles") {

        final encryptVals = EncryptionClass().Encrypt(fileName);
        await Delete().deletionParams(username: username, fileName: encryptVals, tableName: tableName);
        
      } else {

        final getDirApplication = await getApplicationDocumentsDirectory();
        final offlineDirs = Directory('${getDirApplication.path}/offline_files');

        final file = File('${offlineDirs.path}/$fileName');
        file.deleteSync();
      }

      SnakeAlert.okSnake(message: "`$fileName` Has been deleted",context: context);

      NavigatePage.permanentPageMainboard(context);

    } catch (err) {
      print("Exception from _deletionFile {PreviewFile}: $err");
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}",context);
    }
    
  }

  Future _deleteFileDialog(String fileName,BuildContext context) {
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
            'Delete this file? Action is permanent.',
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
                
                Navigator.pop(context);

                String fileExtension = fileName.split('.').last;

                await _deletionFile(Globals.custUsername,fileName,Globals.fileTypesToTableNames[fileExtension]!,context);
                _removeFileFromListView(fileName);
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

  Widget _buildFileDataWidget(Uint8List? snapshotValue) {

    Widget previewWidget;

    Map<String, Widget Function()> previewMap = {

      'png': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'jpeg': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'jpg': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'webp': () => PreviewImage(onPageChanged: _updateAppBarTitle),
      'gif': () => PreviewImage(onPageChanged: _updateAppBarTitle),

      'pdf': () => PreviewPdf(pdfData: snapshotValue),
      'ppt': () => PreviewPdf(pdfData: snapshotValue),
      'pptx': () => PreviewPdf(pdfData: snapshotValue),
      'docx': () => PreviewPdf(pdfData: snapshotValue),
      'doc': () => PreviewPdf(pdfData: snapshotValue),

      'mp4': () => const PreviewVideo(),
      'mov': () => const PreviewVideo(),
      'wmv': () => const PreviewVideo(),
      'avi': () => const PreviewVideo(),

      'mp3': () => _previewAudio(),
      'wav': () => _previewAudio(),

    };

    if (previewMap.containsKey(_fileType)) {
      previewWidget = snapshotValue!.isEmpty ? FailedLoad.buildFailedLoad() : previewMap[_fileType]!();
    } else {
      previewWidget = FailedLoad.buildFailedLoad();
    }

    snapshotValue = null;

    return previewWidget;
  }

  Widget _buildHeaderTitle() {
    return _currentTable == "file_info_expand" ? Row(
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
      _currentTable,
      widget.originFrom
    );
  }

  Future<Uint8List> _callData() async {

    try {

      switch (_currentTable) {

        case "file_info_vid":
        case "file_info_audi":
          return Future.value(Uint8List.fromList([0]));

        case "file_info":
          return Future.value(Uint8List.fromList([0]));

        default:
          return await Future(() => retrieveData.retrieveDataParams(
            Globals.custUsername,
            widget.selectedFilename,
            _currentTable,
            widget.originFrom,
          )
        );
      }
    } catch (err) {
      print("Exception from _callData {File Preview}\n$err");
      return Future.value(Uint8List(0));
    }
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

    } catch (err) {
      print("Exception on _removeFileFromListView {PreviewFile}: $err");
    }

  }

  Widget _buildFilePreview() {
    return GestureDetector(
      onTap: () {
        bottomBarVisible.value = !bottomBarVisible.value;
      },
      child: FutureBuilder<Uint8List>(
        future: _callData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildFileDataWidget(snapshot.data!),
              );
            } else if (snapshot.hasError) {
              return FailedLoad.buildFailedLoad();
            }
          }
          return Center(child: LoadingFile.buildLoading());
        }
    ),
      
    );
  }

  Future<void> _saveExcelChanges(List<int>? newValuesBytes, BuildContext context) async {

    try {

      /*String jsonString = jsonEncode(await _getExcelDataSources());
      List<int> byteList = utf8.encode(jsonString);
      Uint8List byteData = Uint8List.fromList(byteList);*/

      final base64Encoded = base64.encode(newValuesBytes!);
      await UpdateValues().insertValueParams(
        tableName: _currentTable, 
        filePath: Globals.selectedFileName, 
        userName: Globals.custUsername, 
        newValue: base64Encoded,
        columnName: "null",
      );

      SnakeAlert.okSnake(message: "Changes saved.", icon: Icons.check,context: context);

    } catch (err) { 
      print("Exception from _saveExcelChanges {PreviewFile}: $err");
      SnakeAlert.errorSnake("Failed to save changes.",context);

    }
  }

  Future<void> _updateTextChanges(String changesUpdate,BuildContext context) async {

    try {

      await UpdateValues().insertValueParams(
        tableName: _currentTable, 
        filePath: Globals.selectedFileName, 
        userName: Globals.custUsername, 
        newValue: changesUpdate,
        columnName: "null",
      );

      SnakeAlert.okSnake(message: "Changes saved.", icon: Icons.check,context: context);

    } catch (err) {

      SnakeAlert.errorSnake("Failed to save changes.",context);

    }
  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileType];
      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: fileName, context: context);

      Uint8List getBytes = await _callDataDownload();

      await SimplifyDownload(
        fileName: fileName,
        currentTable: tableName!,
        fileData: getBytes
      ).downloadFile();
    
      loadingDialog.stopLoading();

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

              SharingDialog().buildSharingDialog(fileName: Globals.selectedFileName, shareToController: _shareToController,commentController: _commentController,context: context);

            } else if (originFrom == "save") {
              
              final textValue = _textController.text;

              if(textValue.isNotEmpty && _currentTable == "file_info_expand") {
                
                await _updateTextChanges(textValue,context);
                return;
              } 

              if(_currentTable == "file_info_excel") {
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
                child: Text(
                  widget.originFrom == "homeFiles" || widget.originFrom == "sharedToMe" || widget.originFrom == "folderFiles" || widget.originFrom == "dirFiles" ? '   Uploaded By' : "   Shared To",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 136, 136, 136),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 12), 
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  widget.originFrom == "homeFiles" || widget.originFrom == "folderFiles" || widget.originFrom == "dirFiles" ? "  ${Globals.custUsername}" : widget.originFrom == "sharedFiles" ? "  ${await SharingName().shareToOtherName()}" : "  ${await SharingName().sharerName()}",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
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
                  child: _currentTable == "file_info_expand" || _currentTable == "file_info_excel" ? _buildBottomButtons(const Icon(Icons.save, size: 22), ThemeColor.darkPurple, 60, 45,"save",context) : const Text(''),
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
    return await retrieveData.retrieveDataParams(Globals.custUsername, Globals.selectedFileName, _currentTable,widget.originFrom);
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

  Future _buildBottomInfo() {
    return showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      context: context,
      shape: const RoundedRectangleBorder( 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25)
        )
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
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

                    Row(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        const Text('File Name',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(Globals.selectedFileName,
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

                    const SizedBox(height: 8),

                    Row(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        const Text('File Resolution',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(width: 8),

                        _currentTable == "file_info" ? _fileResolution.value == '' ? FutureBuilder<String>(
                          future: _returnImageSize(),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if(snapshot.hasData) {
                              return Text(snapshot.data!,
                              style: const TextStyle(
                                color: ThemeColor.secondaryWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(color: ThemeColor.secondaryWhite)
                              );
                            }
                          }
                        )
                        : ValueListenableBuilder<String>(
                          valueListenable: _fileResolution,
                          builder: (BuildContext context, String value, Widget? child) {
                            return Text(value,
                              style: const TextStyle(
                              color: ThemeColor.secondaryWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        )
                        : const Text('N/A',
                            style: TextStyle(
                                color: ThemeColor.secondaryWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                ),
                              )

                      ]
                    ),

                    const SizedBox(height: 8),

                    Row(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        const Text('File Size',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(width: 9),

                        _fileSize.value == '' ? FutureBuilder<String>(
                          future: _getFileSize(),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if(snapshot.hasData) {
                              return Text("${snapshot.data!}Mb",
                              style: const TextStyle(
                                color: ThemeColor.secondaryWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(color: ThemeColor.secondaryWhite)
                              );
                            }
                          }
                        )
                        : ValueListenableBuilder<String>(
                          valueListenable: _fileSize,
                          builder: (BuildContext context, String value, Widget? child) {
                            return Text(value,
                              style: const TextStyle(
                              color: ThemeColor.secondaryWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        )
                    ]
                  ),
                ]
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniTopButtons(BuildContext context) {

    return Row(

      children: [
        
        IconButton(
          onPressed: () {
            _buildBottomInfo();
          }, 
          icon: const Icon(Icons.info_outline_rounded),
        ),

        Theme(
          data: Theme.of(context).copyWith(
            cardColor: const Color.fromARGB(255, 15, 15, 15),
          ),
          child: PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 15, 15, 15),
                  ),
                  onPressed: () {
                    SharingDialog().buildSharingDialog(fileName: Globals.selectedFileName, shareToController: _shareToController,commentController: _commentController,context: context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 5),
                      Text('Share'),
                    ],
                  ),
                )
              ),  

              const PopupMenuDivider(height: 4),

              PopupMenuItem(
                enabled: _currentTable != "file_info_expand" ? false : true,
                child: IgnorePointer(
                  ignoring: _currentTable == "file_info_expand" ? false : true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
                    ),
                    onPressed: () async {

                      final textValue = _textController.text;
                      Clipboard.setData(ClipboardData(text: textValue));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard'),duration: Duration(milliseconds: 1000),backgroundColor: ThemeColor.darkGrey)
                      );
                    
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 5),
                        Text('Copy',
                          style: TextStyle(
                            color: _currentTable == "file_info_expand" ? Colors.white : ThemeColor.thirdWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              PopupMenuItem(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 15, 15, 15),
                  ),
                  onPressed: () {
                    _deleteFileDialog(widget.selectedFilename,context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete,color: ThemeColor.darkRed),
                      SizedBox(width: 5),
                      Text('Delete',
                        style: TextStyle(
                          color: ThemeColor.darkRed
                        ),
                      ),
                    ],
                  ),
                )
              ),  

            const PopupMenuDivider(height: 4),

            ],

            icon: const Icon(Icons.more_vert,color: Colors.white),

          ),
        ),
      ],
    );
  }

  void _updateAppBarTitle() {
    appBarTitleNotifier.value = Globals.selectedFileName;
  }

  @override
  Widget build(BuildContext context) {

    _currentTable = Globals.fileTypesToTableNames[_fileType]!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: _currentTable == "file_info" || _currentTable == "file_info_vid" ? true : false,
      backgroundColor: ThemeColor.darkBlack,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: bottomBarVisible,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(
              visible: _currentTable == "file_info" ? bottomBarVisible.value : true,
              child: AppBar(
              backgroundColor: _currentTable == "file_info" || _currentTable == "file_info_vid" ? const Color(0x44000000) : ThemeColor.darkBlack,
              actions: [_buildMiniTopButtons(context)],
              titleSpacing: 0,
              elevation: 0,
              centerTitle: false,
              title: _currentTable == "file_info_expand"
                ? const SizedBox()
                : ValueListenableBuilder<String>(
                  valueListenable: appBarTitleNotifier,
                  builder: (BuildContext context, String value, Widget? child) {
                    return Text(value,style: GlobalsStyle.appBarTextStyle);
                  }
                ),
              ),
            );
          }
        ),
      ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              _buildHeaderTitle(),
              Expanded(
                child: _currentTable == "file_info_expand"
                  ? PreviewText(controller: _textController)
                  : (_currentTable == "file_info_excel"
                      ? const PreviewExcel()
                      : _buildFilePreview()),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: bottomBarVisible, 
                builder: (BuildContext context, bool value, Widget? child) {
                  return Visibility(
                    visible: value,
                    child: FutureBuilder<Widget>(
                      future: _buildBottomBar(context),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return Container();
                        }
                      },
                    ),
                  );
                }
              ),
            ],
          ),

      ),
    );
  }
}