class GlobalsTable {

  static const homeImageTable = "file_info";
  static const homeTextTable = "file_info_expand";
  static const homeVideoTable = "file_info_vid";
  static const homeExcelTable = "file_info_excel";
  static const homePdfTable = "file_info_pdf";
  static const homeWordTable = "file_info_word";
  static const homePtxTable = "file_info_ptx";
  static const homeApkTable = "file_info_apk";
  static const homeAudioTable = "file_info_audi";
  static const homeExeTable = "file_info_exe";

  static const directoryInfoTable = "file_info_directory";
  static const folderUploadTable = "folder_upload_info";

  static final Set<String> tableNames = {
    GlobalsTable.homeImageTable, GlobalsTable.homeTextTable,
    GlobalsTable.homeExeTable,GlobalsTable.homePdfTable,
    GlobalsTable.homeVideoTable,GlobalsTable.homeExcelTable,
    GlobalsTable.homePtxTable, GlobalsTable.homeAudioTable,
    GlobalsTable.homeWordTable,
    "file_info_directory","upload_info_directory"
  };

  static const Set<String> tableNamesPs = {
    "ps_info_image","ps_info_text","ps_info_video","ps_info_excel",
    "ps_info_pdf","ps_info_word","ps_info_ptx","ps_info_msi","ps_info_apk",
    "ps_info_exe","ps_info_audio"
  };

  static final Map<String,String> publicToPsTables = {
    homeImageTable: "ps_info_image",
    homeVideoTable: "ps_info_video",
    homeExcelTable: "ps_info_excel",
    homeTextTable: "ps_info_text",
    homeWordTable: "ps_info_word",
    homePtxTable: "ps_info_ptx",
    homePdfTable: "ps_info_pdf",
    homeApkTable: "ps_info_apk",
    homeExeTable: "ps_info_exe",
    homeAudioTable: "ps_info_audio",
  };

}