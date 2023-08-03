class AccountPlan {

  static const int supremeLimitedNumber = 2000;
  static const int expressLimitedNumber = 800;
  static const int maxLimitedNumber = 150;
  static const int basicLimitedNumber = 25;

  static const int supremeLimitedNumberFolder = 20;
  static const int expressLimitedNumberFolder = 10;
  static const int maxLimitedNumberFolder = 5;
  static const int basicLimitedNumberFolder = 3;

  static const int supremeLimitedNumberDir = 5;
  static const int basicLimitedNumberDir = 2;

  static Map<String,int> mapFilesUpload = {
    'Basic': basicLimitedNumber, 
    'Max': maxLimitedNumber,
    'Express': expressLimitedNumber, 
    'Supreme': supremeLimitedNumber
  };

  static final Map<String,int> mapFoldersUpload = {
    'Basic': basicLimitedNumberFolder, 
    'Max': maxLimitedNumberFolder,
    'Express': expressLimitedNumberFolder, 
    'Supreme': supremeLimitedNumberFolder
  };

  static final Map<String,int> mapDirectoryUpload = {
    'Basic': basicLimitedNumberDir, 
    'Max': basicLimitedNumberDir,
    'Express': basicLimitedNumberDir, 
    'Supreme': supremeLimitedNumberDir
  };

}