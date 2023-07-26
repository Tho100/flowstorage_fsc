class GlobalsTable {

  static const homeImage = "file_info";
  static const homeText = "file_info_expand";
  static const homeVideo = "file_info_vid";
  static const homeExcel = "file_info_excel";
  static const homePdf = "file_info_pdf";
  static const homeWord = "file_info_word";
  static const homePtx = "file_info_ptx";
  static const homeApk = "file_info_apk";
  static const homeAudio = "file_info_audi";
  static const homeExe = "file_info_exe";

  static const directoryInfoTable = "file_info_directory";
  static const directoryUploadTable = "upload_info_directory";
  static const folderUploadTable = "folder_upload_info";

  static const psImage = "ps_info_image";
  static const psText = "ps_info_text";
  static const psVideo = "ps_info_video";
  static const psExcel = "ps_info_excel";
  static const psPdf = "ps_info_pdf";
  static const psWord = "ps_info_word";
  static const psPtx = "ps_info_ptx";
  static const psApk = "ps_info_apk";
  static const psAudio = "ps_info_audio";
  static const psExe = "ps_info_exe";

  static final Set<String> tableNames = {
    directoryInfoTable, homeImage, homeText, homeExe, homePdf,
    homeVideo,homeExcel, homePtx, homeAudio, homeWord,
    directoryUploadTable
  };

  static const Set<String> tableNamesPs = {
    "ps_info_image","ps_info_text","ps_info_video","ps_info_excel",
    "ps_info_pdf","ps_info_word","ps_info_ptx","ps_info_msi","ps_info_apk",
    "ps_info_exe","ps_info_audio"
  };

  static final Map<String,String> publicToPsTables = {
    homeImage: "ps_info_image",
    homeVideo: "ps_info_video",
    homeExcel: "ps_info_excel",
    homeText: "ps_info_text",
    homeWord: "ps_info_word",
    homePtx: "ps_info_ptx",
    homePdf: "ps_info_pdf",
    homeApk: "ps_info_apk",
    homeExe: "ps_info_exe",
    homeAudio: "ps_info_audio",
  };

}