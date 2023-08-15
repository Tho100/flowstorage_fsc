import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class GlobalsStyle {

  static const dotSeperator = " \u{2022} ";

  static final psTagsToColor = {
    "Entertainment": Colors.orange,
    "Creativity": const Color.fromARGB(255, 138, 43, 226),
    "Data": const Color.fromARGB(255, 0, 206, 209),
    "Gaming": Colors.green,
    "Software": Colors.blue,
    "Education": Colors.redAccent,
    "Music": Colors.deepOrangeAccent,
    "Random": Colors.grey,
  };

  static final psTagsColor = {
    Colors.orange,
    const Color.fromARGB(255, 138, 43, 226),
    const Color.fromARGB(255, 0, 206, 209),
    Colors.green,
    Colors.blue,
    Colors.redAccent,
    Colors.deepOrangeAccent,
    Colors.grey,
  };

  static const appBarTextStyle = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: Color.fromARGB(255,232,232,232),
    fontWeight: FontWeight.w500,
    fontSize: 19,          
  );

  static const greetingAppBarTextStyle = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: Color.fromARGB(255,232,232,232),
    fontWeight: FontWeight.w500,
    fontSize: 20,          
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
      borderRadius: BorderRadius.circular(16),
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
      contentPadding: const EdgeInsets.fromLTRB(20.0, 18.0, 10.0, 25.0),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
      fillColor: ThemeColor.darkGrey,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide.none,
      ),
      counterText: '',
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          width: 2.0,
          color: Color.fromARGB(255, 6, 102, 226),
        ),
      ),
    );
  }

  static InputDecoration setupPasscodeFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(-2.0, -72.0, 0.0, -18.0),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
      fillColor: ThemeColor.darkBlack,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35.0), 
        borderSide: const BorderSide(
          color: ThemeColor.darkPurple,
          width: 2.0,
        ),
      ),
      counterText: '',
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35.0),
        borderSide: const BorderSide(
          width: 2.0,
          color: ThemeColor.darkPurple,
        ),
      ),
    );
  }

}