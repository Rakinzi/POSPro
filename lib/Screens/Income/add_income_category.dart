// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Income/Repo/income_category_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';

class AddIncomeCategory extends StatefulWidget {
  const AddIncomeCategory({super.key}) ;

  @override
  State<AddIncomeCategory> createState() => _AddIncomeCategoryState();
}

class _AddIncomeCategoryState extends State<AddIncomeCategory> {
  bool showProgress = false;

  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      //final allCategory = ref.watch(expanseCategoryProvider);
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close)),
            title: Text(
              lang.S.of(context).addIncomeCategory,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(
                      color: kMainColor,
                      strokeWidth: 5.0,
                    ),
                  ),
                  Form(
                    key: key,
                    child: TextFormField(
                      validator: (value) {
                        if (value?.trim().isEmptyOrNull ?? true) {
                          //return 'Enter expanse category name';
                          return 'Enter income category name';
                        }
                        return null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: lang.S.of(context).categoryName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (key.currentState?.validate() ?? false) {
                        EasyLoading.show();
                        final incomeRepo = IncomeCategoryRepo();
                        await incomeRepo.addIncomeCategory(
                          ref: ref,
                          context: context,
                          categoryName: nameController.text.trim(),
                        );
                      }
                    },
                    child: Text(lang.S.of(context).save),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
