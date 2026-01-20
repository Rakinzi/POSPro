import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/add_to_cart_model.dart';

import '../../constant.dart';

class SalesAddToCartForm extends StatefulWidget {
  const SalesAddToCartForm({super.key, required this.batchWiseStockModel, required this.previousContext});

  final SaleCartModel batchWiseStockModel;
  final BuildContext previousContext;

  @override
  ProductAddToCartFormState createState() => ProductAddToCartFormState();
}

class ProductAddToCartFormState extends State<SalesAddToCartForm> {
  GlobalKey<FormState> key = GlobalKey();

  bool isUpdating = false;
  String? selectedDate;
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();

  @override
  void initState() {
    salePriceController.text = widget.batchWiseStockModel.unitPrice.toString();
    productQuantityController.text = formatPointNumber(widget.batchWiseStockModel.quantity);

    super.initState();
  }

  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final lang = l.S.of(context);

      return Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock quantity
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: productQuantityController,
                    validator: (value) {
                      if (value == null || value.isEmpty || (num.tryParse(value) ?? 0) <= 0) {
                        return l.S.of(context).enterQuantity;
                      } else if (((num.tryParse(value) ?? 0)) > (widget.batchWiseStockModel.stock ?? 0)) {
                        return lang.outOfStock;
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(l.S.of(context).quantity),
                      hintText: l.S.of(context).enterQuantity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: salePriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return lang.pleaseEnterAValidSalePrice;
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(lang.salePrice),
                      hintText: lang.enterAmount,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 29),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GestureDetector(
                onTap: () async {
                  if (isClicked) {
                    return;
                  }
                  if (!(key.currentState?.validate() ?? false)) {
                    return;
                  }

                  isClicked = true;

                  ref.watch(cartNotifier).updateProduct(productId: widget.batchWiseStockModel.productId, price: salePriceController.text, qty: productQuantityController.text);

                  Navigator.pop(context);
                },
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      l.S.of(context).save,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
