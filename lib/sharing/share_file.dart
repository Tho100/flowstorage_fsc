import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/ui_dialog/TitledAlert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MySqlSharing {

  Future<void> startSharing(
    String? sendTo, 
    String? fileName, 
    String? comment, 
    dynamic fileValue, 
    String? fileExt, 
    {dynamic thumbnail}
  ) async {

    final uploadDate = DateFormat('dd/MM/yyyy').format(DateTime.now()); 
    final crud = Crud();
    
    try {

      const insertSharingData = 'INSERT INTO cust_sharing(CUST_TO, CUST_FROM, CUST_FILE_PATH, CUST_FILE, UPLOAD_DATE, FILE_EXT, CUST_THUMB, CUST_COMMENT) '
        'VALUES (:to, :from, :filename, :fileval, :date, :ext, :thumbnail, :comment)';
      final params = {
        'to': sendTo!, 'from': Globals.custUsername, 
        'fileval': fileValue!, 'filename': fileName!, 
        'date': uploadDate, 'ext': fileExt!, 
        'thumbnail': thumbnail ?? '', 'comment': comment ?? ''
      };

      await crud.insert(query: insertSharingData, params: params);

    } catch (err) {
      print("Exception from startSharing {share_file}: $err");
    }

  }

  Future<void> insertValuesParams(String? sendTo, String? fileName, String? comment, dynamic fileVal, String? fileExt, BuildContext context, {dynamic thumbnail}) async {
    
    try {

      if(sendTo == Globals.custUsername) {
        TitledDialog.startDialog('Sharing Failed', "You can't share to yourself.", context);
        return;
      }

      await startSharing(sendTo, fileName, comment, fileVal, fileExt,thumbnail: thumbnail);

      await CallNotify().customNotification(title: "File Shared", subMesssage: "${EncryptionClass().Decrypt(fileName)} Has been shared to $sendTo");

    } catch (err) {
      print("Exception from insertValuesParam {share_file}");
      await CallNotify().customNotification(title: "Something went wrong",subMesssage: "Failed to share ${EncryptionClass().Decrypt(fileName)}");
    } 

  }

}