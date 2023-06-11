import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flutter/material.dart';

class GlobalsStyle {

  static const appBarTextStyle = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: Color.fromARGB(255,232,232,232),
    fontWeight: FontWeight.w500,
    fontSize: 19,          
  );

  static const sidebarMenuButtonsStyle = TextStyle(
    color: Color.fromARGB(255, 215, 215, 215),
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  static const settingsLeftTextStyle = TextStyle(
    fontSize: 16,
    color: ThemeColor.secondaryWhite,
    fontWeight: FontWeight.w600,
  );

  static const settingsInfoTextStyle = TextStyle(
    fontSize: 15,
    color: ThemeColor.darkPurple,
    fontWeight: FontWeight.w600
  );

  static const settingsRightTextStyle = TextStyle(
    fontSize: 17,
    color: ThemeColor.thirdWhite,
    fontWeight: FontWeight.w500,
  );

  static const btnBottomDialogTextStyle = TextStyle(
    color: Color.fromARGB(255, 200, 200, 200),
    fontSize: 16,
  ); 

  static final btnBottomDialogBackgroundStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkGrey,
    elevation: 0,
  );

  static const bottomDialogBorderStyle = RoundedRectangleBorder( 
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(0)
    )
  );

  static const btnPageTextStyle = TextStyle(
    color: ThemeColor.justWhite,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static final btnMainStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkPurple,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final btnNavigationBarStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.mediumGrey,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    )
  );

  static InputDecoration setupTextFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
      fillColor: ThemeColor.darkGrey,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      counterText: '',
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          width: 2.0,
          color: Color.fromARGB(255, 6, 102, 226),
        ),
      ),
    );
  }


}