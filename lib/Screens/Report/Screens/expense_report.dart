import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Expense/Model/expense_modle.dart';
import 'package:mobile_pos/Screens/Expense/Providers/all_expanse_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/expense_report/expense_report_excel.dart';
import 'package:mobile_pos/pdf_report/expense_report/expense_report_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../global_report_filter_bottomshet.dart';

class ExpenseReport extends StatefulWidget {
  const ExpenseReport({super.key});

  @override
  State<ExpenseReport> createState() => _ExpenseReportState();
}

class _ExpenseReportState extends State<ExpenseReport> {
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
  DateTime? _firstExpenseDate;

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
    });
    Navigator.pop(context);
  }

  List<Expense> _filterExpense(List<Expense> expenses) {
    return expenses.where((expense) {
      if (_appliedCategory != null && expense.category?.categoryName != _appliedCategory) {
        return false;
      }
      if (expense.expenseDate == null || DateTime.tryParse(expense.expenseDate ?? '') == null) return false;

      final expenseDate = DateTime.parse(expense.expenseDate?.substring(0,10) ?? '');
      if (_appliedFromDate != null && expenseDate.isBefore(_appliedFromDate!)) {
        return false;
      }
      if (_appliedToDate != null && expenseDate.isAfter(_appliedToDate!)) {
        return false;
      }

      if (searchController.text.isNotEmpty) {
        final searchLower = searchController.text.toLowerCase();
        if (!(expense.expanseFor?.toLowerCase().contains(searchLower) ?? false) && !(expense.category?.categoryName?.toLowerCase().contains(searchLower) ?? false)) {
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
      final expenseData = ref.watch(expenseProvider);
      final personalData = ref.watch(businessInfoProvider);
      return personalData.when(
        data: (business) {
          return GlobalPopup(
            child: expenseData.when(
              data: (allExpense) {
                if (_firstExpenseDate == null && allExpense.isNotEmpty) {
                  _firstExpenseDate = allExpense.map((expense) => DateTime.parse(expense.expenseDate ?? DateTime.now().toString())).reduce((a, b) => a.isBefore(b) ? a : b);
                }
                final filteredExpenses = _filterExpense(allExpense);
                final totalExpense = filteredExpenses.fold<num>(0, (sum, expense) => sum + (expense.amount ?? 0));

                return Scaffold(
                  backgroundColor: kWhite,
                  appBar: AppBar(
                    title: Text(lang.S.of(context).expenseReport),
                    iconTheme: const IconThemeData(color: Colors.black),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    actions: [
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (filteredExpenses.isNotEmpty) {
                            generateExpenseReportPdf(context, filteredExpenses, business, _firstExpenseDate, DateTime.now());
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
                          if (filteredExpenses.isNotEmpty) {
                            generateExpenseReportExcel(context, filteredExpenses, business, _firstExpenseDate, DateTime.now());
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
                    onRefresh: () => ref.refresh(expenseProvider.future),
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ///__________expense_data_table____________________________________________
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
                                    lang.S.of(context).expenseFor,
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
                          if (filteredExpenses.isEmpty)
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
                                itemCount: filteredExpenses.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  final expense = filteredExpenses[index];
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
                                                    expense.expanseFor ?? '',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    expense.category?.categoryName ?? '',
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
                                                DateTime.tryParse(expense.expenseDate ?? '') != null ? DateFormat.yMMMd().format(DateTime.parse(expense.expenseDate ?? '')) : '',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '$currency${expense.amount?.toStringAsFixed(2)}',
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
                          '$currency${totalExpense.toStringAsFixed(2)}',
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
    final expenseData = ref.read(expenseProvider);
    final categoryNames = expenseData.maybeWhen(
      data: (expenses) {
        return expenses
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
      initialFormDate: _firstExpenseDate,
      initialToDate: DateTime.now(),
      categories: categoryNames,
    );
  }
}
