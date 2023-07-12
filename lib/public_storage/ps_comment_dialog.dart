import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class PsCommentDialog {

  static final commentController = TextEditingController();

  static const tagsItems = {
    "Entertainment",
    "Creativity",
    "Data",
    "Gaming",
    "Software",
    "Education",
    "Music",
    "Random",
  };

  final ValueNotifier<String> selectedTagValue = ValueNotifier<String>('');

  Future buildPsCommentDialog({
    required String fileName,
    required VoidCallback onUploadPressed,
    required BuildContext context
  }) async {
    return showDialog(
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

                        Globals.psCommentValue = commentController.text;
                        
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
                child: Text(
                  ShortenText().cutText(fileName),
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
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
                          Globals.psTagValue = tagsItems.elementAt(index);
                          selectedTagValue.value = Globals.psTagValue;
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
    Globals.psUploadPassed = false;
    Globals.psCommentValue = '';
    Globals.psTagValue = '';
    commentController.clear();
  }

  void clearComment() {
    Globals.psCommentValue = commentController.text;
    commentController.clear();
  }

}