import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

class PasscodePage extends StatefulWidget {

  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => PasscodePageState();
}

class PasscodePageState extends State<PasscodePage> {

  final logger = Logger();

  final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  int currentActiveField = 0;

  final fileNameGetterStartup = NameGetter();
  final dataGetterStartup = DataRetriever();
  final dateGetterStartup = DateGetter();
  final accountInformationRetriever = UserDataRetriever();

  final crud = Crud();

  Future<void> _callData(MySQLConnectionPool conn, String savedCustUsername,String savedCustEmail, String savedAccountType ,BuildContext context) async {

    try {

      Globals.fileOrigin = "homeFiles";
      Globals.custUsername = savedCustUsername;
      
      final accountType = await accountInformationRetriever.retrieveAccountType(email: savedCustEmail);
      Globals.accountType = accountType;

      final dirListCount = await crud.countUserTableRow(GlobalsTable.directoryInfoTable);
      final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

      final tablesToCheck = [
        ...dirLists,
        GlobalsTable.homeImage, GlobalsTable.homeText, 
        GlobalsTable.homePdf, GlobalsTable.homeExcel, 
        GlobalsTable.homeVideo, GlobalsTable.homeAudio,
        GlobalsTable.homePtx, GlobalsTable.homeWord
      ];

      final futures = tablesToCheck.map((table) async {
        final fileNames = await fileNameGetterStartup.retrieveParams(conn,savedCustUsername, table);
        final bytes = await dataGetterStartup.getLeadingParams(conn,savedCustUsername, table);
        final dates = table == GlobalsTable.directoryInfoTable
            ? List.generate(1, (_) => "Directory")
            : await dateGetterStartup.getDateParams(savedCustUsername, table);
        return [fileNames, bytes, dates];
      }).toList();

      final results = await Future.wait(futures);

      final fileNames = <String>{};
      final bytes = <Uint8List>[];
      final dates = <String>[];
      final retrieveFolders = <String>{};

      if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
        retrieveFolders.addAll(await FolderRetrieve().retrieveParams(savedCustUsername));
      }

      for (final result in results) {
        final fileNamesForTable = result[0] as List<String>;
        final bytesForTable = result[1] as List<Uint8List>;
        final datesForTable = result[2] as List<String>;

        fileNames.addAll(fileNamesForTable);
        bytes.addAll(bytesForTable);
        dates.addAll(datesForTable);
      }

      final uniqueFileNames = fileNames.toList();
      final uniqueBytes = bytes.toList();

      Globals.fileValues.addAll(uniqueFileNames);
      Globals.foldValues.addAll(retrieveFolders);
      Globals.imageByteValues.addAll(uniqueBytes);
      Globals.setDateValues.addAll(dates);

    } catch (err) {
      NavigatePage.permanentPageMainboard(context);
      return;
    }

  }

  void validatePassCode(List<String> inputs) async {

    try {

      const storage = FlutterSecureStorage();
      String? storedValue = await storage.read(key: 'key0015');
      String userInput = "";

      for(var input in inputs) {
        userInput += input;
      }

      if(userInput == storedValue) {

        final conn = await SqlConnection.insertValueParams();

        final justLoading = JustLoading();

        if(!mounted) return;
        justLoading.startLoading(context: context);

        await _callData(conn,Globals.custUsername,Globals.custEmail, Globals.accountType,context);

        justLoading.stopLoading();
        
        if(!mounted) return;
        NavigatePage.permanentPageMainboard(context);

      } else {
        if(!mounted) return;
        SnakeAlert.errorSnake("Incorrect passcode.", context);
      }

    } catch (err, st) {
      NavigatePage.replacePageHome(context);
      logger.e("Exception from validatePassCode {PasscodePage}",err, st);
    } 

  }

  void processInput() {

    List<String> inputs = [];

    for (var controller in controllers) {
      inputs.add(controller.text);
    }

    validatePassCode(inputs);

    for (var controller in controllers) { 
      controller.clear();
    }

    currentActiveField = 0;

  }

  Widget buildPassCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 100),

        const Center(
          child: Text(
            "Enter Passcode",
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: TextFormField(
                  style: const TextStyle(
                    color: ThemeColor.darkPurple,
                    fontSize: 118,
                    fontWeight: FontWeight.w600
                  ),
                  autofocus: false,
                  obscureText: true,
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
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
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack
      ),
      body: buildPassCode()
    );
  }
}