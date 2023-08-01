import 'package:flowstorage_fsc/models/feedback_page.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/user_settings/add_passcode_page.dart';
import 'package:flowstorage_fsc/user_settings/backup_recovery_page.dart';
import 'package:flowstorage_fsc/user_settings/update_password_page.dart';
import 'package:flowstorage_fsc/user_settings/update_username_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../home_page.dart';
import '../authentication/passcode_page.dart';
import '../authentication/sign_in_page.dart';
import '../authentication/sign_up_page.dart';
import '../global/globals.dart';
import '../main.dart';
import '../models/create_text.dart';
import '../models/statistics_page.dart';
import '../sharing/sharing_options.dart';
import '../sharing/sharing_page.dart';
import '../upgrades/upgrade_page.dart';
import '../user_settings/settings_page.dart';

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
      MaterialPageRoute(builder: (context) => const CakeSignInPage()),
    );
  }

  static void goToPageRegister(BuildContext context) {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const CakeSignUpPage()),
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

      if(Globals.userSharingStatus == "null") {
        Globals.userSharingStatus = await SharingOptions.retrieveDisabled(Globals.custUsername);
      }
    
      _openSettingsPage(context: context, sharingDisabledStatus: Globals.userSharingStatus);

    } catch (err, st) {

      SnakeAlert.errorSnake("No internet connection.", context);
      Logger().e("Exception on goToPageSettings (NavigatePage)", err, st);
      
      await Future.delayed(const Duration(milliseconds: 1300));

      _openSettingsPage(context: context, sharingDisabledStatus: "0");

    }
  }

  static void _openSettingsPage({
    required BuildContext context, 
    required String sharingDisabledStatus
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => 
          CakeSettingsPage(
          accType: Globals.accountType,
          custEmail: Globals.custEmail,
          custUsername: Globals.custUsername,
          uploadLimit: AccountPlan.mapFilesUpload[Globals.accountType]!,
          sharingEnabledButton: sharingDisabledStatus,
        ),
      ),
    );
  }

  static void goToPageBackupRecovery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BackupRecovery())
    );
  }

  static void goToAddPasscodePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPasscodePage())
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

  static void goToPageFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedBackPage())
    );
  }

}