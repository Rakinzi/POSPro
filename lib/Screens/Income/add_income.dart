// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Income/Model/income_category.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/payment_type/_payment_type_dropdown.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import 'Repo/income_repo.dart';
import 'income_category_list.dart';

// ignore: must_be_immutable
class AddIncome extends StatefulWidget {
  const AddIncome({
    super.key,
  }) ;

  @override  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  IncomeCategory? selectedCategory;
  final dateController = TextEditingController();
  TextEditingController incomeForNameController = TextEditingController();
  TextEditingController incomeAmountController = TextEditingController();
  TextEditingController incomeNoteController = TextEditingController();
  TextEditingController incomeRefController = TextEditingController();
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
              lang.S.of(context).addIncome,
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
                                  labelText: lang.S.of(context).incomeDate,
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
                            border: Border.all(color: kBorderColor, width: 1),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              selectedCategory = await const IncomeCategoryList().launch(context);
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
                          controller: incomeForNameController,
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              //return 'Please Enter Name';
                              return lang.S.of(context).pleaseEnterName;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            incomeForNameController.text = value!;
                          },
                          decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            // border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).incomeFor,
                            hintText: lang.S.of(context).enterName,
                          ),
                        ),
                        const SizedBox.square(dimension: 20),

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
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          controller: incomeAmountController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              //return 'Please Enter Amount';
                              return lang.S.of(context).pleaseEnterAmount;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            incomeAmountController.text = value!;
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
                          controller: incomeRefController,
                          validator: (value) {
                            return null;
                          },
                          onSaved: (value) {
                            incomeRefController.text = value!;
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
                          controller: incomeNoteController,
                          validator: (value) {
                            if (value == null) {
                              //return 'please Inter Amount';
                              return lang.S.of(context).pleaseEnterAmount;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            incomeNoteController.text = value!;
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
                          onPressed: () async {
                            if (validateAndSave()) {
                              if (selectedCategory != null) {
                                EasyLoading.show();
                                IncomeRepo repo = IncomeRepo();

                                await repo.createIncome(
                                  ref: ref,
                                  context: context,
                                  amount: num.tryParse(incomeAmountController.text) ?? 0,
                                  expenseCategoryId: selectedCategory?.id ?? 0,
                                  expanseFor: incomeForNameController.text,
                                  paymentType: selectedPaymentType?.toString() ?? '',
                                  referenceNo: incomeRefController.text,
                                  expenseDate: selectedDate.toString(),
                                  note: incomeNoteController.text,
                                );
                              } else {
                                EasyLoading.showError(
                                  lang.S.of(context).pleaseSelectAExpenseCategory,
                                  //'Please select a expense category'
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          label: Text(lang.S.of(context).continueButton),
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