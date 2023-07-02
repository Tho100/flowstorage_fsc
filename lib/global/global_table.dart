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
    "ps_info_image","ps_info_text","ps_info_video","ps_info_excel"
  };

}