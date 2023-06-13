import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/SingleText.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';

import 'package:flowstorage_fsc/upgrades/customers_dashboard.dart';
import 'package:flowstorage_fsc/upgrades/express_page.dart';
import 'package:flowstorage_fsc/upgrades/max_page.dart';
import 'package:flowstorage_fsc/upgrades/supreme_page.dart';

import 'package:flutter/material.dart';

class UpradePage extends StatefulWidget {
  const UpradePage({super.key});

  @override
  State<UpradePage> createState() => _UpgradePage();
}

class _UpgradePage extends State<UpradePage> {

  final singleLoading = SingleTextLoading();
  String userChoosenPlan = "";

  Widget _buildBanner() {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(title: "Upgrade Plan", subTitle: "Select any of the available plans to access additional file upload and features!"),
        ),
        SizedBox(height: 15),
      ],
    );
      
  }

  Widget _buildSecondHeader(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: ThemeColor.darkBlack,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildHeader(String planName) {
    return Text(
      planName.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 35,
      ),
    );
  }

  Widget _buildPriceTag(String price) {
    return Column(
      children: [
        const Center(
          child: Text(
            "Starting From",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
        ),

        const SizedBox(height: 28.0),

        Center(
          child: Text(
            "\$$price",
            style: const TextStyle(
              color: Color.fromARGB(255, 243, 243, 243),
              fontWeight: FontWeight.w500,
              fontSize: 75,
            ),
          ),
        ),
        
        const SizedBox(height: 5),

        const Center(
          child: Text(
            "/monthly",
            style: TextStyle(
              color: ThemeColor.mediumGrey,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
        ),
      ]
    );
  }

  Widget _buildMaxPage() {
    return SizedBox(
      width: 345,
      height: 500,
      child: Column(
        children: [

          const SizedBox(height: 45),
        
          Container(
            width: 345,
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 228, 188, 13),Color.fromARGB(255, 236, 218, 56)],
              ),
            ),
            child: Column(
              children: [

                const SizedBox(height: 15),
                _buildHeader("max"),
                const SizedBox(height: 25),
                _buildPriceTag("3"),
                const SizedBox(height: 35),
                _buildSecondHeader("Upload up to 500 files!"),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    " + Folder Download",
                    style: TextStyle(
                      color: ThemeColor.darkBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 5),

                const Center(
                  child: Text(
                    " + Upload up to 5 Folders",
                    style: TextStyle(
                      color: ThemeColor.darkBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: 255,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.darkBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      )
                    ),
                    onPressed: () {
                      userChoosenPlan = "Max";
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const MaxPage())).
                        then((value) 
                          async => await validatePayment()
                      );
                    }, 
                    child: const Text(
                      'Get Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.justWhite,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildExpressPage() {
    return SizedBox(
      width: 345,
      height: 500,
      child: Column(
        children: [

          const SizedBox(height: 45),
        
          Container(
            width: 345,
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 93, 108, 248),Color.fromARGB(255, 36, 72, 192)],
              ),
            ),
            child: Column(
              children: [

                const SizedBox(height: 15),
                _buildHeader("express"),
                const SizedBox(height: 25),
                _buildPriceTag("5"),
                const SizedBox(height: 35),
                _buildSecondHeader("Upload up to 1000 files!"),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    " + Folder Download",
                    style: TextStyle(
                      color: ThemeColor.darkBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 5),

                const Center(
                  child: Text(
                    " + Upload up to 10 Folders",
                    style: TextStyle(
                      color: ThemeColor.darkBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: 255,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.darkBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      )
                    ),
                    onPressed: () {
                      userChoosenPlan = "Express";
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const ExpressPage())).
                        then((value) 
                          async => await validatePayment()
                      );
                    }, 
                    child: const Text(
                      'Get Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.justWhite,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildSupremeTab() {
    return SizedBox(
      width: 345,
      height: 500,
      child: Column(
        children: [

          const SizedBox(height: 45),
        
          Container(
            width: 345,
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 141, 79, 223), ThemeColor.darkPurple],
              ),
            ),
            child: Column(
              children: [

                const SizedBox(height: 15),
                _buildHeader("supreme"),
                const SizedBox(height: 25),
                _buildPriceTag("20"),
                const SizedBox(height: 35),
                _buildSecondHeader("Upload up to 2000 files!"),

                const SizedBox(height: 15),

                const Center(
                child: Text(
                  " + Folder Download",
                  style: TextStyle(
                    color: ThemeColor.darkBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 5),

               const Center(
                child: Text(
                  " + Upload up to 5 Directory",
                  style: TextStyle(
                    color: ThemeColor.darkBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

                const SizedBox(height: 5),

                const Center(
                  child: Text(
                    " + Upload up to 20 Folders",
                    style: TextStyle(
                      color: ThemeColor.darkBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: 255,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.darkBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      )
                    ),
                    onPressed: () {
                      userChoosenPlan = "Supreme";
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const SupremePage())).
                        then((value) 
                          async => await validatePayment()
                      );
                    }, 
                    child: const Text(
                      'Get Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.justWhite,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildTabUpgrade() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildBanner(),
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
          SizedBox(
            height: MediaQuery.of(context).size.height-300,
            child: TabBarView(
              children: [
                _buildMaxPage(),
                _buildExpressPage(),
                _buildSupremeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserAccountPlan(String customerId) async {
    
    const queryUpdateAccType = "UPDATE cust_type SET ACC_TYPE = :type WHERE CUST_EMAIL = :email AND CUST_USERNAME = :username";
    final params = {"username": Globals.custUsername,"email": Globals.custEmail,"type": userChoosenPlan};
    await Crud().update(query: queryUpdateAccType, params: params);

    const queryInsertBuyer = "INSERT INTO cust_buyer(CUST_USERNAME,CUST_EMAIL,ACC_TYPE,CUST_ID) VALUES (:username,:email,:type,:id)";
    final paramsBuyer = {"username": Globals.custUsername,"email": Globals.custEmail,"type": userChoosenPlan,"id": customerId};
    await Crud().insert(query: queryInsertBuyer, params: paramsBuyer);

  }

  Future<void> validatePayment() async {

    singleLoading.startLoading(title: "Validating...",context: context);

    final returnedEmail = await StripeCustomers.getCustomersEmails();

    singleLoading.stopLoading();

    if(returnedEmail.contains(Globals.custEmail)) {

      singleLoading.startLoading(title: "Upgrading...", context: context);

      final returnedId = await StripeCustomers.getCustomerIdByEmail(Globals.custEmail);
    
      await updateUserAccountPlan(returnedId);
      await StripeCustomers.deleteEmailByEmail(Globals.custEmail);

      Globals.accountType = userChoosenPlan;      

      singleLoading.stopLoading();

      CallNotify().customNotification(title: "Account Upgraded", subMesssage: "Thank you for subscribing to our service! You subscribed for $userChoosenPlan plan");

      AlertForm.alertDialogTitle("Account Upgraded","You've subscribed to Flowstorage $userChoosenPlan account plan.",context);

    } else {
      AlertForm.alertDialogTitle("Payment failed", "No payment has been made.", context);
    }

    returnedEmail.clear();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: ThemeColor.darkPurple, 
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
     ),

      body: _buildTabUpgrade(),
    );
  }
}