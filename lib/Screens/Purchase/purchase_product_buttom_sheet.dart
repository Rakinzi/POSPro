import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../Provider/add_to_cart_purchase.dart';
import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../Products/Repo/product_repo.dart';
import 'Repo/purchase_repo.dart';

Future<void> addProductInPurchaseCartButtomSheet(
    {required BuildContext context, required CartProductModelPurchase product, required WidgetRef ref, required bool fromUpdate, required int index, required bool fromStock}) {
  int counter = 0;
  final theme = Theme.of(context);
  final TextEditingController productStockController = TextEditingController(text: product.quantities.toString());
  final TextEditingController salePriceController = TextEditingController(text: '${product.productSalePrice}');
  final TextEditingController purchaseExclusivePriceController =
      TextEditingController(text: product.vatType == 'exclusive' ? '${product.productPurchasePrice}' : '${((product.productPurchasePrice ?? 0) / (1 + product.vatRate / 100))}');
  final TextEditingController profitMarginController = TextEditingController(text: '${product.profitPercent}');
  final TextEditingController purchaseInclusivePriceController = TextEditingController();
  final TextEditingController wholeSalePriceController = TextEditingController(text: '${product.productWholeSalePrice}');
  final TextEditingController dealerPriceController = TextEditingController(text: '${product.productDealerPrice}');
  final TextEditingController expireDateController = TextEditingController(text: product.expireDate ?? '');
  final TextEditingController manufactureDateController = TextEditingController(text: product.mfgDate ?? '');
  final TextEditingController productBatchNumberController = TextEditingController(text: product.batchNumber ?? '');

  final decimalInputFormatter = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];

  void calculatePurchaseAndMrp({String? from, required Function setState}) {
    num purchaseExc = 0;
    num purchaseInc = 0;
    num profitMargin = num.tryParse(profitMarginController.text) ?? 0;
    num salePrice = 0;

    if (from == 'purchase_inc') {
      purchaseExc = (num.tryParse(purchaseInclusivePriceController.text) ?? 0) / (1 + product.vatRate / 100);
      purchaseExclusivePriceController.text = purchaseExc.toStringAsFixed(2);
    } else {
      purchaseExc = num.tryParse(purchaseExclusivePriceController.text) ?? 0;
      purchaseInc = purchaseExc + (purchaseExc * product.vatRate / 100);
      purchaseInclusivePriceController.text = purchaseInc.toStringAsFixed(2);
    }

    purchaseInc = num.tryParse(purchaseInclusivePriceController.text) ?? 0;

    if (from == 'mrp') {
      salePrice = num.tryParse(salePriceController.text) ?? 0;
      profitMargin =
          ((salePrice - (product.vatType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) / (product.vatType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) *
              100;
      profitMarginController.text = profitMargin.toStringAsFixed(2);
    } else {
      salePrice = (product.vatType.toLowerCase() == 'exclusive') ? purchaseExc + (purchaseExc * profitMargin / 100) : purchaseInc + (purchaseInc * profitMargin / 100);
      salePriceController.text = salePrice.toStringAsFixed(2);
    }

    setState();
  }

  final _formKey = GlobalKey<FormState>();

  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        if (counter == 0) {
          counter++;
          calculatePurchaseAndMrp(setState: () {});
        }
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Variant Details', style: theme.textTheme.titleMedium),
                        IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                      ],
                    ),
                    Divider(color: kBorderColor),
                    const SizedBox(height: 12),
                    Row(
                      spacing: 12,
                      children: [
                        if (product.productType == ProductType.variant.name)
                          Expanded(
                            child: TextFormField(
                              controller: productBatchNumberController,
                              decoration: kInputDecoration.copyWith(
                                labelText: 'Batch No.',
                                hintText: 'Enter Batch No.',
                              ),
                            ),
                          ),
                        Expanded(
                          child: TextFormField(
                            controller: productStockController,
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: lang.S.of(context).quantity,
                              hintText: lang.S.of(context).enterQuantity,
                            ),
                            validator: (value) {
                              if ((num.tryParse(value ?? '') ?? 0) <= 0) {
                                return 'Purchase quantity required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: purchaseExclusivePriceController,
                            onChanged: (value) => calculatePurchaseAndMrp(setState: setState),
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Purchase Price Ex.',
                              hintText: lang.S.of(context).enterPurchasePrice,
                            ),
                            validator: (value) {
                              if ((num.tryParse(value ?? '') ?? 0) <= 0) {
                                return 'Purchase price Ex. required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: purchaseInclusivePriceController,
                            onChanged: (value) => calculatePurchaseAndMrp(from: "purchase_inc", setState: setState),
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Purchase Price Inc.',
                              hintText: lang.S.of(context).enterSaltingPrice,
                            ),
                            validator: (value) {
                              if ((num.tryParse(value ?? '') ?? 0) <= 0) {
                                return 'Purchase price Inc. required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: profitMarginController,
                            onChanged: (value) => calculatePurchaseAndMrp(setState: setState),
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Profit Margin (%)',
                              hintText: lang.S.of(context).enterPurchasePrice,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: salePriceController,
                            onChanged: (value) => calculatePurchaseAndMrp(from: 'mrp', setState: setState),
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: lang.S.of(context).mrp,
                              hintText: lang.S.of(context).enterSaltingPrice,
                            ),
                            validator: (value) {
                              if ((num.tryParse(value ?? '') ?? 0) <= 0) {
                                return 'Sales price required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: wholeSalePriceController,
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: lang.S.of(context).wholeSalePrice,
                              hintText: lang.S.of(context).enterWholesalePrice,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: dealerPriceController,
                            inputFormatters: decimalInputFormatter,
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              labelText: lang.S.of(context).dealerPrice,
                              hintText: lang.S.of(context).enterDealerPrice,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: manufactureDateController,
                            readOnly: true,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Manufacture Date',
                              hintText: 'Select Date',
                              suffixIcon: IconButton(
                                icon: Icon(IconlyLight.calendar),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2015),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      manufactureDateController.text = DateFormat.yMd().format(picked);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: expireDateController,
                            readOnly: true,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Exp. Date',
                              hintText: 'Select Date',
                              suffixIcon: IconButton(
                                icon: Icon(IconlyLight.calendar),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2015),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      expireDateController.text = DateFormat.yMd().format(picked);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: Color(0xffF68A3D)))),
                            child: Text('Cancel', style: TextStyle(color: Color(0xffF68A3D))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final cartProduct = CartProductModelPurchase(
                                    productId: product.productId,
                                    stockId: product.stockId,
                                    brandName: product.brandName,
                                    productName: product.productName,
                                    productType: product.productType,
                                    vatAmount: product.vatAmount,
                                    vatRate: product.vatRate,
                                    vatType: product.vatType,
                                    batchNumber: productBatchNumberController.text,
                                    productDealerPrice: num.tryParse(dealerPriceController.text),
                                    productPurchasePrice:
                                        num.tryParse(product.vatType == 'exclusive' ? purchaseExclusivePriceController.text : purchaseInclusivePriceController.text),
                                    productSalePrice: num.tryParse(salePriceController.text),
                                    productWholeSalePrice: num.tryParse(wholeSalePriceController.text),
                                    quantities: num.tryParse(productStockController.text),
                                    stock: product.stock,
                                    expireDate: dateFormateChange(date: expireDateController.text),
                                    mfgDate: dateFormateChange(date: manufactureDateController.text),
                                    profitPercent: num.tryParse(profitMarginController.text));

                                if (fromStock) {
                                  debugPrint('------------------------stock');
                                  ProductRepo productRepo = ProductRepo();
                                  bool success = await productRepo.updateVariation(data: cartProduct);
                                  if (success) {
                                    ref.invalidate(productProvider);
                                    ref.invalidate(fetchProductDetails(product.productId.toString()));
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  }
                                } else if (fromUpdate) {
                                  ref.watch(cartNotifierPurchaseNew).updateProduct(index: index, newProduct: cartProduct);
                                  Navigator.pop(context);
                                } else {
                                  ref.watch(cartNotifierPurchaseNew).addToCartRiverPod(cartItem: cartProduct, isVariation: product.productType == ProductType.variant.name);
                                  int count = 0;
                                  Navigator.popUntil(context, (route) {
                                    return count++ == 2;
                                  });
                                }
                                // Navigator.pop(context);
                              }
                            },
                            child: Text('Save Variant'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// String dateFormateChange({required String? date}) {
//   if (date == null || date == '') return '';
//   DateTime parsedDate = DateFormat("M/d/yyyy").parse(date);
//   return DateFormat("yyyy-MM-dd").format(parsedDate);
// }
String dateFormateChange({required String? date}) {
  if (date == null || date.trim().isEmpty) return '';

  try {
    DateTime parsed;
    if (date.contains('-')) {
      parsed = DateTime.parse(date);
    } else {
      parsed = DateFormat("M/d/yyyy").parse(date);
    }

    return DateFormat("yyyy-MM-dd").format(parsed);
  } catch (e) {
    debugPrint('Failed to format date: $date → $e');
    return '';
  }
}
