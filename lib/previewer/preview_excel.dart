import 'dart:typed_data';

import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/public_storage/get_uploader_name.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_viewer;
import 'package:logger/logger.dart';

class PreviewExcel extends StatefulWidget {

  static List<int>? excelUpdatedBytes;

  const PreviewExcel({super.key,});

  @override
  State<PreviewExcel> createState() => PreviewExcelState();
}

class PreviewExcelState extends State<PreviewExcel> {

  List<DataColumn> _columnsExcel = [];
  List<DataRow> _rowsExcel = [];

  List<String>? workSheets;
  final Map<int, Map<int, String>> _editedValues = {}; 
  final List<List<TextEditingController>> _excelControllers = [];
  
  final retrieveData = RetrieveData();

  Future<Uint8List> _callData() async {

    try {

      final tableName = Globals.fileOrigin == "psFiles" ? "ps_info_excel" : "file_info_excel";
      final uploaderUsername = Globals.fileOrigin == "psFiles" 
      ? await UploaderName().getUploaderName(tableName: "ps_info_excel",fileValues: Globals.excelType)
      : Globals.custUsername;

      return retrieveData.retrieveDataParams(
        uploaderUsername,
        Globals.selectedFileName,
        tableName,
        Globals.fileOrigin,
      );
      
    } catch (err, st) {
      Logger().e("Exception from _callData {preview_excel}", err, st);
      return Future.value(Uint8List(0));
    }
  }

  void _updateExcelBytes(List<int> bytes) {
    setState(() {
      PreviewExcel.excelUpdatedBytes = bytes;
    });
  }

  @override
  void dispose() {

    for (List<TextEditingController> rowControllers in _excelControllers) {
      for (TextEditingController controller in rowControllers) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _callData(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData) {

          final excelValues = excel_viewer.Excel.decodeBytes(snapshot.data!);
          workSheets = excelValues.tables.keys.toList();

          _columnsExcel = excelValues.tables[workSheets!.first]!.row(0).map(
            (cell) => DataColumn(
              label: Text(cell!.value.toString()),
            ),
          ).toList();

       if (_rowsExcel.isEmpty) {
        
          final table = excelValues.tables[workSheets!.first]!;
          
          final firstRow = table.row(0);
          final numColumns = firstRow.length;
          
          _columnsExcel = List.generate(numColumns, (columnIndex) {
            final cell = firstRow[columnIndex];
            return DataColumn(
              label: Text(cell!.value.toString()),
            );
          });

          _rowsExcel = table.rows.asMap().entries.skip(1).map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;

            final cells = row.asMap().entries.map((cellEntry) {
              final columnIndex = cellEntry.key;
              final cell = cellEntry.value;

              final isEdited = _editedValues.containsKey(rowIndex) &&
                  _editedValues[rowIndex]!.containsKey(columnIndex);

              final editedValue = isEdited
                  ? _editedValues[rowIndex]![columnIndex]
                  : cell!.value.toString();

              return DataCell(
                TextField(
                  controller: TextEditingController(text: editedValue),
                  onChanged: (newValue) { 
                    setState(() {
                      if (!_editedValues.containsKey(rowIndex)) {
                        _editedValues[rowIndex] = {};
                      }

                      _editedValues[rowIndex]![columnIndex] = newValue;

                      final cellIndex = excel_viewer.CellIndex.indexByColumnRow(
                        columnIndex: columnIndex,
                        rowIndex: rowIndex,
                      );

                      table.updateCell(
                        cellIndex,
                        newValue,
                      );

                      _updateExcelBytes(excelValues.save()!);

                    });
                  },
                ),
              );
            }).toList();

            return DataRow(cells: cells);
          }).toList();
        }

          return Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _columnsExcel,
                  rows: _rowsExcel,
                  dataRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.white,
                  ),
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => ThemeColor.darkPurple,
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return FailedLoad.buildFailedLoad();
        } else {
          return LoadingFile.buildLoading();
        }
      },
    );
  }
}