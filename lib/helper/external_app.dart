import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ExternalApp {

  static Future<OpenResult> openFileInExternalApp({
    required Uint8List bytes, 
    required String fileName
  }) async {

    try {

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File tempFile = File('$tempPath/$fileName');
      
      await tempFile.writeAsBytes(bytes, flush: true);

      String filePath = tempFile.path;
      final OpenResult result = await OpenFile.open(filePath);

      return result;
      
    } catch (err, st) {
      Logger().e(err, st);
      return OpenResult(
        type: ResultType.error,
        message: 'An error occurred while opening the file.',
      );
    }

  }

}