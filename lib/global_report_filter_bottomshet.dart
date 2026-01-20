import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constant.dart';

void globalReportFilterBottomSheet(
  BuildContext context, {
  required String? selectedCategory,
  required Function(String?) onCategoryChanged,
  required TextEditingController fromDateController,
  required TextEditingController toDateController,
  required String? errorMessage,
  required Function() onClearFilters,
  required Function() onApplyFilters,
  required Function() onSelectFromDate,
  required Function() onSelectToDate,
  DateTime? initialFormDate,
  DateTime? initialToDate,
  required List<String> categories, // Add this parameter for the category list
}) {
  final theme = Theme.of(context);
  // Initialize the controllers if dates are provided
  if (initialFormDate != null && fromDateController.text.isEmpty) {
    fromDateController.text = DateFormat('yyyy-MM-dd').format(initialFormDate);
  }
  if (initialToDate != null && toDateController.text.isEmpty) {
    toDateController.text = DateFormat('yyyy-MM-dd').format(initialToDate);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          openMenuIcon: Icon(Icons.keyboard_arrow_up),
                          iconEnabledColor: Colors.grey,
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: onCategoryChanged,
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
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: onSelectFromDate,
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
                              onTap: onSelectToDate,
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
                              onPressed: onClearFilters,
                              child: const Text('Clear'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onApplyFilters,
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
