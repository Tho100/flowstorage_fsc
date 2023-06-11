import 'package:flowstorage_fsc/ui_dialog/SnakeAlert.dart';
import 'package:flowstorage_fsc/user_settings/BackupRecovery.dart';
import 'package:flowstorage_fsc/user_settings/ChangePassword.dart';
import 'package:flowstorage_fsc/user_settings/ChangeUsername.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import '../authentication/PasscodePage.dart';
import '../authentication/SignIn.dart';
import '../authentication/SignUp.dart';
import '../global/Globals.dart';
import '../main.dart';
import '../models/CreateText.dart';
import '../models/StatisicsPage.dart';
import '../sharing/SharingOptions.dart';
import '../sharing/SharingPage.dart';
import '../upgrades/UpgradePage.dart';
import '../user_settings/SettingMenu.dart';

class NavigatePage {

  static void replacePageHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
  
  static void permanentPageHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const HomePage()), 
      (route) => false);
  }

  static void replacePageMainboard(BuildContext context) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const Mainboard())
    );   
  }

  static void permanentPageMainboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Mainboard()),
      (route) => false,
    );
  }

  static void goToPageLogin(BuildContext context) {
     Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const cakeLogin()),
    );
  }

  static void goToPageRegister(BuildContext context) {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const cakeMySignUp()),
    );
  }
  
  static void goToPageSharing(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => const SharingPage(),
      ),
    );
  }

  static void goToPageStatistics(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => const StatisticsPage(),
      )
    );
  }

  static void goToPageUpgrade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpradePage())
    );
  }

  static void goToPageCreateText(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateText())
    );
  }

  static void goToPageSettings(BuildContext context) async {

    try {

      String currentDisabledStatus = await SharingOptions.retrieveDisabled(Globals.custUsername);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => 
            CakeSettingsPage(
            accType: Globals.accountType,
            custEmail: Globals.custEmail,
            custUsername: Globals.custUsername,
            uploadLimit: Globals.filesUploadLimit[Globals.accountType]!,
            sharingEnabledButton: currentDisabledStatus,
          ),
        ),
      );

    } catch (err) {
      print("Exception on goToPageSettings (NavigatePage): $err");
      SnakeAlert.errorSnake("No internet connection.", context);
    }
  }

  static void goToPageBackupRecovery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BackupRecovery())
    );
  }

  static void goToPageChangeUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangeUsername())
    );
  }

  static void goToPageChangePass(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePassword())
    );
  }

  static void goToPagePasscode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasscodePage())
    );
  }

}