import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../Screens/PDF/pdf.dart';

class PDFCommonFunctions {
  //-------------------image
  Future<dynamic> getNetworkImage(String imageURL) async {
    if (imageURL.isEmpty) return null;
    try {
      final Uri uri = Uri.parse(imageURL);
      final String fileExtension = uri.path.split('.').last.toLowerCase();
      if (fileExtension == 'png' || fileExtension == 'jpg' || fileExtension == 'jpeg') {
        final List<int> responseBytes = await http.readBytes(uri);
        return Uint8List.fromList(responseBytes);
      } else if (fileExtension == 'svg') {
        final response = await http.get(uri);
        return response.body;
      } else {
        debugPrint('Unsupported image type: $fileExtension');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }



  Future<Uint8List?> loadAssetImage(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading local image: $e');
      return null;
    }
  }

  int serialNumber = 1; // Initialize serial number
  num getProductQuantity({required num detailsId, required SalesTransactionModel transactions}) {
    num totalQuantity = transactions.salesDetails?.where((element) => element.id == detailsId).first.quantities ?? 0;
    if (transactions.salesReturns?.isNotEmpty ?? false) {
      for (var returns in transactions.salesReturns!) {
        if (returns.salesReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.salesReturnDetails!) {
            if (details.saleDetailId == detailsId) {
              totalQuantity += details.returnQty ?? 0;
            }
          }
        }
      }
    }

    return totalQuantity;
  }

  static Future<void> savePdfAndShowPdf(
      {required BuildContext context, required String shopName, required String invoice, required pw.Document doc, bool? isShare, bool? download}) async {
    if (Platform.isIOS) {
      // EasyLoading.show(status: 'Generating PDF');
      if (download ?? false) {
        EasyLoading.show(status: 'Downloading...');
      } else {
        EasyLoading.show(status: 'Generating PDF');
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${'$appsName-$shopName-$invoice'}.pdf');

      final byteData = await doc.save();
      try {
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        EasyLoading.showSuccess('Done');
        if (isShare ?? false) {
          await SharePlus.instance.share(ShareParams(
            files: [XFile(file.path)],
            text: 'Here is your invoice PDF: ',
          ));
        } else if (download ?? false) {
          EasyLoading.showSuccess('Download successful! Check your Downloads folder');
        } else {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(path: file.path),
            ),
          );
        }
      } on FileSystemException catch (err) {
        EasyLoading.showError(err.message);
        // handle error
      }
    }

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();
      }
      if (true) {
        if (download ?? false) {
          EasyLoading.show(status: 'Downloading...');
        } else {
          EasyLoading.show(status: 'Generating PDF');
        }
        const downloadsFolderPath = '/storage/emulated/0/Download/';
        Directory dir = Directory(downloadsFolderPath);
        var file = File('${dir.path}/${'$appsName-$shopName-$invoice'}.pdf');
        for (var i = 1; i < 20; i++) {
          if (await file.exists()) {
            try {
              await file.delete();
              break;
            } catch (e) {
              if (e.toString().contains('Cannot delete file')) {
                file = File('${file.path.replaceAll(RegExp(r'\(\d+\)?'), '').replaceAll('.pdf', '')}($i).pdf');
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

          if (isShare ?? false) {
            await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Here is your invoice PDF: '));
          } else if (download ?? false) {
            EasyLoading.showSuccess('Download successful! Check your Downloads folder');
          } else {
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerPage(path: file.path),
              ),
            );
          }
        } on FileSystemException catch (err) {
          EasyLoading.showError(err.message);
        }
      }
    }
  }

  String numberToWords(num amount) {
    int taka = amount.floor();
    int paisa = ((amount - taka) * 100).round();

    String takaWords = _convertNumberToWords(taka);
    String paisaWords = paisa > 0 ? ' and ${_convertNumberToWords(paisa)} Cents' : '';

    return '$takaWords $paisaWords Only';
  }

  String _convertNumberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String convert(int n) {
      if (n < 20) return units[n];
      if (n < 100) {
        return '${tens[n ~/ 10]}${n % 10 != 0 ? ' ${units[n % 10]}' : ''}';
      }
      if (n < 1000) {
        return '${units[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${convert(n % 100)}' : ''}';
      }
      if (n < 100000) {
        return '${convert(n ~/ 1000)} Thousand${n % 1000 != 0 ? ' ${convert(n % 1000)}' : ''}';
      }
      if (n < 10000000) {
        return '${convert(n ~/ 100000)} Lakh${n % 100000 != 0 ? ' ${convert(n % 100000)}' : ''}';
      }
      return '${convert(n ~/ 10000000)} Crore${n % 10000000 != 0 ? ' ${convert(n % 10000000)}' : ''}';
    }

    return convert(number);
  }
}
