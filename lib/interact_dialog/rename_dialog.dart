import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RenameDialog {

  static final renameController = TextEditingController();
  final storageData = GetIt.instance<StorageDataProvider>();

  Future buildRenameFileDialog({
    required String fileName,
    required VoidCallback onRenamePressed,
    required BuildContext context
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Stack(
                    children: [
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                          ),
                        ),
                      ),

                      if(Globals.videoType.contains(fileName.split('.').last))
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0, left: 24.0),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ThemeColor.mediumGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                        ),
                      ),
                    ],
                  ),

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
                      CallToast.call(message: "Copied to clipboard.");
                    },
                    icon: const Icon(Icons.copy,color: ThemeColor.thirdWhite,size: 22),
                  ),

                ],
              ),

              const Divider(color: ThemeColor.lightGrey),

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