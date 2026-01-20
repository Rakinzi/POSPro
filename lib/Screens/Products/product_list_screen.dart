import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/product_details.dart';
import 'package:mobile_pos/Screens/product_category/category_list_screen.dart';
import 'package:mobile_pos/Screens/product_unit/unit_list.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../barcode/gererate_barcode.dart';
import '../product_brand/brands_list.dart';
import '../product_category/provider/product_category_provider/product_unit_provider.dart';
import '../product_model/product_model_list.dart';
import 'Repo/product_repo.dart';
import 'Widgets/widgets.dart';
import 'add_product.dart';
import 'bulk product upload/bulk_product_upload_screen.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    ref.invalidate(productProvider);
    ref.invalidate(categoryProvider);

    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () {
        setState(() {
          _searchQuery = _searchController.text;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) {
        final businessInfo = ref.watch(businessInfoProvider);
        final providerData = ref.watch(productProvider);
        final _theme = Theme.of(context);

        return businessInfo.when(
          data: (details) {
            return GlobalPopup(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: kWhite,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: Text(
                    lang.S.of(context).productList,
                  ),
                  actions: [
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CategoryList(
                                          isFromProductList: true,
                                        )));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                IconlyBold.category,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                lang.S.of(context).productCategory,
                                //"Product Category",
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BrandsList(
                                          isFromProductList: true,
                                        )));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                IconlyBold.bookmark,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                lang.S.of(context).brand,
                                //"Brand",
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProductModelList(
                                          fromProductList: true,
                                        )));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Model",
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UnitList(
                                          isFromProductList: true,
                                        )));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.scale,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                lang.S.of(context).productUnit,
                                // "Product Unit",
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BulkUploader()));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.list_alt,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Bulk Upload',
                                // "Product Unit",
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BarcodeGeneratorScreen()));
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.barcode_reader,
                                color: kGreyTextColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Barcode Generator',
                                style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              )
                            ],
                          ),
                        ),
                      ],
                      offset: const Offset(0, 40),
                      color: kWhite,
                      padding: EdgeInsets.zero,
                      elevation: 2,
                    ),
                  ],
                  centerTitle: true,
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: kMainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/AddProducts');
                  },
                  child: const Icon(Icons.add, color: kWhite),
                ),
                body: RefreshIndicator(
                  onRefresh: () => refreshData(ref),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: providerData.when(
                      data: (products) {
                        final filteredProducts = products.where((product) {
                          final query = _searchQuery.toLowerCase();
                          final name = product.productName?.toLowerCase() ?? '';
                          final code = product.productCode?.toLowerCase() ?? '';
                          return name.contains(query) || code.contains(query);
                        }).toList();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: TextFormField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  prefixIcon: const Icon(
                                    IconlyLight.search,
                                    color: kMainColor,
                                  ),
                                  suffixIcon: Container(
                                    margin: EdgeInsets.all(1),
                                    height: 48,
                                    width: 48,
                                    decoration: const BoxDecoration(
                                      color: kMainColor,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) => BarcodeScannerWidget(
                                            onBarcodeFound: (String code) {
                                              setState(() {
                                                _searchController.text = code;
                                                _searchQuery = code;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        'images/search_icon.svg',
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            filteredProducts.isNotEmpty
                                ? ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (_, i) {
                                      final product = filteredProducts[i];
                                      return ListTile(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetails(details: product),
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        contentPadding: const EdgeInsets.only(left: 16),
                                        leading: product.productPicture == null
                                            ? CircleAvatarWidget(
                                                name: product.productName,
                                                size: const Size(50, 50),
                                              )
                                            : Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: _productImageProvider(product.productPicture),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                        title: Text(
                                          product.productName ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: _theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                                        ),
                                        subtitle: Text(
                                          "${lang.S.of(context).stock} : ${product.productStockSum}",
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: DAppColors.kSecondary,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "$currency${product.stocks != null && product.stocks!.isNotEmpty && product.stocks!.first.productSalePrice != null ? product.stocks!.first.productSalePrice : 'N/A'}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            PopupMenuButton<int>(
                                              style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => AddProduct(productModel: product),
                                                      ),
                                                    );
                                                  },
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      const Icon(IconlyBold.edit, color: kGreyTextColor),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        lang.S.of(context).edit,
                                                        style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  onTap: () async {
                                                    bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'product');
                                                    if (confirmDelete) {
                                                      if (!context.mounted) return;
                                                      EasyLoading.show(status: lang.S.of(context).deleting);
                                                      ProductRepo productRepo = ProductRepo();
                                                      await productRepo.deleteProduct(id: product.id.toString(), context: context, ref: ref);
                                                    }
                                                  },
                                                  value: 2,
                                                  child: Row(
                                                    children: [
                                                      const Icon(IconlyBold.delete, color: kGreyTextColor),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        lang.S.of(context).delete,
                                                        style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              offset: const Offset(0, 40),
                                              color: kWhite,
                                              padding: EdgeInsets.zero,
                                              elevation: 2,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(color: const Color(0xff808191).withAlpha(50));
                                    },
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 30.0),
                                      child: Text(
                                        lang.S.of(context).addProduct,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                      error: (e, stack) => Text(e.toString()),
                      loading: () => const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            );
          },
          error: (e, stack) => Text(e.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
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
