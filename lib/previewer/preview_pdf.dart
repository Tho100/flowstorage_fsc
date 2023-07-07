import 'dart:typed_data';

import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
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

  Future<Uint8List> callPdfData() async {

    try {
      
      final fileData = await CallPreviewData().call(tableNamePs: "ps_info_pdf", tableNameHome: "file_info_pdf", fileValues: {"pdf"});
      return fileData;

    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }
  }

 @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Uint8List>(
        future: callPdfData(),
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