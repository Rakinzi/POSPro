import 'dart:async';
import 'dart:ui' as ui;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../constant.dart';
import '../model/print_transaction_model.dart';

final printerPurchaseProviderNotifier = ChangeNotifierProvider((ref) => PrinterPurchase());

class PrinterPurchase extends ChangeNotifier {
  List<BluetoothInfo> availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List<BluetoothInfo> bluetooths = await PrintBluetoothThermal.pairedBluetooths;
    availableBluetoothDevices = bluetooths;
    notifyListeners();
  }

  Future<bool> setConnect(String mac) async {
    bool status = false;
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (result == true) {
      connected = true;
      status = true;
    }
    notifyListeners();
    return status;
  }

  Future<bool> printCustomTicket({required PrintPurchaseTransactionModel printTransactionModel, required String data, required String paperSize}) async {
    bool isPrinted = false;
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      List<int> bytes = await customPrintTicket(
        printTransactionModel: printTransactionModel,
        data: data,
        paperSize: paperSize,
      );
      await PrintBluetoothThermal.writeBytes(bytes);
      isPrinted = true;
    } else {
      isPrinted = false;
    }
    notifyListeners();
    return isPrinted;
  }

  Future<List<int>> customPrintTicket({required PrintPurchaseTransactionModel printTransactionModel, required String data, required String paperSize}) async {
    List<int> bytes = [];
    final PaperSize size = paperSize == '2 inch 58mm' ? PaperSize.mm58 : PaperSize.mm80;

    try {
      CapabilityProfile profile = await CapabilityProfile.load();
      final generator = Generator(size, profile);

      Future<void> addText(String text, {PosStyles? styles, int linesAfter = 0}) async {
        if (_isAscii(text)) {
          bytes += generator.text(
            text,
            linesAfter: linesAfter,
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          );
        } else {
          final imageBytes = await _textToImageBytes(
            generator,
            text,
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          );
          bytes += imageBytes;
          if (linesAfter > 0) {
            bytes += generator.feed(linesAfter);
          }
        }
      }

      // Add company name
      final companyNameText = printTransactionModel.personalInformationModel.companyName ?? '';
      bytes += generator.text(
        companyNameText,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1,
      );

      // Add address
      final address = printTransactionModel.personalInformationModel.address ?? '';
      if (address.isNotEmpty) {
        bytes += generator.text(
          address,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      // Add phone number
      final phoneNumber = printTransactionModel.personalInformationModel.phoneNumber ?? '';
      if (phoneNumber.isNotEmpty) {
        bytes += generator.text(
          'Tel: $phoneNumber',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: printTransactionModel.personalInformationModel.vatNumber?.trim().isNotEmpty == true ? 0 : 1,
        );
      }

      // Add VAT information if available
      final vatNumber = printTransactionModel.personalInformationModel.vatNumber;
      if (vatNumber != null && vatNumber.trim().isNotEmpty) {
        final vatName = printTransactionModel.personalInformationModel.vatName;
        final label = vatName != null ? '$vatName:' : 'Shop GST:';
        bytes += generator.text(
          '$label $vatNumber',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1,
        );
      }

      await addText(
        data,
        styles: const PosStyles(
          align: PosAlign.center,
        ),
        linesAfter: 1,
      );

      // Add footer
      bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: const PosStyles(align: PosAlign.center, bold: false),
        linesAfter: 1,
      );

      bytes += generator.text(
        'Developed By: $companyName',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );

      bytes += generator.cut();
      return bytes;
    } catch (e) {
      debugPrint('Error generating print ticket: $e');
      rethrow;
    }
  }
}

bool _isAscii(String input) {
  for (final c in input.runes) {
    if (c > 127) return false;
  }
  return true;
}

Future<List<int>> _textToImageBytes(
  Generator generator,
  String text, {
  PosStyles? styles,
}) async {
  try {
    const double fontSize = 26.0;
    const double horizontalPadding = 10.0;
    const double lineSpacing = 1.2;

    const double printerWidthMm = 58.0;
    const double printerDpi = 203.0;

    final double printerWidthPx = (printerWidthMm * printerDpi / 25.4) - (horizontalPadding * 2);
    const String fallbackFont = 'Arial Unicode MS';

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: styles?.bold == true ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
      fontFamily: fallbackFont,
      height: lineSpacing,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 100,
      ellipsis: '...',
    );

    textPainter.layout(maxWidth: printerWidthPx);

    final double imageWidth = printerWidthPx + (horizontalPadding * 2);
    final double imageHeight = textPainter.height + 20.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, imageWidth, imageHeight),
    );

    textPainter.paint(
      canvas,
      Offset(horizontalPadding, 10.0),
    );

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(
      imageWidth.toInt(),
      imageHeight.toInt(),
    );

    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final image = img.decodePng(pngBytes)!;

    return generator.image(image);
  } catch (e) {
    debugPrint('Error in _textToImageBytes: $e');
    rethrow;
  }
}
