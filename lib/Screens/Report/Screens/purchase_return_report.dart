import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../PDF Invoice/purchase_invoice_pdf.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../core/theme/_app_colors.dart';
import '../../../currency.dart';
import '../../../thermal priting invoices/model/print_transaction_model.dart';
import '../../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../invoice_details/purchase_invoice_details.dart';

class PurchaseReturnReportScreen extends StatefulWidget {
  const PurchaseReturnReportScreen({super.key});

  @override
  PurchaseReportState createState() => PurchaseReportState();
}

class PurchaseReportState extends State<PurchaseReturnReportScreen> {
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month, 1)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate = DateTime.now();

  List<String> timeLimit = [
    'ToDay',
    'This Week',
    'This Month',
    'This Year',
    'All Time',
    'Custom',
  ];
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

  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.invalidate(purchaseReturnTransactionProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  void changeDate({required DateTime from}) {
    setState(() {
      fromDate = from;
      fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(from));

      toDate = DateTime.now();
      toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final translateTime = getTranslateTime(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).purchaseReturnReport,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          final purchaseData = ref.watch(purchaseReturnTransactionProvider);
          final printerData = ref.watch(thermalPrinterProvider);
          final businessInfo = ref.watch(businessInfoProvider);
          final businessData = ref.watch(businessSettingProvider);

          return RefreshIndicator(
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
                  purchaseData.when(data: (transaction) {
                    final filteredTransactions = transaction.where((element) {
                      final purchaseDate = DateTime.tryParse(element.purchaseDate ?? '');
                      if (purchaseDate == null) return false;

                      return (fromDate.isBefore(purchaseDate) || fromDate.isAtSameMomentAs(purchaseDate)) &&
                          (toDate.isAfter(purchaseDate) || toDate.isAtSameMomentAs(purchaseDate));
                    }).toList();

                    // total purchase return amount
                    double totalPurchaseReturn = 0;
                    for (var element in filteredTransactions) {
                      for (var returnItem in element.purchaseReturns ?? []) {
                        for (var detail in returnItem.purchaseReturnDetails ?? []) {
                          totalPurchaseReturn += (detail.returnAmount ?? 0);
                        }
                      }
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                      "$currency${totalPurchaseReturn.toStringAsFixed(2)}",
                                      style: const TextStyle(color: Colors.green, fontSize: 20),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Total Return', style: TextStyle(color: Colors.black, fontSize: 16)),
                                  ],
                                ),
                                Container(width: 1, height: 60, color: kMainColor),
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
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  num returndAmount = 0;
                                  for (var element in filteredTransactions[index].purchaseReturns!) {
                                    for (var sales in element.purchaseReturnDetails!) {
                                      returndAmount += (sales.returnAmount ?? 0);
                                    }
                                  }
                                  return Visibility(
                                    visible: (fromDate.isBefore(DateTime.parse(filteredTransactions[index].purchaseDate ?? '')) ||
                                            DateTime.parse(filteredTransactions[index].purchaseDate ?? '').isAtSameMomentAs(fromDate)) &&
                                        (toDate.isAfter(DateTime.parse(filteredTransactions[index].purchaseDate ?? '')) ||
                                            DateTime.parse(filteredTransactions[index].purchaseDate ?? '').isAtSameMomentAs(toDate)),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            PurchaseInvoiceDetails(
                                              businessInfo: businessInfo.value!,
                                              transitionModel: filteredTransactions[index],
                                            ).launch(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            width: context.width(),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        filteredTransactions[index].party?.name ?? '',
                                                        style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '#${filteredTransactions[index].invoiceNumber}',
                                                      style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                          decoration: BoxDecoration(
                                                              color: filteredTransactions[index].dueAmount! <= 0
                                                                  ? const Color(0xff0dbf7d).withValues(alpha: 0.1)
                                                                  : const Color(0xFFED1A3B).withValues(alpha: 0.1),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                          child: Text(
                                                            transaction[index].dueAmount! <= 0 ? lang.S.of(context).paid : lang.S.of(context).unPaid,
                                                            style:
                                                                TextStyle(color: filteredTransactions[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      DateFormat.yMMMd().format(DateTime.parse(filteredTransactions[index].purchaseDate ?? '')),
                                                      style: const TextStyle(color: DAppColors.kSecondary),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${lang.S.of(context).total} : $currency${filteredTransactions[index].totalAmount.toString()}',
                                                      style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${lang.S.of(context).paid} : $currency${filteredTransactions[index].totalAmount!.toDouble() - filteredTransactions[index].dueAmount!.toDouble()}',
                                                      style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        '${lang.S.of(context).returnAmount}: $currency$returndAmount',
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                      ),
                                                    ),
                                                    businessInfo.when(data: (data) {
                                                      return Row(
                                                        children: [
                                                          IconButton(
                                                              padding: EdgeInsets.zero,
                                                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                              onPressed: () async {
                                                                if ((Theme.of(context).platform == TargetPlatform.android)) {
                                                                  ///________Print_______________________________________________________

                                                                  PrintPurchaseTransactionModel model = PrintPurchaseTransactionModel(
                                                                      purchaseTransitionModel: filteredTransactions[index], personalInformationModel: data);

                                                                  await printerData.printPurchaseThermalInvoiceNow(
                                                                    transaction: model,
                                                                    productList: model.purchaseTransitionModel!.details,
                                                                    context: context,
                                                                    invoiceSize: businessInfo.value?.invoiceSize,
                                                                  );
                                                                }
                                                              },
                                                              icon: const Icon(
                                                                FeatherIcons.printer,
                                                                color: Colors.grey,
                                                                size: 22,
                                                              )),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          businessData.when(data: (business) {
                                                            return Row(
                                                              children: [
                                                                IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                                    onPressed: () =>
                                                                        PurchaseInvoicePDF.generatePurchaseDocument(filteredTransactions[index], data, context, business),
                                                                    icon: const Icon(
                                                                      Icons.picture_as_pdf,
                                                                      color: Colors.grey,
                                                                      size: 22,
                                                                    )),
                                                                IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                                    onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                                                                        filteredTransactions[index], data, context, business,
                                                                        download: true),
                                                                    icon: const Icon(
                                                                      FeatherIcons.download,
                                                                      color: Colors.grey,
                                                                      size: 22,
                                                                    )),
                                                                IconButton(
                                                                  style: IconButton.styleFrom(
                                                                      padding: EdgeInsets.zero,
                                                                      visualDensity: const VisualDensity(
                                                                        horizontal: -4,
                                                                        vertical: -4,
                                                                      )),
                                                                  onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(filteredTransactions[index], data, context, business,
                                                                      isShare: true),
                                                                  icon: const Icon(
                                                                    Icons.share_outlined,
                                                                    color: Colors.grey,
                                                                    size: 22,
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }, error: (e, stack) {
                                                            return Text(e.toString());
                                                          }, loading: () {
                                                            return const Center(
                                                              child: CircularProgressIndicator(),
                                                            );
                                                          })
                                                        ],
                                                      );
                                                    }, error: (e, stack) {
                                                      return Text(e.toString());
                                                    }, loading: () {
                                                      //return const Text('Loading');
                                                      return Text(lang.S.of(context).loading);
                                                    }),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(height: 0),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: EmptyWidgetUpdated(
                                  message: TextSpan(
                                    text: lang.S.of(context).addNewPurchase,
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
