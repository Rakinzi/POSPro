import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../GlobalComponents/sales_transaction_widget.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  SalesReportScreenState createState() => SalesReportScreenState();
}

class SalesReportScreenState extends State<SalesReportScreen> {
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month, 1)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate = DateTime.now();

  List<String> timeLimit = ['ToDay', 'This Week', 'This Month', 'This Year', 'All Time', 'Custom'];
  String? dropdownValue = 'This Month';

  Map<String, String> getTranslateTime(BuildContext context) {
    return {
      'ToDay': lang.S.of(context).today,
      'This Week': lang.S.of(context).thisWeek,
      'This Month': lang.S.of(context).thisMonth,
      'This Year': lang.S.of(context).thisYear,
      "All Time": lang.S.of(context).allTime,
      // "Custom": lang.S.of(context).custom,
    };
  }

  void changeDate({required DateTime from}) {
    setState(() {
      fromDate = from;
      fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(from));

      toDate = DateTime.now();
      toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
    });
  }

  bool _isRefreshing = false;

  Future<void> refreshAllProviders({required WidgetRef ref}) async {
    if (_isRefreshing) return; // Prevent multiple refresh calls

    _isRefreshing = true;
    try {
      ref.invalidate(salesTransactionProvider);
      ref.invalidate(thermalPrinterProvider);
      ref.invalidate(businessInfoProvider);
      ref.invalidate(getExpireDateProvider(ref));
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translateTime = getTranslateTime(context);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).salesReport,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          final providerData = ref.watch(salesTransactionProvider);
          final personalData = ref.watch(businessInfoProvider);
          return RefreshIndicator(
            onRefresh: () => refreshAllProviders(ref: ref),
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
                                    // totalSale = 0;//
                                    dropdownValue = 'Custom';
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
                                    // totalSale = 0;
                                    dropdownValue = 'Custom';
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
                  providerData.when(data: (transaction) {
                    // Filter transactions
                    final filteredTransactions = transaction.where((element) {
                      final saleDate = DateTime.tryParse(element.saleDate ?? '');
                      if (saleDate == null) return false;
                      return (fromDate.isBefore(saleDate) || fromDate.isAtSameMomentAs(saleDate)) && (toDate.isAfter(saleDate) || toDate.isAtSameMomentAs(saleDate));
                    }).toList();

                    // total sales
                    double totalSale = 0;
                    for (var element in filteredTransactions) {
                      totalSale += element.totalAmount ?? 0;
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kMainColor.withValues(alpha: 0.1),
                              border: Border.all(width: 1, color: kMainColor),
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency ${totalSale.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      lang.S.of(context).totalSales,
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
                                Container(
                                  height: 40,
                                  width: 150,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kMainColor, width: 1),
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: dropdownValue,
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      items: timeLimit.map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(translateTime[items] ?? items),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          dropdownValue = newValue.toString();

                                          switch (newValue) {
                                            case 'ToDay':
                                              changeDate(from: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
                                              break;
                                            case 'This Week':
                                              DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                                              changeDate(from: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day));
                                              break;
                                            case 'This Month':
                                              changeDate(from: DateTime(DateTime.now().year, DateTime.now().month, 1));
                                              break;
                                            case 'This Year':
                                              changeDate(from: DateTime(DateTime.now().year, 1, 1));
                                              break;
                                            case 'All Time':
                                              changeDate(from: DateTime(2020, 1, 1));
                                              break;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        filteredTransactions.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  return salesTransactionWidget(
                                    context: context,
                                    ref: ref,
                                    businessInfo: personalData.value!,
                                    sale: filteredTransactions[index],
                                    advancePermission: true,
                                  );
                                },
                              )
                            : Center(
                                child: EmptyWidgetUpdated(
                                  message: TextSpan(
                                    text: lang.S.of(context).addSale,
                                  ),
                                ),
                              ),
                      ],
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
