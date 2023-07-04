import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
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

  bool videoIsPlaying = false;
  bool videoIsLoading = false;
  bool videoIsPlayed = false;

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  late Size? videoSize;

  final retrieveData = RetrieveData();

  Future<void> _initializeVideoPlayer(String videoUrl) async {

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await videoPlayerController.initialize();
    videoPlayerController.play();

    setState(() {});

    videoIsPlaying = true;
    videoIsLoading = false;

    videoSize = videoPlayerController.value.size;

  }

  Future<void> _playVideo() async {
    
    setState(() {});
    
    videoIsLoading = true;

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
                CakePreviewFileState.bottomBarVisible.value = false;
                videoIsPlayed = !videoIsPlayed;
                iconPausePlay.value = videoIsPlayed == true ? Icons.pause_rounded : Icons.play_arrow_rounded;
                await _playVideo();
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
    return Center(
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

  @override
  void initState() {
    super.initState();
    indexThumbnail = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    videoThumbailByte = Globals.filteredSearchedBytes[indexThumbnail]!;
    videoPlayerController = VideoPlayerController.networkUrl(Uri());
  }

  @override
  void dispose() {
    CakePreviewFileState.bottomBarVisible.value = true;
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Stack(
        children: [
          buildThumbnail(videoIsPlaying),
          buildPlayPauseButton(),
          if(videoIsLoading) buildLoadingVideo(),
          if(videoIsPlaying) buildVideo()
        ],
      ),
    );
  }
}