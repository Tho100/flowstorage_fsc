import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {

  final String title;
  final String subTitle;

  const HeaderText({
    super.key,
    required this.title,
    required this.subTitle
  });

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          const SizedBox(height: 15),
    
          Text(
            title,
            style: const TextStyle(
              color: ThemeColor.darkPurple,
              fontWeight: FontWeight.w900,
              fontSize: 32,
            ),
          ),
    
          const SizedBox(height: 12),
          
          Text(
           subTitle,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,  // # Color(0xFFB4B4B4)
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

}