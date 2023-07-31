import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';

class CompressorApi {

  static Future<File> processImageCompression({
    required String path, 
    required int quality
    }) async {

    final compressedFile = await FlutterNativeImage.compressImage(
      path,
      quality: quality,
    );
    
    return Future.value(compressedFile);
  }

  static Future<List<int>> compressedByteImage({
    required String path,
    required int quality,
  }) async {

    File? compressedFile = await processImageCompression(path: path, quality: quality);

    List<int> bytes = await compressedFile.readAsBytes();
    return bytes;

  }
  
}