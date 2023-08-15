import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RenameDialog {

  static final renameController = TextEditingController();

  Future buildRenameFileDialog({
    required String fileName,
    required VoidCallback onRenamePressed,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
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
                  ),

                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fileName));
                    },
                    icon: const Icon(Icons.copy,color: ThemeColor.thirdWhite,size: 22),
                  ),

                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: ThemeColor.secondaryWhite),
                    enabled: true,
                    controller: renameController,
                    decoration: GlobalsStyle.setupTextFieldDecoration("Enter a new name"),
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
                      child: MainDialogButton(
                        text: "Cancel", 
                        onPressed: () {
                          renameController.clear();
                          Navigator.pop(context);
                        }, 
                        isButtonClose: true
                      )
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MainDialogButton(
                        text: "Rename", 
                        onPressed: () {
                          onRenamePressed();
                          renameController.clear();
                          Navigator.pop(context);
                        }, 
                        isButtonClose: false
                      )
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

}