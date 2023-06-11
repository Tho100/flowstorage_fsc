import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/RetrieveData.dart';
import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flowstorage_fsc/widgets/FailedLoad.dart';
import 'package:flowstorage_fsc/widgets/LoadingFile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';


class PreviewText extends StatefulWidget {

  final TextEditingController controller;

  const PreviewText({
    super.key,
    required this.controller
  });

  @override
  State<PreviewText> createState() => PreviewTextState();
}

class PreviewTextState extends State<PreviewText> {

  final retrieveData = RetrieveData();

  Future<Uint8List> _loadOfflineFile(String fileName) async {
    
    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirs = Directory('${getDirApplication.path}/offline_files');

    final file = File('${offlineDirs.path}/$fileName');

    if (await file.exists()) {
      final text = await file.readAsString();
      return Uint8List.fromList(text.codeUnits);
    } else {
      throw Exception('File not found');
    }
  }

  Future<Uint8List> _callData() async {

    try {

      if (Globals.fileOrigin != "offlineFiles") {

        return retrieveData.retrieveDataParams(
          Globals.custUsername,
          Globals.selectedFileName,
          "file_info_expand",
          Globals.fileOrigin,
        );

      } else {
        return await _loadOfflineFile(Globals.selectedFileName);
      }

      
    } catch (err) {
      print("Exception from _callData {PreviewText}\n$err");
      return Future.value(Uint8List(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _callData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {        
          widget.controller.text = utf8.decode(snapshot.data!);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(controller: widget.controller,
            keyboardType: TextInputType.multiline,
                maxLines: null,
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 214, 213, 213),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
            ),
          );
        } else if (snapshot.hasError) {
          return FailedLoad.buildFailedLoad();
        } else {
          return LoadingFile.buildLoading();
        }
      },
    );
  }
}