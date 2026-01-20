// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Expense/Model/expanse_category.dart';
import 'package:mobile_pos/Screens/Expense/expense_category_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../widgets/payment_type/_payment_type_dropdown.dart';
import 'Repo/expanse_repo.dart';

// ignore: must_be_immutable
class AddExpense extends StatefulWidget {
  const AddExpense({
    super.key,
  }) ;

  @override  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  ExpenseCategory? selectedCategory;
  final dateController = TextEditingController();
  TextEditingController expanseForNameController = TextEditingController();
  TextEditingController expanseAmountController = TextEditingController();
  TextEditingController expanseNoteController = TextEditingController();
  TextEditingController expanseRefController = TextEditingController();
  List<String> paymentMethods = [
    //lang.S.of(context).cancel,
    'Cash',
    'Bank',
    'Card',
    'Mobile Payment',
    'Due',
  ];

  int? selectedPaymentType;

  /*
  DropdownButton<String> getPaymentMethods() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentMethods) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedPaymentType,
      onChanged: (value) {
        setState(() {
          selectedPaymentType = value!;
        });
      },
    );
  }
  */

  @override
  void initState() {
    super.initState();
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).addExpense,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: context.width(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        ///_______date________________________________
                        SizedBox(
                          height: 48,
                          child: FormField(
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: kInputDecoration.copyWith(
                                  suffixIcon: const Icon(IconlyLight.calendar, color: kGreyTextColor),
                                  // enabledBorder: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8),
                                  labelText: lang.S.of(context).expenseDate,
                                  hintText: lang.S.of(context).enterExpenseDate,
                                ),
                                child: Text(
                                  '${DateFormat.d().format(selectedDate)} ${DateFormat.MMM().format(selectedDate)} ${DateFormat.y().format(selectedDate)}',
                                ),
                              );
                            },
                          ).onTap(() => _selectDate(context)),
                        ),
                        const SizedBox(height: 20),

                        ///_________category_______________________________________________
                        Container(
                          height: 48.0,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kBorderColor),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              selectedCategory = await const ExpenseCategoryList().launch(context);
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 10.0),
                                Text(selectedCategory?.categoryName ?? lang.S.of(context).selectCategory),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down),
                                const SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///________Expense_for_______________________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseForNameController,
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              //return 'Please Enter Name';
                              return lang.S.of(context).pleaseEnterName;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseForNameController.text = value!;
                          },
                          decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            // border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).expenseFor,
                            hintText: lang.S.of(context).enterName,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///________PaymentType__________________________________
                        /*
                        SizedBox(
                          height: 48,
                          child: FormField(
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: kInputDecoration.copyWith(
                                    // enabledBorder: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(8.0),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelText: lang.S.of(context).paymentTypes),
                                child: DropdownButtonHideUnderline(
                                  child: getPaymentMethods(),
                                ),
                              );
                            },
                          ),
                        ),
                        */
                        PaymentTypeSelectorDropdown(
                          isFormField: true,
                          value: selectedPaymentType,
                          onChanged: (v) => setState(
                            () => selectedPaymentType = v,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///_________________Amount_____________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseAmountController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              //return 'Please Enter Amount';
                              return lang.S.of(context).pleaseEnterAmount;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseAmountController.text = value!;
                          },
                          decoration: kInputDecoration.copyWith(
                            border: const OutlineInputBorder(),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            labelText: lang.S.of(context).amount,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: lang.S.of(context).enterAmount,
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        ///_______reference_________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseRefController,
                          validator: (value) {
                            return null;
                          },
                          onSaved: (value) {
                            expanseRefController.text = value!;
                          },
                          decoration: kInputDecoration.copyWith(
                            border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).referenceNo,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: lang.S.of(context).enterRefNumber,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///_________note____________________________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseNoteController,
                          validator: (value) {
                            if (value == null) {
                              //return 'please Inter Amount';
                              return lang.S.of(context).pleaseEnterAmount;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseNoteController.text = value!;
                          },
                          decoration: kInputDecoration.copyWith(
                            border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).note,
                            //hintText: 'Enter Note',
                            hintText: lang.S.of(context).enterNote,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///_______button_________________________________
                        ElevatedButton.icon(
                          iconAlignment: IconAlignment.end,
                          label: Text(lang.S.of(context).continueButton),
                          onPressed: () async {
                            if (validateAndSave()) {
                              if (selectedCategory != null) {
                                EasyLoading.show();
                                ExpenseRepo repo = ExpenseRepo();

                                await repo.createExpense(
                                  ref: ref,
                                  context: context,
                                  amount: num.tryParse(expanseAmountController.text) ?? 0,
                                  expenseCategoryId: selectedCategory?.id ?? 0,
                                  expanseFor: expanseForNameController.text,
                                  paymentType: selectedPaymentType?.toString() ?? '',
                                  referenceNo: expanseRefController.text,
                                  expenseDate: selectedDate.toString(),
                                  note: expanseNoteController.text,
                                );
                              } else {
                                EasyLoading.showError(
                                  lang.S.of(context).pleaseSelectAExpenseCategory,
                                  //'Please select a expense category'
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      );
    });
  }
}