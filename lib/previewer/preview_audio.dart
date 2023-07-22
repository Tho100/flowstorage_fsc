import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/players/ajbyte_source.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class PreviewAudio extends StatefulWidget {
  const PreviewAudio({super.key});

  @override
  State<PreviewAudio> createState() => PreviewAudioState();
}

class PreviewAudioState extends State<PreviewAudio> {

  final StreamController<double> sliderValueController = StreamController<double>();
  final ValueNotifier<double> audioPositionNotifier = ValueNotifier<double>(0.0);

  final ValueNotifier<IconData> iconPausePlay = ValueNotifier<IconData>(Icons.play_arrow_rounded);

  final AudioPlayer audioPlayerController = AudioPlayer();  

  final retrieveData = RetrieveData();

  bool isPressedPlayedOnFirstTry = false;
  bool audioIsPlaying = false;

  late Uint8List? byteAudio;

  Future<Uint8List> _loadOfflineFile(String fileName) async {
    
    final offlineDirsPath = await OfflineMode().returnOfflinePath();

    final file = File('${offlineDirsPath.path}/$fileName');

    if (await file.exists()) {
      return file.readAsBytes();
    } else {
      throw Exception('File not found');
    }
  }

  Future<Uint8List> _callAudioDataAsync() async {

    try {
      
      if (Globals.fileOrigin != "offlineFiles") {

        final fileData = await CallPreviewData().callDataAsync(tableNamePs: "ps_info_audio", tableNameHome: "file_info_audi", fileValues: Globals.audioType);
        return fileData;

      } else {
        return await _loadOfflineFile(Globals.selectedFileName);
      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }

  }
  
  Future<void> _playOrPauseAudioAsync(Uint8List byteAudio) async {

    if (audioPlayerController.playing) {
      audioPlayerController.pause(); 
      iconPausePlay.value = Icons.play_arrow_rounded; 
    } else {

      final fileType = Globals.selectedFileName.split('.').last;
      String? audioContentType;

      if (fileType == "wav") {
        audioContentType = 'audio/wav';
      } else if (fileType == "mp3") {
        audioContentType = 'audio/mpeg';
      }

      if (audioPlayerController.duration == null) {
        await audioPlayerController.setAudioSource(MyJABytesSource(byteAudio, audioContentType!));
      }

      audioPlayerController.play();

      iconPausePlay.value = Icons.pause;

      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (audioPlayerController.playing) {
          audioPositionNotifier.value = audioPlayerController.position.inSeconds.toDouble();
        }
      });

      audioPlayerController.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          iconPausePlay.value = Icons.replay;
        }
      });

    }
  }

  StreamBuilder buildSlider() {
    return StreamBuilder<double>(
      stream: sliderValueController.stream,
      initialData: 0.0,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return ValueListenableBuilder<double>(
          valueListenable: audioPositionNotifier,
          builder: (context, audioPosition, _) {
            return SliderTheme(
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
      valueListenable: iconPausePlay,
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
              if(value == Icons.replay) {
                await audioPlayerController.seek(Duration.zero);
                audioPlayerController.play();
                iconPausePlay.value = Icons.pause;
              } else {
                byteAudio = await _callAudioDataAsync();
                await _playOrPauseAudioAsync(byteAudio!);
              }
            },
            icon: Icon(value, color: ThemeColor.darkPurple, size: 50),
          ),
        );
      },
    ),
  );
}


  Widget buildSkipPrevious() {

    return SizedBox(
      width: 100,
      height: 100,
      child: ValueListenableBuilder(
        valueListenable: iconPausePlay,
        builder: (BuildContext context, IconData value, Widget? child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  // 
                },
                icon: const Icon(Icons.skip_previous, color: ThemeColor.justWhite, size: 50),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget buildSkipNext() {

    return SizedBox(
      width: 100,
      height: 100,
      child: ValueListenableBuilder(
        valueListenable: iconPausePlay,
        builder: (BuildContext context, IconData value, Widget? child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  //
                },
                icon: const Icon(Icons.skip_next, color: ThemeColor.justWhite, size: 50),
              ),
            ),
          );
        }
      ),
    );

  }

  Widget buildHeader() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          Globals.selectedFileName.substring(0,Globals.selectedFileName.length-4),
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 24,
            fontWeight: FontWeight.w700
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          Globals.custUsername,
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

              buildSkipPrevious(),
              buildPlayPauseButton(),
              buildSkipNext()

            ],
          ),
          
          const SizedBox(height: 48),

        ],
      
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    CakePreviewFileState.bottomBarVisibleNotifier.value = true;
    audioPlayerController.dispose();
    sliderValueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }
}