import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Income/Model/income_modle.dart';
import 'package:mobile_pos/Screens/Income/Providers/all_income_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/income_report/income_report_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../global_report_filter_bottomshet.dart';
import '../../../pdf_report/income_report/income_report_excel.dart';

class IncomeReport extends StatefulWidget {
  const IncomeReport({super.key});

  @override
  State<IncomeReport> createState() => _IncomeReportState();
}

class _IncomeReportState extends State<IncomeReport> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  String? selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _errorMessage;
  String? _appliedCategory;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;
  bool isFiltered = false;
  DateTime? _firstIncomeDate;

  @override
  void dispose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
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
    DateTime? selectedDate = await _selectDate(context, initialDate: _fromDate);
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

  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedFromDate = _fromDate;
      _appliedToDate = _toDate;
      isFiltered = true;
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      _fromDate = null;
      _toDate = null;
      _appliedCategory = null;
      _appliedFromDate = null;
      _appliedToDate = null;
      fromDateController.clear();
      toDateController.clear();
      _errorMessage = null;
      isFiltered = false;
    });
    Navigator.pop(context);
  }

  List<Income> _filterIncomes(List<Income> incomes) {
    // if (!_isFiltered) return incomes;

    return incomes.where((income) {
      if (_appliedCategory != null && income.category?.categoryName != _appliedCategory) {
        return false;
      }
      if (income.incomeDate == null || DateTime.tryParse(income.incomeDate ?? '') == null) return false;

      final incomeDate = DateTime.parse(income.incomeDate?.substring(0, 10) ?? '');
      if (_appliedFromDate != null && incomeDate.isBefore(_appliedFromDate!)) {
        return false;
      }
      if (_appliedToDate != null && incomeDate.isAfter(_appliedToDate!)) {
        return false;
      }

      if (searchController.text.isNotEmpty) {
        final searchLower = searchController.text.toLowerCase();
        if (!(income.incomeFor?.toLowerCase().contains(searchLower) ?? false) && !(income.category?.categoryName?.toLowerCase().contains(searchLower) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final incomeData = ref.watch(incomeProvider);
      final personalData = ref.watch(businessInfoProvider);
      return personalData.when(
        data: (business) {
          return GlobalPopup(
            child: incomeData.when(
              data: (allIncomes) {
                if (_firstIncomeDate == null && allIncomes.isNotEmpty) {
                  _firstIncomeDate = allIncomes.map((income) => DateTime.parse(income.incomeDate ?? DateTime.now().toString())).reduce((a, b) => a.isBefore(b) ? a : b);
                }
                final filteredIncomes = _filterIncomes(allIncomes);
                final totalIncome = filteredIncomes.fold<num>(0, (sum, income) => sum + (income.amount ?? 0));

                return Scaffold(
                  backgroundColor: kWhite,
                  appBar: AppBar(
                    title: Text(lang.S.of(context).incomeReport),
                    iconTheme: const IconThemeData(color: Colors.black),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    actions: [
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (filteredIncomes.isNotEmpty) {
                            generateIncomeReportPdf(context, filteredIncomes, business, _firstIncomeDate, DateTime.now());
                          } else {
                            EasyLoading.showInfo('No data available for generate pdf');
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
                          if (filteredIncomes.isNotEmpty) {
                            generateIncomeReportExcel(context, filteredIncomes, business, _firstIncomeDate, DateTime.now());
                          } else {
                            EasyLoading.showInfo('No data available for generate pdf');
                          }
                        },
                        icon: SvgPicture.asset('assets/excel.svg'),
                      ),
                      SizedBox(width: 8),
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
                                      onTap: () => _showFilterBottomSheet(context, ref, theme),
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
                    onRefresh: () => ref.refresh(incomeProvider.future),
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ///__________income_data_table____________________________________________
                          Container(
                            width: context.width(),
                            padding: EdgeInsetsDirectional.symmetric(vertical: 13, horizontal: 24),
                            height: 50,
                            decoration: const BoxDecoration(color: kMainColor50),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    lang.S.of(context).incomeFor,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    lang.S.of(context).date,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    lang.S.of(context).amount,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (filteredIncomes.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(lang.S.of(context).noData),
                              ),
                            )
                          else
                            SizedBox(
                              width: context.width(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredIncomes.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  final income = filteredIncomes[index];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 24),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    income.incomeFor ?? '',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    income.category?.categoryName ?? '',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: kPeraColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                DateFormat.yMMMd().format(DateTime.parse(income.incomeDate ?? '')),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '$currency${income.amount?.toStringAsFixed(2)}',
                                                textAlign: TextAlign.end,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        color: Colors.black12,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: Container(
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: kMainColor50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${lang.S.of(context).total}:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$currency${totalIncome.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              error: (error, stackTrace) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      );
    });
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref, ThemeData theme) {
    final incomeData = ref.read(incomeProvider);
    final categoryNames = incomeData.maybeWhen(
      data: (income) {
        return income
            .map((e) => e.category?.categoryName)
            .whereType<String>()
            .toSet() // Remove duplicates
            .toList();
      },
      orElse: () => <String>[], // Return empty list if loading/error
    );
    globalReportFilterBottomSheet(
      context,
      selectedCategory: selectedCategory,
      onCategoryChanged: (value) => setState(() => selectedCategory = value),
      fromDateController: fromDateController,
      toDateController: toDateController,
      errorMessage: _errorMessage,
      onClearFilters: _clearFilters,
      onApplyFilters: _applyFilters,
      onSelectFromDate: () => _selectFromDate(context),
      onSelectToDate: () => _selectToDate(context),
      initialFormDate: _firstIncomeDate,
      initialToDate: DateTime.now(),
      categories: categoryNames,
    );
  }
}

// void _showFilterBottomSheet(BuildContext context, WidgetRef ref, ThemeData theme) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     isDismissible: false,
//     useSafeArea: true,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           return SingleChildScrollView(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsetsDirectional.only(start: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Filter',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.close, size: 18),
//                       )
//                     ],
//                   ),
//                 ),
//                 const Divider(color: kBorderColor, height: 1),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Consumer(
//                         builder: (context, ref, child) {
//                           final categoryData = ref.watch(incomeCategoryProvider);
//                           return categoryData.when(
//                             data: (categories) => DropdownButtonFormField2<String>(
//                               value: selectedCategory,
//                               hint: const Text('Select Category'),
//                               iconStyleData: const IconStyleData(
//                                 icon: Icon(Icons.keyboard_arrow_down),
//                                 iconSize: 24,
//                                 openMenuIcon: Icon(Icons.keyboard_arrow_up),
//                                 iconEnabledColor: Colors.grey,
//                               ),
//                               items: categories.map((category) {
//                                 return DropdownMenuItem<String>(
//                                   value: category.categoryName,
//                                   child: Text(category.categoryName.toString()),
//                                 );
//                               }).toList(),
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   selectedCategory = value;
//                                 });
//                               },
//                               dropdownStyleData: DropdownStyleData(
//                                 // Add this
//                                 maxHeight: 500, // Set max height for scrollable items
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 scrollbarTheme: ScrollbarThemeData(
//                                   // Optional scrollbar styling
//                                   radius: const Radius.circular(40),
//                                   thickness: WidgetStateProperty.all<double>(6),
//                                   thumbVisibility: WidgetStateProperty.all<bool>(true),
//                                 ),
//                               ),
//                               menuItemStyleData:
//                                   const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 6)),
//                               decoration: const InputDecoration(
//                                 labelText: 'Category',
//                               ),
//                             ),
//                             error: (error, stack) => Text(error.toString()),
//                             loading: () => const Center(child: CircularProgressIndicator()),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       if (_errorMessage != null)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 10),
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => _selectFromDate(context),
//                               child: TextField(
//                                 controller: fromDateController,
//                                 enabled: false,
//                                 decoration: const InputDecoration(
//                                   labelText: 'From Date',
//                                   hintText: 'Select from date',
//                                   suffixIcon: Icon(Icons.calendar_month_rounded),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => _selectToDate(context),
//                               child: TextField(
//                                 controller: toDateController,
//                                 enabled: false,
//                                 decoration: const InputDecoration(
//                                   labelText: 'To Date',
//                                   hintText: 'Select to date',
//                                   suffixIcon: Icon(Icons.calendar_month_rounded),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: _clearFilters,
//                               child: const Text('Clear'),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: _applyFilters,
//                               child: const Text('Apply'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
