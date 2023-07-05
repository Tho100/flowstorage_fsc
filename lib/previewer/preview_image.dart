import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {

  final VoidCallback onPageChanged;

  const PreviewImage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  PreviewImageState createState() => PreviewImageState();
}

class PreviewImageState extends State<PreviewImage> {

  static List<String> imagesNameList = Globals.filteredSearchedFiles.where((image) => Globals.imageType.any((ext) => image.endsWith(ext))).toList();
  
  int currentSelectedIndex = 0;
  int imageTotalLength = imagesNameList.length;

  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    pageController = PageController(initialPage: currentSelectedIndex);
  }

  void validateFileType(String fileType) {
    if(Globals.imageType.contains(fileType)) {
      imageTotalLength = Globals.filteredSearchedFiles.length;
    } else {
      imageTotalLength = 0;
      return;
    }
  }

  void handlePageChange(int index) {

    final getSelectedFileName = Globals.fileValues[index];
    final fileType = getSelectedFileName.split('.').last;

    setState(() {
      validateFileType(fileType);
    });

    Globals.selectedFileName = getSelectedFileName;
    widget.onPageChanged();

  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const ClampingScrollPhysics(),
      controller: pageController, 
      itemCount: imagesNameList.length,
      onPageChanged: handlePageChange,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          scaleEnabled: true,
          panEnabled: true,
          child: Container(
          constraints: const BoxConstraints.expand(),
          child: Image.memory(
            Globals.filteredSearchedBytes[index]!,
            fit: BoxFit.fitWidth,
          ),
          ),
        );
      },
    );
  }
}