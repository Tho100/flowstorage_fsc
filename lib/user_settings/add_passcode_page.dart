import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class AddPasscodePage extends StatefulWidget {

  const AddPasscodePage({super.key});

  @override
  State<AddPasscodePage> createState() => AddPasscodePageState();
}

class AddPasscodePageState extends State<AddPasscodePage> {

  final logger = Logger();

  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());

  int currentActiveField = 0;

  Future<void> addPassCode() async {

    const storage = FlutterSecureStorage();

    String passCode = "";

    List<String> inputs = [];

    for (var controller in controllers) {
      inputs.add(controller.text);
    }

    for(String inputCode in inputs) {
      passCode += inputCode;
    }

    await storage.write(key: "key0015",value: passCode);

    CallToast.call(message: "Passcode added.");

    for (var controller in controllers) { 
      controller.clear();
    }

    if(!mounted) return;
    NavigatePage.permanentPageMainboard(context);

  }

  void cancelPassCode() {
    for (var controller in controllers) { 
      controller.clear();
    }
    NavigatePage.permanentPageMainboard(context);
  }

  void processInput() async {

    try {

      if(!mounted) return;
      CustomAlertDialog.alertDialogCustomOnPressed(
        messages: "Confrim passcode?", 
        oPressedEvent: () async { 
          Navigator.pop(context);
          await addPassCode();
          return;
        }, 
        onCancelPressed: () {
          cancelPassCode();
          return;
        },
        context: context
      );

    } catch (err, st) {
      logger.e("Exception from validatePassCode {PasscodePage}",err, st);
    }
  }

  Widget buildPassCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 100),

        const Center(
          child: Text(
            "Add new passcode",
            style: TextStyle(
              color: ThemeColor.darkPurple,
              fontSize: 22,
              fontWeight: FontWeight.w600
            ),
          ),
        ),

        const SizedBox(height: 70),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: TextFormField(
                  style: const TextStyle(
                    color: ThemeColor.darkPurple,
                    fontSize: 118,
                    fontWeight: FontWeight.w600
                  ),
                  obscureText: true,
                  autofocus: false,
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  decoration: GlobalsStyle.setupPasscodeFieldDecoration(),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 3) {
                        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        currentActiveField = index + 1;
                      } else {
                        processInput();
                        focusNodes[index].unfocus();
                      }
                    } else {
                      controllers[index].clear();
                      if (index > 0) {
                        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                        currentActiveField = index - 1;
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        const SizedBox(height: 185),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildButtons("1", ""),
            buildButtons("2", "ABC"),
            buildButtons("3", "DEF"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildButtons("4", "GHI"),
            buildButtons("5", "JKL"),
            buildButtons("6", "MNO"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildButtons("7", "PQRS"),
            buildButtons("8", "TUV"),
            buildButtons("9", "WXYZ"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildButtons("", ""),
            buildButtons("0", "*"),
            buildEraseButton(),
          ],
        ),

        const SizedBox(height: 18),

        const Spacer(),

      ],
    );
  }

  Widget buildEraseButton() {
    return SizedBox(
      width: 82,
      height: 82,
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
        padding: EdgeInsets.zero,
        onPressed: () {
          updateBackSpace();
        },
        icon: const Icon(Icons.backspace_rounded, size: 30, color: ThemeColor.justWhite),
      ),
    );
  }

  Widget buildButtons(String input, String bottomInput) {
    return SizedBox(
      width: 82,
      height: 82,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          padding: EdgeInsets.zero
        ),
        onPressed: () {
          setState(() {
            updateCurrentFieldText(input);
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              input,
              style: const TextStyle(
                color: ThemeColor.justWhite,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              bottomInput,
              style: const TextStyle(
                color: ThemeColor.thirdWhite,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateBackSpace() {
    controllers[currentActiveField].clear();
    if (currentActiveField > 0) {
      FocusScope.of(context).requestFocus(focusNodes[currentActiveField - 1]);
      currentActiveField--;
    }
  }

  void updateCurrentFieldText(String text) {
    controllers[currentActiveField].text = text;
    if (currentActiveField < 3) {
      FocusScope.of(context).requestFocus(focusNodes[currentActiveField + 1]);
      currentActiveField++;
    } else {
      processInput();
      focusNodes[currentActiveField].unfocus();
    }
  }

  @override 
  void dispose() {

    for(var controller in controllers) {
      controller.dispose();
    }

    for(var node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack
      ),
      body: buildPassCode()
    );
  }
}