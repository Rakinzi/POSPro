import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Purchase/add_and_edit_purchase.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../PDF Invoice/purchase_invoice_pdf.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../core/theme/_app_colors.dart';
import '../../currency.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Home/home.dart';
import '../invoice return/invoice_return_screen.dart';
import '../invoice_details/purchase_invoice_details.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  PurchaseReportState createState() => PurchaseReportState();
}

class PurchaseReportState extends State<PurchaseListScreen> {
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.invalidate(purchaseTransactionProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        const Home().launch(context, isNewTask: true);
      },
      child: GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).purchaseList,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Consumer(builder: (context, ref, __) {
            final providerData = ref.watch(purchaseTransactionProvider);
            final printerData = ref.watch(thermalPrinterProvider);
            final businessSetting = ref.watch(businessSettingProvider);
            final businessInfoData = ref.watch(businessInfoProvider);
            return RefreshIndicator.adaptive(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: providerData.when(data: (purchaseTransactions) {
                  return purchaseTransactions.isNotEmpty
                      ? businessInfoData.when(data: (details) {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: purchaseTransactions.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      PurchaseInvoiceDetails(
                                        businessInfo: businessInfoData.value!,
                                        transitionModel: purchaseTransactions[index],
                                      ).launch(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
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
                                                  purchaseTransactions[index].party?.name ?? '',
                                                  style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '#${purchaseTransactions[index].invoiceNumber}',
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
                                                        color: purchaseTransactions[index].dueAmount! <= 0
                                                            ? const Color(0xff0dbf7d).withValues(alpha: 0.1)
                                                            : const Color(0xFFED1A3B).withValues(alpha: 0.1),
                                                        borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                    child: Text(
                                                      purchaseTransactions[index].dueAmount! <= 0 ? lang.S.of(context).paid : lang.S.of(context).unPaid,
                                                      style: TextStyle(color: purchaseTransactions[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                    ),
                                                  ),

                                                  ///________Return_tag_________________________________________
                                                  Visibility(
                                                    visible: purchaseTransactions[index].purchaseReturns?.isNotEmpty ?? false,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange.withValues(alpha: 0.2),
                                                          borderRadius: const BorderRadius.all(
                                                            Radius.circular(2),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          lang.S.of(context).returned,
                                                          style: const TextStyle(color: Colors.orange),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                DateFormat.yMMMd().format(DateTime.parse(purchaseTransactions[index].purchaseDate ?? '')),
                                                style: const TextStyle(color: DAppColors.kSecondary),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${lang.S.of(context).total} : $currency ${purchaseTransactions[index].totalAmount.toString()}',
                                                style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                              ),
                                              const SizedBox(width: 4),
                                              if (purchaseTransactions[index].dueAmount!.toInt() != 0)
                                                Text(
                                                  '${lang.S.of(context).paid} : $currency ${purchaseTransactions[index].totalAmount!.toDouble() - purchaseTransactions[index].dueAmount!.toDouble()}',
                                                  style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (purchaseTransactions[index].dueAmount!.toInt() == 0)
                                                Flexible(
                                                  child: Text(
                                                    '${lang.S.of(context).paid} : $currency ${purchaseTransactions[index].totalAmount!.toDouble() - purchaseTransactions[index].dueAmount!.toDouble()}',
                                                    style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              if (purchaseTransactions[index].dueAmount!.toInt() != 0)
                                                Flexible(
                                                  child: Text(
                                                    '${lang.S.of(context).due}: $currency ${purchaseTransactions[index].dueAmount.toString()}',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                  ),
                                                ),
                                              businessInfoData.when(data: (data) {
                                                return Row(
                                                  children: [
                                                    IconButton(
                                                        padding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                        onPressed: () async {
                                                          ///________Print_______________________________________________________

                                                          PrintPurchaseTransactionModel model =
                                                              PrintPurchaseTransactionModel(purchaseTransitionModel: purchaseTransactions[index], personalInformationModel: data);

                                                          await printerData.printPurchaseThermalInvoiceNow(
                                                            transaction: model,
                                                            productList: model.purchaseTransitionModel!.details,
                                                            invoiceSize: businessInfoData.value?.invoiceSize,
                                                            context: context,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          FeatherIcons.printer,
                                                          color: Colors.grey,
                                                          size: 22,
                                                        )),
                                                    const SizedBox(
                                                      width: 6,
                                                    ),
                                                    businessSetting.when(data: (bussiness) {
                                                      return Row(
                                                        children: [
                                                          IconButton(
                                                              padding: EdgeInsets.zero,
                                                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                              onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(purchaseTransactions[index], data, context, bussiness),
                                                              icon: const Icon(
                                                                Icons.picture_as_pdf,
                                                                color: Colors.grey,
                                                                size: 22,
                                                              )),
                                                          IconButton(
                                                              padding: EdgeInsets.zero,
                                                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                              onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(purchaseTransactions[index], data, context, bussiness,
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
                                                            onPressed: () =>
                                                                PurchaseInvoicePDF.generatePurchaseDocument(purchaseTransactions[index], data, context, bussiness, isShare: true),
                                                            icon: const Icon(
                                                              Icons.share_outlined,
                                                              color: Colors.grey,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }, error: (e, statck) {
                                                      return Text(e.toString());
                                                    }, loading: () {
                                                      return const Center(
                                                        child: CircularProgressIndicator(),
                                                      );
                                                    }),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),

                                                    ///_________Edit_purchase______________________________
                                                    Visibility(
                                                      visible: !(purchaseTransactions[index].purchaseReturns?.isNotEmpty ?? false),
                                                      child: IconButton(
                                                          padding: EdgeInsets.zero,
                                                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                          onPressed: () async {
                                                            ref.invalidate(cartNotifierPurchaseNew);
                                                            AddAndUpdatePurchaseScreen(
                                                              transitionModel: purchaseTransactions[index],
                                                              customerModel: null,
                                                            ).launch(context);
                                                          },
                                                          icon: const Icon(
                                                            FeatherIcons.edit,
                                                            color: Colors.grey,
                                                          )),
                                                    ),

                                                    ///_____More____________________________________________
                                                    PopupMenuButton(
                                                      offset: const Offset(0, 30),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (BuildContext bc) => [
                                                        ///________Sale List Delete_______________________________
                                                        // PopupMenuItem(
                                                        //   child: GestureDetector(
                                                        //     onTap: () async {
                                                        //       bool? result = await invoiceDeleteAlert(context: context, type: 'Purchase Invoice');
                                                        //       Navigator.pop(bc);
                                                        //       if (result != null && result) {}
                                                        //     },
                                                        //     child: const Row(
                                                        //       children: [
                                                        //         Icon(
                                                        //           Icons.delete,
                                                        //           color: kGreyTextColor,
                                                        //         ),
                                                        //         SizedBox(
                                                        //           width: 10.0,
                                                        //         ),
                                                        //         Text(
                                                        //           'Delete',
                                                        //           style: TextStyle(color: kGreyTextColor),
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // ),

                                                        ///________Purchase Return___________________________________
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => InvoiceReturnScreen(purchaseTransaction: purchaseTransactions[index]),
                                                                ),
                                                              );
                                                              if (!context.mounted) return;
                                                              Navigator.pop(bc);
                                                            },
                                                            child: const Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.keyboard_return_outlined,
                                                                  color: kGreyTextColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Purchase return',
                                                                  style: TextStyle(color: kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      onSelected: (value) {
                                                        Navigator.pushNamed(context, '$value');
                                                      },
                                                      child: const Icon(
                                                        FeatherIcons.moreVertical,
                                                        color: kGreyTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }, error: (e, stack) {
                                                return Text(e.toString());
                                              }, loading: () {
                                                //return  Text('Loading');
                                                return Text(lang.S.of(context).loading);
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 0)
                                ],
                              );
                            },
                          );
                        }, error: (e, stack) {
                          return Text(e.toString());
                        }, loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        })
                      : Center(
                          child: EmptyWidget(
                            message: TextSpan(
                              text: lang.S.of(context).addAPurchase,
                            ),
                          ),
                        );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
