import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../Screens/Income/Model/income_modle.dart';
import '../../model/business_info_model.dart';

Future<void> generateIncomeReportExcel(
  BuildContext context,
  List<Income>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Income Report'];

    double totalAmount = data?.fold(0, (sum, item) => sum! + (item.amount ?? 0)) ?? 0;

    // // Styles
    // final businessStyle = CellStyle(bold: true, fontSize: 12);
    // final titleStyle = CellStyle(bold: true, fontSize: 12);
    // final headerStyle = CellStyle(bold: true, fontSize: 12);
    // final footerStyle = CellStyle(bold: true, fontSize: 12);

    // Row 1: Company Name
    sheet.appendRow([TextCellValue(business?.companyName ?? '')]);
    sheet.cell(CellIndex.indexByString("A1")).cellStyle;

    // Row 2: Report Title
    sheet.appendRow([TextCellValue('Income Report')]);
    sheet.cell(CellIndex.indexByString("A2")).cellStyle;

    // Row 3: Duration
    if (fromDate != null) {
      sheet.appendRow([
        TextCellValue('Duration: ${DateFormat('dd-MM-yyyy').format(fromDate)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}'),
      ]);
    }

    // Row 4: Empty for spacing
    sheet.appendRow([]);

    // Row 5: Header
    final headerRowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('SL'),
      TextCellValue('Date'),
      TextCellValue('Income For'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
    ]);

    sheet.appendRow([]);

    // Apply bold style to each header cell only
    for (var i = 0; i < 5; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerRowIndex)).cellStyle;
    }

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        sheet.appendRow([
          TextCellValue('${i + 1}'),
          TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.parse(data[i].incomeDate.toString()))),
          TextCellValue(data[i].incomeFor ?? 'n/a'),
          TextCellValue(data[i].category?.categoryName ?? 'n/a'),
          TextCellValue(data[i].amount?.toStringAsFixed(2) ?? '0.00'),
        ]);
      }
    }

    final totalRowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('Total'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(totalAmount.toStringAsFixed(2)),
    ]);

    for (var i = 0; i < 5; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRowIndex)).cellStyle;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${business?.companyName ?? "Company"}_Income_Report.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Report Generated');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Error during Excel generation: $e');
  }
}
