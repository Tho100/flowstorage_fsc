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

  final ValueNotifier<IconData> iconPausePlay = ValueNotifier<IconData>(Icons.play_arrow_rounded);

  bool buttonPlayPausePressed = false;
  bool videoIsPlaying = false;
  bool videoIsLoading = false;
  bool isVideoEnded = false;

  final Duration endThreshold = const Duration(milliseconds: 200);

  bool videoIsTapped = false;

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  late Size? videoSize;

  Future<void> initializeVideoPlayer(String videoUrl) async {

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await videoPlayerController.initialize();
    videoPlayerController.play();

    setState(() {});

    videoIsPlaying = true;
    videoIsLoading = false;

    videoSize = videoPlayerController.value.size;
    videoPlayerController.addListener(videoPlayerListener);

  }

  Future<void> playVideoDataAsync() async {
    
    setState(() {});
    
    videoIsLoading = true;

    final videoBytes = await CallPreviewData().callDataAsync(
      tableNamePs: GlobalsTable.psVideo, 
      tableNameHome: GlobalsTable.homeVideo, 
      fileValues: Globals.videoType
    );

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await initializeVideoPlayer(videoUrl);

  }

  Widget buildPlayPauseButton() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: ValueListenableBuilder(
          valueListenable: iconPausePlay,
          builder: (BuildContext context, IconData value, Widget? child) {
            return IconButton(
              color: ThemeColor.justWhite,
              iconSize: 64,
              icon: Icon(
                iconPausePlay.value
              ),
              onPressed: () async {
                CakePreviewFileState.bottomBarVisibleNotifier.value = false;
                buttonPlayPausePressed = !buttonPlayPausePressed;
                iconPausePlay.value = buttonPlayPausePressed == true ? Icons.pause_rounded : Icons.play_arrow_rounded;
                await playVideoDataAsync();
              },
            );
          }
        ),
      ),
    );
  }

  Widget buildLoadingVideo() {
    return Positioned.fill(
      child: Center(child: LoadingFile.buildLoading()),
    );
  }

  Widget buildVideo() {
    return GestureDetector(
      onTap: () {
        videoIsTapped = !videoIsTapped;
        if(videoIsTapped) {
          CakePreviewFileState.bottomBarVisibleNotifier.value = true;
          videoPlayerController.pause();
        } else {
          CakePreviewFileState.bottomBarVisibleNotifier.value = false;
          videoPlayerController.play();
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: videoSize!.width,
              height: videoSize!.height,
              child: VideoPlayer(videoPlayerController),
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
    
    if (!isVideoEnded &&videoPlayerController.value.isInitialized &&
        !videoPlayerController.value.isPlaying && duration - position <= endThreshold) {
      isVideoEnded = true;
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