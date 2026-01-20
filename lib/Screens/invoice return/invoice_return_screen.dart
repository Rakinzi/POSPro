import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/Screens/invoice%20return/repo/invoice_return_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';

class InvoiceReturnScreen extends StatefulWidget {
  const InvoiceReturnScreen({super.key, this.saleTransactionModel, this.purchaseTransaction});

  final SalesTransactionModel? saleTransactionModel;
  final PurchaseTransaction? purchaseTransaction;

  @override
  State<InvoiceReturnScreen> createState() => _InvoiceReturnScreenState();
}

class _InvoiceReturnScreenState extends State<InvoiceReturnScreen> {
  num calculateDiscountForEachProduct({
    required num totalDiscount,
    required num productPrice,
    required num totalPrice,
    required num quantity,
  }) {
    debugPrint(totalPrice.toString());
    num thisProductDiscount = (totalDiscount * (productPrice * quantity)) / totalPrice;
    // Return the discount per unit of the product
    return productPrice - (thisProductDiscount / quantity);
  }

  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  num getTotalReturnAmount() {
    num returnAmount = 0;
    for (var element in returnList) {
      if (element.quantity > 0) {
        returnAmount += element.quantity * (num.tryParse(element.unitPrice.toString()) ?? 0);
      }
    }
    return returnAmount;
  }

  num getOriginalSalesQuantity({required num detailsId}) {
    return widget.saleTransactionModel?.salesDetails
            ?.where(
              (element) => element.id == detailsId,
            )
            .first
            .quantities ??
        0;
  }

  List<SaleCartModel> returnList = [];
  List<TextEditingController> controllers = [];
  List<FocusNode> focus = [];

  @override
  void initState() {
    super.initState();

    if (widget.saleTransactionModel != null && widget.saleTransactionModel?.salesDetails != null) {
      for (var element in widget.saleTransactionModel!.salesDetails!) {
        SaleCartModel cartItem = SaleCartModel(
          productName: element.product?.productName,
          batchName: element.stock?.batchNo ?? '',
          stockId: element.stock?.id??0,
          unitPrice: calculateDiscountForEachProduct(
            productPrice: (element.price ?? 0),
            quantity: (element.quantities ?? 0),
            totalDiscount: (widget.saleTransactionModel?.discountAmount ?? 0) - (widget.saleTransactionModel?.roundingAmount ?? 0),
            totalPrice: ((widget.saleTransactionModel?.totalAmount ?? 0) + (widget.saleTransactionModel?.discountAmount ?? 0)) -
                ((widget.saleTransactionModel?.vatAmount ?? 0) + (widget.saleTransactionModel?.shippingCharge ?? 0)),
          ),
          productId: element.id ?? 0,
          quantity: 0,
          productCode: element.product?.id.toString(),
          stock: element.quantities ?? 0,
          lossProfit: element.lossProfit,
        );

        returnList.add(cartItem);
        controllers.add(TextEditingController());
        focus.add(FocusNode());
      }
    }
    if (widget.purchaseTransaction != null && widget.purchaseTransaction?.details != null) {
      for (var element in widget.purchaseTransaction!.details!) {
        SaleCartModel cartItem = SaleCartModel(
          batchName: element.stock?.batchNo ?? '',
          productName: element.product?.productName,
          stockId: element.stock?.id??0,
          unitPrice: calculateDiscountForEachProduct(
            productPrice: (element.productPurchasePrice ?? 0),
            quantity: (element.quantities ?? 0),
            totalDiscount: (widget.purchaseTransaction?.discountAmount ?? 0),
            totalPrice: ((widget.purchaseTransaction?.totalAmount ?? 0) + (widget.purchaseTransaction?.discountAmount ?? 0)) -
                ((widget.purchaseTransaction?.vatAmount ?? 0) + (widget.purchaseTransaction?.shippingCharge ?? 0)),
          ),
          productId: element.id ?? 0,
          quantity: 0,
          productCode: element.product?.id.toString(),
          stock: element.quantities ?? 0,
        );

        returnList.add(cartItem);
        controllers.add(TextEditingController());
        focus.add(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Consumer(builder: (context, consumerRef, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.saleTransactionModel != null ? 'Sales Return' : "Purchase Return",
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: widget.saleTransactionModel != null ? widget.saleTransactionModel!.invoiceNumber : widget.purchaseTransaction!.invoiceNumber,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Invoice No',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: DateFormat.yMMMd().format(DateTime.parse(
                            widget.saleTransactionModel != null ? widget.saleTransactionModel!.saleDate! : widget.purchaseTransaction!.purchaseDate!,
                          )),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).date,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    readOnly: true,
                    initialValue: widget.saleTransactionModel != null ? widget.saleTransactionModel!.party?.name : widget.purchaseTransaction!.user?.name,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).customerName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///_______Added_ItemS__________________________________________________
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: _theme.colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 0.08),
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xffFEF0F1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: context.width() / 1.35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).itemAdded,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    lang.S.of(context).quantity,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: returnList.length,
                            itemBuilder: (context, index) {
                              focus[index].addListener(() {
                                if (!focus[index].hasFocus) {
                                  setState(() {});
                                }
                              });
                              num currentQuantity = returnList[index].quantity;
                              return Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: ListTile(
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          returnList[index].productName.toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      const Text('Return QTY'),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${formatPointNumber((returnList[index].stock ?? 0) - (returnList[index].quantity))} X ${formatPointNumber(returnList[index].unitPrice ?? 0)} = ${double.tryParse((double.parse(returnList[index].unitPrice.toString()) * ((returnList[index].stock ?? 0) - currentQuantity)).toStringAsFixed(2)) ?? 0}',
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  returnList[index].quantity > 0
                                                      ? {returnList[index].quantity < 1 ? returnList[index].quantity = 0 : returnList[index].quantity--}
                                                      : returnList[index].quantity = 0;
                                                  controllers[index].text = returnList[index].quantity.toString();
                                                });
                                              },
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: const BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.remove, size: 14, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: 50,
                                              child: TextFormField(
                                                onTap: () {
                                                  controllers[index].clear();
                                                },
                                                focusNode: focus[index],
                                                controller: controllers[index],
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                onChanged: (value) {
                                                  num stock = returnList[index].stock ?? 1;
                                                  if (value.isEmpty || value == '0') {
                                                    value = '1';
                                                  } else if (num.tryParse(value) == null) {
                                                    return;
                                                  } else {
                                                    final newQuantity = num.parse(value);
                                                    if (newQuantity <= stock) {
                                                      returnList[index].quantity = newQuantity;
                                                    } else {
                                                      controllers[index].text = '1';
                                                      EasyLoading.showError(
                                                        lang.S.of(context).outOfStock,
                                                        // 'Out Of Stock'
                                                      );
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: focus[index].hasFocus ? null : returnList[index].quantity.toString(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () {
                                                if (returnList[index].quantity < (returnList[index].stock ?? 0)) {
                                                  setState(() {
                                                    if ((returnList[index].quantity.toInt() == (returnList[index].stock?.toInt() ?? 0)) &&
                                                        (returnList[index].quantity.toInt() < (returnList[index].stock ?? 0))) {
                                                      returnList[index].quantity = returnList[index].stock ?? 0;
                                                    } else {
                                                      returnList[index].quantity += 1;
                                                    }
                                                    controllers[index].text = returnList[index].quantity.toString();
                                                  });
                                                } else {
                                                  EasyLoading.showError('Out of Stock');
                                                }
                                              },
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: const BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.add, size: 14, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ).visible(returnList.isNotEmpty),
                  ),
                  const SizedBox(height: 20),

                  ///______________________Total_Return____________________________________
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 0.08),
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                          blurRadius: 24,
                        ),
                      ],
                      color: _theme.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Total return amount:',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              '$currency ${getTotalReturnAmount().toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Non Refundable(VAT/Discount):',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              widget.saleTransactionModel != null
                                  ? '$currency ${((widget.saleTransactionModel?.vatAmount ?? 0) + (widget.saleTransactionModel?.shippingCharge ?? 0)).toStringAsFixed(2)}'
                                  : '$currency ${((widget.purchaseTransaction?.vatAmount ?? 0) + (widget.purchaseTransaction?.shippingCharge ?? 0)).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      maximumSize: const Size(double.infinity, 48),
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                      lang.S.of(context).cancel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      maximumSize: const Size(double.infinity, 48),
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                    onPressed: widget.saleTransactionModel != null
                        ? () async {
                            EasyLoading.show();
                            returnList.removeWhere(
                              (element) => element.quantity < 0.01,
                            );
                            if (returnList.isNotEmpty) {
                              num totalDiscountReturn = 0;
                              ReturnDataModel? data = ReturnDataModel(
                                saleId: widget.saleTransactionModel!.id!,
                                returnDate: DateTime.now().toString(),
                                saleDetailId: [],
                                returnAmount: [],
                                returnQty: [],
                                lossProfit: [],
                                dueAmount: (widget.saleTransactionModel!.dueAmount ?? 0) < getTotalReturnAmount()
                                    ? 0
                                    : (widget.saleTransactionModel!.dueAmount ?? 0) - getTotalReturnAmount(),
                                paidAmount: widget.saleTransactionModel!.paidAmount ?? 0,
                                totalAmount: (widget.saleTransactionModel!.totalAmount ?? 0) - getTotalReturnAmount(),
                                discountAmount: widget.saleTransactionModel?.discountAmount ?? 0,
                              );
                              for (var items in returnList) {
                                final SalesDetails salesProduct =
                                    widget.saleTransactionModel!.salesDetails![widget.saleTransactionModel!.salesDetails!.indexWhere((element) => element.id == items.productId)];
                                totalDiscountReturn += ((salesProduct.price ?? 0) - (items.unitPrice ?? 0)) * items.quantity;
                                data.saleDetailId.add(items.productId);
                                data.returnAmount.add(items.quantity * (items.unitPrice ?? 0));
                                data.returnQty.add(items.quantity);
                                data.lossProfit.add((items.lossProfit! / items.stock!) * ((getOriginalSalesQuantity(detailsId: items.productId)) - items.quantity));
                              }
                              data.discountAmount = data.discountAmount - totalDiscountReturn;
                              debugPrint('Return Data ${data.toJson()}');
                              InvoiceReturnRepo repo = InvoiceReturnRepo();
                              final bool? result = await repo.createSalesReturn(ref: consumerRef, context: context, salesReturn: data);
                              if (!context.mounted) return;
                              if (result ?? false) {
                                // SalesInvoiceDetails(
                                //   businessInfo: consumerRef.watch(businessInfoProvider).value!,
                                //   saleTransaction: consumerRef.watch(salesD),
                                //   fromSale: true,
                                // ).launch(context);
                                Navigator.pop(context);
                              }
                            } else {
                              EasyLoading.showError('Please select product for return');
                            }
                          }
                        : () async {
                            EasyLoading.show();
                            returnList.removeWhere((element) => element.quantity < 1);
                            if (returnList.isNotEmpty) {
                              num totalDiscountReturn = 0;
                              ReturnDataModel? data = ReturnDataModel(
                                saleId: widget.purchaseTransaction!.id!,
                                returnDate: DateTime.now().toString(),
                                saleDetailId: [],
                                returnAmount: [],
                                returnQty: [],
                                lossProfit: [],
                                dueAmount: (widget.purchaseTransaction!.dueAmount ?? 0) < getTotalReturnAmount()
                                    ? 0
                                    : (widget.purchaseTransaction!.dueAmount ?? 0) - getTotalReturnAmount(),
                                paidAmount: widget.purchaseTransaction!.paidAmount ?? 0,
                                totalAmount: (widget.purchaseTransaction!.totalAmount ?? 0) - getTotalReturnAmount(),
                                discountAmount: widget.purchaseTransaction!.discountAmount ?? 0,
                              );
                              for (var items in returnList) {
                                final PurchaseDetails purchaseProduct =
                                    widget.purchaseTransaction!.details![widget.purchaseTransaction!.details!.indexWhere((element) => element.id == items.productId)];
                                totalDiscountReturn += ((purchaseProduct.productPurchasePrice ?? 0) - (items.unitPrice ?? 0)) * items.quantity;
                                data.saleDetailId.add(items.productId);
                                data.returnAmount.add(items.quantity * (items.unitPrice ?? 0));
                                data.returnQty.add(items.quantity);
                              }
                              data.discountAmount = data.discountAmount - totalDiscountReturn;
                              InvoiceReturnRepo repo = InvoiceReturnRepo();

                              final bool? result = await repo.createPurchaseReturn(ref: consumerRef, context: context, returnData: data);
                              if (!context.mounted) return;
                              if (result ?? false) {
                                Navigator.pop(context);
                              }
                            } else {
                              EasyLoading.showError('Please select product for return');
                            }
                          },
                    child: Text(
                      'Confirm return',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.primaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
}
