import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../constant.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/custom_print_provider.dart';

class CustomPrintScreen extends StatefulWidget {
  const CustomPrintScreen({super.key});

  @override
  State<CustomPrintScreen> createState() => _CustomPrintScreenState();
}

class _CustomPrintScreenState extends State<CustomPrintScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_lang.customPrint),
      ),
      body: Consumer(builder: (context, ref, __) {
        final printerData = ref.watch(printerPurchaseProviderNotifier);
        final personalData = ref.watch(businessInfoProvider);
        final purchaseData = ref.watch(purchaseTransactionProvider);
        return purchaseData.when(data: (purchaseData) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: textEditingController,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: _lang.writerTaxHere,
                  ),
                ),
                SizedBox(height: 20),
                personalData.when(data: (data) {
                  return ElevatedButton(
                    onPressed: () async {
                      await printerData.getBluetooth();
                      if (!context.mounted) return;
                      if (connected) {
                        await printerData.printCustomTicket(
                            printTransactionModel: PrintPurchaseTransactionModel(personalInformationModel: data, purchaseTransitionModel: null),
                            data: textEditingController.text,
                            paperSize: '');
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return PopScope(
                                canPop: false,
                                child: Dialog(
                                  child: SizedBox(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: printerData.availableBluetoothDevices.isNotEmpty ? printerData.availableBluetoothDevices.length : 0,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () async {
                                                BluetoothInfo select = printerData.availableBluetoothDevices[index];
                                                bool isConnect = await printerData.setConnect(select.macAdress);
                                                if (!context.mounted) return;
                                                isConnect ? finish(context) : toast(l.S.of(context).tryAgain);
                                              },
                                              title: Text(printerData.availableBluetoothDevices[index].name),
                                              subtitle: Text(l.S.of(context).clickToConnect),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                                          child: Text(
                                            l.S.of(context).pleaseConnectYourBlutohPrinter,
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(height: 1, width: double.infinity, color: Colors.grey),
                                        const SizedBox(height: 15),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Center(
                                            child: Text(
                                              l.S.of(context).cancel,
                                              style: const TextStyle(color: kMainColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    },
                    child: Text(l.S.of(context).print),
                  );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const CircularProgressIndicator();
                })
              ],
            ),
          );
        }, error: (e, stack) {
          return Text(e.toString());
        }, loading: () {
          return Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}
