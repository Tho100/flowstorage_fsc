import 'dart:io';

import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ScannerPdf {

  final pdf = pw.Document();

  Future<void> convertImageToPdf({required File imagePath}) async {

    final image = pw.MemoryImage(imagePath.readAsBytesSync());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
      return pw.Center(child: pw.Image(image));
    }));

  }

  Future<void> convertDocToPdf({required String docPath}) async {

    final pdf = pw.Document();

    final file = File(docPath);
    final fileContent = await file.readAsBytes();

    final pdfContent = pw.Text(fileContent.toString());
    pdf.addPage(pw.Page(build: (pw.Context context) => pdfContent));


  }

  Future<void> savePdf({
    required String fileName,
    required BuildContext? context
  }) async {

    try {

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save PDF",context!);
    }
  }
}