import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
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

  final fileNameGetterStartup = NameGetter();
  final dataGetterStartup = DataRetriever();
  final dateGetterStartup = DateGetter();

  final crud = Crud();

  Future<void> _callData(MySQLConnectionPool conn, String savedCustUsername,String savedCustEmail, String savedAccountType ,BuildContext context) async {

    try {

      Globals.fileOrigin = "homeFiles";
      Globals.custUsername = savedCustUsername;

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
  }

  Widget buildPassCode() {
    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Passcode", subTitle: "Enter your passcode to unlock Flowstorage"),
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
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack
      ),
      body: buildPassCode()
    );
  }
}