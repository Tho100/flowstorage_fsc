import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';

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

  final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

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

    await Future.delayed(const Duration(milliseconds: 420));

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
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Passcode", subTitle: "Add new passcode"),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => SizedBox(
              width: 65,
              child: TextFormField(
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 25,
                  fontWeight: FontWeight.w600
                ),
                autofocus: true,
                controller: controllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                decoration: GlobalsStyle.setupTextFieldDecoration(""),
                onChanged: (value) {
                  if(value.isNotEmpty) {
                    if(index < 3) {
                      FocusScope.of(context).requestFocus(focusNodes[index+1]);
                    } else {
                      processInput();
                      focusNodes[index].unfocus();
                    }
                  }
                },
              ),
            ),
          ),
        ),

      ],
    );
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