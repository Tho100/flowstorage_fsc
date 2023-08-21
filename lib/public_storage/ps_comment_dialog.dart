import 'dart:convert';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PsCommentDialog {

  static final commentController = TextEditingController();

  static const tagsItems = {
    "Entertainment",
    "Random",
    "Creativity",
    "Data",
    "Gaming",
    "Software",
    "Education",
    "Music",
  };

  final  selectedTagValue = ValueNotifier<String>('');
  final psUploadData = GetIt.instance<PsUploadDataProvider>();

  Future buildPsCommentDialog({
    required String fileName,
    required VoidCallback onUploadPressed,
    required BuildContext context,
    String? imageBase64Encoded
  }) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Row(
                children: [

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 14, top: 4),
                      child: Text(
                        "Public Storage",
                        style: TextStyle(
                          color: ThemeColor.justWhite,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 5, top: 4),
                    child: TextButton( 
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeColor.secondaryWhite,
                      ),
                      onPressed: () {
                        clearValues();
                        Navigator.pop(context);
                        return;
                      },
                      child: const Text("Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeColor.darkPurple
                      ),
                      onPressed: () {

                        psUploadData.setCommentValue(commentController.text);
                        
                        onUploadPressed();
                        clearComment();

                        Navigator.pop(context);
                      },
                      child: const Text("Upload",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [

                    if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.memory(
                          base64.decode(imageBase64Encoded!),
                          fit: BoxFit.fitWidth,
                        )
                      ),
                    ),

                    if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
                    const SizedBox(width: 10),

                    Text(
                      ShortenText().cutText(fileName),
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),
                
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: ThemeColor.secondaryWhite),
                    enabled: true,
                    controller: commentController,
                    maxLines: 5,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment (Optional)"),
                  ),
                ),
              ),

              const SizedBox(height: 5),

                Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Text(
                      "Tags", 
                      style: TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: selectedTagValue,
                      builder: (BuildContext context, String value, Widget? child) {
                        return Visibility(
                          visible: value != "",
                          child: Text(
                            "${GlobalsStyle.dotSeperator} $value",
                            style: TextStyle(
                              color: GlobalsStyle.psTagsToColor[value],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ), 
                          ),
                        );
                      }
                    )
                  ),
                  
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 55,
                  child: ListView.builder(
                    itemCount: tagsItems.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Container(
                      height: 45,
                      width: 122,
                      margin: const EdgeInsets.all(10),
                      color: Colors.transparent,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          backgroundColor: GlobalsStyle.psTagsToColor[tagsItems.elementAt(index)]
                        ),
                        onPressed: () {
                          psUploadData.setTagValue(tagsItems.elementAt(index));
                          selectedTagValue.value = psUploadData.psTagValue;
                        },
                        child: Text(tagsItems.elementAt(index)),
                      )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  void clearValues() async {
    await NotificationApi.stopNotification(0);
    psUploadData.setCommentValue('');
    psUploadData.setTagValue('');
    commentController.clear();
  }

  void clearComment() {
    psUploadData.setCommentValue(commentController.text);
    commentController.clear();
  }

}