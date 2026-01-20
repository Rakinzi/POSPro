import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/Providers/product_provider.dart' hide productProvider;
import 'package:mobile_pos/Screens/stock_list/stock_in_batch.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/stock_report_pdf/stock_report_pdf.dart';
import 'package:mobile_pos/thermal%20priting%20invoices/provider/print_thermal_invoice_provider.dart';
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';

import '../../Provider/product_provider.dart';
import '../../currency.dart';
import '../../pdf_report/stock_report_pdf/stock_report_excel.dart';

class StockList extends ConsumerStatefulWidget {
  const StockList({super.key, required this.isFromReport});

  final bool isFromReport;

  @override
  ConsumerState createState() => StockListState();
}

class StockListState extends ConsumerState<StockList> {
  String productSearch = '';
  bool _isRefreshing = false;
  String selectedFilter = 'All';
  String selectedExpireFilter = '7 Days';

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.invalidate(productProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  final _horizontalScroll = ScrollController();

  // Helper function to check if any stock is expired or near expiration
  bool _isProductExpiredOrNearExpiry(ProductModel product, DateTime now) {
    if (product.stocks == null || product.stocks!.isEmpty) return false;

    for (final stock in product.stocks!) {
      if (stock.expireDate != null) {
        final expiryDate = DateTime.tryParse(stock.expireDate!);
        if (expiryDate != null) {
          final daysLeft = expiryDate.difference(now).inDays;

          switch (selectedExpireFilter) {
            case '7 Days':
              if (daysLeft <= 7 && daysLeft >= 0) return true;
              break;
            case '15 Days':
              if (daysLeft <= 15 && daysLeft >= 0) return true;
              break;
            case '30 Days':
              if (daysLeft <= 30 && daysLeft >= 0) return true;
              break;
            case '60 Days':
              if (daysLeft <= 50 && daysLeft >= 0) return true;
              break;
            case 'Expired':
              if (daysLeft < 0) return true;
              break;
          }
        }
      }
    }
    return false;
  }

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(productProvider);
      final totalStockValueProvider = ref.watch(productListProvider);
      final businessData = ref.watch(businessInfoProvider);
      return totalStockValueProvider.when(
          data: (stockValue) {
            return businessData.when(data: (business) {
              return providerData.when(
                data: (product) {
                  List<ProductModel> showableProducts = [];
                  DateTime now = DateTime.now();

                  double totalStockValue = 0;

                  for (var element in product) {
                    bool matchesSearch = element.productName!.toLowerCase().contains(productSearch.toLowerCase().trim());
                    bool matchesFilter = selectedFilter == 'All' || (selectedFilter == 'Low Stock' && (element.productStockSum ?? 0) <= (element.alertQty ?? 0));

                    // Expire filtering based on stocks
                    bool matchesExpireFilter = true;
                    if (selectedFilter == 'Expire') {
                      matchesExpireFilter = _isProductExpiredOrNearExpiry(element, now);
                    }

                    if (selectedFilter == 'Expire') {
                      if (matchesSearch && matchesExpireFilter) {
                        showableProducts.add(element);
                        totalStockValue += (element.productPurchasePrice ?? 0) * (element.productStockSum ?? 0);
                      }
                    } else if (selectedFilter == 'Low Stock') {
                      if (matchesSearch && matchesFilter) {
                        showableProducts.add(element);
                        totalStockValue += (element.productPurchasePrice ?? 0) * (element.productStockSum ?? 0);
                      }
                    } else {
                      if (matchesSearch) {
                        showableProducts.add(element);
                        totalStockValue += (element.productPurchasePrice ?? 0) * (element.productStockSum ?? 0);
                      }
                    }
                  }

                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(lang.S.of(context).stockList),
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      actions: [
                        IconButton(
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (showableProducts.isNotEmpty) {
                              generateStockReportPdf(context, product, business, stockValue, false);
                            } else {
                              EasyLoading.showError('No data available for generate pdf');
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPdf01,
                            color: kSecondayColor,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (showableProducts.isNotEmpty) {
                              generateStockReportExcel(context, product, business, stockValue);
                            } else {
                              EasyLoading.showError('No data available for generate pdf');
                            }
                          },
                          icon: SvgPicture.asset('assets/excel.svg'),
                        ),
                        IconButton(
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref.watch(thermalPrinterProvider).printStockInvoiceNow(
                                  products: product,
                                  businessInformationModel: business,
                                  context: context,
                                  totalStock: stockValue,
                                );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPrinter,
                            color: kMainColor,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      toolbarHeight: 100,
                      bottom: PreferredSize(
                        preferredSize: const Size(double.infinity, 40),
                        child: Column(
                          children: [
                            Container(
                              color: updateBorderColor.withValues(alpha: 0.5),
                              width: double.infinity,
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextFormField(
                                      controller: searchController,
                                      onChanged: (value) {
                                        setState(() {
                                          productSearch = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: updateBorderColor, width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Colors.red, width: 1),
                                          ),
                                          prefixIcon: const Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(
                                              FeatherIcons.search,
                                              color: kNeutralColor,
                                            ),
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (searchController.text.isNotEmpty)
                                                IconButton(
                                                  visualDensity: const VisualDensity(horizontal: -4),
                                                  tooltip: 'Clear',
                                                  onPressed: () {
                                                    setState(() {
                                                      searchController.clear();
                                                    });
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
                                                    isDismissible: false,
                                                    useSafeArea: true,
                                                    builder: (BuildContext context) {
                                                      String tempSelectedFilter = selectedFilter;
                                                      String tempSelectedExpireFilter = selectedExpireFilter;

                                                      return StatefulBuilder(
                                                        builder: (BuildContext context, StateSetter setNewState) {
                                                          return SingleChildScrollView(
                                                            padding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(context).viewInsets.bottom,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional.only(start: 16),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Filter',
                                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed: () => Navigator.pop(context),
                                                                        icon: const Icon(Icons.close, size: 18),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(color: kBorderColor, height: 1),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    children: [
                                                                      DropdownButtonFormField2<String>(
                                                                        value: tempSelectedFilter,
                                                                        hint: const Text('Select Category'),
                                                                        iconStyleData: const IconStyleData(
                                                                          icon: Icon(Icons.keyboard_arrow_down),
                                                                          iconSize: 24,
                                                                          openMenuIcon: Icon(Icons.keyboard_arrow_up),
                                                                          iconEnabledColor: Colors.grey,
                                                                        ),
                                                                        onChanged: (String? newValue) {
                                                                          setNewState(() {
                                                                            tempSelectedFilter = newValue!;
                                                                          });
                                                                        },
                                                                        items: <String>['All', 'Low Stock', 'Expire'].map<DropdownMenuItem<String>>((String value) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: value,
                                                                            child: Text(value, style: theme.textTheme.bodyMedium),
                                                                          );
                                                                        }).toList(),
                                                                        dropdownStyleData: DropdownStyleData(
                                                                          maxHeight: 500,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(8),
                                                                          ),
                                                                          scrollbarTheme: ScrollbarThemeData(
                                                                            radius: const Radius.circular(40),
                                                                            thickness: WidgetStateProperty.all<double>(6),
                                                                            thumbVisibility: WidgetStateProperty.all<bool>(true),
                                                                          ),
                                                                        ),
                                                                        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 6)),
                                                                        decoration: const InputDecoration(
                                                                          labelText: 'Category',
                                                                        ),
                                                                      ),
                                                                      if (tempSelectedFilter == 'Expire') SizedBox(height: 16),
                                                                      if (tempSelectedFilter == 'Expire')
                                                                        DropdownButtonFormField2<String>(
                                                                          value: tempSelectedExpireFilter,
                                                                          isDense: true,
                                                                          iconStyleData: const IconStyleData(
                                                                            icon: Icon(Icons.keyboard_arrow_down),
                                                                            iconSize: 24,
                                                                            openMenuIcon: Icon(Icons.keyboard_arrow_up),
                                                                            iconEnabledColor: Colors.grey,
                                                                          ),
                                                                          hint: Text("Select Days", style: theme.textTheme.bodyMedium),
                                                                          onChanged: (String? newValue) {
                                                                            setNewState(() {
                                                                              tempSelectedExpireFilter = newValue!;
                                                                            });
                                                                          },
                                                                          items: <String>['7 Days', '15 Days', '30 Days', '60 Days', 'Expired']
                                                                              .map<DropdownMenuItem<String>>((String value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Text(value, style: theme.textTheme.bodyMedium),
                                                                            );
                                                                          }).toList(),
                                                                          dropdownStyleData: DropdownStyleData(
                                                                            maxHeight: 500,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            scrollbarTheme: ScrollbarThemeData(
                                                                              radius: const Radius.circular(40),
                                                                              thickness: WidgetStateProperty.all<double>(6),
                                                                              thumbVisibility: WidgetStateProperty.all<bool>(true),
                                                                            ),
                                                                          ),
                                                                          menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 6)),
                                                                        ),
                                                                      const SizedBox(height: 20),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: OutlinedButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 16),
                                                                          Expanded(
                                                                            child: ElevatedButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  selectedFilter = tempSelectedFilter;
                                                                                  selectedExpireFilter = tempSelectedExpireFilter;
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text('Apply'),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
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
                                          hintText: lang.S.of(context).searchH,
                                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: kNeutralColor,
                                              )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () => refreshData(ref),
                        child: Column(
                          children: [
                            showableProducts.isNotEmpty
                                ? LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      final kWidth = constraints.maxWidth;
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _horizontalScroll,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: kWidth),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              dividerTheme: const DividerThemeData(color: Colors.transparent),
                                              checkboxTheme: CheckboxThemeData(),
                                            ),
                                            child: DataTable(
                                              border: const TableBorder(
                                                horizontalInside: BorderSide(
                                                  width: 1,
                                                  color: updateBorderColor,
                                                ),
                                              ),
                                              dataRowColor: const WidgetStatePropertyAll(Colors.white),
                                              headingRowColor: WidgetStateProperty.all(const Color(0xffFEF0F1)),
                                              showBottomBorder: false,
                                              dividerThickness: 0.0,
                                              headingTextStyle: theme.textTheme.titleSmall,
                                              dataTextStyle: theme.textTheme.bodyMedium,
                                              columnSpacing: 20.0,
                                              headingRowHeight: 40,
                                              dataRowMinHeight: 40,
                                              columns: [
                                                DataColumn(label: Text(lang.S.of(context).product)),
                                                DataColumn(
                                                    label: Text(
                                                  lang.S.of(context).qty,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  lang.S.of(context).cost,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  lang.S.of(context).sale,
                                                  textAlign: TextAlign.center,
                                                )),
                                              ],
                                              rows: showableProducts.asMap().entries.map((entry) {
                                                final product = entry.value;
                                                final lastStock = product.stocks?.isNotEmpty == true ? product.stocks?.last : null;

                                                // Find the first expired stock (if any)
                                                Stocks? expiredStock;
                                                if (product.stocks != null) {
                                                  for (final stock in product.stocks!) {
                                                    if (stock.expireDate != null) {
                                                      final expiryDate = DateTime.tryParse(stock.expireDate!);
                                                      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
                                                        expiredStock = stock;
                                                        break;
                                                      }
                                                    }
                                                  }
                                                }
                                                bool isExpired = expiredStock != null;

                                                void navigateNextScreen() {
                                                  if (product.productType == "variant" && product.stocks?.isNotEmpty == true) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StockInBatchList(product: product),
                                                      ),
                                                    );
                                                  }
                                                }

                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              product.productName ?? 'N/A',
                                                              style: theme.textTheme.bodyMedium,
                                                              textAlign: TextAlign.start,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            if (isExpired) SizedBox(height: 1),
                                                            if (isExpired)
                                                              Text.rich(
                                                                TextSpan(text: 'Expired: ', children: [
                                                                  TextSpan(
                                                                      text: DateFormat('dd MMM yyyy').format(DateTime.parse(expiredStock.expireDate.toString())),
                                                                      style: TextStyle(
                                                                        color: Colors.red,
                                                                        fontSize: 12,
                                                                      ))
                                                                ]),
                                                                style: theme.textTheme.bodySmall,
                                                              )
                                                          ],
                                                        )),
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Text(
                                                          product.productStockSum.toString(),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    DataCell(
                                                      onTap: () => navigateNextScreen(),
                                                      Text(
                                                        '$currency${lastStock?.productPurchasePrice?.toStringAsFixed(2)}',
                                                        textAlign: TextAlign.center,
                                                        style: theme.textTheme.bodyMedium?.copyWith(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Text(
                                                          '$currency${lastStock?.productSalePrice?.toStringAsFixed(2)}',
                                                          textAlign: TextAlign.center,
                                                        )),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : EmptyWidget(
                                    message: TextSpan(text: lang.S.of(context).noProductFound),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: Container(
                      color: const Color(0xffFEF0F1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.S.of(context).stockValue,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            selectedFilter == "All" ? '$currency${stockValue.totalStockValue.toStringAsFixed(2)}' : '$currency${totalStockValue.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (e, stack) => Center(child: Text("Error: $e")),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return Center(child: CircularProgressIndicator());
            });
          },
          error: (e, stack) => Center(
                child: Text(e.toString()),
              ),
          loading: () {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    });
  }
}
