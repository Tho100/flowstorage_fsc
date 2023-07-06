import 'package:flowstorage_fsc/global/global_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {

  final VoidCallback onPageChanged;

  const PreviewImage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  PreviewImageState createState() => PreviewImageState();
}

class PreviewImageState extends State<PreviewImage> {

  int currentSelectedIndex = 0;
  List<String> imagesNameList = Globals.filteredSearchedFiles.where((image) => Globals.imageType.any((ext) => image.endsWith(ext))).toList();
  
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    pageController = PageController(initialPage: currentSelectedIndex);
  }

  void handlePageChange(int index) {
    final getSelectedFileName = imagesNameList[index];
    Globals.selectedFileName = getSelectedFileName;
    widget.onPageChanged(); 
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const ClampingScrollPhysics(),
      controller: pageController, 
      itemCount: Globals.fileOrigin == "homeFiles" ? imagesNameList.length : Globals.filteredSearchedFiles.length,
      onPageChanged: handlePageChange,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          scaleEnabled: true,
          panEnabled: true,
          child: Container(
          constraints: const BoxConstraints.expand(),
          child: Image.memory(
            Globals.fileOrigin == "homeFiles" ? GlobalsData.homeImageData[index] : Globals.filteredSearchedBytes[index]!,
            fit: BoxFit.fitWidth,
          ),
          ),
        );
      },
    );
  }
}