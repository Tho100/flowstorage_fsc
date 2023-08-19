import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/upgrades/customers_dashboard.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyPlanPage extends StatefulWidget {

  const MyPlanPage({super.key});

  @override
  State<MyPlanPage> createState() => MyPlanPageState();
}

class MyPlanPageState extends State<MyPlanPage> {

  final _locator = GetIt.instance;

  late final UserDataProvider userData;

  final double containerWidth = 35.0;
  final double containerheight = 305.0;

  Widget buildHeader(String typeTag, String priceTag, String featuresTag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          typeTag,
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontWeight: FontWeight.w700,
            fontSize: 45
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 5),
        Text(
          "Charged \$$priceTag monthly",
          style: const TextStyle(
            color: ThemeColor.darkBlack,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 22),
        const Text(
          "FEATURES",
          style: TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 16,
            fontWeight: FontWeight.w900
          ),
        ),
        const SizedBox(height: 5),
        Text(
          featuresTag,
          style: const TextStyle(
            color: ThemeColor.darkBlack,
            fontSize: 16,
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    );
  }

  Widget buildCancelPlanButton() {

    const cardButtonHeight = 50.0;
    const cardButtonWidth = 205.0;

    return SizedBox(
      width: cardButtonWidth,
      height: cardButtonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )
        ),
        onPressed: () async {
          CustomAlertDialog.alertDialogCustomOnPressed(
            messages: "Are you sure you want to cancel your subscription plan? \n\nYour account will downgraded to Basic from ${userData.accountType} and you'll no longer be charged.", 
            oPressedEvent: () async {

              try {

                await StripeCustomers.
                cancelCustomerSubscriptionByEmail(userData.email, context);

                if(!mounted) return;
                Navigator.pop(context);

                CustomAlertDialog.alertDialogTitle(
                  "Subscription plan cancelled successfully", 
                  "Thank you for being previously a part of our customer!", 
                  context
                );

              } catch (er) {
                SnakeAlert.errorSnake("Subscription cancellation failed.", context);
                return;
              }

            }, 
            onCancelPressed: () {
              Navigator.pop(context);
            }, 
            context: context
          );
        }, 
        child: const Text(
          'Cancel Plan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ThemeColor.justWhite,
          ),
        ),
      ),
    );
  }

  Widget buildMaxPage() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width-containerWidth,
          height: containerheight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 228, 188, 13),
                Color.fromARGB(255, 236, 218, 56),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12.0, right: 18.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft, 
                    child: buildHeader(
                      "Max", "2", "${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFilesUpload[userData.accountType]} Files \n${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFoldersUpload[userData.accountType]} Folders \n${GlobalsStyle.dotSeperator} Folder Download"
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight, 
                  child: buildCancelPlanButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildExpressPage() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width-containerWidth,
          height: containerheight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: 
                [Color.fromARGB(255, 93, 108, 248),
                Color.fromARGB(255, 36, 72, 192)
              ]
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12.0, right: 18.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft, 
                    child: buildHeader(
                      "Express", "8", "${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFilesUpload[userData.accountType]} Files \n${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFoldersUpload[userData.accountType]} Folders \n${GlobalsStyle.dotSeperator} Folder Download"
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight, 
                  child: buildCancelPlanButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSupremePage() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width-containerWidth,
          height: containerheight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 141, 79, 223), 
                ThemeColor.darkPurple
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12.0, right: 18.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft, 
                    child: buildHeader(
                      "Supreme", "20", 
                      "${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFilesUpload[userData.accountType]} Files \n${GlobalsStyle.dotSeperator} Upload up to ${AccountPlan.mapFoldersUpload[userData.accountType]} Folders \n${GlobalsStyle.dotSeperator} Folder Download \n${GlobalsStyle.dotSeperator} Upload up to 5 Directories"
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight, 
                  child: buildCancelPlanButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    userData = _locator<UserDataProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text(
          "My plan",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            if(userData.accountType == "Max") buildMaxPage(),
            if(userData.accountType == "Express") buildExpressPage(),
            if(userData.accountType == "Supreme") buildSupremePage(),
          ],
        ),
      ),
    );
  }
}