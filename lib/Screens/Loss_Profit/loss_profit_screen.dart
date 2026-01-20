import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/loss_profit_report/loss_profit_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../GlobalComponents/sales_transaction_widget.dart';
import '../../currency.dart';
import '../../model/sale_transaction_model.dart';
import '../Home/home.dart';

class LossProfitScreen extends StatefulWidget {
  const LossProfitScreen({super.key, this.fromReport});

  final bool? fromReport;

  @override  State<LossProfitScreen> createState() => _LossProfitScreenState();
}

class _LossProfitScreenState extends State<LossProfitScreen> {
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month, 1)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate = DateTime.now();

  num calculateTotalProductQtyNow({required SalesTransactionModel sales}) {
    num totalQty = 0;
    for (var element in sales.salesDetails!) {
      totalQty += element.quantities ?? 0;
    }
    return totalQty;
  }

  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.invalidate(salesTransactionProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        const Home().launch(context, isNewTask: true);
      },
      child: Consumer(
        builder: (_, ref, watch) {
          final providerData = ref.watch(salesTransactionProvider);
          final personalData = ref.watch(businessInfoProvider);
          return personalData.when(
              data: (business) {
                return providerData.when(
                    data: (transaction) {
                      double totalSale = 0;
                      double totalProfit = 0;
                      double totalLoss = 0;
                      // for (var element in transaction) {
                      //   if ((fromDate.isBefore(DateTime.parse(element.saleDate ?? '')) ||
                      //           DateTime.parse(element.saleDate ?? '').isAtSameMomentAs(fromDate)) &&
                      //       (toDate.isAfter(DateTime.parse(element.saleDate ?? '')) ||
                      //           DateTime.parse(element.saleDate ?? '').isAtSameMomentAs(toDate))) {
                      //     (element.detailsSumLossProfit ?? 0).isNegative
                      //         ? totalLoss = totalLoss + (element.detailsSumLossProfit ?? 0).abs()
                      //         : totalProfit = totalProfit + (element.detailsSumLossProfit ?? 0);
                      //   }
                      // }
                      // Filter transactions based on date range
                      for (var element in transaction) {
                        if ((fromDate.isBefore(DateTime.parse(element.saleDate ?? '')) || DateTime.parse(element.saleDate ?? '').isAtSameMomentAs(fromDate)) &&
                            (toDate.isAfter(DateTime.parse(element.saleDate ?? '')) || DateTime.parse(element.saleDate ?? '').isAtSameMomentAs(toDate))) {
                          totalSale = totalSale + element.totalAmount!;
                          (element.detailsSumLossProfit ?? 0).isNegative
                              ? totalLoss = totalLoss + (element.detailsSumLossProfit ?? 0).abs()
                              : totalProfit = totalProfit + (element.detailsSumLossProfit ?? 0);
                        }
                      }
                      return GlobalPopup(
                        child: Scaffold(
                          backgroundColor: kWhite,
                          appBar: AppBar(
                            backgroundColor: Colors.white,
                            title: Text(
                              (widget.fromReport ?? false) ? 'Loss/Profit Report' : lang.S.of(context).lp,
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  if (transaction.isNotEmpty) {
                                    generateLossProfitReportPdf(context, transaction, business, fromDate, toDate);
                                  } else {
                                    EasyLoading.showError('List is empty');
                                  }
                                },
                                icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                              ),
                            ],
                            iconTheme: const IconThemeData(color: Colors.black),
                            centerTitle: true,
                            elevation: 0.0,
                          ),
                          body: RefreshIndicator(
                            onRefresh: () => refreshData(ref),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20, bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: AppTextField(
                                            textFieldType: TextFieldType.NAME,
                                            readOnly: true,
                                            controller: fromDateTextEditingController,
                                            decoration: InputDecoration(
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              labelText: lang.S.of(context).fromDate,
                                              border: const OutlineInputBorder(),
                                              suffixIcon: IconButton(
                                                onPressed: () async {
                                                  final DateTime? picked = await showDatePicker(
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2015, 8),
                                                    lastDate: DateTime(2101),
                                                    context: context,
                                                  );
                                                  setState(() {
                                                    fromDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                                    fromDate = picked!;
                                                  });
                                                },
                                                icon: const Icon(FeatherIcons.calendar),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: AppTextField(
                                            textFieldType: TextFieldType.NAME,
                                            readOnly: true,
                                            controller: toDateTextEditingController,
                                            decoration: InputDecoration(
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              labelText: lang.S.of(context).toDate,
                                              border: const OutlineInputBorder(),
                                              suffixIcon: IconButton(
                                                onPressed: () async {
                                                  final DateTime? picked = await showDatePicker(
                                                    initialDate: toDate,
                                                    firstDate: DateTime(2015, 8),
                                                    lastDate: DateTime(2101),
                                                    context: context,
                                                  );

                                                  setState(() {
                                                    toDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                                    picked!.isToday ? toDate = DateTime.now() : toDate = picked;
                                                  });
                                                },
                                                icon: const Icon(FeatherIcons.calendar),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  transaction.isNotEmpty
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Container(
                                                height: 100,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: kMainColor.withValues(alpha: 0.1),
                                                    border: Border.all(width: 1, color: kMainColor),
                                                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '$currency ${totalProfit.toStringAsFixed(2)}',
                                                          style: const TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          lang.S.of(context).profit,
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: 60,
                                                      color: kMainColor,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '$currency ${totalLoss.toStringAsFixed(2)}',
                                                          style: const TextStyle(
                                                            color: Colors.orange,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          lang.S.of(context).loss,
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: transaction.length,
                                              itemBuilder: (context, index) {
                                                return salesTransactionWidget(
                                                  context: context,
                                                  ref: ref,
                                                  businessInfo: personalData.value!,
                                                  sale: transaction[index],
                                                  advancePermission: true,
                                                  fromLossProfit: true,
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(top: 60),
                                          child: Text(
                                            lang.S.of(context).pleaseMakeASaleFirst,
                                            //"Please make a sale first"
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    error: (e, stack) => Text(e.toString()),
                    loading: () => Center(
                          child: CircularProgressIndicator(),
                        ));
              },
              error: (e, stack) => Text(e.toString()),
              loading: () => Center(
                    child: CircularProgressIndicator(),
                  ));
        },
      ),
    );
  }
}