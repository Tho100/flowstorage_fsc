import 'dart:async';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/models/ajbyte_source.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class PreviewAudio extends StatefulWidget {
  const PreviewAudio({super.key});

  @override
  State<PreviewAudio> createState() => PreviewAudioState();
}

class PreviewAudioState extends State<PreviewAudio> {

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final sliderValueController = StreamController<double>();

  final audioPositionNotifier = ValueNotifier<double>(0.0);
  final iconPausePlayNotifier = ValueNotifier<IconData>(
                                  Icons.play_arrow_rounded);

  final keepPlayingIconColorNotifier = ValueNotifier<Color>(
                                ThemeColor.thirdWhite);

  final isKeepPlayingEnabledNotifier = ValueNotifier<bool>(false);
  final currentAudioDuration = ValueNotifier<String>("0:00");

  final audioPlayerController = AudioPlayer();  
  final retrieveData = RetrieveData();

  String audioDuration = "0:00";

  bool isPressedPlayedOnFirstTry = false;
  bool audioIsPlaying = false;

  late Uint8List byteAudio;

  Future<Uint8List> callAudioDataAsync() async {

    try {
      
      if (tempData.fileOrigin != "offlineFiles") {

        final fileData = await CallPreviewData().callDataAsync(
          tableNamePs: GlobalsTable.psAudio, 
          tableNameHome: GlobalsTable.homeAudio, 
          fileValues: Globals.audioType
        );
        
        return fileData;

      } else {
        return await OfflineMode().loadOfflineFileByte(tempData.selectedFileName);
      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }

  }
  
  Future<void> playOrPauseAudioAsync() async {

    if(byteAudio.isEmpty) {
      byteAudio = await callAudioDataAsync();
    }

    if (audioPlayerController.playing) {
      audioPlayerController.pause(); 
      iconPausePlayNotifier.value = Icons.play_arrow_rounded; 
    } else {

      final fileType = tempData.selectedFileName.split('.').last;
      String? audioContentType;

      if (fileType == "wav") {
        audioContentType = 'audio/wav';
      } else if (fileType == "mp3") {
        audioContentType = 'audio/mpeg';
      }

      if (audioPlayerController.duration == null) {
        await audioPlayerController.setAudioSource(MyJABytesSource(byteAudio, audioContentType!));
        Duration duration = audioPlayerController.duration!;
        String formattedDuration = getDurationString(duration);
        audioDuration = formattedDuration;
      }

      audioPlayerController.play();

      iconPausePlayNotifier.value = Icons.pause;

      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (audioPlayerController.playing) {
          Duration currentPosition = audioPlayerController.position;
          String formattedPosition = getDurationString(currentPosition);
          currentAudioDuration.value = formattedPosition;
          audioPositionNotifier.value = audioPlayerController.position.inSeconds.toDouble();
        }
      });

      audioPlayerController.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          iconPausePlayNotifier.value = Icons.replay_rounded;
          if(isKeepPlayingEnabledNotifier.value == true) {
            audioPlayerController.seek(Duration.zero);
            audioPlayerController.play();
            iconPausePlayNotifier.value = Icons.pause;
          }
        }
      });

    }
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

  StreamBuilder buildSlider() {
    return StreamBuilder<double>(
      stream: sliderValueController.stream,
      initialData: 0.0,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return ValueListenableBuilder<double>(
          valueListenable: audioPositionNotifier,
          builder: (context, audioPosition, _) {
            return Column(
              children: [
                SliderTheme(
                  data: const SliderThemeData(
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6.0
                    )
                  ),
                  child: Slider(value: audioPosition,
                    min: 0,
                    max: audioPlayerController.duration?.inSeconds.toDouble() ?? 100,
                    thumbColor: ThemeColor.justWhite,
                    inactiveColor: ThemeColor.thirdWhite,
                    activeColor: ThemeColor.justWhite,
                    onChanged: (double value) {
                      sliderValueController.add(value);
                      audioPlayerController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                  child: Row(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: currentAudioDuration,
                        builder: (BuildContext context, String value, Widget? child) {
                          return Text(
                            value,
                            style: const TextStyle(
                              color: ThemeColor.secondaryWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          );
                        }
                      ),
                      const Spacer(),
                      Text(
                        audioDuration,
                        style: const TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildPlayPauseButton() {
    return SizedBox(
      width: 72,
      height: 72,
      child: ValueListenableBuilder(
        valueListenable: iconPausePlayNotifier,
        builder: (BuildContext context, IconData value, Widget? child) {
          return Container(
            decoration: BoxDecoration(
              color: ThemeColor.justWhite,
              border: Border.all(
                color: ThemeColor.justWhite,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(65),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                if(value == Icons.replay_rounded) {
                  await audioPlayerController.seek(Duration.zero);
                  audioPlayerController.play();
                  iconPausePlayNotifier.value = Icons.pause;
                } else {
                  byteAudio = await callAudioDataAsync();
                  await playOrPauseAudioAsync();
                }
              },
              icon: Icon(value, color: ThemeColor.darkPurple, size: 45),
            ),
          );
        },
      ),
    );
  }

  Widget buildFastBackward() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              forwardingImplementation("negative");
            },
            icon: const Icon(Icons.replay_5_rounded, color: ThemeColor.justWhite, size: 50),
          ),
        ),
      ),
    );
  }

  Widget buildFastForward() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              forwardingImplementation("positive");
            },
            icon: const Icon(Icons.forward_5_rounded, color: ThemeColor.justWhite, size: 50),
          ),
        ),
      )
    );
  }

  Widget buildKeepPlaying() {
    return SizedBox(
      width: 45,
      height: 45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: ValueListenableBuilder(
            valueListenable: isKeepPlayingEnabledNotifier,
            builder: (BuildContext context, bool value, Widget? child) {
              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  isKeepPlayingEnabledNotifier.value = !isKeepPlayingEnabledNotifier.value;
                },
                icon: Icon(Icons.autorenew_rounded, size: 35, color: value ? ThemeColor.justWhite : ThemeColor.thirdWhite),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tempData.selectedFileName.substring(0,tempData.selectedFileName.length-4),
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 24,
            fontWeight: FontWeight.w700
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          userData.username,
          style: const TextStyle(
            color: ThemeColor.secondaryWhite,
            fontSize: 19,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildBody() {

    final mediaQuery = MediaQuery.of(context).size;

    return Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 172.0),
            child: SizedBox(
              width: mediaQuery.width-90,
              height: mediaQuery.height-570,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeColor.secondaryWhite,
                      ThemeColor.darkPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Spacer(),

          buildHeader(),

          const SizedBox(height: 10),

          buildSlider(),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(width: 42),

              buildFastBackward(),
              buildPlayPauseButton(),
              buildFastForward(),
              buildKeepPlaying(),

            ],
          ),
          
          const SizedBox(height: 48),

        ],
      
    );
  }

  void forwardingImplementation(String value) {

    if(currentAudioDuration.value == audioDuration && value != "negative") {
      return;
    }

    if(currentAudioDuration.value == audioDuration && value == "negative") {
      iconPausePlayNotifier.value = Icons.pause;
    }

    double currentPosition = audioPlayerController.position.inSeconds.toDouble();
    double newPosition =
        value == "positive" 
        ? currentPosition + 5 
        : currentPosition - 5;

    double maxDuration = audioPlayerController.duration?.inSeconds.toDouble() ?? 0;

    newPosition = newPosition.clamp(0.0, maxDuration);

    audioPositionNotifier.value = newPosition;
    audioPlayerController.seek(Duration(seconds: newPosition.toInt()));
  }


  @override
  void initState() {
    super.initState();
    byteAudio = Uint8List(0);
    playOrPauseAudioAsync();
  }

  @override
  void dispose(){
    CakePreviewFileState.bottomBarVisibleNotifier.value = true;
    audioPlayerController.dispose();
    audioPositionNotifier.dispose();
    iconPausePlayNotifier.dispose();
    keepPlayingIconColorNotifier.dispose();
    isKeepPlayingEnabledNotifier.dispose();
    sliderValueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }
}