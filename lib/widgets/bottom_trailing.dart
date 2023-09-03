import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailing {

  final storageData = GetIt.instance<StorageDataProvider>();

  Future buildBottomTrailing({
    required String fileName,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDeletePressed,
    required VoidCallback onSharingPressed,
    required VoidCallback onAOPressed,
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
                  padding: const EdgeInsets.only(left: 12,top: 12, bottom: 12),
                  child: Visibility(
                    visible: Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12.0, top: 12.0),
                    child: Text(
                      ShortenText().cutText(fileName, customLength: 50),
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last),
              child: const Divider(color: ThemeColor.thirdWhite),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("psFiles"),
              child: ElevatedButton(
                onPressed: onRenamePressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 10.0),
                    Text(
                      fileName.contains('.') ? "Rename File" : "Rename Directory",
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("offlineFiles") && fileName.split('.').last != fileName,
              child: ElevatedButton(
                onPressed: onSharingPressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                  child: const Row(
                  children: [
                    Icon(Icons.share_rounded),
                    SizedBox(width: 10.0),
                    Text('Share File',
                      style: GlobalsStyle.btnBottomDialogTextStyle
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("offlineFiles"),
              child: const Divider(color: ThemeColor.thirdWhite)
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("offlineFiles") && fileName.split('.').last != fileName,
              child: ElevatedButton(
                onPressed: onAOPressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt_rounded),
                    SizedBox(width: 10.0),
                    Text('Make available Offline',
                      style: GlobalsStyle.btnBottomDialogTextStyle
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: fileName.split('.').last != fileName,
              child: const Divider(color: ThemeColor.thirdWhite)
            ),

            ElevatedButton(
              onPressed: onDownloadPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 10.0),
                  Text('Download',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("psFiles"),
              child: ElevatedButton(
                onPressed: onDeletePressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.delete,color: ThemeColor.darkRed),
                    SizedBox(width: 10.0),
                    Text('Delete',
                      style: TextStyle(
                        color: ThemeColor.darkRed,
                        fontSize: 17,
                      )
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