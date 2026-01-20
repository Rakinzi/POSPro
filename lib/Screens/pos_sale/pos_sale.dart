import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mobile_pos/constant.dart';

import '../../Const/api_config.dart';
import '../../Provider/add_to_cart.dart';
import '../../Provider/product_provider.dart';
import '../../model/add_to_cart_model.dart';
import '../Customers/Model/parties_model.dart';
import '../Customers/Provider/customer_provider.dart';
import '../Customers/add_customer.dart';
import '../Products/Model/product_model.dart';
import '../Products/add_product.dart';
import '../Sales/add_sales.dart';
import '../Sales/batch_select_popup_sales.dart';
import '../product_category/model/category_model.dart';
import '../product_category/provider/product_category_provider/product_unit_provider.dart';

class PosSaleScreen extends ConsumerStatefulWidget {
  const PosSaleScreen({super.key});

  @override
  ConsumerState<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends ConsumerState<PosSaleScreen> {
  final productController = TextEditingController();
  List<ProductModel> filteredProducts = [];
  Party? selectedCustomer;
  CategoryModel? selectedCategory;
  String? selectedPrice;

  @override
  void initState() {
    super.initState();
    ref.invalidate(cartNotifier);
    filteredProducts = ref.read(productProvider).value ?? [];
    productController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    productController.removeListener(_applyFilters);
    productController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = productController.text.toLowerCase();
    final products = ref.read(productProvider).value ?? [];
    setState(() {
      filteredProducts = products.where((product) {
        return product.productName!.toLowerCase().startsWith(query) && (selectedCategory == null || product.categoryId == selectedCategory!.id);
      }).toList();
      if (selectedPrice == 'Low to high Price') {
        filteredProducts.sort((a, b) => (a.stocks?.last.productSalePrice ?? 0).compareTo(b.stocks?.last.productSalePrice ?? 0));
      } else if (selectedPrice == 'High to Low Price') {
        filteredProducts.sort((a, b) => (b.stocks?.last.productSalePrice ?? 0).compareTo(a.stocks?.last.productSalePrice ?? 0));
      }
    });
  }

  final TextEditingController _searchController = TextEditingController();
  bool _hasInitializedFilters = false;
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final providerData = ref.watch(cartNotifier);
    final productsList = ref.watch(productProvider);
    final categoryData = ref.watch(categoryProvider);
    final customer = ref.watch(partiesProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text('Pos Sale'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: productsList.when(
          data: (products) {
            if (!_hasInitializedFilters) {
              filteredProducts = products;
              _hasInitializedFilters = true;
            }
            return Column(
              children: [
                customer.when(
                  data: (customers) {
                    return TypeAheadField<Party>(
                      controller: _searchController,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: selectedCustomer != null ? selectedCustomer?.name : 'Select Customer',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: const VisualDensity(horizontal: -4),
                                  tooltip: 'Clear',
                                  onPressed: selectedCustomer == null
                                      ? () {
                                          focusNode.requestFocus();
                                        }
                                      : () {
                                          _searchController.clear();
                                          selectedCustomer = null;
                                          setState(() {});
                                        },
                                  icon: Icon(
                                    selectedCustomer != null ? Icons.close : Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: kSubPeraColor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddParty()),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      width: 50,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: kMainColor50,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Icon(Icons.add, color: kMainColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) {
                          return customers;
                        }
                        return customers.where((party) => (party.name ?? '').toLowerCase().startsWith(pattern.toLowerCase())).toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(suggestion.name ?? '', style: const TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(suggestion.phone ?? ''),
                            ),
                            Divider(),
                          ],
                        );
                      },
                      onSelected: (Party selectedParty) {
                        setState(() {
                          _searchController.text = selectedParty.name ?? '';
                          selectedCustomer = selectedParty;
                        });
                        Future.delayed(Duration.zero, () {
                          if (!context.mounted) return;
                          FocusScope.of(context).unfocus();
                        });
                      },
                    );
                  },
                  error: (e, stack) => Text('Error: $e'),
                  loading: () => const Center(child: LinearProgressIndicator()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: productController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (productController.text.isNotEmpty)
                          IconButton(
                            visualDensity: const VisualDensity(horizontal: -4),
                            tooltip: 'Clear',
                            onPressed: () {
                              productController.clear();
                              selectedCategory = null;
                              selectedPrice = null;
                              filteredProducts = ref.read(productProvider).value ?? [];
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.close,
                              size: 20,
                              color: kSubPeraColor,
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              isDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                    return SingleChildScrollView(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(start: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Filter',
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedCategory = null;
                                                      selectedPrice = null;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(Icons.close, size: 18),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(color: kBorderColor, height: 1),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                categoryData.when(
                                                  data: (catSnap) {
                                                    return DropdownButtonFormField2<CategoryModel>(
                                                      value: selectedCategory,
                                                      hint: const Text('Select one'),
                                                      iconStyleData: const IconStyleData(
                                                        icon: Icon(Icons.keyboard_arrow_down),
                                                        iconSize: 24,
                                                        openMenuIcon: Icon(Icons.keyboard_arrow_up),
                                                        iconEnabledColor: Colors.grey,
                                                      ),
                                                      items: catSnap.map((category) {
                                                        return DropdownMenuItem<CategoryModel>(
                                                          value: category,
                                                          child: Text(category.categoryName ?? 'Unnamed'),
                                                        );
                                                      }).toList(),
                                                      onChanged: (CategoryModel? value) {
                                                        setState(() {
                                                          selectedCategory = value;
                                                        });
                                                      },
                                                      menuItemStyleData: const MenuItemStyleData(
                                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                                      ),
                                                      decoration: const InputDecoration(
                                                        labelText: 'Category',
                                                      ),
                                                    );
                                                  },
                                                  error: (e, stack) {
                                                    return Text('Error: $e');
                                                  },
                                                  loading: () {
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                RadioGroup<String>(
                                                  groupValue: selectedPrice,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedPrice = value;
                                                    });
                                                  },
                                                  child: Column(
                                                    children: [
                                                      ...['Low to high Price', 'High to Low Price'].map((entry) {
                                                        return Theme(
                                                          data: Theme.of(context).copyWith(
                                                              radioTheme: RadioThemeData(
                                                                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return kMainColor;
                                                                    }
                                                                    return kSubPeraColor;
                                                                  }),
                                                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4))),
                                                          child: RadioListTile(
                                                            visualDensity: VisualDensity(horizontal: -4, vertical: -2),
                                                            contentPadding: EdgeInsets.zero,
                                                            value: entry,
                                                            title: Text(entry),
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: OutlinedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                productController.clear();
                                                                selectedCategory = null;
                                                                selectedPrice = null;
                                                                filteredProducts = ref.read(productProvider).value ?? [];
                                                                _applyFilters();
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('Cancel'))),
                                                    SizedBox(width: 16),
                                                    Expanded(
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              _applyFilters();
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('Apply')))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              width: 50,
                              height: 45,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kMainColor50,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                              child: SvgPicture.asset('assets/filter.svg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (filteredProducts.isEmpty)
                  Text('No matched products found.', style: _theme.textTheme.bodyMedium)
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 1,
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
                      mainAxisExtent: 180,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, i) {
                      final product = filteredProducts[i];
                      bool isSelected = providerData.cartItemList.any((item) => item.productId == product.id);
                      num quantity = isSelected ? providerData.cartItemList.firstWhere((item) => item.productId == product.id).quantity : 0;

                      return GestureDetector(
                        onTap: () async {
                          final product = products[i];

                          // If it's variant type, show the batch selector popup
                          if (product.productType == ProductType.variant.name) {
                            await showAddItemPopup(
                              mainContext: context,
                              productModel: product,
                              ref: ref,
                              customerType: 'Retailer',
                              fromPOSSales: true,
                            );
                            return;
                          }

                          // If product is out of stock
                          if ((product.productStockSum ?? 0) <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Out of stock',
                                style: _theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                              backgroundColor: kMainColor,
                            ));
                            return;
                          }

                          // Determine price based on customer type
                          String getPriceByCustomerType() {
                            final type = selectedCustomer?.type ?? 'Retailer';
                            if (product.stocks?.isEmpty ?? true) return '0';
                            if (type.contains('Dealer')) return product.stocks?.first.productDealerPrice.toString() ?? '0';

                            if (type.contains('Wholesaler')) return product.stocks?.first.productWholeSalePrice.toString() ?? '0';
                            if (type.contains('Supplier')) return product.stocks?.first.productPurchasePrice.toString() ?? '0';
                            return product.stocks?.first.productSalePrice.toString() ?? '0';
                          }

                          final cartItem = SaleCartModel(
                            productName: product.productName,
                            batchName: '',
                            stockId: product.stocks?.first.id ?? 0,
                            unitPrice: num.tryParse(getPriceByCustomerType()),
                            productCode: product.productCode,
                            productPurchasePrice: product.stocks?.first.productPurchasePrice,
                            stock: product.productStockSum ?? 0,
                            productId: product.id ?? 0,
                            quantity: 1,
                          );

                          providerData.addToCartRiverPod(cartItem: cartItem);
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected ? kMainColor : kBottomBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  product.productPicture?.isNotEmpty ?? false
                                      ? Image.network(
                                          fit: BoxFit.cover,
                                          '${APIConfig.domain}${product.productPicture}',
                                          height: 92,
                                          width: 92,
                                        )
                                      : Image.asset(
                                          fit: BoxFit.cover,
                                          noProductImageUrl,
                                          height: 92,
                                          width: 92,
                                        ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.productName ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      color: kPeraColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    () {
                                      final customerType = selectedCustomer?.type;
                                      switch (customerType) {
                                        case String type when type.contains('Retailer'):
                                          return '\$${product.stocks?.last.productSalePrice}';
                                        case String type when type.contains('Dealer'):
                                          return '\$${product.stocks?.last.productDealerPrice}';
                                        case String type when type.contains('Wholesaler'):
                                          return '\$${product.stocks?.last.productWholeSalePrice}';
                                        case String type when type.contains('Supplier'):
                                          return '\$${product.stocks?.last.productPurchasePrice}';
                                        default:
                                          return '\$${product.stocks?.last.productSalePrice}';
                                      }
                                    }(),
                                    style: _theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 34,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: _theme.textTheme.titleSmall?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        providerData.deleteAllVariant(productId: product.id ?? 0);
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            );
          },
          error: (e, stack) {
            return Text(e.toString());
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      bottomNavigationBar: providerData.cartItemList.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(thickness: 0.2, color: kBorderColorTextField),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSalesScreen(customerModel: selectedCustomer, isFromPos: true),
                        ),
                      );
                      if (!mounted) return;
                      if (result == true) {
                        _searchController.clear();
                        selectedCustomer = null;
                        setState(() {});
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
