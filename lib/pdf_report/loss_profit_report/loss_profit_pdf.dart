import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../Screens/PDF/pdf.dart';
import '../../model/business_info_model.dart';
import '../../model/sale_transaction_model.dart';

Future<void> generateLossProfitReportPdf(BuildContext context, List<SalesTransactionModel>? data, BusinessInformationModel? business, DateTime? fromDate, DateTime? toDate) async {
  final pw.Document pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');
  double totalProfit = 0;

// Calculate totals from data
  if (data != null) {
    for (var item in data) {
      final profit = item.detailsSumLossProfit ?? 0;
      if (!profit.isNegative) {
        totalProfit += profit;
      }
    }
  }

  double totalLoss = 0;

// Calculate totals from data
  if (data != null) {
    for (var item in data) {
      final profit = item.detailsSumLossProfit ?? 0;
      if (profit.isNegative) {
        totalLoss += profit;
      }
    }
  }

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
                  'Loss/Profit Reports',
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
              data[i].invoiceNumber ?? 'n/a',
              DateFormat('dd-MM-yyyy').format(DateTime.parse(data[i].saleDate.toString())),
              data[i].party!.name ?? 'n/a',
              data[i].isPaid == true ? 'Paid' : 'Unpaid',
              data[i].totalAmount.toString(),
              !data[i].detailsSumLossProfit!.isNegative ? data[i].detailsSumLossProfit.toString() : '0',
              data[i].detailsSumLossProfit!.isNegative ? data[i].detailsSumLossProfit.toString() : '0',
            ]);
          }

          return [
            pw.SizedBox(height: 16),

            // Main Table
            pw.TableHelper.fromTextArray(
              headers: [
                'SL',
                'Invoice',
                'Date',
                'Name',
                'Status',
                'Total',
                'Profit',
                'Loss',
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
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2),
                6: const pw.FlexColumnWidth(2),
                7: const pw.FlexColumnWidth(2),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
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
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2),
                6: const pw.FlexColumnWidth(2),
                7: const pw.FlexColumnWidth(2),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
              },
              data: [
                [
                  '',
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  totalProfit,
                  totalLoss,
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
