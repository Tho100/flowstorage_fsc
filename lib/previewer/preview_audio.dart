import 'dart:async';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/players/ajbyte_source.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PreviewAudio extends StatefulWidget {
  const PreviewAudio({super.key});

  @override
  State<PreviewAudio> createState() => PreviewAudioState();
}

class PreviewAudioState extends State<PreviewAudio> {

  final StreamController<double> sliderValueController = StreamController<double>();
  final ValueNotifier<IconData> iconPausePlay = ValueNotifier<IconData>(Icons.play_arrow_rounded);

  final AudioPlayer audioPlayerController = AudioPlayer();  
  final retrieveData = RetrieveData();

  final centeredMusicImage = Image.asset('assets/nice/music0.png');

  bool audioIsPlaying = false;

  Future<Uint8List> _retrieveAudio() async {

    final tableName = Globals.fileOrigin == "psFiles" ? "ps_info_audio" : "file_info_audi";
    final uploaderUsername = Globals.fileOrigin == "psFiles" 
    ? await UploaderName().getUploaderName(tableName: "ps_info_video",fileValues: Globals.videoType)
    : Globals.custUsername;

    final audioBytes = await retrieveData.retrieveDataParams(
      uploaderUsername,
      Globals.selectedFileName,
      tableName,
      Globals.fileOrigin,
    );

    return audioBytes;

  }

  Future<void> _playAudio(Uint8List byteAudio) async {

    final fileType = Globals.selectedFileName.split('.').last;
    String? audioContentType;

    if(fileType == "wav") {
      audioContentType = 'audio/wav';
    } else if (fileType == "mp3") {
      audioContentType = 'audio/mpeg';
    }

    await audioPlayerController.setAudioSource(MyJABytesSource(byteAudio,audioContentType!));
    
    audioPlayerController.play();
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
              borderRadius: BorderRadius.circular(65)
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
          
                CakePreviewFileState.bottomBarVisibleNotifier.value = false;
                audioIsPlaying = !audioIsPlaying;
                iconPausePlay.value = audioIsPlaying ? Icons.pause : Icons.play_arrow;
          
                //final byteAudio = await _retrieveAudio();
                //await _playAudio(byteAudio);
              },
              icon: Icon(value, color: ThemeColor.mediumGrey, size: 50),
            ),
          );
        }
      ),
    );

  }

  Widget buildHeader() {

    return Center(
      child: Column(
        children: [
          Text(
            Globals.selectedFileName.substring(0,Globals.selectedFileName.length-4),
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontSize: 28,
              fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "By ${Globals.custUsername}",
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 17,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );

  }

  Widget buildBody() {

    final mediaQuery = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 132.0),
            child: SizedBox(
              width: mediaQuery.width-140,
              height: mediaQuery.height-540,
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

          const SizedBox(height: 8),

          StreamBuilder<double>(
            stream: sliderValueController.stream,
            initialData: 0.0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              return Slider(
                value: snapshot.data ?? 0.0,
                min: 0,
                max: 100,
                thumbColor: ThemeColor.justWhite,
                inactiveColor: ThemeColor.thirdWhite,
                activeColor: ThemeColor.justWhite,
                onChanged: (double value) {
                  sliderValueController.add(value);
                }
              );
            },
          ),

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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    CakePreviewFileState.bottomBarVisibleNotifier.value = false;
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