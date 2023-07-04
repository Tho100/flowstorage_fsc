import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  const PreviewVideo({Key? key}) : super(key: key);

  @override
  State<PreviewVideo> createState() => PreviewVideoState();
}

class PreviewVideoState extends State<PreviewVideo> {

  late VideoPlayerController _videoPlayerController;
  final ValueNotifier<bool> _videoIsPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _videoIsLoading = ValueNotifier<bool>(false);

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  Size? videoSize;

  final retrieveData = RetrieveData();

  Future<void> _initializeVideoPlayer(String videoUrl) async {

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await _videoPlayerController.initialize();
    _videoPlayerController.play();

    setState(() {});

    _videoIsPlaying.value = true;
    _videoIsLoading.value = false;

    videoSize = _videoPlayerController.value.size;

  }

  Future<void> _playVideo() async {

    CakePreviewFileState.bottomBarVisible.value = false;
    
    setState(() {});
    
    _videoIsLoading.value = true;

    final tableName = Globals.fileOrigin == "psFiles" ? "ps_info_video" : "file_info_vid";
    final uploaderUsername = Globals.fileOrigin == "psFiles" 
    ? await UploaderName().getUploaderName(tableName: "ps_info_video",fileValues: Globals.videoType)
    : Globals.custUsername;

    final videoBytes = await retrieveData.retrieveDataParams(
      uploaderUsername,
      Globals.selectedFileName,
      tableName,
      Globals.fileOrigin,
    );

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await _initializeVideoPlayer(videoUrl);
  }

  @override
  void initState() {
    super.initState();
    indexThumbnail = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    videoThumbailByte = Globals.filteredSearchedBytes[indexThumbnail]!;
    _videoPlayerController = VideoPlayerController.networkUrl(Uri());
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final bool isVideoPlaying = _videoIsPlaying.value;
    final bool isVideoLoading = _videoIsLoading.value;

    return Center(
      child: Stack(
        children: [
          Visibility(
            visible: !isVideoPlaying,
            replacement: Container(),
            child: Image.memory(
              videoThumbailByte,
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  isVideoPlaying ? Icons.pause : Icons.play_arrow,
                ),
                color: Colors.white,
                iconSize: 64.0,
                onPressed: _playVideo,
              ),
            ),
          ),
          if (isVideoLoading)
            Positioned.fill(
              child: Center(child: LoadingFile.buildLoading()),
            ),
          if (isVideoPlaying)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: videoSize!.width,
                    height: videoSize!.height,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}