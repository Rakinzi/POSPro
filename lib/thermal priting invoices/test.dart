import 'dart:async';
import 'dart:io';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_pos/thermal%20priting%20invoices/barcode_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as p;
import 'package:pdf/widgets.dart' as pw;

import 'label_print_test.dart';
import 'sticker_image_generation.dart';

class LablePrinterDemo extends StatefulWidget {
  const LablePrinterDemo({super.key});

  @override
  State<LablePrinterDemo> createState() => _LablePrinterDemoState();
}

class _LablePrinterDemoState extends State<LablePrinterDemo> {
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];

  @override
  void initState() {
    super.initState();
    initBluetoothPrintPlusListen();
  }

  @override
  void dispose() {
    super.dispose();
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
      }
    });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((event) {
      debugPrint('********** isScanning: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      debugPrint('********** blueState change: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) async {
      debugPrint('********** connectState change: $event **********');
      switch (event) {
        case ConnectState.connected:
          setState(() {});
          break;
        case ConnectState.disconnected:
          setState(() {
            _device = null;
          });
          break;
      }
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      debugPrint('********** received data: $data **********');

      /// do something...
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrintPlus'),
        ),
        body: SafeArea(
            child: BluetoothPrintPlus.isBlueOn
                ? Scaffold(
                    body: SizedBox(
                      child: ListView.builder(
                        itemCount: _scanResults.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_scanResults[index].name),
                                    Text(
                                      _scanResults[index].address,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Divider(),
                                  ],
                                )),
                                SizedBox(width: 10),
                                Visibility(
                                  visible: BluetoothPrintPlus.isConnected && _scanResults[index].address == _device?.address,
                                  child: TextButton(
                                    onPressed: () async {
                                      // final pdf = await generatePdf(productCode: '3746328476', price: '1200', productName: 'IPhone 13', date: "12/05/2025");
                                      // await BluetoothPrintPlus.write();

                                      // rendererTest(pdf.path);
                                      // await printImageTest(imageB: await generatePdfAsImage());
                                      // await printProductLabel(productName: 'ABCDEFG', price: '500', expireDate: '12/07/2025', productCode: '734682');
                                    },
                                    child: const Text("print"),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _device = _scanResults[index];
                                    await BluetoothPrintPlus.connect(_scanResults[index]);
                                    setState(() {});
                                  },
                                  child: const Text("connect"),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Column(
                    children: [
                      StickerWidget(
                        data: StickerData(
                            name: 'Tasla Cyber Tank',
                            price: 200.0,
                            code: '0001',
                            mfg: '',
                            isTwoIch: false,
                            showName: true,
                            showPrice: true,
                            showCode: true,
                            showMfg: true,
                            nameFontSize: 20,
                            codeFontSize: 20,
                            mfgFontSize: 20,
                            priceFontSize: 20,
                            businessName: '',
                            showBusinessName: true),
                      ),
                      SizedBox(height: 20),
                      buildBlueOffWidget(),
                    ],
                  )),
        floatingActionButton: BluetoothPrintPlus.isBlueOn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildScanButton(context),
                  FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      final pngBytes = await createImageFromWidget(
                        context,
                        StickerWidget(
                          data: StickerData(
                              name: 'Product Name',
                              price: 50.0,
                              code: '123456789',
                              mfg: '15-08-2025',
                              isTwoIch: false,
                              showName: true,
                              showPrice: true,
                              showCode: true,
                              showMfg: true,
                              nameFontSize: 20,
                              codeFontSize: 20,
                              mfgFontSize: 20,
                              priceFontSize: 20,
                              businessName: '',
                              showBusinessName: true),
                        ),
                        logicalSize: const Size(280, 180),
                        imageSize: const Size(280, 180),
                      );
                      await printLabelTest(productName: 'Tasla Cyber Tank', date: '', price: '\$200', barcodeData: '0001', pngBytes: pngBytes!, isTwoInch: false);
                    },
                    child: Text(
                      'Print',
                    ),
                  ),
                ],
              )
            : null);
  }

  Widget buildBlueOffWidget() {
    return Center(
        child: Text(
      "Bluetooth is turned off\nPlease turn on Bluetooth...",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.red),
      textAlign: TextAlign.center,
    ));
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(onPressed: onScanPressed, backgroundColor: Colors.green, child: Text("SCAN"));
    }
  }

  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: Duration(seconds: 10));
      setState(() {});
    } catch (e) {
      debugPrint("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      debugPrint("onStopPressed error: $e");
    }
  }
}

Future<File> generatePdf({
  required String productName,
  required String price,
  required String date,
  required String productCode,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: p.PdfPageFormat(32 * p.PdfPageFormat.mm, 25 * p.PdfPageFormat.mm),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(productName, style: pw.TextStyle(fontSize: 8)),
            pw.Text("\$$price", style: pw.TextStyle(fontSize: 8)),
            pw.Text("EXP: $date", style: pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: productCode,
              width: 100,
              height: 30,
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/label.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}
