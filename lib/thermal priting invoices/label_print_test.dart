import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/foundation.dart';

Future<void> printLabelTest({
  required String productName,
  required String price,
  required String date,
  required String barcodeData,
  required Uint8List pngBytes,
  required bool isTwoInch,
}) async {
  TscCommand tscCommand = TscCommand();
  await tscCommand.cleanCommand();
  await tscCommand.size(width: isTwoInch ? 45 : 38, height: 25); // mm
  await tscCommand.gap(2);
  await tscCommand.cls();
  await tscCommand.image(image: pngBytes, x: 0, y: 0);
  final cmd = await tscCommand.getCommand();
  BluetoothPrintPlus.write(cmd);
}

String centerText(String text, {int lineWidth = 24}) {
  if (text.length >= lineWidth) return text;
  int totalPadding = lineWidth - text.length;
  int leftPadding = totalPadding ~/ 2; // only add left padding
  return ' ' * leftPadding + text;
}
