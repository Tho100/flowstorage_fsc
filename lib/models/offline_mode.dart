import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OfflineMode {
  late Directory offlineDirs;

  OfflineMode() {
    initializeOfflineDirs();
  }

  Future<void> initializeOfflineDirs() async {
    final getDirApplication = await getApplicationDocumentsDirectory();
    offlineDirs = Directory('${getDirApplication.path}/offline_files');
  }

  Future<void> init() async {
    await initializeOfflineDirs();
  }

  Future<void> deleteFile(String fileName) async {
    await init();
    final file = File('${offlineDirs.path}/$fileName');
    file.deleteSync();
  }

  Future<void> renameFile(String fileName, String newFileName) async {
    await init();
    final file = File('${offlineDirs.path}/$fileName');
    String newPath = '${offlineDirs.path}/$newFileName';
    await file.rename(newPath);
  }
}