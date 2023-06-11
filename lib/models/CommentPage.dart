import 'package:flowstorage_fsc/Connection/ClusterFsc.dart';
import 'package:flowstorage_fsc/Encryption/EncryptionClass.dart';
import 'package:flowstorage_fsc/global/GlobalsStyle.dart';
import 'package:flowstorage_fsc/global/Globals.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentPage extends StatefulWidget {

  final String fileName;

  const CommentPage({required this.fileName, Key? key}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPage();
}

class _CommentPage extends State<CommentPage> {

  final _fileOrigin = Globals.fileOrigin;
  final TextEditingController noCommentController = TextEditingController(text: '(No Comment)');

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

  /// <summary>
  /// 
  /// Retrieve the username of file the user have shared to
  /// 
  /// </summary>

  Future<String> _shareToOtherName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_TO FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName)};
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
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName),'sharedto': await _shareToOtherName()};
    final results = await connection.execute(query,params);

    String? decryptedComment;
    for(final row in results.rows) {
      decryptedComment = row.assoc()['CUST_COMMENT'] == ' ' ? '(No Comment)' : EncryptionClass().Decrypt(row.assoc()['CUST_COMMENT']);
    }

    return decryptedComment!;

  }

  /// <summary>
  /// 
  /// Retrieve username of the user that shared a file
  /// 
  /// </summary>
  /// 
  Future<String> _sharerName() async {

    final connection = await SqlConnection.insertValueParams();
    
    const query = "SELECT CUST_FROM FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName)};
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
    final params = {'from': Globals.custUsername, 'filename': EncryptionClass().Encrypt(Globals.selectedFileName),'sharedto': await _sharerName()};
    final results = await connection.execute(query,params);

    String? decryptedComment;
    for(final row in results.rows) {
      decryptedComment = EncryptionClass().Decrypt(row.assoc()['CUST_COMMENT']);
    }

    return decryptedComment!;
    
  }

  Future<Widget> _buildComment() async {

    late final String mainFileComment;

    if(_fileOrigin == "homeFiles") {
      mainFileComment = "(No Comment)";
    } else if (_fileOrigin == "sharedFiles") {
      mainFileComment = await _sharedFileComment();
    } else if (_fileOrigin == "sharedToMe") {
      mainFileComment = await _sharedToMeComment();
    }

    final TextEditingController commentText = TextEditingController(text: mainFileComment);
    
    return Column(
      children: [

        _buildHeader(),

        Padding(
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
        Globals.selectedFileName,
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