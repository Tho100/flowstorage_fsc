import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class GetAssets {

  static const assetPath = 'assets/nice/';

  Future<File> loadAssetsFile(String path) async {   
    final byteData = await rootBundle.load('$assetPath$path');   
    final file = await File('${(await getTemporaryDirectory()).path}/$path')       
    .create(recursive: true);   
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));   
    return file; 
  }

  Future<Uint8List> loadAssetsData(String path) async {
    final byteData = await rootBundle.load('$assetPath$path');
    return byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

}