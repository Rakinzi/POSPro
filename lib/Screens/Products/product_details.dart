import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/product_provider.dart';
import '../../widgets/key_values/key_values_widget.dart';
import '../Purchase/Repo/purchase_repo.dart';
import '../Purchase/purchase_product_buttom_sheet.dart';
import 'Repo/product_repo.dart';
import 'Widgets/widgets.dart';
import 'add_product.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({
    super.key,
    required this.details,
  });

  final ProductModel details;

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  TextEditingController productStockController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerData = ref.watch(fetchProductDetails(widget.details.id.toString()));
    return GlobalPopup(
        child: providerData.when(data: (snapshot) {
      return Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: Text(
            lang.S.of(context).productDetails,
            //'Product Details',
          ),
          actions: [
            IconButton(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProduct(
                        productModel: snapshot,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  HugeIcons.strokeRoundedPencilEdit02,
                  color: Colors.green,
                  size: 22,
                )),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              onPressed: () async {
                bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'product');
                if (!context.mounted) return;
                if (confirmDelete) {
                  EasyLoading.show(
                    status: lang.S.of(context).deleting,
                  );
                  ProductRepo productRepo = ProductRepo();
                  await productRepo.deleteProduct(id: snapshot.id.toString(), context: context, ref: ref);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: kMainColor,
                size: 22,
              ),
            ),
            SizedBox(width: 10),
          ],
          centerTitle: true,
          // iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 20,),
                Container(
                  height: 256,
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xffF5F3F3),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xffF5F3F3),
                        borderRadius: BorderRadius.circular(5),
                        image: snapshot.productPicture == null
                            ? DecorationImage(fit: BoxFit.cover, image: AssetImage(noProductImageUrl))
                            : DecorationImage(fit: BoxFit.cover, image: _productImageProvider(snapshot.productPicture))),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.productName.toString(),
                        //'Smart watch',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.category?.categoryName.toString() ?? 'n/a',
                        //'Apple Watch',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: kGreyTextColor,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: EdgeInsetsGeometry.symmetric(vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Color(0xffFEF0F1),
                        ),
                        child: Column(
                          children: [
                            if (snapshot.productType == 'single')
                              ...{
                                'SKU / Code': snapshot.productCode ?? 'n/a',
                                'Brand': snapshot.brand?.brandName ?? 'n/a',
                                'Model': snapshot.productModel?.modelName ?? 'n/a',
                                'Unit': snapshot.unit?.unitName ?? 'n/a',
                                'Stock': snapshot.productStockSum ?? '0',
                                'Low Stock Alert': snapshot.alertQty ?? 'n/a',
                                'Tax Type': snapshot.vatType ?? 'n/a',
                                'Tax': snapshot.vatAmount ?? 'n/a',
                                'Cost exc. tax': snapshot.vatType != 'exclusive'
                                    ? (snapshot.stocks?.first.productPurchasePrice != null && snapshot.vatAmount != null
                                        ? snapshot.stocks!.first.productPurchasePrice! - snapshot.vatAmount!
                                        : '0')
                                    : ('$currency${snapshot.stocks?.first.productPurchasePrice}'),
                                'Cost inc. tax': snapshot.vatType == 'exclusive'
                                    ? (snapshot.stocks?.first.productPurchasePrice != null && snapshot.vatAmount != null
                                        ? '$currency${snapshot.stocks!.first.productPurchasePrice! + snapshot.vatAmount!}'
                                        : '0')
                                    : ('$currency${snapshot.stocks?.first.productPurchasePrice}'),
                                'Profit Margin (%)': (snapshot.stocks?.first.profitPercent != null ? snapshot.stocks!.first.profitPercent : '0'),
                                'MRP/Sales Price': (snapshot.stocks?.first.productSalePrice != null ? '$currency${snapshot.stocks!.first.productSalePrice}' : '0'),
                                'Wholesale Price': (snapshot.stocks?.first.productWholeSalePrice != null ? '$currency${snapshot.stocks!.first.productWholeSalePrice}' : '0'),
                                'Dealer Price': (snapshot.stocks?.first.productDealerPrice != null ? '$currency${snapshot.stocks!.first.productDealerPrice}' : '0'),
                                'Manufacture Date': (snapshot.stocks?.first.mfgDate != null ? snapshot.stocks!.first.mfgDate : 'n/a'),
                                'Expire Date': (snapshot.stocks?.first.expireDate != null ? snapshot.stocks!.first.expireDate : 'n/a'),
                              }.entries.map(
                                (entry) {
                                  return KeyValueRow(
                                    title: entry.key,
                                    titleFlex: 6,
                                    description: entry.value.toString(),
                                    descriptionFlex: 8,
                                  );
                                },
                              ),
                            if (snapshot.productType != 'single')
                              ...{
                                'SKU / Code': snapshot.productCode ?? 'n/a',
                                'Brand': snapshot.brand?.brandName ?? 'n/a',
                                'Low Stock Alert': snapshot.alertQty ?? 'n/a',
                                'Tax Type': snapshot.vatType ?? 'n/a',
                                'Tax': snapshot.vatAmount ?? 'n/a',
                              }.entries.map(
                                (entry) {
                                  return KeyValueRow(
                                    title: entry.key,
                                    titleFlex: 6,
                                    description: entry.value.toString(),
                                    descriptionFlex: 8,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (snapshot.productType != 'single')
                  ListView.separated(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 16),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.stocks?.length ?? 0,
                    separatorBuilder: (context, index) => Divider(
                      thickness: 0.3,
                      color: kBorderColorTextField,
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Batch: ${snapshot.stocks?[index].batchNo ?? 'N/A'}',
                                maxLines: 1,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Sale: \$${snapshot.stocks?[index].productSalePrice ?? '0'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Stock: ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: kNeutralColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: snapshot.stocks?[index].productStock.toString() ?? '0',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Color(0xff34C759),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Purchase: \$${snapshot.stocks?[index].productPurchasePrice ?? '0'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                viewModal(context, snapshot, index);
                                break;
                              case 'edit':
                                final stock = snapshot.stocks?[index];

                                final cartProduct = CartProductModelPurchase(
                                  productId: snapshot.id ?? 0,
                                  stockId: stock?.id ?? 0,
                                  brandName: snapshot.brand?.brandName,
                                  productName: snapshot.productName ?? '',
                                  productDealerPrice: stock?.productDealerPrice,
                                  productPurchasePrice: stock?.productPurchasePrice,
                                  productSalePrice: stock?.productSalePrice,
                                  productWholeSalePrice: stock?.productWholeSalePrice,
                                  quantities: stock?.productStock,
                                  productType: snapshot.productType ?? '',
                                  vatAmount: snapshot.vatAmount ?? 0,
                                  vatRate: snapshot.vat?.rate ?? 0,
                                  vatType: snapshot.vatType ?? 'exclusive',
                                  expireDate: stock?.expireDate,
                                  mfgDate: stock?.mfgDate,
                                  profitPercent: stock?.profitPercent ?? 0,
                                  stock: stock?.productStock,
                                  batchNumber: stock?.batchNo ?? '',
                                );
                                addProductInPurchaseCartButtomSheet(context: context, product: cartProduct, ref: ref, fromUpdate: false, index: index, fromStock: true);
                                break;
                              case 'add_stock':
                                final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                                productStockController.text = '1';
                                salePriceController.text = snapshot.stocks?[index].productSalePrice?.toString() ?? '0.0';
                                addStockPopUp(context, _formKey, theme, snapshot, index);
                                break;
                              case 'delete':
                                showEditDeletePopUp(context: context, data: snapshot.stocks?[index], ref: ref, productId: widget.details.id.toString());
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'view', child: Text('View')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'add_stock', child: Text('Add Stock')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    }, error: (e, stack) {
      return Text(e.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }));
  }

  // Add stock popup
  Future<dynamic> addStockPopUp(BuildContext context, GlobalKey<FormState> _formKey, ThemeData theme, ProductModel snapshot, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Stock',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kTitleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: kTitleColor, size: 16),
                        iconSize: 16,
                        constraints: BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xffEEF3FF)),
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.3,
                  color: kBorderColorTextField,
                  height: 0,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        textAlign: TextAlign.center,
                        controller: productStockController,
                        validator: (value) {
                          final int? enteredStock = int.tryParse(value ?? '');
                          if (enteredStock == null || enteredStock < 1) {
                            return 'Stock must be at least 1';
                          }
                          return null;
                        },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter Stock',
                          prefixIcon: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffE0E2E7),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                int quantity = int.tryParse(productStockController.text) ?? 1;
                                if (quantity > 1) {
                                  quantity--;
                                  productStockController.text = quantity.toString();
                                }
                              },
                              child: Icon(Icons.remove, color: Color(0xff4A4A52)),
                            ),
                          ),
                          suffixIcon: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kMainColor.withValues(alpha: 0.15),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                int quantity = int.tryParse(productStockController.text) ?? 1;
                                quantity++;
                                productStockController.text = quantity.toString();
                              },
                              child: Icon(Icons.add, color: theme.colorScheme.primary),
                            ),
                          ),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        readOnly: true,
                        controller: salePriceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Sale Price',
                          hintText: 'Enter Amount',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xffF68A3D)),
                              ),
                              child: Text('Cancel', style: TextStyle(color: Color(0xffF68A3D))),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              child: Text('Save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  final int newStock = int.tryParse(productStockController.text) ?? 0;

                                  try {
                                    EasyLoading.show(status: 'Updating...');

                                    final repo = ProductRepo();
                                    final String productId = snapshot.stocks?[index].id.toString() ?? '';

                                    final bool success = await repo.addStock(
                                      id: productId,
                                      qty: newStock.toString(),
                                    );

                                    EasyLoading.dismiss();

                                    if (!context.mounted) return;

                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Updated Successfully')),
                                      );

                                      ref.invalidate(fetchProductDetails(widget.details.id.toString()));
                                      ref.invalidate(productProvider);

                                      productStockController.clear();
                                      salePriceController.clear();

                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to update stock')),
                                      );
                                    }
                                  } catch (e) {
                                    EasyLoading.dismiss();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // view modal sheet
  Future<dynamic> viewModal(BuildContext context, ProductModel snapshot, int index) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setNewState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 18),
                    )
                  ],
                ),
              ),
              Divider(color: kBorderColor, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    ...{
                      'Batch No.': snapshot.stocks?[index].batchNo ?? 'n/a',
                      'Qty': snapshot.stocks?[index].productStock ?? '0',
                      'Cost exc. tax': snapshot.vatType != 'exclusive'
                          ? (snapshot.stocks?[index].productPurchasePrice != null && snapshot.vatAmount != null
                              ? (snapshot.stocks?[index].productPurchasePrice ?? 0) - (snapshot.vatAmount ?? 0)
                              : 'n/a')
                          : (snapshot.stocks?.first.productPurchasePrice ?? 'n/a'),
                      'Cost inc. tax': snapshot.vatType == 'exclusive'
                          ? (snapshot.stocks?[index].productPurchasePrice != null && snapshot.vatAmount != null
                              ? (snapshot.stocks?[index].productPurchasePrice ?? 0) + (snapshot.vatAmount ?? 0)
                              : 'n/a')
                          : (snapshot.stocks?[index].productPurchasePrice ?? 'n/a'),
                      'Profit Margin (%)': (snapshot.stocks?.first.profitPercent != null ? snapshot.stocks!.first.profitPercent : 'n/a'),
                      'Sales Price': (snapshot.stocks?.first.productSalePrice != null ? snapshot.stocks!.first.productSalePrice : 'n/a'),
                      'Wholesale Price': (snapshot.stocks?.first.productWholeSalePrice != null ? snapshot.stocks!.first.productWholeSalePrice : 'n/a'),
                      'Dealer Price': (snapshot.stocks?.first.productDealerPrice != null ? snapshot.stocks!.first.productDealerPrice : 'n/a'),
                      'Manufacture Date': snapshot.stocks?.first.mfgDate != null ? DateFormat('d MMMM yyyy').format(DateTime.parse(snapshot.stocks?[index].mfgDate ?? '')) : 'n/a',
                      'Expire Date': snapshot.stocks?.first.expireDate != null ? DateFormat('d MMMM yyyy').format(DateTime.parse(snapshot.stocks?[index].expireDate ?? '')) : 'n/a',
                    }.entries.map(
                      (entry) {
                        return KeyValueRow(
                          title: entry.key,
                          titleFlex: 6,
                          description: entry.value.toString(),
                          descriptionFlex: 8,
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

ImageProvider _productImageProvider(dynamic productPicture) {
  final picture = productPicture?.toString() ?? '';
  final isLocal = picture.startsWith('/') || picture.startsWith('file:');
  if (isLocal) {
    final path = picture.startsWith('file:') ? picture.replaceFirst('file://', '') : picture;
    if (!File(path).existsSync()) {
      return AssetImage(noProductImageUrl);
    }
    return FileImage(File(path));
  }
  return NetworkImage('${APIConfig.domain}$picture');
}

Future<void> showEditDeletePopUp({required BuildContext context, Stocks? data, required WidgetRef ref, required String productId}) async {
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext dialogContext) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Are you sure you want to delete this Batch?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 26),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF68A3D).withValues(alpha: 0.1),
                  ),
                  padding: EdgeInsets.all(20),
                  child: SvgPicture.asset(
                    height: 146,
                    width: 146,
                    'images/trash.svg',
                  ),
                ),
                SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await Future.delayed(Duration.zero);
                          ProductRepo repo = ProductRepo();
                          bool success;
                          success = await repo.deleteStock(
                            id: data?.id.toString() ?? '',
                          );
                          if (!context.mounted) return;
                          if (success) {
                            ref.invalidate(fetchProductDetails(productId));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully')));
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
