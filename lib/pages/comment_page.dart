import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentPage extends StatefulWidget {

  final String fileName;

  const CommentPage({required this.fileName, Key? key}) : super(key: key);

  @override
  State<CommentPage> createState() => CommentPageState();
}

class CommentPageState extends State<CommentPage> {

  final noCommentController = TextEditingController(text: '(No Comment)');

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Comment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            )),
        ),
      ],
    );
  }

  Future<String> _shareToOtherName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_TO FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': userData.username, 'filename': EncryptionClass().encrypt(tempData.selectedFileName)};
    final results = await connection.execute(query,params);

    String? sharedToName;
    for(final row in results.rows) {
      sharedToName = row.assoc()['CUST_TO'];
    }

    return sharedToName!;
    
  }

  Future<String> _sharedFileComment() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_COMMENT FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename AND CUST_TO = :sharedto";
    final params = {'from': userData.username, 'filename': EncryptionClass().encrypt(tempData.selectedFileName),'sharedto': await _shareToOtherName()};
    final results = await connection.execute(query,params);

    String? decryptedComment;
    for(final row in results.rows) {
      decryptedComment = row.assoc()['CUST_COMMENT'] == ' ' ? '(No Comment)' : EncryptionClass().decrypt(row.assoc()['CUST_COMMENT']);
    }

    return decryptedComment!;

  }

  Future<String> _sharerName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_FROM FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': userData.username, 'filename': EncryptionClass().encrypt(tempData.selectedFileName)};
    final results = await connection.execute(query,params);

    String? sharedToMeName;
    for(final row in results.rows) {
      sharedToMeName = row.assoc()['CUST_FROM'];
    }

    return sharedToMeName!;
    
  }

  Future<String> _sharedToMeComment() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_COMMENT FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': userData.username, 'filename': EncryptionClass().encrypt(tempData.selectedFileName),'sharedto': await _sharerName()};
    final results = await connection.execute(query,params);

    String? decryptedComment;
    for(final row in results.rows) {
      decryptedComment = EncryptionClass().decrypt(row.assoc()['CUST_COMMENT']);
    }

    return decryptedComment!;
    
  }

  Future<String> _psFileComment() async {

    final fileType = tempData.selectedFileName.split('.').last;
    final tableName = Globals.fileTypesToTableNamesPs[fileType];

    final connection = await SqlConnection.insertValueParams();
    
    final query = "SELECT CUST_COMMENT FROM $tableName WHERE CUST_FILE_PATH = :filename";
    final params = {'filename': EncryptionClass().encrypt(tempData.selectedFileName)};
    final results = await connection.execute(query,params);

    String? decryptedComment;
    for(final row in results.rows) {
      decryptedComment = EncryptionClass().decrypt(row.assoc()['CUST_COMMENT']);
    }

    return decryptedComment! == '' ? '(No Comment)' : decryptedComment;
  }

  Future<Widget> _buildComment() async {

    late final String mainFileComment;

    if(tempData.fileOrigin == "homeFiles") {
      mainFileComment = "(No Comment)";
    } else if (tempData.fileOrigin == "sharedFiles") {
      mainFileComment = await _sharedFileComment();
    } else if (tempData.fileOrigin == "sharedToMe") {
      mainFileComment = await _sharedToMeComment();
    } else if (tempData.fileOrigin == "psFiles") {
      mainFileComment = await _psFileComment();
    }

    final commentText = TextEditingController(text: mainFileComment);
    final mediaQuery = MediaQuery.of(context).size;

    return Column(
      children: [

        _buildHeader(),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: mediaQuery.height * 0.7, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: ThemeColor.darkBlack, 
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: commentText,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: GoogleFonts.roboto(
                        color: const Color.fromARGB(255, 224, 223, 223),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoComment() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: ThemeColor.darkBlack, 
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  enabled: false,
                  controller: noCommentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: GoogleFonts.roboto(
                    color: const Color.fromARGB(255, 224, 223, 223),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    noCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
      elevation: 0,
      backgroundColor: ThemeColor.darkBlack,
      title: Text(
        tempData.selectedFileName,
        style: GlobalsStyle.appBarTextStyle
      )
    ),

    body: FutureBuilder(
        future: _buildComment(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return _buildNoComment();
          }
        },
      ),
    );
  }
}