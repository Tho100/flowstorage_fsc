import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomNavigationBar extends StatefulWidget {

  final VoidCallback openFolderDialog;
  final VoidCallback toggleHome;
  final VoidCallback togglePhotos;
  final VoidCallback togglePublicStorage;
  final BuildContext context;

  const CustomNavigationBar({
    super.key, 
    required this.openFolderDialog,
    required this.toggleHome,
    required this.togglePhotos,
    required this.togglePublicStorage,
    required this.context,
  });

  @override
  CustomNavigationBarState createState() => CustomNavigationBarState();
}

class CustomNavigationBarState extends State<CustomNavigationBar> {

  final tempData = GetIt.instance<TempDataProvider>();
  
  final bottomNavigationBarIndex = ValueNotifier<int>(0); 
  final isPhotosPressedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bottomNavigationBarIndex.dispose();
    super.dispose();
  }

  Widget _buildNavigationBar() {
    const labelTextStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: ThemeColor.justWhite,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.8,
          color: ThemeColor.whiteGrey,
        ),
        Container(
          color: ThemeColor.whiteGrey,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: ThemeColor.mediumBlack,
            unselectedItemColor: Colors.grey,
            fixedColor: Colors.grey,
            currentIndex: bottomNavigationBarIndex.value,
            selectedLabelStyle: labelTextStyle,
            unselectedLabelStyle: labelTextStyle,
            iconSize: 25.2,
            items: [
              BottomNavigationBarItem(
                icon: tempData.fileOrigin == "homeFiles" 
                ? const Icon(Icons.home) 
                : const Icon(Icons.home_outlined),
                activeIcon: tempData.fileOrigin == "homeFiles" 
                ? const Icon(Icons.home) 
                : const Icon(Icons.home_outlined),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: ValueListenableBuilder(
                  valueListenable: isPhotosPressedNotifier,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return value == false 
                      ? const Icon(Icons.photo_outlined) 
                      : const Icon(Icons.photo);
                  }
                ),
                label: "Photos",
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 26,
                  height: 26,
                  child: Image.asset('assets/nice/public_icon.png'),
                ),
                activeIcon: tempData.fileOrigin == "psFiles" 
                ? SizedBox(
                  width: 26,
                  height: 26,
                  child: Image.asset('assets/nice/public_icon_selected.png'),
                ) 
                : SizedBox(
                  width: 26,
                  height: 26,
                  child: Image.asset('assets/nice/public_icon.png'),
                ),
                label: "Public",
              ),
              BottomNavigationBarItem(
                icon: tempData.fileOrigin == "folderFiles" 
                ? const Icon(Icons.folder) 
                : const Icon(Icons.folder_outlined),
                label: "Folders",
              ),
            ],
            onTap: (indexValue) async {

              if (indexValue == 3) {
                bottomNavigationBarIndex.value = bottomNavigationBarIndex.value;
              } else {
                bottomNavigationBarIndex.value = indexValue;
              }

              switch (indexValue) {
                case 0:
                  isPhotosPressedNotifier.value = false;
                  widget.toggleHome();
                  break;
                case 1:
                  isPhotosPressedNotifier.value = !isPhotosPressedNotifier.value;
                  widget.togglePhotos();
                  break;
                case 2:
                  isPhotosPressedNotifier.value = false;
                  widget.togglePublicStorage();
                  break;
                case 3:
                  widget.openFolderDialog();
                  break;
              }
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return _buildNavigationBar();
  }

}
