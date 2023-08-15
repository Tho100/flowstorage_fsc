import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

class HomePage extends StatelessWidget {

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 15),

        MainButton(
          text: "Sign In",
          minusWidth: 65,
          onPressed: () async {
            NavigatePage.goToPageLogin(context);
          },
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 65,
          width: MediaQuery.of(context).size.width-65,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColor.darkBlack,
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: ThemeColor.darkPurple,
              width: 3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),  
          ),

          onPressed: () async {
            NavigatePage.goToPageRegister(context);
          },

          child: const Text("Sign Up",
            style: TextStyle(
              color: ThemeColor.darkPurple,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 70),

      ],
    );
  }

  Widget buildHeaderText(String title) {
    return Text(title,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: ThemeColor.darkPurple,
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildSubText(String text) {
    return Text(text,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: ThemeColor.secondaryWhite,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }


  List<PageViewModel> getPages(BuildContext context) {
    return [
      PageViewModel(
        title: "",
        bodyWidget: Column(
          children: [

            const SizedBox(height: 55),
            buildHeaderText("Flow Your Files Anywhere"),
            const SizedBox(height: 18),
            buildSubText("Store your files on Flowstorage and access them effortlessly across all your devices"),
        
          ],
        ),
        footer: const Text('')
      ),

      PageViewModel(
        title: "",
        bodyWidget: Column(
          children: [

            const SizedBox(height: 55),
            buildHeaderText("Sharing Made Easy"),
            const SizedBox(height: 18),
            buildSubText("Easily share your photo and video memories to your friends or anyone"),
          
          ],
        ),

        footer: const Text('')
      ),

      PageViewModel(
        title: "",
        bodyWidget: Column(
          children: [

            const SizedBox(height: 55),
            buildHeaderText("Public Storage"),
            const SizedBox(height: 18),
            buildSubText("Explore a vast collection of publicly shared files from around the world"),
          
          ],
        ),

        footer: const Text('')
      ),

      PageViewModel(
        title: "",
        bodyWidget: Column(
          children: [

            const SizedBox(height: 55),
            buildHeaderText("Privacy Is Our Priority"),
            const SizedBox(height: 18),
            buildSubText("We ensure that your files information and personal data are securely stored in our server"),
          
          ],
        ),

        footer: const Text('')
      ),
    ];
  }

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      body: IntroductionScreen(
        resizeToAvoidBottomInset: false,
        showNextButton: false,
        done: const Text(""),
        onDone: () {},
        pages: getPages(context),
        globalBackgroundColor: ThemeColor.darkBlack,
        globalFooter: buildButtons(context)
      ),
    );
  }
}