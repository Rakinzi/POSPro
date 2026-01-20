import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Expense/Model/expense_modle.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../Screens/PDF/pdf.dart';
import '../../model/business_info_model.dart';

Future<void> generateExpenseReportPdf(BuildContext context, List<Expense>? data, BusinessInformationModel? business, DateTime? fromDate, DateTime? toDate) async {
  final pw.Document pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');
  double totalAmount = 0;

  // Calculate totals from data
  if (data != null) {
    for (var item in data) {
      totalAmount += item.amount ?? 0;
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
                  'Expense Report',
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
              DateFormat('dd-MM-yyyy').format(DateTime.parse(data[i].expenseDate.toString())),
              data[i].expanseFor ?? 'n/a',
              data[i].category?.categoryName.toString() ?? 'n/a',
              data[i].amount.toString(),
            ]);
          }

          return [
            pw.SizedBox(height: 16),

            // Main Table
            pw.TableHelper.fromTextArray(
              headers: [
                'SL',
                'Date',
                'Income For',
                'Category',
                'Amount',
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
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(4),
                3: const pw.FlexColumnWidth(4),
                4: const pw.FlexColumnWidth(2),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
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
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(4),
                3: const pw.FlexColumnWidth(4),
                4: const pw.FlexColumnWidth(2),
              },
              data: [
                [
                  'Total',
                  '',
                  '',
                  '',
                  totalAmount.toStringAsFixed(2),
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
