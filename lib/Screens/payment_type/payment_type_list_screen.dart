import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/payment_type/provider/payment_type_provider.dart';
import 'package:mobile_pos/Screens/payment_type/repo/payment_type_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../Products/Widgets/widgets.dart';
import '../product_category/category_list_screen.dart';
import 'manage_payment_type_view.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  PaymentTypeScreenState createState() => PaymentTypeScreenState();
}

class PaymentTypeScreenState extends State<PaymentTypeScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(lang.S.of(context).paymentTypes,
              //'Categories',
              style: const TextStyle(
                fontSize: 20.0,
              )),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          final paymentTypes = ref.watch(paymentTypeProvider);
          return Column(
            children: [
              ///______Search_and_add_button______________________________________
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  spacing: 10,
                  children: [
                    ///_______Search_________________________________________
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        textFieldType: TextFieldType.NAME,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          //hintText: 'Search',
                          hintText: lang.S.of(context).search,
                          prefixIcon: Icon(
                            Icons.search,
                            color: kGreyTextColor.withValues(alpha: 0.5),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),

                    ///_______Add_Type_________________________________________
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          const ManagePaymentTypeView().launch(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          height: 48.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: kGreyTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: paymentTypes.when(data: (data) {
                  return SingleChildScrollView(
                    child: data.isNotEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final _type = data[i];
                              return (_type.name ?? 'N/A').toLowerCase().contains(search.toLowerCase())
                                  ? ListCardWidget(
                                      title: _type.name ?? "N/A",
                                      // Delete
                                      onDelete: () async {
                                        bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'payment type');
                                        if (!context.mounted) return;
                                        if (confirmDelete) {
                                          EasyLoading.show();
                                          if (await PaymentTypeRepo().deletePaymentType(context: context, id: _type.id!, ref: ref)) {
                                            if (!context.mounted) return;
                                            ref.invalidate(paymentTypeProvider);
                                          }
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      // Edit
                                      onEdit: () async {
                                        return await ManagePaymentTypeView(
                                          editModel: _type,
                                        ).launch<void>(context);
                                      },
                                    )
                                  : const SizedBox.shrink();
                            },
                          )
                        : Center(
                            child: EmptyWidget(
                              message: TextSpan(text: lang.S.of(context).noDataFound),
                            ),
                          ),
                  );
                }, error: (_, __) {
                  return Container();
                }, loading: () {
                  return const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator()));
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
