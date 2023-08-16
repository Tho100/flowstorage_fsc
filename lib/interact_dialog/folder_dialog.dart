import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class FolderDialog {

  Future buildFolderDialog({
    required Function(int) folderOnPressed,
    required Function(int) trailingOnPressed,
    required BuildContext context
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColor.darkGrey,
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, 
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: Globals.foldValues.length,
                  separatorBuilder: (BuildContext context, int index) => const Divider(
                    color: ThemeColor.thirdWhite,
                    height: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => folderOnPressed(index),
                      child: Ink(
                        child: ListTile(
                          leading: Image.asset(
                            'assets/nice/dir1.png',
                            width: 35,
                            height: 35,
                          ),
                          title: Text(
                            Globals.foldValues[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => trailingOnPressed(index),
                          child: const Icon(Icons.more_vert,color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Folders',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}