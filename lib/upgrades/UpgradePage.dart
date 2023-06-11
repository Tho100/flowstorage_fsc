import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/SingleText.dart';
import 'package:flowstorage_fsc/upgrades/GetEmails.dart';
import 'package:flowstorage_fsc/upgrades/MaxPage.dart';
import 'package:flowstorage_fsc/widgets/HeaderText.dart';
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
          child: HeaderText(title: "Upgrade Plan", subTitle: "Cancel anytime without getting charged"),
        ),
        SizedBox(height: 15),
      ],
    );
      
  }

  Widget _buildMaxPage() {
    return Column(
      children: [

        const SizedBox(height: 45),

        Container(
          width: 345,
          height: 500,
          decoration: BoxDecoration(
            color: ThemeColor.darkBlack,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            children: [
            
              Container(
                width: 345,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 228, 188, 13),Color.fromARGB(255, 236, 218, 56)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "MAX",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 25),
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

              const Center(
                child: Text(
                  "\$3",
                  style: TextStyle(
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
                    color: Color.fromARGB(255, 213, 213, 213),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
               
              ),

              const SizedBox(height: 35),
              const Center(
                child: Text(
                  "Upload up to 500 files!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  " + Folder Download",
                  style: TextStyle(
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    backgroundColor: const Color.fromARGB(255, 243, 223, 44),
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
                      color: ThemeColor.darkBlack
                    ),
                  ),
                ),
              ),

            ],
          ),        
        ),
      ]
    );
  }

  Widget _buildExpressPage() {
    return Column(
      children: [

        const SizedBox(height: 45),

        Container(
          width: 345,
          height: 500,
          decoration: BoxDecoration(
            color: ThemeColor.darkBlack,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            children: [
            
              Container(
                width: 345,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 93, 108, 248),Color.fromARGB(255, 36, 72, 192)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "EXPRESS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
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

              const Center(
                child: Text(
                  "\$5",
                  style: TextStyle(
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
                    color: Color.fromARGB(255, 213, 213, 213),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
               
              ),

              const SizedBox(height: 35),
              const Center(
                child: Text(
                  "Upload up to 1000 files!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  " + Folder Download",
                  style: TextStyle(
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    backgroundColor: const Color.fromARGB(255, 41, 89, 192),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )
                  ),
                  onPressed: () {}, 
                  child: const Text(
                    'Get Now',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.darkBlack
                    ),
                  ),
                ),
              ),

            ],
          ),        
        ),
      ]
    );
  }

    Widget _buildSupremeTab() {
    return Column(
      children: [

        const SizedBox(height: 45),

        Container(
          width: 345,
          height: 500,
          decoration: BoxDecoration(
            color: ThemeColor.darkBlack,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            children: [
            
              Container(
                width: 345,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 141, 79, 223), ThemeColor.darkPurple],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "SUPREME",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 25),
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

              const Center(
                child: Text(
                  "\$10",
                  style: TextStyle(
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
                    color: Color.fromARGB(255, 213, 213, 213),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
               
              ),

              const SizedBox(height: 25),
              
              const Center(
                child: Text(
                  "Upload up to 2000 files!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  " + Folder Download",
                  style: TextStyle(
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    color: Color.fromARGB(255, 233, 233, 233),
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
                    color: Color.fromARGB(255, 233, 233, 233),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: 255,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.darkPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )
                  ),
                  onPressed: () {}, 
                  child: const Text(
                    'Get Now',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.darkBlack
                    ),
                  ),
                ),
              ),

            ],
          ),        
        ),
      ]
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

  Future<void> validatePayment() async {

    singleLoading.startLoading(title: "Validating...",context: context);

    final returnedEmail = await GetEmails.getEmails();

    singleLoading.stopLoading();

    if(returnedEmail.contains(Globals.custEmail)) {
      // TODO: Update user plan based on their chose
      AlertForm.alertDialogTitle("PASS", "${Globals.custEmail}\n$userChoosenPlan", context);
    } else {
      AlertForm.alertDialogTitle("BAD ${returnedEmail[0]}", Globals.custEmail, context);
    }
    
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