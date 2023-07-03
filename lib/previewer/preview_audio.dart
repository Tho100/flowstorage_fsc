import 'dart:async';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/players/ajbyte_source.dart';
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
  final AudioPlayer audioPlayerController = AudioPlayer();  

  final centeredMusicImage = Image.asset('assets/nice/music0.png');

  final retrieveData = RetrieveData();

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

  Widget buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Spacer(),

          centeredMusicImage,
          
          const Spacer(),

          StreamBuilder<double>(
            stream: sliderValueController.stream,
            initialData: 0.0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              return Slider(
                value: snapshot.data ?? 0.0,
                min: 0,
                max: 100,
                thumbColor: ThemeColor.darkPurple,
                inactiveColor: ThemeColor.darkGrey,
                onChanged: (double value) {
                  sliderValueController.add(value);
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

  @override
  void dispose(){
    audioPlayerController.dispose();
    sliderValueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }
}