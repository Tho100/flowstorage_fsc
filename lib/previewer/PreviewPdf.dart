import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewPdf extends StatelessWidget {

  final Uint8List? pdfData;
  
  const PreviewPdf({super.key,required this.pdfData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfPdfViewer.memory(
        pdfData!,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }
}