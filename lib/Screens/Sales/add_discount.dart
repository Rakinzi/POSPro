import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/GlobalComponents/tab_buttons.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';

class AddDiscount extends StatefulWidget {
  const AddDiscount({super.key}) ;

  @override  State<AddDiscount> createState() => _AddDiscountState();
}

class _AddDiscountState extends State<AddDiscount> {
  String discountType = 'USD';
  List<String> allDataList = [];
  String amount = '0';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GlobalPopup(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).discount,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TabButton(
                          title: 'USD',
                          text: discountType == 'USD' ? Colors.white : kMainColor,
                          background: discountType == 'USD' ? kMainColor : kDarkWhite,
                          press: () {
                            setState(() {
                              discountType = 'USD';
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TabButton(
                          title: '%',
                          text: discountType == '%' ? Colors.white : kMainColor,
                          background: discountType == '%' ? kMainColor : kDarkWhite,
                          press: () {
                            setState(() {
                              discountType = '%';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: const InputDecoration(border: OutlineInputBorder(), floatingLabelBehavior: FloatingLabelBehavior.always, labelText: 'Discount (USD)'),
                    onChanged: (value) {
                      amount = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), floatingLabelBehavior: FloatingLabelBehavior.always, labelText: 'Note'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // providerData.addDiscount(discountType, amount.toDouble());
                    Navigator.pop(context);
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