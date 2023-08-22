import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
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

  final tempData = GetIt.instance<TempDataProvider>();

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

  Future<Uint8List> _callTextDataAsync() async {

    try {
      
      if (tempData.fileOrigin != "offlineFiles") {

        final fileData = await CallPreviewData().callDataAsync(
          tableNamePs: GlobalsTable.psText, 
          tableNameHome: GlobalsTable.homeText, 
          fileValues: Globals.textType
        );

        return fileData;

      } else {
        return await _loadOfflineFile(tempData.selectedFileName);
      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _callTextDataAsync(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {        
          widget.controller.text = utf8.decode(snapshot.data!);
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextFormField(controller: widget.controller,
            keyboardType: TextInputType.multiline,
              maxLines: null,
              style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 220, 220, 220),
                fontWeight: FontWeight.w500,
                fontSize: 17,
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