import 'dart:ui';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

final labelPrinterProvider = ChangeNotifierProvider((ref) => ThermalPrinter());

class ThermalPrinter extends ChangeNotifier {
  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);
    await BluetoothPrintPlus.startScan(timeout: Duration(seconds: 10));
  }

  List<BluetoothDevice> availableBluetoothDevices = [];
  bool isBluetoothConnected = false;

  // Future<void> getBluetooth() async {
  //   availableBluetoothDevices = await BluetoothPrintPlus.scanResults;
  //   isBluetoothConnected = await PrintBluetoothThermal.connectionStatus;
  //   notifyListeners();
  // }
  //
  // Future<bool> setConnect(String mac) async {
  //   bool status = false;
  //   final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
  //   if (result == true) {
  //     isBluetoothConnected = true;
  //     status = true;
  //   }
  //   notifyListeners();
  //   return status;
  // }

  Future<dynamic> listOfBluDialog({required BuildContext context}) async {
    // begin scan

    // final _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
    //   debugPrint('${event.length}');
    //    // if (mounted) {
    //    //   setState(() {
    //    //     _scanResults = event;
    //    //   });
    //    // }
    //  });
    return showCupertinoDialog(
      context: context,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: CupertinoAlertDialog(
              insetAnimationCurve: Curves.bounceInOut,
              // content: Container(
              //     height: availableBluetoothDevices.isNotEmpty ? (availableBluetoothDevices.length * 80).toDouble() : 150,
              //     width: double.maxFinite,
              //     child: StreamBuilder(
              //         stream: FlutterBluetoothPrinter.discovery,
              //         builder: (context, snapshot){
              //
              //
              //           // final List<BluetoothDevice> hh = snapshot.data as List<BluetoothDevice>;
              //           debugPrint('this is it--------->$snapshot');
              //           return ListView.builder(
              //               itemCount: 0,
              //               itemBuilder: (context, index){
              //                 // final device = hh.elementAt(index);
              //                 return ListTile(
              //                     // title: Text(device.name ?? 'No Name'),
              //                     // subtitle: Text(device.address),
              //                     onTap: (){
              //                       // do anything
              //                       // FlutterBluetoothPrinter.printImage(
              //                       //     address: device.address,
              //                       //     image: // some image
              //                       // );
              //                     }
              //                 );
              //               }
              //           );
              //         }
              //     )),
              title: Text(
                'Connect Your Device',
                textAlign: TextAlign.start,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    lang.S.of(context).cancel,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> printSalesThermalInvoiceNow({required PrintSalesTransactionModel transaction, required List<SalesDetails>? productList, required BuildContext context}) async {
  //   await getBluetooth();
  //   isBluetoothConnected ? SalesThermalPrinterInvoice().printSalesTicket(printTransactionModel: transaction, productList: productList) : listOfBluDialog(context: context);
  // }
}
