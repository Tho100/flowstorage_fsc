import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

class PasscodePage extends StatefulWidget {

  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => PasscodePageState();
}

class PasscodePageState extends State<PasscodePage> {

  final _locator = GetIt.instance;

  final logger = Logger();

  final isButtonsEnabledNotifier = ValueNotifier<bool>(true);
  final isPasscodeIncorrectNotifier = ValueNotifier<bool>(false);

  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());

  final fileNameGetterStartup = NameGetter();
  final dataGetterStartup = DataRetriever();
  final dateGetterStartup = DateGetter();
  final accountInformationRetriever = UserDataRetriever();

  final crud = Crud();

  int currentActiveField = 0;
  int totalAttempts = 0;

  void disableButtons() {
    isButtonsEnabledNotifier.value = false;
  }

  Future<void> _callData(MySQLConnectionPool conn, String savedCustUsername,String savedCustEmail, String savedAccountType ,BuildContext context) async {

    try {
      
      final userData = _locator<UserDataProvider>();
      final storageData = _locator<StorageDataProvider>();
      final tempData = _locator<TempDataProvider>();

      tempData.setOrigin("homeFiles");
      userData.setUsername(savedCustUsername);
      userData.setEmail(savedCustEmail);

      final accountType = await accountInformationRetriever.retrieveAccountType(email: savedCustEmail);
      userData.setAccountType(accountType);

      final dirListCount = await crud.countUserTableRow(GlobalsTable.directoryInfoTable);
      final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

      final tablesToCheck = [
        ...dirLists,
        GlobalsTable.homeImage, GlobalsTable.homeText, 
        GlobalsTable.homePdf, GlobalsTable.homeExcel, 
        GlobalsTable.homeVideo, GlobalsTable.homeAudio,
        GlobalsTable.homePtx, GlobalsTable.homeWord,
        GlobalsTable.homeExe, GlobalsTable.homeApk
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
        retrieveFolders.addAll(await FolderRetriever().retrieveParams(savedCustUsername));
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
      final uniqueFolders = retrieveFolders.toList();

      storageData.setFilesName(uniqueFileNames);
      storageData.setFoldersName(uniqueFolders);
      storageData.setImageBytes(uniqueBytes);
      storageData.setFilesDate(dates);

    } catch (err) {
      NavigatePage.permanentPageMainboard(context);
      return;
    }

  }

  void validatePassCode(List<String> inputs) async {

    try {

      final userData = _locator<UserDataProvider>();

      const storage = FlutterSecureStorage();
      String? storedValue = await storage.read(key: 'key0015');
      String userInput = "";

      for(var input in inputs) {
        userInput += input;
      }

      totalAttempts++;

      if(userInput == storedValue) {

        isPasscodeIncorrectNotifier.value = false;
        isButtonsEnabledNotifier.value = true;

        final conn = await SqlConnection.insertValueParams();

        final justLoading = JustLoading();

        if(!mounted) return;
        justLoading.startLoading(context: context);

        await _callData(conn, userData.username, userData.email, userData.accountType, context);

        justLoading.stopLoading();
        
        if(!mounted) return;
        NavigatePage.permanentPageMainboard(context);

      } else {        
        isPasscodeIncorrectNotifier.value = true;
        disableButtonsOnFailed5Attempts();
      }

    } catch (err, st) {
      NavigatePage.replacePageHome(context);
      logger.e("Exception from validatePassCode {PasscodePage}",err, st);
    } 

  }

  void disableButtonsOnFailed5Attempts() {
    if(totalAttempts == 5) {
      disableButtons();
      CallToast.call(message: "Passcode has been locked.");
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

        const SizedBox(height: 25),
      
        Visibility(
          visible: isPasscodeIncorrectNotifier.value,
          child: const Center(
            child: Text(
              "Passcode is incorrect",
              style: TextStyle(
                color: ThemeColor.darkRed,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ),

        const Spacer(),

        const SizedBox(height: 125),

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

          if(isButtonsEnabledNotifier.value == false) {
            CallToast.call(message: "Passcode has been locked.");
            return;
          }

          isButtonsEnabledNotifier.value == false 
          ? null 
          : setState(() {
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

    isButtonsEnabledNotifier.dispose();
    isPasscodeIncorrectNotifier.dispose();

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