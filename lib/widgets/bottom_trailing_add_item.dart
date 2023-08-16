import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class BottomTrailingAddItem {
  
  Future buildTrailing({
    required String headerText,
    required VoidCallback galleryOnPressed,
    required VoidCallback fileOnPressed,
    required VoidCallback folderOnPressed,
    required VoidCallback photoOnPressed,
    required VoidCallback scannerOnPressed,
    required VoidCallback textOnPressed,
    required VoidCallback directoryOnPressed,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    headerText,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
    
            Visibility(
              visible: VisibilityChecker.setNotVisibleList(["offlineFiles","psFiles"]),
              child: ElevatedButton(
                onPressed: galleryOnPressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.photo),
                    SizedBox(width: 10.0),
                    Text(
                      'Upload from Gallery',
                      style: GlobalsStyle.btnBottomDialogTextStyle
                    ),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              onPressed: fileOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.upload_file),
                  SizedBox(width: 10.0),
                  Text(
                    'Upload Files',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisibleList(["offlineFiles","psFiles","dirFiles","folderFiles"]),
              child: ElevatedButton(
              onPressed: folderOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.folder),
                  SizedBox(width: 10.0),
                  Text('Upload Folder',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: ThemeColor.thirdWhite),

          ElevatedButton(
            onPressed: photoOnPressed,
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.camera_alt_rounded),
                SizedBox(width: 10.0),
                Text(
                  'Take a photo',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

          Visibility(
            visible: VisibilityChecker.setNotVisibleList(["psFiles","offlineFiles"]),
            child: ElevatedButton(
              onPressed: scannerOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.center_focus_strong_rounded),
                  SizedBox(width: 10.0),
                  Text(
                    'Scan Document',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: ThemeColor.thirdWhite),

          Visibility(
            visible: VisibilityChecker.setNotVisible("psFiles"),
            child: ElevatedButton(
              onPressed: textOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.add_box),
                    SizedBox(width: 10.0),
                    Text(
                      'Create Text file',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
        
            Visibility(
              visible: VisibilityChecker.setNotVisibleList(["psFiles","dirFiles","folderFiles","offlineFiles"]),
              child: ElevatedButton(
              onPressed: directoryOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.add_box),
                    SizedBox(width: 10.0),
                    Text(
                      'Create Directory',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

}