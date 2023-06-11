import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flutter/material.dart';

class TitledDialog {

  static Future startDialog(String headMessage,String subMessage, BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          content: Container(
            width: MediaQuery.of(context).size.width*4,
            height: 250,
            child: Center(
              child: Column(
                children: [

                    Text(headMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    Text(subMessage,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK',
                        style: TextStyle(
                          color: ThemeColor.darkPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
            
                ],
              ),
            ),
          )
        );
      },
    );
  }
}