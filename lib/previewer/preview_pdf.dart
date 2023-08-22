import 'dart:typed_data';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewPdf extends StatefulWidget {
  
  const PreviewPdf({super.key});

  @override
  State<PreviewPdf> createState() => PreviewPdfState();
}

class PreviewPdfState extends State<PreviewPdf> {

  final tempData = GetIt.instance<TempDataProvider>();

  Future<Uint8List> _callPDFDataAsync() async {

    try {
      
      if(tempData.fileOrigin != "offlineFiles") {

        final fileData = await CallPreviewData().callDataAsync(
          tableNamePs: GlobalsTable.psPdf, 
          tableNameHome: GlobalsTable.homePdf, 
          fileValues: {"pdf"}
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