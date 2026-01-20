import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/sale_transaction_model.dart';

class SingleLossProfitScreen extends StatefulWidget {
  const SingleLossProfitScreen({
    super.key,
    required this.transactionModel,
  });

  final SalesTransactionModel transactionModel;

  @override
  State<SingleLossProfitScreen> createState() => _SingleLossProfitScreenState();
}

class _SingleLossProfitScreenState extends State<SingleLossProfitScreen> {
  double getTotalProfit() {
    double totalProfit = 0;
    for (var element in widget.transactionModel.salesDetails!) {
      if (!element.lossProfit!.isNegative) {
        totalProfit = totalProfit + element.lossProfit!;
      }
    }

    return totalProfit;
  }

  double getTotalLoss() {
    double totalLoss = 0;
    for (var element in widget.transactionModel.salesDetails!) {
      if (element.lossProfit!.isNegative) {
        totalLoss = totalLoss + element.lossProfit!.abs();
      }
    }

    return totalLoss;
  }

  num getTotalQuantity() {
    num total = 0;
    for (var element in widget.transactionModel.salesDetails!) {
      total += element.quantities ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            lang.S.of(context).lpDetails,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${lang.S.of(context).invoice} #${widget.transactionModel.invoiceNumber}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Text(
                      widget.transactionModel.party?.name ?? '',
                      maxLines: 2,
                    )),
                    Text(
                      "${lang.S.of(context).dates} ${DateFormat.yMMMd().format(
                        DateTime.parse(widget.transactionModel.saleDate ?? ''),
                      )}",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${lang.S.of(context).mobile}${widget.transactionModel.party?.phone ?? ''}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      DateFormat.jm().format(DateTime.parse(widget.transactionModel.saleDate ?? '')),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: kMainColor.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).product,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).quantity,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).profit,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        lang.S.of(context).loss,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    itemCount: widget.transactionModel.salesDetails!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${widget.transactionModel.salesDetails?[index].product?.productName.toString() ?? ''}${widget.transactionModel.salesDetails?[index].product?.productType == ProductType.variant.name ? ' [${widget.transactionModel.salesDetails?[index].stock?.batchNo}]' : ''}',
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  widget.transactionModel.salesDetails?[index].quantities.toString() ?? '',
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    !(widget.transactionModel.salesDetails?[index].lossProfit?.isNegative ?? false)
                                        ? "$currency${widget.transactionModel.salesDetails?[index].lossProfit!.abs().toString()}"
                                        : '0',
                                  ),
                                )),
                            Expanded(
                              child: Center(
                                child: Text(
                                  (widget.transactionModel.salesDetails?[index].lossProfit?.isNegative ?? false)
                                      ? "$currency${widget.transactionModel.salesDetails?[index].lossProfit!.abs().toString()}"
                                      : '0',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: kMainColor.withValues(alpha: 0.2), border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              lang.S.of(context).total,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              formatPointNumber(getTotalQuantity()),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "$currency${getTotalProfit()}",
                              )),
                          Text(
                            "$currency${getTotalLoss()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: kMainColor.withValues(alpha: 0.2), border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              lang.S.of(context).discount,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            "$currency${widget.transactionModel.discountAmount ?? 0}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kMainColor.withValues(alpha: 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              widget.transactionModel.detailsSumLossProfit!.isNegative ? lang.S.of(context).totalLoss : lang.S.of(context).totalProfit,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            widget.transactionModel.detailsSumLossProfit!.isNegative
                                ? "$currency${widget.transactionModel.detailsSumLossProfit!.toInt().abs()}"
                                : "$currency${widget.transactionModel.detailsSumLossProfit!.toInt()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
