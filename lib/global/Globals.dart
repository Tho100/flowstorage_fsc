import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class Globals {

  static final _tempData = GetIt.instance<TempDataProvider>();

  static const String fileInfoTable = 'file_info';
  static const String fileInfoExpandTable = 'file_info_expand';
  static const String fileInfoPdfTable = 'file_info_pdf';
  static const String fileInfoAudioTable = 'file_info_audi';
  static const String fileInfoWordTable = 'file_info_word';
  static const String fileInfoPtxTable = 'file_info_ptx';
  static const String fileInfoExcelTable = 'file_info_excel';
  static const String fileInfoExeTable = 'file_info_exe';
  static const String fileInfoVidTable = 'file_info_vid';

  static const Set<String> imageType = {"png","jpeg","jpg","webp"};
  static const Set<String> textType = {"txt","csv","html","sql","md"};
  static const Set<String> videoType = {"mp4","wmv","avi","mov","mkv"};
  static const Set<String> wordType = {"docx","doc"};
  static const Set<String> excelType = {"xls","xlsx"};
  static const Set<String> ptxType = {"pptx","ptx"};
  static const Set<String> audioType = {"wav","mp3"};

  static const Set<String> unsupportedOfflineModeTypes = {
    "mp4","wmv", "exe", "apk"
  };

  static const Map<String, String> fileTypesToTableNames = {
    'png': fileInfoTable,
    'jpg': fileInfoTable,
    'webp': fileInfoTable,
    'jpeg': fileInfoTable,
    'gif': fileInfoTable,

    'txt': fileInfoExpandTable,
    'sql': fileInfoExpandTable,
    'md': fileInfoExpandTable,
    'csv': fileInfoExpandTable,
    'html': fileInfoExpandTable,

    'pdf': fileInfoPdfTable,

    'doc': fileInfoWordTable,
    'docx': fileInfoWordTable,

    'pptx': fileInfoPtxTable,
    'ptx': fileInfoPtxTable,

    'xlsx': fileInfoExcelTable,
    'xls': fileInfoExcelTable,

    'exe': fileInfoExeTable,

    'mp4': fileInfoVidTable,
    'avi': fileInfoVidTable,
    'mov': fileInfoVidTable,

    'mp3' : fileInfoAudioTable,
    'wav': fileInfoAudioTable
  };

  static const Map<String, String> fileTypesToTableNamesPs = {

    'png': 'ps_info_image',
    'jpg': 'ps_info_image',
    'webp': 'ps_info_image',
    'jpeg': 'ps_info_image',
    'gif': 'ps_info_image',

    'txt': 'ps_info_text',
    'sql': 'ps_info_text',
    'md': 'ps_info_text',
    'csv': 'ps_info_text',
    'html': 'ps_info_text',

    'pdf': 'ps_info_pdf',
    'doc': 'file_info_word',
    'docx': 'file_info_word',
    'pptx': 'file_info_ptx',
    'ptx': 'file_info_ptx',
    'xlsx': 'ps_info_excel',
    'xls': 'ps_info_excel',
    
    'exe': 'ps_info_exe',

    'mp4': 'ps_info_video',
    'avi': 'ps_info_video',
    'mov': 'ps_info_video',
    
    'mp3' : 'ps_info_audio',
    'wav': 'ps_info_audio'
  };

  static const Set<String> supportedFileTypes = {
    "png","jpeg","gif","jpg",
    "html","sql","md","txt","pptx","ptx",
    "pdf","doc","docx","mp4","wav","avi","wmv","mov","mp3",
    "exe","xlsx","xls","csv","apk"
  };

  static Map<String,String> get originToName {
    return {
      'homeFiles': 'Home',
      'folderFiles': _tempData.folderName,
      'dirFiles': _tempData.directoryName,
      'sharedToMe': 'Shared to me',
      'sharedFiles': 'Shared files',
      'offlineFiles': 'Offline',
      'psFiles': 'Public Storage'
    };
  }

  static Map<String,String> get nameToOrigin {
    return {
      'Home': 'homeFiles',
      _tempData.folderName: 'folderFiles',
      _tempData.directoryName: 'dirFiles',
      'Shared to me': 'sharedToMe',
      'Shared files': 'sharedFiles',
      'Offline': 'offlineFiles',
      'Public Storage': 'psFiles',
    };
  }

  static const fileTypeToAssets = {
    "txt": "txt0.png",
    "csv": "txt0.png",
    "html": "txt0.png",
    "sql": "txt0.png",
    "md": "txt0.png",
    "pdf": "pdf0.png",
    "doc": "doc0.png",
    "docx": "doc0.png",
    "xlsx": "exl0.png",
    "xls": "exl0.png",
    "pptx": "ptx0.png",
    "ptx": "ptx0.png",
    "apk": "apk0.png",
    "mp3": "music0.png",
    "wav": "music0.png",
    "exe": "exe0.png",
  };

}