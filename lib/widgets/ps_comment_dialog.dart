import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class PsCommentDialog {

  static final commentController = TextEditingController();

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

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  ShortenText().cutText(fileName),
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
                
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
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment (Optional)"),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            await NotificationApi.stopNotification(0);
                            commentController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.darkBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeColor.darkPurple),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 85,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {

                            Globals.psCommentValue = commentController.text;
                            
                            onUploadPressed();
                            _clearComment();

                            Navigator.pop(context);

                          },
                          style: GlobalsStyle.btnMainStyle,
                          child: const Text('Upload'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  void _clearComment() {
    Globals.psCommentValue = commentController.text;
    commentController.clear();
  }

}