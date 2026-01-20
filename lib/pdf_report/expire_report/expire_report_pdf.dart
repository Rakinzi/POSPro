import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../Screens/PDF/pdf.dart';

Future<void> generateExpireReportPdf(BuildContext context, List<ProductModel>? data, BusinessInformationModel? business, DateTime? fromDate, DateTime? toDate) async {
  final pw.Document pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');
  double totalPurchase = 0;
  double totalSalePrice = 0;

  // Calculate totals from data
  if (data != null) {
    for (var item in data) {
      totalPurchase += item.productPurchasePrice ?? 0;
    }
  }

  if (data != null) {
    for (var item in data) {
      totalSalePrice += item.productSalePrice ?? 0;
    }
  }
  // debugPrint('--font family---$ttf---------------');

  try {
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        //----------------pdf header--------------
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  business!.companyName.toString(),
                  style: pw.TextStyle(
                    // font: interFont,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                pw.Text(
                  // 'বিক্রয় প্রতিবেদন',
                  'Expired List',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    // font: ttf,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  fromDate != null ? 'Duration: ${DateFormat('dd-MM-yyyy').format(fromDate)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}' : '',
                  style: pw.TextStyle(
                    font: interFont,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
        //-----------------pdf footer-------------
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${business?.developedByLevel ?? ''} ${business?.developedBy ?? ''}'),
              pw.Text('Page-${context.pageNumber}'),
            ],
          );
        },
        build: (pw.Context context) {
          final List<List<String>> tableData = [];

          for (int i = 0; i < data!.length; i++) {
            tableData.add([
              '${i + 1}',
              data[i].productName ?? 'n/a',
              data[i].productCode ?? 'n/a',
              data[i].productStockSum.toString(),
              data[i].expireDate ?? 'n/a',
              data[i].productPurchasePrice.toString(),
              data[i].productSalePrice.toString(),
            ]);
          }

          return [
            pw.SizedBox(height: 16),

            // Main Table
            pw.TableHelper.fromTextArray(
              headers: [
                'SL',
                'Product',
                'Code',
                'Stock',
                'Expired In',
                'Purchase',
                'Sale',
              ],
              data: tableData,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xffC52127),
              ),
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              rowDecoration: const pw.BoxDecoration(
                color: PdfColors.white,
              ),
              oddRowDecoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xffF7F7F7),
              ),
              cellPadding: const pw.EdgeInsets.all(8),
              columnWidths: <int, pw.TableColumnWidth>{
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(3),
                5: const pw.FlexColumnWidth(3),
                6: const pw.FlexColumnWidth(3),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
            ),
            // Totals row (styled to match)
            pw.TableHelper.fromTextArray(
              border: const pw.TableBorder(
                left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
              ),
              columnWidths: <int, pw.TableColumnWidth>{
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(3),
                5: const pw.FlexColumnWidth(4),
                6: const pw.FlexColumnWidth(4),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerLeft,
                6: pw.Alignment.centerLeft,
              },
              data: [
                [
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  '',
                  totalPurchase.toStringAsFixed(2),
                  totalSalePrice.toStringAsFixed(2),
                ]
              ],
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xffC52127),
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ];
        }));

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-sales report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    EasyLoading.showSuccess('Generate Complete');
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(path: file.path),
      ),
    );
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Error during PDF generation: $e');
  }
}
