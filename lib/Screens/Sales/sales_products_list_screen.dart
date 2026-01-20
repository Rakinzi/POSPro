import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/add_to_cart.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../Products/add_product.dart';
import 'batch_select_popup_sales.dart';

class SaleProductsList extends StatefulWidget {
  const SaleProductsList({super.key, this.customerModel});

  final Party? customerModel;

  @override  State<SaleProductsList> createState() => _SaleProductsListState();
}

class _SaleProductsListState extends State<SaleProductsList> {
  String productCode = '0000';
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Consumer(builder: (context, ref, __) {
        final providerData = ref.watch(cartNotifier);
        final productList = ref.watch(productProvider);

        return Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).addItems,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppTextField(
                            controller: codeController,
                            textFieldType: TextFieldType.NAME,
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
                      ),
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
                  productList.when(data: (products) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          num sentProductPrice;

                          final stock = products[i].stocks?.first;

                          if (widget.customerModel?.type != null) {
                            final type = widget.customerModel!.type!;
                            if (type.contains('Dealer')) {
                              sentProductPrice = stock?.productDealerPrice ?? 0;
                            } else if (type.contains('Wholesaler')) {
                              sentProductPrice = stock?.productWholeSalePrice ?? 0;
                            } else if (type.contains('Supplier')) {
                              sentProductPrice = stock?.productPurchasePrice ?? 0;
                            } else {
                              // Default to Retailer or unknown types
                              sentProductPrice = stock?.productSalePrice ?? 0;
                            }
                          } else {
                            sentProductPrice = stock?.productSalePrice ?? 0;
                          }

                          return GestureDetector(
                            onTap: products[i].productType == ProductType.variant.name
                                ? () async {
                                    await showAddItemPopup(mainContext: context, productModel: products[i], ref: ref, customerType: widget.customerModel?.type,fromPOSSales: false);
                                  }
                                : () async {
                                    if ((products[i].productStockSum ?? 0) <= 0) {
                                      EasyLoading.showError('Out of stock');
                                    } else {
                                      SaleCartModel cartItem = SaleCartModel(
                                        productName: products[i].productName,
                                        batchName: '',
                                        stockId: products[i].stocks?.first.id??0,
                                        unitPrice: sentProductPrice,
                                        productCode: products[i].productCode,
                                        productPurchasePrice: stock?.productPurchasePrice,
                                        stock: stock?.productStock,
                                        productType: products[i].productType,
                                        productId: products[i].id ?? 0,
                                        quantity: (stock?.productStock ?? 0) < 1 ? (stock?.productStock ?? 0) : 1,
                                      );
                                      providerData.addToCartRiverPod(cartItem: cartItem, fromEditSales: false);
                                      Navigator.pop(context);
                                    }
                                  },
                            child: ProductCard(
                              productTitle: products[i].productName.toString(),
                              productPrice: sentProductPrice,
                              productImage: products[i].productPicture,
                              stock: products[i].productStockSum ?? 0,
                            ).visible((products[i].productCode == productCode || productCode == '0000' || productCode == '-1') && sentProductPrice.toString() != '0' ||
                                products[i].productName!.toLowerCase().contains(productCode.toLowerCase())),
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
      }),
    );
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard({super.key, required this.productTitle, required this.productPrice, required this.productImage, required this.stock});

  String productTitle;
  num productPrice, stock;
  String? productImage;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  num quantity = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      for (var element in providerData.cartItemList) {
        if (element.productName == widget.productTitle) {
          quantity = element.quantity;
        }
      }

      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
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
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.productTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium!.copyWith(fontSize: 18),
                              ),
                              Text(
                                '${lang.S.of(context).stocks}${widget.stock}',
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
            Text(
              '$currency${widget.productPrice}',
              style: theme.textTheme.titleMedium!.copyWith(fontSize: 18),
            ),
          ],
        ),
      );
    });
  }
}