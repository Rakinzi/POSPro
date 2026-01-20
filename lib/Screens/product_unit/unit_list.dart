import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/product_unit/provider/product_unit_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../Products/Repo/unit_repo.dart';
import '../Products/Widgets/widgets.dart';
import '../product_category/category_list_screen.dart';
import 'add_units.dart';

// ignore: must_be_immutable
class UnitList extends StatefulWidget {
  const UnitList({super.key, required this.isFromProductList});

  final bool isFromProductList;

  @override  State<UnitList> createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).units,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, __) {
            final unitData = ref.watch(unitsProvider);
            final businessInfo = ref.watch(businessInfoProvider);
            return businessInfo.when(data: (details) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
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
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              final currentIndex = context;
                              const AddUnits().launch(currentIndex);
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
                  unitData.when(data: (data) {
                    return data.isNotEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              return (data[i].unitName ?? '').toLowerCase().contains(search.toLowerCase())
                                  ? ListCardWidget(
                                      onSelect: widget.isFromProductList
                                          ? () {}
                                          : () {
                                              Navigator.pop(context, data[i]);
                                            },
                                      title: data[i].unitName.toString(),
                                      onDelete: () async {
                                        bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'unit');
                                        if (confirmDelete) {
                                          if (!context.mounted) return;
                                          EasyLoading.show();
                                          if (await UnitsRepo().deleteUnit(context: context, unitId: data[i].id ?? 0, ref: ref)) {
                                            ref.invalidate(unitsProvider);
                                          }
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      onEdit: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddUnits(
                                                unit: data[i],
                                              ),
                                            ));
                                      },
                                    )
                                  : Container();
                            })
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              lang.S.of(context).noDataFound,
                              //'No Data Found'
                            ),
                          );
                  }, error: (_, __) {
                    return Container();
                  }, loading: () {
                    return const CircularProgressIndicator();
                  }),
                ],
              );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return const Center(child: CircularProgressIndicator());
            });
          }),
        ),
      ),
    );
  }
}