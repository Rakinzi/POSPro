import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../constant.dart';

class PdfPreviewScreen extends StatelessWidget {
  final pw.Document pdfDocument;

  const PdfPreviewScreen({super.key, required this.pdfDocument});

  Future<void> _saveBarcodeLabels(pw.Document doc) async {
    if (Platform.isIOS) {
      EasyLoading.show(status: 'Downloading...');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/barcode_labels.pdf');
      final byteData = await doc.save();
      try {
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        EasyLoading.showSuccess('Download successful! Check your Documents folder');
      } on FileSystemException catch (err) {
        EasyLoading.showError(err.message);
      }
    }

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();
      }

      // Use the same condition as your working method
      if (true) {
        EasyLoading.show(status: 'Downloading...');
        const downloadsFolderPath = '/storage/emulated/0/Download/';
        Directory dir = Directory(downloadsFolderPath);
        var file = File('${dir.path}/barcode_labels.pdf');

        // Exact same file conflict handling as your working method
        for (var i = 1; i < 20; i++) {
          if (await file.exists()) {
            try {
              await file.delete();
              break;
            } catch (e) {
              if (e.toString().contains('Cannot delete file')) {
                file = File('${file.path.replaceAll(RegExp(r'\\(\\d+\\)?'), '').replaceAll('.pdf', '')}($i).pdf');
              }
            }
          } else {
            break;
          }
        }

        try {
          final byteData = await doc.save();
          await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          EasyLoading.dismiss();
          EasyLoading.showSuccess('Download successful! Check your Downloads folder');
        } on FileSystemException catch (err) {
          EasyLoading.showError(err.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Print Barcode',
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: PdfPreview(
        dynamicLayout: false,
        actionBarTheme: PdfActionBarTheme(
          backgroundColor: Colors.white,
        ),
        previewPageMargin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        initialPageFormat: PdfPageFormat.a4,
        scrollViewDecoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        pdfPreviewPageDecoration: const BoxDecoration(
          backgroundBlendMode: BlendMode.overlay,
          color: Colors.white,
        ),
        useActions: false,
        build: (format) => pdfDocument.save(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: kMainColor,
            minimumSize: const Size(double.maxFinite, 48),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            await _saveBarcodeLabels(pdfDocument);
            if (!context.mounted) return;
            Navigator.of(context).pop(); // Close the preview screen
          },
          icon: Icon(Icons.download),
          label: Text(
            'Download',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
