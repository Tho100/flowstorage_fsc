import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PreviewImage extends StatefulWidget {

  final VoidCallback onPageChanged;

  const PreviewImage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  PreviewImageState createState() => PreviewImageState();
}

class PreviewImageState extends State<PreviewImage> {

  int currentSelectedIndex = 0;
  
  late final PageController pageController;

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    pageController = PageController(initialPage: currentSelectedIndex);
  }

  void handlePageChange(int index) {
    tempData.setCurrentFileName(storageData.fileNamesFilteredList[index]);
    widget.onPageChanged(); 
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const ClampingScrollPhysics(),
      controller: pageController, 
      itemCount: storageData.fileNamesFilteredList.length,
      onPageChanged: handlePageChange,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          scaleEnabled: true,
          panEnabled: true,
          child: Container(
          constraints: const BoxConstraints.expand(),
          child: Image.memory(
            storageData.imageBytesFilteredList[index]!,
            fit: BoxFit.fitWidth,
          ),
          ),
        );
      },
    );
  }
}