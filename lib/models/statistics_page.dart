import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/navigator/navigate_page.dart';
import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => StatsPage();
}

class StatsPage extends State<StatisticsPage> {

  final categoryNamesHomeFiles = ['Image', 'Audio', 'Document', 'Video', 'Text'];

  late List<_UploadCountValue> data;
  bool dataIsLoading = true;

  int totalUpload = 0;
  int directoryCount = 0;
  int folderCount = 0;

  String categoryWithMostUpload = "";
  String categoryWithLeastUpload = "";

  String accountCreationDate = "";

  double usageProgress = 0.0;
  
  final crud = Crud();

  @override 
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {

    try {

      setState(() {
        dataIsLoading = true;
      });

      final futuresFile = [
        _countUpload("file_info"),
        _countUpload("file_info_audi"),
        _countUpload("file_info_pdf"),
        _countUpload("file_info_vid"),
        _countUpload("file_info_expand"),
        _countUpload("file_info_ptx"),
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

      categoryWithMostUpload = categoryNamesHomeFiles[maxCategoryIndex];
      categoryWithLeastUpload = categoryNamesHomeFiles[minCategoryIndex];

      final countDirectories = await _countUploadFoldAndDir("file_info_directory", "DIR_NAME");

      folderCount = Globals.foldValues.length;
      directoryCount = countDirectories;

      accountCreationDate = await _accountCreationDate();

      final document0 = await _countUpload("file_info_pdf");
      final document1 = await _countUpload("file_info_excel");
      final document2 = await _countUpload("file_info_word");

      setState(() {
        data = [
          _UploadCountValue('Image', uploadCategoryList[0]),
          _UploadCountValue('Audio',uploadCategoryList[1]),
          _UploadCountValue('Document', document0+document1+document2),
          _UploadCountValue('Video', uploadCategoryList[3]),
          _UploadCountValue('Text', uploadCategoryList[4])
        ];
        dataIsLoading = false;
      });

    } catch (err) {
      SnakeAlert.errorSnake("No internet connection.", context);
      print("Exception from _initData (StatisticsPage): $err");
    }

  }

  Future<int> _countUpload(String tableName) async {

    final countRowsFiles = "SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': Globals.custUsername};

    final rowsCount = await crud.count(
      query: countRowsFiles, 
      params: params
    );

    return rowsCount;

  }

  Future<int> _countUploadFoldAndDir(String tableName,String columnName) async {

    final countRowFolderNDir = "SELECT COUNT($columnName) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': Globals.custUsername};

    final rowsCount = await crud.count(
      query: countRowFolderNDir, 
      params: params
    ); 

    return rowsCount;
  }

  Future<String> _accountCreationDate() async {

    const selectAccCreatedDate = "SELECT CREATED_DATE FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': Globals.custUsername};

    final createdDateValue = await crud.select(
      query: selectAccCreatedDate, 
      returnedColumn: "CREATED_DATE", 
      params: params
    );

    return createdDateValue;

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

  Widget _buildInfo(String HeaderText, String SubText) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            HeaderText,
            style: const TextStyle(
              color: Color.fromARGB(225, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),

          const Spacer(),

          Text(
            SubText,
            style: const TextStyle(
              color: Color.fromARGB(200, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context, String origin) {

    // Most Uploaded
    // Least Uploaded
    // Latest Uploaded

    // Total Upload
    // Folder Count
    // Directory Count

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 135,
        width: MediaQuery.of(context).size.width-25,
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColor.darkGrey,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ThemeColor.darkGrey, width: 2),
          ),
          child: Column(
            children: [
              _buildInfo(
                origin == "top" 
              ? "Most Uploaded" 
              : "Total Upload",
                
                origin == "top" 
                ? categoryWithMostUpload
                : totalUpload.toString()
              ),

              _buildInfo(
                origin == "top" 
              ? "Least Uploaded" 
              : "Folder Count",

                origin == "top"
                ? categoryWithLeastUpload
                : folderCount.toString()
              ),

              _buildInfo(
                  origin == "top" 
                ? "Account Creation Date" 
                : "Directory Count",

                  origin == "top" 
                  ? accountCreationDate
                  : directoryCount.toString()
                ),

            ],
          ),
        ),
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
          series: <ChartSeries<_UploadCountValue, String>>[
            ColumnSeries<_UploadCountValue, String>(
              color: ThemeColor.darkPurple,
              dataSource: data,
              xValueMapper: (_UploadCountValue value, _) => value.category,
              yValueMapper: (_UploadCountValue value, _) => value.totalUpload,
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
            _buildBottom(context,"top"),
            const SizedBox(height: 5),
            _buildBottom(context,"bottom"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoUsage(String HeaderText, String SubText) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            HeaderText,
            style: const TextStyle(
              color: Color.fromARGB(225, 255, 255, 255),
              fontSize: 19,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),

          const Spacer(),

          Text(
            SubText,
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

    final int maxValue = AccountPlan.mapFilesUpload[Globals.accountType]!;
    final int percentage = ((Globals.fileValues.length/maxValue) * 100).toInt();
    usageProgress = percentage/100.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 245,
        width: MediaQuery.of(context).size.width-25,
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColor.darkGrey,
            borderRadius: BorderRadius.circular(15),
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
            dataIsLoading ? _buildLoading() : _buildPage(context),
            dataIsLoading ? _buildLoading() : _buildUsagePage(context),
          ],
        ),
      ),
    );
  }
}

class _UploadCountValue {

  _UploadCountValue(this.category, this.totalUpload);

  final String category;
  final int totalUpload;

}