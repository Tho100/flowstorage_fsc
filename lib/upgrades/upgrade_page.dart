import 'dart:io';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';

import 'package:flowstorage_fsc/upgrades/customers_dashboard.dart';
import 'package:flowstorage_fsc/upgrades/express_page.dart';
import 'package:flowstorage_fsc/upgrades/max_page.dart';
import 'package:flowstorage_fsc/upgrades/supreme_page.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class UpradePage extends StatefulWidget {
  const UpradePage({super.key});

  @override
  State<UpradePage> createState() => UpgradePageState();
}

class UpgradePageState extends State<UpradePage> {

  String userChoosenPlan = "";

  final userData = GetIt.instance<UserDataProvider>();

  final singleLoading = SingleTextLoading();

  final cardBorderRadius = 25.0;

  Widget _buildSubHeader(String text, {double? customFont}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: const Color.fromARGB(255, 18, 18, 18),
          fontWeight: FontWeight.w600,
          fontSize: customFont ?? 15,
        ),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFeatures(String text) {
    return Text(text,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: Color.fromARGB(255, 15, 15, 15),
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
      ),
      maxLines: 1,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildGetNowButton(VoidCallback getNowOnPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width-55,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )
        ),
        onPressed: getNowOnPressed,
        child: const Text(
          'Get Now',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ThemeColor.justWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildMaxPage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 52),
        
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("MAX",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 250, 195, 4),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
                        Text("\$2/monthly",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 15, 15, 15),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30),
                    Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 150 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 5 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ), 
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildGetNowButton(() {
                    userChoosenPlan = "Max";
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const MaxPage())).
                      then((value) 
                        async => await validatePayment()
                    );
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Cancel anytime without getting extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildSupremePage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 52),
        
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                        
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("SUPREME",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 74, 3, 164),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
                        Text("\$20/monthly",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 15, 15, 15),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                        
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 2000 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 20 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 5 Directories"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildGetNowButton(() {
                    userChoosenPlan = "Supreme";
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SupremePage())).
                      then((value) 
                        async => await validatePayment()
                    );
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Cancel anytime without getting extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildExpressPage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 52),
        
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                        
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("EXPRESS",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 40, 100, 169),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
                        Text("\$8/monthly",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 15, 15, 15),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                        
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 800 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 10 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildGetNowButton(() {
                    userChoosenPlan = "Express";
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const ExpressPage())).
                      then((value) 
                        async => await validatePayment()
                    );
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Cancel anytime without getting extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildTabUpgrade() {

    final cardHeight = MediaQuery.of(context).size.height-180;
    final cardWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: ThemeColor.darkPurple,
            tabs: [
              Tab(
                text: 'Max',
              ),
              Tab(
                text: 'Express',
              ),
              Tab(
                text: 'Supreme',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMaxPage(cardWidth, cardHeight),
                _buildExpressPage(cardWidth, cardHeight),
                _buildSupremePage(cardWidth, cardHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserAccountPlan(String customerId) async {

    final dateToStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

    const queryUpdateAccType = "UPDATE cust_type SET ACC_TYPE = :type WHERE CUST_EMAIL = :email AND CUST_USERNAME = :username";
    final params = {"username": userData.username,"email": userData.email,"type": userChoosenPlan};
    await Crud().update(query: queryUpdateAccType, params: params);

    const queryInsertBuyer = "INSERT INTO cust_buyer(CUST_USERNAME,CUST_EMAIL,ACC_TYPE,CUST_ID,PURCHASE_DATE) VALUES (:username,:email,:type,:id,:date)";
    final paramsBuyer = {"username": userData.username,"email": userData.email,"type": userChoosenPlan,"id": customerId,"date": dateToStr};
    await Crud().insert(query: queryInsertBuyer, params: paramsBuyer);

  }

  Future<void> updateLocallyStoredAccountType(String accountType) async {
      
    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);
    if (accountType.isNotEmpty) {
      if (setupInfosDir.existsSync()) {
        setupInfosDir.deleteSync(recursive: true);
      }

      setupInfosDir.createSync();

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {
        
        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync('${EncryptionClass().encrypt(userData.username)}\n${EncryptionClass().encrypt(userData.email)}\n$accountType');

      } catch (e) {
        // TODO: Ignore
      }
    } else {
      // TODO: Ignore
    }
    
  }

  Future<void> validatePayment() async {

    try {

      singleLoading.startLoading(title: "Validating...",context: context);

      final returnedEmail = await StripeCustomers.getCustomersEmails("");

      singleLoading.stopLoading();

      if(returnedEmail.contains(userData.email)) {
        
        if(!mounted) return;
        singleLoading.startLoading(title: "Upgrading...", context: context);

        final returnedId = await StripeCustomers.getCustomerIdByEmail(userData.email);
      
        await updateUserAccountPlan(returnedId);

        userData.setAccountType(userChoosenPlan);      

        await updateLocallyStoredAccountType(userChoosenPlan);

        singleLoading.stopLoading();

        CallNotify().customNotification(title: "Account Upgraded", subMesssage: "Thank you for subscribing to our service! You subscribed for $userChoosenPlan plan");

        if(!mounted) return;
        CustomAlertDialog.alertDialogTitle("Account Upgraded","You've subscribed to Flowstorage $userChoosenPlan account plan.",context);

      } else {
        if(!mounted) return;
        CustomAlertDialog.alertDialogTitle("Payment failed", "No payment has been made.", context);
      }

      returnedEmail.clear();

    } catch (err) {
      singleLoading.stopLoading();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        title: const Text("Upgrade Plan",
          style: GlobalsStyle.appBarTextStyle
        ),
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
     ),
      body: _buildTabUpgrade(),
    );
  }
}