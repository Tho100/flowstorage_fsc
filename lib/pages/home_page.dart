import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 30),

        MainButton(
          text: "Sign In",
          minusWidth: 62,
          onPressed: () async {
            NavigatePage.goToPageLogin(context);
          },
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 68,
          width: MediaQuery.of(context).size.width-62,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColor.justWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),  
          ),
          onPressed: () async {
            NavigatePage.goToPageRegister(context);
          },
          child: const Text("Create Account",
            style: TextStyle(
              color: ThemeColor.darkBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget buildHeaderText() {
    return Text("Flow your files anywhere.",
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: ThemeColor.justWhite,
          fontSize: 46,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget buildSubText() {
    return Text("Backup your photos and files \nsecurely on the cloud with \nFlowstorage",
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: Color(0xfff9f9f9),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget buildBottomContainer(BuildContext context) {
    return Container(
      color: ThemeColor.darkBlack,
      width: MediaQuery.of(context).size.width,
      height: 205,
      child: buildButtons(context),
    );
  }

  Widget buildPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 115),

        Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: buildHeaderText(),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: buildSubText(),
        ),
      
        const Spacer(),
        buildBottomContainer(context)
      ],
    );
  }

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4A03A4),
      body: buildPage(context)
    );
  }
}