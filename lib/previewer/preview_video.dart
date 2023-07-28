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

  final ValueNotifier<IconData> iconPausePlay = ValueNotifier<IconData>(Icons.play_arrow);
  final ValueNotifier<bool> videoIsTapped = ValueNotifier(false);
  final Duration endThreshold = const Duration(milliseconds: 200);
  
  bool videoIsPlaying = false;
  bool videoIsLoading = false;
  bool videoIsEnded = false;
  bool buttonPlayPausePressed = true;

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  late Size? videoSize;

  late Uint8List videoBytes = Uint8List(0);

  ValueNotifier<String> videoDurationNotifier = ValueNotifier<String>("0:00");
  ValueNotifier<String> currentVideoDurationNotifier = ValueNotifier<String>("0:00");

  Future<void> initializeVideoPlayer(String videoUrl, {bool autoPlay = false}) async {

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    if (autoPlay) {
      await videoPlayerController.initialize();
      videoPlayerController.play();
    } else {
      await videoPlayerController.initialize();
    }

    setState(() {});

    videoIsPlaying = true;
    videoIsLoading = false;

    videoSize = videoPlayerController.value.size;
    videoDurationNotifier.value = getDurationString(videoPlayerController.value.duration);

    videoIsTapped.value = true;
    videoPlayerController.addListener(videoPlayerListener);

  }

  Future<void> playVideoDataAsync() async {
    
    setState(() {});

    if (videoBytes.isEmpty) {
      videoIsLoading = true;
      videoBytes = await CallPreviewData().callDataAsync(
        tableNamePs: GlobalsTable.psVideo, 
        tableNameHome: GlobalsTable.homeVideo, 
        fileValues: Globals.videoType
      );
    } 

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await initializeVideoPlayer(videoUrl, autoPlay: false);
  }

  Widget buildDurationText(ValueNotifier<String> notifier) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.lightGrey.withOpacity(0.5),
        border: Border.all(
          color: Colors.transparent,
          width: 8.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (BuildContext context, String value, Widget? child) {
          return Text(
            value,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w600,
              fontSize: 16
            ),
            textAlign: TextAlign.center,
          );
        }
      ),
    );
  }

  Widget buildPlayPauseButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDurationText(currentVideoDurationNotifier),
                const SizedBox(width: 18),
                SizedBox(
                  height: 72,
                  width: 72,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.lightGrey.withOpacity(0.5),
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
                          iconPausePlay.value = Icons.pause;
                          videoPlayerController.play();
                        } else {
                          iconPausePlay.value = buttonPlayPausePressed 
                          ? Icons.play_arrow
                          : Icons.pause;
                        }
                        
                        if (buttonPlayPausePressed) {
                          videoPlayerController.pause();
                        } else {                
                          iconPausePlay.value = Icons.pause;
                          videoPlayerController.play();
                        }

                        Future.delayed(const Duration(milliseconds: 0), videoPlayerListener);
                    
                      },
                      icon: ValueListenableBuilder(
                        valueListenable: iconPausePlay,
                        builder: (BuildContext context, IconData value, Widget? child) {
                          return Icon(
                            value,
                            size: 52,
                            color: ThemeColor.secondaryWhite,
                          );
                        }
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                buildDurationText(videoDurationNotifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoWithButtonsOutside() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            videoIsTapped.value = !videoIsTapped.value;
            CakePreviewFileState.bottomBarVisibleNotifier.value =
                !CakePreviewFileState.bottomBarVisibleNotifier.value;
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
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
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: ValueListenableBuilder(
              valueListenable: videoIsTapped,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: value && videoBytes.isNotEmpty,
                  child: buildPlayPauseButton(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLoadingVideo() {
    return Positioned.fill(
      child: Center(
        child: LoadingFile.buildLoading()
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

  String getDurationString(Duration duration) {

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void videoPlayerListener() {

    final position = videoPlayerController.value.position;
    final duration = videoPlayerController.value.duration;

    String currentDuration = getDurationString(position);
    currentVideoDurationNotifier.value = currentDuration;

    if (videoPlayerController.value.isInitialized &&
        !videoPlayerController.value.isPlaying && duration - position <= endThreshold) {
      iconPausePlay.value = Icons.replay;
      videoIsEnded = true;
      videoIsTapped.value = true;
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
          if(videoIsPlaying) buildVideoWithButtonsOutside()
        ],
      ),
    );
  }
}