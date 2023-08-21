import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

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

  late ValueNotifier<int> _bottomNavigationBarIndex;
  
  final isPhotosPressedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _bottomNavigationBarIndex = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _bottomNavigationBarIndex.dispose();
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
            currentIndex: _bottomNavigationBarIndex.value,
            selectedLabelStyle: labelTextStyle,
            unselectedLabelStyle: labelTextStyle,
            iconSize: 25.2,
            items: [
              BottomNavigationBarItem(
                icon: Globals.fileOrigin == "homeFiles" 
                ? const Icon(Icons.home) 
                : const Icon(Icons.home_outlined),
                activeIcon: Globals.fileOrigin == "homeFiles" 
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
                activeIcon: Globals.fileOrigin == "psFiles" 
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
                icon: Globals.fileOrigin == "folderFiles" 
                ? const Icon(Icons.folder) 
                : const Icon(Icons.folder_outlined),
                label: "Folders",
              ),
            ],
            onTap: (indexValue) async {

              if (indexValue == 3) {
                _bottomNavigationBarIndex.value = _bottomNavigationBarIndex.value;
              } else {
                _bottomNavigationBarIndex.value = indexValue;
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
