import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/Model/product_total_stock_model.dart';
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> generateStockReportExcel(
  BuildContext context,
  List<ProductModel>? data,
  BusinessInformationModel? business,
  ProductListResponse? totalStock,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Stock Report'];

    sheet.appendRow([TextCellValue(business?.companyName ?? '')]);
    sheet.cell(CellIndex.indexByString("A1")).cellStyle;

    // Row 2: Report Title
    sheet.appendRow([TextCellValue('Stock Report')]);
    sheet.cell(CellIndex.indexByString("A2")).cellStyle;

    sheet.appendRow([]);

    // Row 5: Header
    final headerRowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('SL'),
      TextCellValue('Product Name'),
      TextCellValue('Quantity'),
      TextCellValue('Cost'),
    ]);

    sheet.appendRow([]);

    // Apply bold style to each header cell only
    for (var i = 0; i < 5; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerRowIndex)).cellStyle;
    }

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        final stockValue = data[i].stocks != null && data[i].stocks!.isNotEmpty ? data[i].stocks?.last.productPurchasePrice : 0;
        sheet.appendRow([
          TextCellValue('${i + 1}'),
          TextCellValue(data[i].productName ?? 'n/a'),
          TextCellValue(data[i].productStockSum.toString()),
          TextCellValue(stockValue.toString()),
        ]);
      }
    }

    final totalRowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('Total'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(totalStock!.totalStockValue.toStringAsFixed(2)),
    ]);

    for (var i = 0; i < 5; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRowIndex)).cellStyle;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${business?.companyName ?? "Company"}_stock_report.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Report Generated');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Error during Excel generation: $e');
  }
}
