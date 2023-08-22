import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingFilter {

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildFilterTypeButtons(
    String filterName, 
    IconData icon, 
    String filterType,
    Function filterTypePublicStorage,
    Function filterTypeNormal,
    BuildContext context 
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        tempData.fileOrigin == "psFiles" 
        ? filterTypePublicStorage(filterType) 
        : filterTypeNormal(filterType);
        Navigator.pop(context);
      },
      icon: Icon(icon),
      label: Text(filterName),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(112,25),
        backgroundColor: ThemeColor.mediumGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
      ),
    );
  }

  Future buildFilterTypeAll({
    required Function filterTypePublicStorage,
    required Function filterTypeNormal,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 315,
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Filter Type",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ), 
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                        
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 5),
              
                        _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg', filterTypePublicStorage, filterTypeNormal, context),
              
                        Row(
      
                          children: [

                          _buildFilterTypeButtons("Text",Icons.text_snippet_rounded,'.txt,.html', filterTypePublicStorage, filterTypeNormal, context),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio",Icons.music_note_rounded,'.mp3,.wav', filterTypePublicStorage, filterTypeNormal, context),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Videos",Icons.video_collection_rounded,'.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
              
                        ],
                      ),
                      ],
                    ),
                      
                    const SizedBox(height: 5),
                      
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 5),
              
                        Row(
                          children: [

                            _buildFilterTypeButtons("PDFs",Icons.picture_as_pdf,'.pdf', filterTypePublicStorage, filterTypeNormal, context),
                            const SizedBox(width: 8),
                            _buildFilterTypeButtons("Sheets",Icons.table_chart,'.xls,.xlsx', filterTypePublicStorage, filterTypeNormal, context),

                          ]
                        ),
              
                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("DOCs",Icons.text_snippet_outlined,'.docx,.doc', filterTypePublicStorage, filterTypeNormal, context),
              
                            const SizedBox(width: 8),
              
                            _buildFilterTypeButtons("CSV",Icons.insert_chart_outlined,'.csv', filterTypePublicStorage, filterTypeNormal, context),
                  
                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("All",Icons.shape_line_rounded,' ', filterTypePublicStorage, filterTypeNormal, context),
                                    
                          ],
                        ),
                      ],
                    ),  
                          
                  ],
              
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future buildFilterTypePhotos({
    required Function filterTypePublicStorage,
    required Function filterTypeNormal,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 145,
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Filter Type",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ), 
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
              
                  crossAxisAlignment: CrossAxisAlignment.start,
          
                  children: [
                    
                    _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg', filterTypePublicStorage, filterTypeNormal, context),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("Videos",Icons.video_collection_rounded,'.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("All",Icons.shape_line_rounded,'.png,.jpg,.jpeg,.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
          
                  ],
                ),
              ),   
            ],
          ),
        );
      },
    );
  }
}