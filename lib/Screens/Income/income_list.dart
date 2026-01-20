import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Income/Providers/all_income_provider.dart';
import 'package:mobile_pos/Screens/Income/Providers/income_category_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import 'add_income.dart';

class IncomeList extends StatefulWidget {
  const IncomeList({super.key});

  @override  State<IncomeList> createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {
  final dateController = TextEditingController();
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  num totalExpense = 0;

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.invalidate(incomeProvider);
    ref.invalidate(incomeCategoryProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    totalExpense = 0;
    return Consumer(builder: (context, ref, __) {
      final incomeData = ref.watch(incomeProvider);
      final businessInfoData = ref.watch(businessInfoProvider);

      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).incomeReport,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: RefreshIndicator(
            onRefresh: () => refreshData(ref),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              controller: fromDateTextEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).fromDate,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                      context: context,
                                    );
                                    setState(() {
                                      fromDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                      fromDate = picked!;
                                      totalExpense = 0;
                                    });
                                  },
                                  icon: const Icon(FeatherIcons.calendar),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              controller: toDateTextEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).toDate,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      initialDate: toDate,
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                      context: context,
                                    );

                                    setState(() {
                                      toDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                      picked!.isToday ? toDate = DateTime.now() : toDate = picked;
                                      totalExpense = 0;
                                    });
                                  },
                                  icon: const Icon(FeatherIcons.calendar),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///__________expense_data_table____________________________________________
                    Container(
                      width: context.width(),
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: kDarkWhite),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              lang.S.of(context).incomeFor,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(lang.S.of(context).date),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            width: 70,
                            child: Text(lang.S.of(context).amount),
                          )
                        ],
                      ),
                    ),

                    incomeData.when(data: (mainData) {
                      if (mainData.isNotEmpty) {
                        totalExpense = 0;
                        for (var income in mainData) {
                          if ((fromDate.isBefore(DateTime.tryParse(income.incomeDate?.substring(0, 10) ?? '') ?? DateTime.now()) ||
                                  DateTime.parse(income.incomeDate?.substring(0, 10) ?? '').isAtSameMomentAs(fromDate)) &&
                              (toDate.isAfter(DateTime.tryParse(income.incomeDate?.substring(0, 10) ?? '') ?? DateTime.now()) ||
                                  DateTime.parse(income.incomeDate?.substring(0, 10) ?? '').isAtSameMomentAs(DateTime.parse(toDate.toString().substring(0, 10))))) {
                            totalExpense += income.amount ?? 0;
                          }
                        }
                        return SizedBox(
                          width: context.width(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: mainData.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Visibility(
                                visible: (fromDate.isBefore(DateTime.parse(mainData[index].incomeDate ?? '')) ||
                                        DateTime.parse(mainData[index].incomeDate?.substring(0, 10) ?? '').isAtSameMomentAs(fromDate)) &&
                                    (toDate.isAfter(DateTime.parse(mainData[index].incomeDate ?? '')) ||
                                        DateTime.parse(mainData[index].incomeDate?.substring(0, 10) ?? '').isAtSameMomentAs(DateTime.parse(toDate.toString().substring(0, 10)))),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 130,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  mainData[index].incomeFor ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  mainData[index].category?.categoryName ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              DateFormat.yMMMd().format(DateTime.parse(mainData[index].incomeDate ?? '')),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            width: 70,
                                            child: Text("$currency${mainData[index].amount.toString()}"),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.black12,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(lang.S.of(context).noData),
                          ),
                        );
                      }
                    }, error: (Object error, StackTrace? stackTrace) {
                      return Text(error.toString());
                    }, loading: () {
                      return const Center(child: CircularProgressIndicator());
                    }),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///_________total______________________________________________
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: kDarkWhite),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.S.of(context).totalIncome,
                      ),
                      Text('$currency$totalExpense')
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                ///________button________________________________________________
                businessInfoData.when(data: (details) {
                  return ElevatedButton(
                    onPressed: () async {
                      const AddIncome().launch(context);
                    },
                    child: Text(lang.S.of(context).addIncome),
                  );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
              ],
            ),
          ),
        ),
      );
    });
  }
}