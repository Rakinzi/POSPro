import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart' as main_constant;
import '../../invoice_constant.dart';
import '../../model/business_info_model.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../Due Calculation/Model/due_collection_model.dart';

class DueInvoiceDetails extends StatefulWidget {
  const DueInvoiceDetails({super.key, required this.dueCollection, required this.personalInformationModel, this.isFromDue});

  final DueCollection dueCollection;
  final BusinessInformationModel personalInformationModel;
  final bool? isFromDue;

  @override
  State<DueInvoiceDetails> createState() => _DueInvoiceDetailsState();
}

class _DueInvoiceDetailsState extends State<DueInvoiceDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);
    return Consumer(builder: (context, ref, __) {
      final printerData = ref.watch(thermalPrinterProvider);
      final businessSettingData = ref.watch(businessSettingProvider);
      return GlobalPopup(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4),
                      leading: businessSettingData.when(
                        data: (business) {
                          final isSvg = business.pictureUrl?.endsWith('.svg');
                          final imageUrl = '${APIConfig.domain}${business.pictureUrl}';
                          const placeholder = AssetImage(main_constant.logo);
                          return business.pictureUrl.isEmptyOrNull
                              ? _buildInvoiceLogo(image: placeholder)
                              : (isSvg ?? false)
                                  ? SvgPicture.network(imageUrl, height: 54.12, width: 52, fit: BoxFit.cover)
                                  : _buildInvoiceLogo(
                                      image: NetworkImage(imageUrl),
                                    );
                        },
                        error: (e, stack) => Text(e.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      title: Text(
                        '${widget.personalInformationModel.companyName}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          text: '${_lang.mobiles} : ',
                          children: [
                            TextSpan(
                              text: '${widget.personalInformationModel.phoneNumber}',
                            )
                          ],
                        ),
                      ),
                      trailing: Container(
                        alignment: Alignment.center,
                        height: 52,
                        width: 110,
                        // padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                        ),
                        child: Text(
                          _lang.moneyReceipt,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // ListTile(
                    //   contentPadding: EdgeInsets.zero,
                    //   title: Text(
                    //     '${widget.personalInformationModel.companyName}',
                    //     style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                    //   ),
                    //   subtitle: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         widget.personalInformationModel.address.toString(),
                    //         style: kTextStyle.copyWith(
                    //           color: kGreyTextColor,
                    //         ),
                    //       ),
                    //       Text(
                    //         widget.personalInformationModel.phoneNumber.toString(),
                    //         style: kTextStyle.copyWith(
                    //           color: kGreyTextColor,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   isThreeLine: true,
                    // ),
                    const SizedBox(height: 10.0),

                    ///-----------------header data----------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '${lang.S.of(context).billTO} : ',
                                  children: [
                                    TextSpan(
                                      text: widget.dueCollection.party?.name ?? '',
                                    )
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '${_lang.mobiles} : ',
                                  children: [
                                    TextSpan(
                                      text: widget.dueCollection.party?.phone ?? '',
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '${_lang.receipt} : ',
                                  children: [
                                    TextSpan(
                                      text: '#${widget.dueCollection.invoiceNumber}',
                                    )
                                  ],
                                ),
                                textAlign: TextAlign.end,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '${lang.S.of(context).date} : ',
                                  children: [
                                    TextSpan(
                                      text: DateFormat.yMMMd().format(DateTime.parse(widget.dueCollection.paymentDate ?? '')),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.end,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '${_lang.collectedBys} : ',
                                  children: [
                                    TextSpan(
                                      text: widget.dueCollection.user?.role == "shop-owner" ? 'Admin' : widget.dueCollection.user?.name ?? '',
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.end,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '${widget.personalInformationModel.vatName ?? 'VAT Number'} : ',
                                  children: [
                                    TextSpan(
                                      text: widget.personalInformationModel.vatNumber ?? '',
                                    )
                                  ],
                                ),
                                textAlign: TextAlign.end,
                              ).visible(widget.personalInformationModel.vatNumber != null),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30.0),
                    //Product data
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        defaultColumnWidth: const FixedColumnWidth(150),
                        border: const TableBorder(
                          verticalInside: BorderSide(
                            color: Color(0xffD9D9D9),
                          ),
                          left: BorderSide(
                            color: Color(0xffD9D9D9),
                          ),
                          right: BorderSide(
                            color: Color(0xffD9D9D9),
                          ),
                          bottom: BorderSide(
                            color: Color(0xffD9D9D9),
                          ),
                        ),
                        children: [
                          TableRow(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffC52127), // Red background
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _lang.sl,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                color: const Color(0xffC52127), // Red background
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _lang.totalDue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                color: const Color(0xff000000), // Black background
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _lang.paymentsAmount,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                color: const Color(0xff000000), // Black background
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _lang.remainingDue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('1', textAlign: TextAlign.left),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "$currency${widget.dueCollection.totalDue?.toStringAsFixed(2)}",
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "$currency${(widget.dueCollection.totalDue!.toDouble() - widget.dueCollection.dueAmountAfterPay!).toStringAsFixed(2)}",
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "$currency${widget.dueCollection.dueAmountAfterPay?.toStringAsFixed(2)}",
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            "${_lang.paidVia}: ${widget.dueCollection.paymentType?.name ?? 'N/A'}",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // const Spacer(),
                        Text(
                          "${_lang.payableAmount}: $currency ${widget.dueCollection.totalDue?.toStringAsFixed(2) ?? '0.00'}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${_lang.receivedAmount}: $currency ${(widget.dueCollection.totalDue!.toDouble() - widget.dueCollection.dueAmountAfterPay!.toDouble()).toStringAsFixed(2)}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${_lang.dueAmount} $currency ${widget.dueCollection.dueAmountAfterPay?.toStringAsFixed(2) ?? '0.00'}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        widget.personalInformationModel.postSaleMassage ?? '',
                        maxLines: 3,
                        style: theme.textTheme.titleMedium?.copyWith(color: kTitleColor, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.isFromDue ?? false) {
                        int count = 0;
                        Navigator.popUntil(context, (route) {
                          return count++ == 2;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      height: 60,
                      width: context.width() / 3,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          lang.S.of(context).cancel,
                          // 'Cancel',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () async {
                      PrintDueTransactionModel model =
                          PrintDueTransactionModel(dueTransactionModel: widget.dueCollection, personalInformationModel: widget.personalInformationModel);
                      await printerData.printDueThermalInvoiceNow(invoiceSize: widget.personalInformationModel.invoiceSize, transaction: model, context: context);
                    },
                    child: Container(
                      height: 60,
                      width: context.width() / 3,
                      decoration: const BoxDecoration(
                        color: main_constant.kMainColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          lang.S.of(context).print,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInvoiceLogo({required ImageProvider image}) {
    return Container(
      height: 54.12,
      width: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: image,
        ),
      ),
    );
  }
}
