import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewPdf extends StatefulWidget {
  
  const PreviewPdf({super.key});

  @override
  State<PreviewPdf> createState() => PreviewPdfState();
}

class PreviewPdfState extends State<PreviewPdf> {

  Future<Uint8List> _loadOfflineFile(String fileName) async {
    
    final offlineDirsPath = await OfflineMode().returnOfflinePath();

    final file = File('${offlineDirsPath.path}/$fileName');

    if (await file.exists()) {
      return file.readAsBytes();
    } else {
      throw Exception('Failed to load offline file: File not found');
    }
  }

  Future<Uint8List> _callPDFDataAsync() async {

    try {
      
      if(Globals.fileOrigin != "offlineFiles") {

        final fileData = await CallPreviewData().callDataAsync(tableNamePs: "ps_info_pdf", tableNameHome: "file_info_pdf", fileValues: {"pdf"});
        return fileData;

      } else {
        return await _loadOfflineFile(Globals.selectedFileName);
      }

    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }
  }

 @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Uint8List>(
        future: _callPDFDataAsync(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfPdfViewer.memory(
              snapshot.data!,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
            );
          } else if (snapshot.hasError) {
            return FailedLoad.buildFailedLoad();
          } else {
            return LoadingFile.buildLoading();
          }
        }, 
      ),
    );
  }
}