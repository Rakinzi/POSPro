// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/Repo/unit_repo.dart';
import 'package:mobile_pos/Screens/product_unit/model/unit_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';

class AddUnits extends StatefulWidget {
  const AddUnits({super.key, this.unit});

  final Unit? unit;

  @override  State<AddUnits> createState() => _AddUnitsState();
}

class _AddUnitsState extends State<AddUnits> {
  bool showProgress = false;
  TextEditingController unitController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.unit != null) {
      unitController.text = widget.unit?.unitName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).addUnit,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Visibility(
                  visible: showProgress,
                  child: const CircularProgressIndicator(
                    color: kMainColor,
                    strokeWidth: 5.0,
                  ),
                ),
                Form(
                  key: _key,
                  child: TextFormField(
                    controller: unitController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // return 'Please enter a valid unit name';
                        return lang.S.of(context).pleaseEnterAValidUnitName;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      // hintText: 'Please enter unit name',
                      hintText: lang.S.of(context).pleaseEnterUnitName,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).unitName,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      UnitsRepo unit = UnitsRepo();

                      if ((widget.unit == null)) {
                        await unit.addUnit(ref: ref, context: context, name: unitController.text);
                      } else {
                        await unit.editUnit(ref: ref, id: widget.unit?.id ?? 0, context: context, name: unitController.text);
                      }
                    }
                  },
                  child: Text(lang.S.of(context).save),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}