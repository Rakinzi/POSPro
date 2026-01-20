import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/expire_report/expire_report_pdf.dart';
import '../../../Provider/product_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';

class ExpiredList extends StatefulWidget {
  const ExpiredList({super.key});

  @override
  ExpiredListState createState() => ExpiredListState();
}

class ExpiredListState extends State<ExpiredList> {
  String productSearch = '';
  bool _isRefreshing = false;
  String selectedFilter = 'All';

  final TextEditingController searchController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  String? selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _errorMessage;
  bool _isFiltered = false;
  DateTime? _firstExpenseDate;

  @override
  void dispose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.invalidate(productProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<DateTime?> _selectDate(BuildContext context, {DateTime? initialDate}) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    DateTime? selectedDate = await _selectDate(context);
    if (selectedDate != null) {
      setState(() {
        _fromDate = selectedDate;
        fromDateController.text = _formatDate(selectedDate);
        _errorMessage = null;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    DateTime? selectedDate = await _selectDate(context, initialDate: _fromDate ?? DateTime.now());
    if (selectedDate != null) {
      if (_fromDate != null && selectedDate.isBefore(_fromDate!)) {
        setState(() {
          _errorMessage = "To Date cannot be before From Date.";
        });
      } else {
        setState(() {
          _toDate = selectedDate;
          toDateController.text = _formatDate(selectedDate);
          _errorMessage = null;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedFilter = 'All';
      _fromDate = null;
      _toDate = null;
      fromDateController.clear();
      toDateController.clear();
      _errorMessage = null;
      _isFiltered = false;
    });
    Navigator.pop(context);
  }

  void _applyFilters() {
    if (_fromDate != null && _toDate != null && _toDate!.isBefore(_fromDate!)) {
      setState(() {
        _errorMessage = "To Date cannot be before From Date.";
      });
      return;
    }

    setState(() {
      _isFiltered = true;
      _errorMessage = null;
    });
    Navigator.pop(context);
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    DateTime now = DateTime.now();

    return products.where((product) {
      // Handle search filter
      if (searchController.text.isNotEmpty) {
        final searchLower = searchController.text.toLowerCase();
        if (!(product.productName?.toLowerCase().contains(searchLower) ?? false) && !(product.category?.categoryName?.toLowerCase().contains(searchLower) ?? false)) {
          return false;
        }
      }

      // Handle category filter
      if (selectedCategory != null && selectedCategory != 'All' && product.category?.categoryName != selectedCategory) {
        return false;
      }

      // Check if any stock matches the expiration criteria
      bool hasMatchingStock = false;
      if (product.stocks != null && product.stocks!.isNotEmpty) {
        for (final stock in product.stocks!) {
          final stockExpireDate = stock.expireDate != null ? DateTime.tryParse(stock.expireDate!) : null;

          if (stockExpireDate == null) continue;

          // Handle date range filter
          if (_isFiltered) {
            if (_fromDate != null && stockExpireDate.isBefore(_fromDate!)) {
              continue;
            }
            if (_toDate != null && stockExpireDate.isAfter(_toDate!)) {
              continue;
            }
          }

          // Handle expiration status filter
          if (selectedFilter != 'All') {
            int daysUntilExpiration = stockExpireDate.difference(now).inDays;

            switch (selectedFilter) {
              case 'Expired':
                if (!stockExpireDate.isBefore(now)) continue;
                break;
              case '7 days':
                if (!(daysUntilExpiration >= 0 && daysUntilExpiration <= 7)) continue;
                break;
              case '15 days':
                if (!(daysUntilExpiration > 7 && daysUntilExpiration <= 15)) continue;
                break;
              case '30 days':
                if (!(daysUntilExpiration > 15 && daysUntilExpiration <= 30)) continue;
                break;
            }
          }

          // If we get here, this stock matches all criteria
          hasMatchingStock = true;
          break;
        }
      }

      return hasMatchingStock;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final _theme = Theme.of(context);

    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(productProvider);
      final personalInfoProvider = ref.watch(businessInfoProvider);

      return personalInfoProvider.when(
          data: (business) {
            return providerData.when(
              data: (products) {
                if (_firstExpenseDate == null && products.isNotEmpty) {
                  // Find the earliest expiration date across all stocks
                  DateTime? earliestDate;
                  for (final product in products) {
                    if (product.stocks != null) {
                      for (final stock in product.stocks!) {
                        if (stock.expireDate != null) {
                          final date = DateTime.tryParse(stock.expireDate!);
                          if (date != null && (earliestDate == null || date.isBefore(earliestDate))) {
                            earliestDate = date;
                          }
                        }
                      }
                    }
                  }
                  _firstExpenseDate = earliestDate;
                }

                final filteredProducts = _filterProducts(products);
                final totalParPrice = filteredProducts.fold<double>(0, (sum, product) => sum + (product.productPurchasePrice ?? 0) * (product.productStockSum ?? 0));

                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: Text(_lang.expiredList),
                    iconTheme: const IconThemeData(color: Colors.black),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    actions: [
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (filteredProducts.isNotEmpty) {
                            generateExpireReportPdf(context, filteredProducts, business, _firstExpenseDate, DateTime.now());
                          } else {
                            EasyLoading.showInfo('No data available for generate pdf');
                          }
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedPdf01,
                          color: kSecondayColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Column(
                        children: [
                          Divider(thickness: 1, color: kBottomBorder),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            child: TextFormField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (searchController.text.isNotEmpty)
                                      IconButton(
                                        visualDensity: const VisualDensity(horizontal: -4),
                                        tooltip: 'Clear',
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 20,
                                          color: kSubPeraColor,
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () => _showFilterBottomSheet(context, ref, _theme),
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
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: () => refreshData(ref),
                    child: filteredProducts.isNotEmpty
                        ? ListView.separated(
                            // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shrinkWrap: true,
                            itemCount: filteredProducts.length,
                            itemBuilder: (_, i) {
                              final product = filteredProducts[i];
                              final now = DateTime.now();

                              // Get all matching stocks for this product
                              final matchingStocks = product.stocks?.where((stock) {
                                    final stockExpireDate = stock.expireDate != null ? DateTime.tryParse(stock.expireDate!) : null;
                                    if (stockExpireDate == null) return false;

                                    // Check if this stock matches the current filters
                                    if (_isFiltered) {
                                      if (_fromDate != null && stockExpireDate.isBefore(_fromDate!)) return false;
                                      if (_toDate != null && stockExpireDate.isAfter(_toDate!)) return false;
                                    }

                                    if (selectedFilter != 'All') {
                                      int daysUntilExpiration = stockExpireDate.difference(now).inDays;
                                      switch (selectedFilter) {
                                        case 'Expired':
                                          if (!stockExpireDate.isBefore(now)) return false;
                                          break;
                                        case '7 days':
                                          if (!(daysUntilExpiration >= 0 && daysUntilExpiration <= 7)) return false;
                                          break;
                                        case '15 days':
                                          if (!(daysUntilExpiration > 7 && daysUntilExpiration <= 15)) return false;
                                          break;
                                        case '30 days':
                                          if (!(daysUntilExpiration > 15 && daysUntilExpiration <= 30)) return false;
                                          break;
                                      }
                                    }
                                    return true;
                                  }).toList() ??
                                  [];

                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  showTrailingIcon: false,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.productName.toString(),
                                            style: _theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${_lang.sale}: $currency${product.productSalePrice?.toStringAsFixed(2) ?? 'N/A'}',
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${_lang.code}: ${product.productCode ?? 'N/A'}',
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            '${_lang.purchase}: $currency${product.productPurchasePrice?.toStringAsFixed(2) ?? '0'}',
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  children: matchingStocks.map((stock) {
                                    final stockExpireDate = DateTime.parse(stock.expireDate!);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Batch: ${stock.batchNo ?? 'N/A'}',
                                                style: _theme.textTheme.titleSmall,
                                              ),
                                              Text(
                                                'Qty: ${stock.productStock?.toString() ?? '0'}',
                                                style: _theme.textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text.rich(TextSpan(
                                                  text: 'Expiry: ',
                                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                                    color: kPeraColor,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: DateFormat('yyyy-MM-dd').format(stockExpireDate),
                                                      style: TextStyle(
                                                        color: _getExpirationColor(stockExpireDate),
                                                      ),
                                                    ),
                                                  ])),
                                              Text(
                                                getExpirationStatus(stockExpireDate),
                                                style: TextStyle(
                                                  color: _getExpirationColor(stockExpireDate),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                thickness: 1,
                                color: updateBorderColor,
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              _lang.listIsEmpty,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  bottomNavigationBar: Container(
                    color: const Color(0xffFEF0F1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _lang.stockValue,
                            style: _theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$currency${totalParPrice.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              error: (e, stack) {
                return Text(e.toString());
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
          error: (e, stack) => Text(e.toString()),
          loading: () => Center(
                child: CircularProgressIndicator(),
              ));
    });
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
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
                        DropdownButtonFormField<String>(
                          initialValue: selectedFilter,
                          hint: const Text('Select Status'),
                          items: ['All', 'Expired', '7 days', '15 days', '30 days'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Expiration Status',
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectFromDate(context),
                                child: TextFormField(
                                  controller: fromDateController,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'From Date',
                                    hintText: 'Select from date',
                                    suffixIcon: Icon(Icons.calendar_month_rounded),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectToDate(context),
                                child: TextFormField(
                                  controller: toDateController,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'To Date',
                                    hintText: 'Select to date',
                                    suffixIcon: Icon(Icons.calendar_month_rounded),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _applyFilters,
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
  }
}

Color _getExpirationColor(DateTime expireDate) {
  final DateTime now = DateTime.now();
  final Duration difference = expireDate.difference(now);

  if (difference.isNegative) {
    return Colors.red; // Expired
  } else if (difference.inDays <= 7) {
    return Colors.orange; // Expiring soon (7 days or less)
  } else if (difference.inDays <= 30) {
    return Colors.amber; // Expiring within a month
  } else {
    return Colors.green; // Not expiring soon
  }
}

String getExpirationStatus(DateTime date) {
  final DateTime now = DateTime.now();
  final Duration difference = date.difference(now);

  if (difference.isNegative) {
    return 'Expired ${difference.inDays.abs()} days ago';
  } else if (difference.inDays == 0) {
    return 'Expires today';
  } else if (difference.inDays == 1) {
    return 'Expires tomorrow';
  } else if (difference.inDays <= 7) {
    return 'Expires in ${difference.inDays} days';
  } else if (difference.inDays <= 30) {
    return 'Expires in ${difference.inDays} days';
  } else {
    return 'Expires in ${difference.inDays} days';
  }
}
