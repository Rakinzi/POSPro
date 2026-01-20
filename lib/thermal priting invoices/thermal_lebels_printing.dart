import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';

class SalesThermalLabels {
  ///________Sales____________________

  Future<void> printLabels({required List<ProductModel>? productList}) async {
    bool conn = BluetoothPrintPlus.isConnected;

    debugPrint('Collection State----------------> $conn');

    ///_________________Old_______________________________________________
    // bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    // if (isConnected == true) {
    //   List<int> bytes = await labelPrinter(productList: productList);
    //   if (true) {
    //     await PrintBluetoothThermal.writeBytes(bytes);
    //     EasyLoading.showSuccess('Successfully Printed');
    //   } else {
    //     toast('No Product Found');
    //   }
    // } else {
    //   EasyLoading.showError('Unable to connect with printer');
    // }
  }
  //
  // Future<List<int>> labelPrinter({required List<ProductModel>? productList}) async {
  //   List<int> bytes = [];
  //   CapabilityProfile profile = await CapabilityProfile.load();
  //
  //   final generator = Generator(PaperSize.mm80, profile);
  //
  //   ///____________Header_____________________________________
  //   bytes += generator.text('This is a test',
  //       styles: const PosStyles(
  //         align: PosAlign.center,
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       ),
  //       linesAfter: 1);
  //   final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  //   bytes += generator.barcode(Barcode.upcA(barData));
  //
  //   bytes += generator.cut();
  //   return bytes;
  // }
}
