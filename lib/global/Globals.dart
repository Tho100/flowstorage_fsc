import 'dart:io';
import 'dart:typed_data';

/// <summary>
/// 
/// Initialize global variables and list for listView
/// items to store/load later on
/// 
/// </summary>

class Globals {

  static String custUsername = '';
  static String custEmail = '';
  static String accountType = '';
  
  static String fileOrigin = '';
  static String folderTitleValue = '';
  static String directoryTitleValue = '';
  static String selectedFileName = '';

  static bool fromLogin = false;

  static List<String> fileValues = [];
  static List<File> imageValues = [];
  static List<String> foldValues = [];
  static List<String> dateStoresValues = [];

  static List<Uint8List?> imageByteValues = <Uint8List?>[];
  static List<String> setDateValues = <String>[];

  static List<String> filteredSearchedFiles = <String>[];
  static List<File> filteredSearchedImage = <File>[];
  static List<Uint8List?> filteredSearchedBytes = <Uint8List?>[];

  static const Map<String, String> fileTypesToTableNames = {

    'png': 'file_info',
    'jpg': 'file_info',
    'webp': 'file_info',
    'jpeg': 'file_info',
    'gif': 'file_info',

    'txt': 'file_info_expand',
    'sql': 'file_info_expand',
    'md': 'file_info_expand',
    'csv': 'file_info_expand',
    'html': 'file_info_expand',

    'pdf': 'file_info_pdf',
    'doc': 'file_info_word',
    'docx': 'file_info_word',
    'pptx': 'file_info_ptx',
    'ptx': 'file_info_ptx',
    'xlsx': 'file_info_excel',
    'xls': 'file_info_excel',
    
    'exe': 'file_info_exe',

    'mp4': 'file_info_vid',
    'avi': 'file_info_vid',
    'mov': 'file_info_vid',
  };
  
  static const Set<String> supportedFileTypes = {
    "png","jpeg","webp","gif","jpg",
    "html","sql","md","txt","pptx","ptx",
    "pdf","doc","docx","mp4","wav","avi","wmv","mov","mp3",
    "exe","xlsx","xls","csv","apk"
  };

  static const Set<String> imageType = {"png","jpeg","jpg","webp"};
  static const Set<String> textType = {"txt","csv","html","sql"};
  static const Set<String> videoType = {"mp4","wmv","avi","mov","mkv"};
  static const Set<String> tableNames = {
    "file_info","file_info_expand","file_info_exe","file_info_pdf",
    "file_info_vid","file_info_excel","file_info_ptx","file_info_audi",
    "file_info_word","file_info_directory","upload_info_directory"};

  static const Map<String, int> filesUploadLimit = {
    'Basic': 25,
    'Max': 500,
    'Express': 1000,
    'Supreme': 2000
  };

  static Map<String,String> get originToName {
    return {
      'homeFiles': 'Home',
      'folderFiles': Globals.folderTitleValue,
      'dirFiles': Globals.directoryTitleValue,
      'sharedToMe': 'Shared to me',
      'sharedFiles': 'Shared files',
      'offlineFiles': 'Offline files'
    };
  }

}