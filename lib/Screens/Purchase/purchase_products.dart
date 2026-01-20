import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/Screens/Purchase/Repo/purchase_repo.dart';
import 'package:mobile_pos/Screens/Purchase/purchase_product_buttom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../core/theme/_app_colors.dart';
import '../../widgets/empty_widget/_empty_widget.dart';

class PurchaseProducts extends StatefulWidget {
  const PurchaseProducts({super.key, this.customerModel});

  final Party? customerModel;

  @override
  State<PurchaseProducts> createState() => _PurchaseProductsState();
}

class _PurchaseProductsState extends State<PurchaseProducts> {
  String productCode = '0000';
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final _theme = Theme.of(context);
      final productList = ref.watch(productProvider);
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).productList,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: codeController,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            setState(() {
                              productCode = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).productCode,
                            hintText: productCode == '0000' || productCode == '-1' ? 'Scan product QR code' : productCode,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) => BarcodeScannerWidget(
                                onBarcodeFound: (String code) {
                                  setState(() {
                                    productCode = code;
                                    codeController.text = productCode;
                                  });
                                },
                              ),
                            );
                          },
                          child: const BarCodeButton(),
                        ),
                      ),
                    ],
                  ),
                ),
                productList.when(data: (products) {
                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        return Visibility(
                          visible: ((products[i].productCode == productCode || productCode == '0000' || productCode == '-1')) ||
                              products[i].productName!.toLowerCase().contains(productCode.toLowerCase()),
                          child: ListTile(
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            leading: products[i].productPicture == null
                                ? CircleAvatarWidget(
                                    name: products[i].productName,
                                    size: const Size(50, 50),
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${APIConfig.domain}${products[i].productPicture!}',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    products[i].productName.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lang.S.of(context).stock,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    products[i].brand?.brandName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: DAppColors.kSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  products[i].productStockSum.toString(),
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: DAppColors.kSecondary,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              final stock = products[i].stocks?.first;

                              final cartProduct = CartProductModelPurchase(
                                productId: products[i].id ?? 0,
                                brandName: products[i].brand?.brandName ?? '',
                                productName: products[i].productName ?? '',
                                productDealerPrice: stock?.productDealerPrice,
                                productPurchasePrice: stock?.productPurchasePrice,
                                productSalePrice: stock?.productSalePrice,
                                productWholeSalePrice: stock?.productWholeSalePrice,
                                quantities: 1,
                                productType: products[i].productType ?? ProductType.single.name,
                                vatAmount: products[i].vatAmount ?? 0,
                                vatRate: products[i].vat?.rate ?? 0,
                                vatType: products[i].vatType ?? 'exclusive',
                                expireDate: '',
                                mfgDate: '',
                                profitPercent: stock?.profitPercent ?? 0,
                                stock: products[i].productStockSum,
                              );
                              addProductInPurchaseCartButtomSheet(context: context, product: cartProduct, ref: ref, fromUpdate: false, index: 0, fromStock: false);
                              // showDialog(
                              //     context: context,
                              //     builder: (_) {
                              // final cartProduct = CartProductModelPurchase(
                              //   productId: products[i].id ?? 0,
                              //   brandName: products[i].brand?.brandName ?? '',
                              //   productName: products[i].productName ?? '',
                              //   productDealerPrice: products[i].productDealerPrice,
                              //   productPurchasePrice: products[i].productPurchasePrice,
                              //   productSalePrice: products[i].productSalePrice,
                              //   productWholeSalePrice: products[i].productWholeSalePrice,
                              //   quantities: 1,
                              //   stock: products[i].productStockSum,
                              // );
                              //
                              //       return purchaseProductAddBottomSheet(context: context, product: cartProduct, ref: ref, fromUpdate: false);
                              //     });
                            },
                          ),
                        );
                      });
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard({super.key, required this.productTitle, required this.productDescription, required this.stock, required this.productImage});

  // final Product product;
  String productTitle, productDescription, stock;
  String? productImage;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: 50,
                width: 50,
                decoration: widget.productImage == null
                    ? BoxDecoration(
                        image: DecorationImage(image: AssetImage(noProductImageUrl), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(90.0),
                      )
                    : BoxDecoration(
                        image: DecorationImage(image: NetworkImage("${APIConfig.domain}${widget.productImage}"), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(90.0),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.productTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Text(
                    widget.productDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lang.S.of(context).stock,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.stock,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: kGreyTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// AlertDialog purchaseProductAddBottomSheet({required BuildContext context, required CartProductModelPurchase product, required WidgetRef ref, required bool fromUpdate}) {
//   CartProductModelPurchase tempProduct = CartProductModelPurchase(
//     productDealerPrice: product.productDealerPrice,
//     productId: product.productId,
//     quantities: product.quantities,
//     brandName: product.brandName,
//     stock: product.stock,
//     productName: product.productName,
//     productPurchasePrice: product.productPurchasePrice,
//     productSalePrice: product.productSalePrice,
//     productWholeSalePrice: product.productWholeSalePrice,
//   );
//   return AlertDialog(
//       content: SizedBox(
//     child: SingleChildScrollView(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   lang.S.of(context).addItems,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Icon(
//                       Icons.cancel,
//                       color: kMainColor,
//                     )),
//               ],
//             ),
//           ),
//           Container(
//             height: 1,
//             width: double.infinity,
//             color: Colors.grey,
//           ),
//           const SizedBox(height: 10),
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: Text(
//                     product.productName.toString(),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   lang.S.of(context).stock,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//             subtitle: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: Text(
//                     product.brandName ?? '',
//                     maxLines: 1,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       overflow: TextOverflow.ellipsis,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   product.stock.toString(),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: AppTextField(
//                   initialValue: product.quantities.toString(),
//                   textFieldType: TextFieldType.NUMBER,
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                   onChanged: (value) {
//                     tempProduct.quantities = num.tryParse(value);
//                   },
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: lang.S.of(context).quantity,
//                     // hintText: 'Enter quantity',
//                     hintText: lang.S.of(context).enterQuantity,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   initialValue: product.productPurchasePrice.toString(),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                   onChanged: (value) {
//                     tempProduct.productPurchasePrice = num.tryParse(value);
//                   },
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: lang.S.of(context).purchasePrice,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextFormField(
//                   initialValue: product.productSalePrice.toString(),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                   onChanged: (value) {
//                     tempProduct.productSalePrice = num.tryParse(value);
//                   },
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: lang.S.of(context).salePrice,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   initialValue: product.productWholeSalePrice.toString(),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                   onChanged: (value) {
//                     tempProduct.productWholeSalePrice = num.tryParse(value);
//                   },
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: lang.S.of(context).wholeSalePrice,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextFormField(
//                   initialValue: product.productDealerPrice.toString(),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                   onChanged: (value) {
//                     tempProduct.productDealerPrice = num.tryParse(value);
//                   },
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: lang.S.of(context).dealerPrice,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: () {
//               if ((tempProduct.quantities ?? 0) > 0) {
//                 ref.watch(cartNotifierPurchaseNew).addToCartRiverPod(
//                     cartItem: CartProductModelPurchase(
//                       brandName: tempProduct.brandName,
//                       stock: tempProduct.stock,
//                       productId: tempProduct.productId,
//                       productName: tempProduct.productName ?? '',
//                       productDealerPrice: tempProduct.productDealerPrice,
//                       productPurchasePrice: tempProduct.productPurchasePrice,
//                       productSalePrice: tempProduct.productSalePrice,
//                       productWholeSalePrice: tempProduct.productWholeSalePrice,
//                       quantities: tempProduct.quantities,
//                     ),
//                     isVariation: true);
//                 // if (!fromUpdate) {
//                 //
//                 // }else{
//                 //
//                 // }
//
//                 // ref.invalidate(productProvider);
//                 if (fromUpdate) {
//                   Navigator.pop(context);
//                 } else {
//                   int count = 0;
//                   Navigator.popUntil(context, (route) {
//                     return count++ == 2;
//                   });
//                 }
//               } else {
//                 EasyLoading.showError(
//                   lang.S.of(context).pleaseAddQuantity,
//                   // 'Please add quantity'
//                 );
//               }
//             },
//             child: Container(
//               height: 60,
//               width: context.width(),
//               decoration: const BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(15))),
//               child: Center(
//                 child: Text(
//                   lang.S.of(context).save,
//                   style: const TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   ));
// }
