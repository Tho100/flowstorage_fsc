import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  const PreviewVideo({Key? key}) : super(key: key);

  @override
  State<PreviewVideo> createState() => PreviewVideoState();
}

class PreviewVideoState extends State<PreviewVideo> {

  late VideoPlayerController videoPlayerController;

  final ValueNotifier<IconData> iconPausePlay = ValueNotifier<IconData>(Icons.pause_rounded);
  
  bool videoIsPlaying = false;
  bool videoIsLoading = false;
  bool videoIsEnded = false;

  final Duration endThreshold = const Duration(milliseconds: 200);

  ValueNotifier<bool> videoIsTapped = ValueNotifier(false);
  bool buttonPlayPausePressed = false;

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  late Size? videoSize;

  late Uint8List videoBytes = Uint8List(0);

  Future<void> initializeVideoPlayer(String videoUrl) async {

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await videoPlayerController.initialize();
    videoPlayerController.play();

    setState(() {});

    videoIsPlaying = true;
    videoIsLoading = false;

    videoSize = videoPlayerController.value.size;
    videoPlayerController.addListener(videoPlayerListener);
    CakePreviewFileState.bottomBarVisibleNotifier.value = false;

  }

  Future<void> playVideoDataAsync() async {
    
    setState(() {});

    if(videoBytes.isEmpty) {
      videoIsLoading = true;
      videoBytes = await CallPreviewData().callDataAsync(
        tableNamePs: GlobalsTable.psVideo, 
        tableNameHome: GlobalsTable.homeVideo, 
        fileValues: Globals.videoType
      );
    } 

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await initializeVideoPlayer(videoUrl);

  }

  Widget buildPlayPauseButton() {
    return Center(
      child: SizedBox(
        width: 92,
        height: 92,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            border: Border.all(
              color: Colors.transparent,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(65),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
          
              buttonPlayPausePressed = !buttonPlayPausePressed;
          
              if(iconPausePlay.value == Icons.replay) {
                iconPausePlay.value = Icons.pause_rounded;
                videoPlayerController.play();
              } else {
                iconPausePlay.value = buttonPlayPausePressed ? Icons.play_arrow_rounded : Icons.pause_rounded;
              }
              
              if (buttonPlayPausePressed) {
                videoPlayerController.pause();
              } else {
                videoPlayerController.play();
              }
          
            },
            icon: ValueListenableBuilder(
              valueListenable: iconPausePlay,
              builder: (BuildContext context, IconData value, Widget? child) {
                return Icon(
                  value,
                  size: 72,
                  color: ThemeColor.secondaryWhite,
                );
              }
            ),
          
          ),
        ),   
      ),
    );
  }

  Widget buildLoadingVideo() {
    return Positioned.fill(
      child: Center(
        child: LoadingFile.buildLoading()
      ),
    );
  }

  Widget buildVideo() {
    return GestureDetector(
      onTap: () {
        videoIsTapped.value = !videoIsTapped.value;
        CakePreviewFileState.bottomBarVisibleNotifier.value = !CakePreviewFileState.bottomBarVisibleNotifier.value;
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: videoSize!.width,
              height: videoSize!.height,
              child: Stack(
                children: [
                  VideoPlayer(videoPlayerController),
                  ValueListenableBuilder(
                    valueListenable: videoIsTapped,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Visibility(
                        visible: value,
                        child: buildPlayPauseButton()
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildThumbnail(bool isVideoPlaying) {
    return Visibility(
      visible: !isVideoPlaying,
      replacement: Container(),
      child: Image.memory(
        videoThumbailByte,
        fit: BoxFit.contain,
      ),
    );
  }

  void videoPlayerListener() {

    final position = videoPlayerController.value.position;
    final duration = videoPlayerController.value.duration;
    
    if (!videoIsEnded &&videoPlayerController.value.isInitialized &&
        !videoPlayerController.value.isPlaying && duration - position <= endThreshold) {
      videoIsEnded = true;
      videoIsTapped.value = true;
      iconPausePlay.value = Icons.replay;
      CakePreviewFileState.bottomBarVisibleNotifier.value = true;
    }
  }

  @override
  void initState() {
    super.initState();
    indexThumbnail = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    videoThumbailByte = Globals.filteredSearchedBytes[indexThumbnail]!;
    videoPlayerController = VideoPlayerController.networkUrl(Uri());
    playVideoDataAsync();
  }

  @override
  void dispose() {
    CakePreviewFileState.bottomBarVisibleNotifier.value = true;
    videoPlayerController.removeListener(videoPlayerListener);
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Stack(
        children: [
          buildThumbnail(videoIsPlaying),
          if(videoIsLoading) buildLoadingVideo(),
          if(videoIsPlaying) buildVideo()
        ],
      ),
    );
  }
}