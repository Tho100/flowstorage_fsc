import 'dart:io';

import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => StatsPageState();
}

class StatsPageState extends State<StatisticsPage> {

  final logger = Logger();
  final crud = Crud();

  final categoryNamesHomeFiles = {'Image', 'Audio', 'Document', 'Video', 'Text'};

  late List<UploadCountValue> data;

  final dataIsLoading = ValueNotifier<bool>(true);

  int totalUpload = 0;
  int directoryCount = 0;
  int folderCount = 0;
  int offlineCount = 0;

  String categoryWithMostUpload = "";
  String categoryWithLeastUpload = "";

  double usageProgress = 0.0;
  
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  @override 
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    dataIsLoading.dispose();
    storageData.statisticsFilesName.clear();
    super.dispose();
  }

  Future<void> _initData() async {

    try {

      dataIsLoading.value = true;

      final futuresFile = [
        _countUpload(GlobalsTable.homeImage),
        _countUpload(GlobalsTable.homeAudio),
        _countUpload(GlobalsTable.homePdf),
        _countUpload(GlobalsTable.homeVideo),
        _countUpload(GlobalsTable.homeText),
        _countUpload(GlobalsTable.homePtx),
      ];

      final uploadCategoryList = await Future.wait(futuresFile);
      totalUpload = uploadCategoryList.reduce((sum, uploadCount) => sum + uploadCount);

      int maxUploadCount = 0;
      int maxCategoryIndex = 0;
      int minUploadCount = 2000;
      int minCategoryIndex = 0;

      for (int i = 0; i < uploadCategoryList.length; i++) {

        final uploadCount = uploadCategoryList[i];

        if (uploadCount > maxUploadCount) {
          maxUploadCount = uploadCount;
          maxCategoryIndex = i;
        }

        if (uploadCount > 0 && uploadCount < minUploadCount) {
          minUploadCount = uploadCount;
          minCategoryIndex = i;
        }
      }

      categoryWithMostUpload = uploadCategoryList[maxCategoryIndex] == 0 ? "None" : categoryNamesHomeFiles.elementAt(maxCategoryIndex);
      categoryWithLeastUpload = categoryNamesHomeFiles.elementAt(minCategoryIndex) == "Image" ? "None" : categoryNamesHomeFiles.elementAt(minCategoryIndex);

      final countDirectories = await _countUploadFoldAndDir(GlobalsTable.directoryInfoTable, "DIR_NAME");

      folderCount = storageData.foldersNameList.length;
      directoryCount = countDirectories;
      offlineCount = await _countUploadOffline();

      final document0 = await _countUpload(GlobalsTable.homePdf);
      final document1 = await _countUpload(GlobalsTable.homeExcel);
      final document2 = await _countUpload(GlobalsTable.homeWord);

      setState(() {
        data = [
          UploadCountValue('Image', uploadCategoryList[0]),
          UploadCountValue('Audio',uploadCategoryList[1]),
          UploadCountValue('Document', document0+document1+document2),
          UploadCountValue('Video', uploadCategoryList[3]),
          UploadCountValue('Text', uploadCategoryList[4])
        ];
      });
      
      dataIsLoading.value = false;

    } catch (err, st) {
      SnakeAlert.errorSnake("No internet connection.", context);
      logger.e('Exception from _initData {statistics_page}',err,st);
    }

  }

  Future<int> _countUpload(String tableName) async {

    final dataOrigin = tempData.fileOrigin != "homeFiles"
    ? storageData.statisticsFilesName
    : storageData.fileNamesFilteredList;

    final fileTypeList = <String>[];

    for(int i=0; i<dataOrigin.length; i++) {
      final fileType = dataOrigin.elementAt(i).split('.').last;
      fileTypeList.add(fileType);
    }
    
    int uploadCount = 0;

    for (String fileType in fileTypeList) {
      if (Globals.fileTypesToTableNames.containsKey(fileType) &&
          Globals.fileTypesToTableNames[fileType] == tableName) {
        uploadCount++;
      }
    }

    return uploadCount;

  }

  Future<int> _countUploadFoldAndDir(String tableName,String columnName) async {

    int countDirectory = storageData.fileNamesFilteredList
      .where((dir) => !dir.contains('.')).length;

    int countFolderOrDirectory = tableName == GlobalsTable.folderUploadTable 
    ? storageData.foldersNameList.length
    : countDirectory;

    return countFolderOrDirectory;

  }

  Future<int> _countUploadOffline() async {

    try {

      final offlineDir = await OfflineMode().returnOfflinePath();
    
      List<FileSystemEntity> files = offlineDir.listSync();
      int fileCount = files.whereType().length;
      return fileCount;

    } catch (err) {
      return 0;
    }

  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: Text(
        'Statistics',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }

  Widget _buildInfo(String headerText, String subText) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                headerText,
                style: const TextStyle(
                  color: Color.fromARGB(225, 255, 255, 255),
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.left,
              ),
            ),
    
            const Spacer(),
    
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                subText,
                style: const TextStyle(
                  color: Color.fromARGB(200, 255, 255, 255),
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildHeaderInfo(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text,
            style: GlobalsStyle.settingsInfoTextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContainer() {
    
    final mediaQuery = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [

          const SizedBox(height: 5),

          _buildHeaderInfo("General"),

          const SizedBox(height: 5),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ThemeColor.darkGrey, width: 2),
            ),
            height: 125,
            width: mediaQuery.width-35,
            child: Column(
              children: [
                _buildInfo("Most Uploaded", categoryWithMostUpload),
                _buildInfo("Least Uploaded", categoryWithLeastUpload),
                _buildInfo("Total Upload", totalUpload.toString()),
              ],
            )
          ),

          const SizedBox(height: 18),

          _buildHeaderInfo("Others"),

          const SizedBox(height: 5),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ThemeColor.darkGrey, width: 2),
            ),
            height: 125,
            width: mediaQuery.width-35,
            child: Column(
              children: [
                _buildInfo("Folder Count", folderCount.toString()),
                _buildInfo("Directory Count", directoryCount.toString()),
                _buildInfo("Offline Total Uploaded", offlineCount.toString()),
              ],
            )
          ),

          const SizedBox(height: 15),

          Container(),

        ],
      ),
    );

  }

  Widget _buildChart(context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        height: 380,
        width: MediaQuery.of(context).size.width-35,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // Chart title
          title: ChartTitle(text: 'File Upload Counter Chart'),
          // Enable legend
          legend: Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<UploadCountValue, String>>[
            ColumnSeries<UploadCountValue, String>(
              color: ThemeColor.darkPurple,
              dataSource: data,
              xValueMapper: (UploadCountValue value, _) => value.category,
              yValueMapper: (UploadCountValue value, _) => value.totalUpload,
              name: 'Files',
              // Enable data label
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 5),
            _buildChart(context),
            const SizedBox(height: 12),
            _buildInfoContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoUsage(String headerText, String subText) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            headerText,
            style: const TextStyle(
              color: Color.fromARGB(225, 255, 255, 255),
              fontSize: 19,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),

          const Spacer(),

          Text(
            subText,
            style: const TextStyle(
              color: Color.fromARGB(200, 255, 255, 255),
              fontSize: 19,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageProgressBar(BuildContext context) {
    return Container(
      height: 10,
      width: MediaQuery.of(context).size.width - 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ThemeColor.darkGrey,
          width: 2.0,
        ),
      ),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
        value: usageProgress,
      ),
    );


  }

  Widget _buildUpgradeButton(BuildContext context) {
    return SizedBox(
        height: 55,
        width: MediaQuery.of(context).size.width-165,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),  
        ),

        onPressed: () {
          NavigatePage.goToPageUpgrade(context);
        },
        
        child: const Text("Upgrade Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      )
    );
  }

  Widget _buildUsageContainer(BuildContext context) {

    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;
    final percentage = ((storageData.fileNamesList.length/maxValue) * 100).toInt();
    usageProgress = percentage/100.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 245,
        width: MediaQuery.of(context).size.width-25,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeColor.darkGrey, width: 2),
          ),
          child: Column(
            children: [
              
              _buildInfoUsage("Limited to", "$maxValue Uploads"),
              _buildInfoUsage("Usage", "$percentage%"),
              const SizedBox(height: 5),
              _buildUsageProgressBar(context),
              const SizedBox(height: 35),
              _buildUpgradeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsagePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildUsageContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: ThemeColor.darkPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
     return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ThemeColor.darkBlack,
        appBar: AppBar(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: ThemeColor.darkPurple,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Usage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            dataIsLoading.value ? _buildLoading() : _buildPage(context),
            dataIsLoading.value ? _buildLoading() : _buildUsagePage(context),
          ],
        ),
      ),
    );
  }
}

class UploadCountValue {

  UploadCountValue(this.category, this.totalUpload);

  final String category;
  final int totalUpload;

}