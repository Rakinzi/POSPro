import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';

import '../../model/add_to_cart_model.dart';

Future<void> showAddItemPopup(
    {required BuildContext mainContext, required ProductModel productModel, required WidgetRef ref, required String? customerType, required bool fromPOSSales}) async {
  TextEditingController _searchController = TextEditingController();
  final product = productModel;
  List<SaleCartModel> tempCartItemList = [];
  List<TextEditingController> controllers = [];
  if (product.stocks?.isNotEmpty ?? false) {
    final cartList = ref.read(cartNotifier).cartItemList; // কার্টের আইটেম লিস্ট

    for (var element in product.stocks!) {
      num sentProductPrice;

      if (customerType != null) {
        if (customerType.contains('Dealer')) {
          sentProductPrice = element.productDealerPrice ?? 0;
        } else if (customerType.contains('Wholesaler')) {
          sentProductPrice = element.productWholeSalePrice ?? 0;
        } else if (customerType.contains('Supplier')) {
          sentProductPrice = element.productPurchasePrice ?? 0;
        } else {
          sentProductPrice = element.productSalePrice ?? 0;
        }
      } else {
        sentProductPrice = element.productSalePrice ?? 0;
      }

      final existingCartItem = cartList.firstWhere(
        (cartItem) => cartItem.productId == product.id && cartItem.stockId == element.id,
        orElse: () => SaleCartModel(productId: -1, batchName: '',stockId: 0), // default not-found case
      );

      final existingQuantity = existingCartItem.productId != -1 ? existingCartItem.quantity : 0;

      controllers.add(TextEditingController(text: existingQuantity.toString()));

      tempCartItemList.add(SaleCartModel(
        batchName: element.batchNo ?? '',
        productName: product.productName,
        stockId: element.id??0,
        unitPrice: sentProductPrice,
        productType: product.productType,
        productCode: product.productCode,
        productPurchasePrice: element.productPurchasePrice,
        stock: element.productStock,
        productId: product.id ?? 0,
        quantity: existingQuantity,
      ));
    }

    // for (var element in product.stocks!) {
    //   num sentProductPrice;
    //
    //   if (customerType != null) {
    //     if (customerType.contains('Dealer')) {
    //       sentProductPrice = element.productDealerPrice ?? 0;
    //     } else if (customerType.contains('Wholesaler')) {
    //       sentProductPrice = element.productWholeSalePrice ?? 0;
    //     } else if (customerType.contains('Supplier')) {
    //       sentProductPrice = element.productPurchasePrice ?? 0;
    //     } else {
    //       sentProductPrice = element.productSalePrice ?? 0;
    //     }
    //   } else {
    //     sentProductPrice = element.productSalePrice ?? 0;
    //   }
    //   controllers.add(TextEditingController(text: '0'));
    //   tempCartItemList.add(SaleCartModel(
    //     batchName: element.batchNo ?? '',
    //     productName: product.productName,
    //     stockId: element.id,
    //     unitPrice: sentProductPrice,
    //     productType: product.productType,
    //     productCode: product.productCode,
    //     productPurchasePrice: element.productPurchasePrice,
    //     stock: element.productStock,
    //     productId: product.id ?? 0,
    //     quantity: 0,
    //   ));
    // }
  }

  showDialog(
    context: mainContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        void updateQuantity(int change, int index) {
          int currentQty = int.tryParse(controllers[index].text) ?? 0;
          int updatedQty = currentQty + change;

          if (updatedQty > (tempCartItemList[index].stock ?? 0)) return;
          if (updatedQty < 0) return;
          setState(() {
            controllers[index].text = updatedQty.toString();
          });
        }

        _searchController.addListener(
          () {
            setState(() {});
          },
        );
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.productName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  SizedBox(height: 8),

                  /// Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Batch no...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  SizedBox(height: 16),

                  SingleChildScrollView(
                    child: Column(
                      children: [
                        /// Batch List
                        ...productModel.stocks!.map((item) => Visibility(
                              visible: _searchController.text.isEmpty || (item.batchNo?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? true),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      /// Batch Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Batch: ${item.batchNo}', style: TextStyle(fontWeight: FontWeight.w600)),
                                            Text('Stock: ${item.productStock}', style: TextStyle(color: Colors.green)),
                                          ],
                                        ),
                                      ),

                                      /// Price
                                      Text('\$${item.productSalePrice}', style: TextStyle(fontWeight: FontWeight.w600)),

                                      SizedBox(width: 12),

                                      /// Quantity Controller with Round Buttons
                                      Row(
                                        children: [
                                          /// - Button
                                          InkWell(
                                            onTap: () => updateQuantity(-1, productModel.stocks?.indexOf(item) ?? 0),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade200,
                                              ),
                                              child: Icon(Icons.remove, size: 16),
                                            ),
                                          ),

                                          SizedBox(width: 8),

                                          /// Quantity TextField
                                          Container(
                                            width: 60,
                                            height: 32,
                                            alignment: Alignment.center,
                                            child: TextFormField(
                                              controller: controllers[productModel.stocks?.indexOf(item) ?? 0],
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(fontSize: 14),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                final parsed = int.tryParse(val);
                                                if (parsed == null || parsed < 0 || parsed > (item.productStock ?? 0)) {
                                                  controllers[productModel.stocks?.indexOf(item) ?? 0].text = '';
                                                }
                                              },
                                            ),
                                          ),

                                          SizedBox(width: 8),

                                          /// + Button
                                          InkWell(
                                            onTap: () => updateQuantity(1, productModel.stocks?.indexOf(item) ?? 0),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade200,
                                              ),
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  /// Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        for (var element in tempCartItemList) {
                          element.quantity = num.tryParse(controllers[tempCartItemList.indexOf(element)].text) ?? 0;
                        }

                        tempCartItemList.removeWhere((element) => element.quantity <= 0);
                        for (var element in tempCartItemList) {
                          ref.read(cartNotifier).addToCartRiverPod(cartItem: element, fromEditSales: false, isVariant: true);
                        }
                        if (!fromPOSSales) Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Add to Cart', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
