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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = Globals.filteredSearchedFiles.indexOf(Globals.selectedFileName);
    _pageController = PageController(initialPage: currentSelectedIndex); 
  }

  void _handlePageChange(int index) {
    String getSelectedFileName = Globals.fileValues[index];
    setState(() {
      Globals.selectedFileName = getSelectedFileName;
    });
    widget.onPageChanged();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const ClampingScrollPhysics(),
      controller: _pageController,
      itemCount: Globals.filteredSearchedBytes.length,
      onPageChanged: _handlePageChange,
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