import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/vat_&_tax/provider/text_repo.dart';
import 'package:mobile_pos/Screens/vat_&_tax/repo/tax_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'model/vat_model.dart';

class AddGroupTax extends ConsumerStatefulWidget {
  const AddGroupTax({
    super.key,
    this.taxModel,
  });

  final VatModel? taxModel;

  @override
  AddTaxGroupState createState() => AddTaxGroupState();
}

class AddTaxGroupState extends ConsumerState<AddGroupTax> {
  List<VatModel> subTaxList = [];

  TextEditingController nameController = TextEditingController();
  bool status = true;

  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  void _saveTax({required BuildContext context, required WidgetRef ref}) async {
    if (_fromKey.currentState!.validate()) {
      if (subTaxList.isNotEmpty) {
        EasyLoading.show();
        TaxRepo repo = TaxRepo();
        List<num> ids = [];
        for (var element in subTaxList) {
          ids.add(element.id!);
        }
        if (widget.taxModel != null) {
          await repo.updateGroupTax(id: widget.taxModel!.id!, ref: ref, context: context, taxName: nameController.text, taxIds: ids, status: status);
        } else {
          await repo.createGroupTax(ref: ref, context: context, taxName: nameController.text, taxIds: ids, status: status);
        }
        EasyLoading.dismiss();

        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        EasyLoading.showError('Please select taxes');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.taxModel?.subTax != null) {
      Future.microtask(() async {
        final data = await ref.read(singleTaxProvider.future);

        List<VatModel> matchingItems = [];

        for (var element in widget.taxModel!.subTax!) {
          try {
            VatModel matchingItem = data.firstWhere(
              (item) => element.id == item.id,
              orElse: () => VatModel(),
            );

            if (matchingItem.id != null) {
              matchingItems.add(matchingItem);
            }
          } catch (_) {}
        }

        setState(() {
          subTaxList = matchingItems;
        });
      });
      nameController.text = widget.taxModel?.name ?? '';
      status = widget.taxModel?.status ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          widget.taxModel == null ? _lang.addTaxGroup : _lang.editTaxGroup,
          // style: GoogleFonts.poppins(
          //   color: Colors.white,
          // ),
        ),
        // iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //___________________________________Tax Rates______________________________
            Text('${widget.taxModel == null ? _lang.add : _lang.edit} ${_lang.taxWithSingleMultipleTaxType}',
                style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            Text('${lang.S.of(context).name}*', style: const TextStyle(color: kTitleColor)),
            const SizedBox(height: 8.0),
            Form(
              key: _fromKey,
              child: TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tax name is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 8, right: 8.0),
                  border: const OutlineInputBorder(),
                  // hintText: 'Enter Name',
                  hintText: lang.S.of(context).enterName,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text('${_lang.subTaxes}*', style: TextStyle(color: kTitleColor)),
            const SizedBox(height: 8.0),
            Consumer(builder: (context, ref, __) {
              final taxes = ref.watch(singleTaxProvider);
              return taxes.when(
                  data: (taxes) {
                    return GestureDetector(
                      onTap: () async {
                        subTaxList = await getTaxesModalSheet(mainContext: context, ref: ref, oldList: subTaxList, taxList: taxes);
                        if (!context.mounted) return;
                        setState(() {
                          subTaxList;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.transparent, border: Border.all(color: kBorderColorTextField)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            subTaxList.isNotEmpty
                                ? Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Wrap(
                                        children: List.generate(
                                          subTaxList.length,
                                          (index) {
                                            final category = subTaxList[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 5.0),
                                              child: Container(
                                                height: 30,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: kMainColor),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        setState(() {
                                                          subTaxList.removeAt(index);
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: kWhite,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      category.name ?? '',
                                                      style: const TextStyle(color: kWhite),
                                                    ),
                                                    const SizedBox(width: 8)
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(_lang.noSubTaxSelected, style: TextStyle(color: kTitleColor)),

                            //___________________________________________showModalBottomSheet______________________
                            const Padding(
                              padding: EdgeInsets.all(11.0),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: kGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return Text(error.toString());
                  },
                  loading: () => Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.transparent, border: Border.all(color: kBorderColorTextField)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_lang.noSubTaxSelected, style: TextStyle(color: kTitleColor)),

                            //___________________________________________showModalBottomSheet______________________
                            Padding(
                              padding: EdgeInsets.all(11.0),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: kGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ));
              // loading: () => Skeletonizer(
              //       enabled: true,
              //       child: Container(
              //         padding: const EdgeInsets.only(left: 10),
              //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.transparent, border: Border.all(color: kBorderColorTextField)),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(_lang.noSubTaxSelected, style: TextStyle(color: kTitleColor)),
              //
              //             //___________________________________________showModalBottomSheet______________________
              //             Padding(
              //               padding: EdgeInsets.all(11.0),
              //               child: Icon(
              //                 Icons.keyboard_arrow_down_rounded,
              //                 color: kGreyTextColor,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ));
            }),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Text(
                  _lang.status,
                  style: TextStyle(color: kTitleColor),
                ),
                const SizedBox(width: 8.0),
                Switch(
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                )
              ],
            ),

            //___________________________________________save_button______________________
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 45.0,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: kMainColor,
                    elevation: 1.0,
                    foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                    shadowColor: kMainColor,
                    animationDuration: const Duration(milliseconds: 300),
                    textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _saveTax(ref: ref, context: context),
                  child: Text(
                    lang.S.of(context).save,
                    style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<VatModel>> getTaxesModalSheet({
  required BuildContext mainContext,
  required WidgetRef ref,
  required List<VatModel> oldList,
  required List<VatModel> taxList,
}) async {
  List<VatModel> subTaxList = [...oldList];

  bool? isDone = await showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    context: mainContext,
    builder: (BuildContext context) {
      final _lang = lang.S.of(context);
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setNewState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 13.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lang.subTaxList,
                      style: TextStyle(color: kTitleColor, fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 21,
                        color: kTitleColor,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const Divider(color: kBorderColorTextField),
              // const SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  itemCount: taxList.length,
                  itemBuilder: (context, index) {
                    final category = taxList[index];
                    return Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          checkColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          // fillColor: WidgetStateProperty.all(
                          //   subTaxList.contains(category) ? kMainColor : Colors.transparent,
                          // ),
                          fillColor: WidgetStatePropertyAll(subTaxList.contains(category) ? kMainColor : kBackgroundColor),
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          side: const BorderSide(color: kBorderColorTextField),
                          title: Text(category.name ?? '', style: const TextStyle(color: kTitleColor, overflow: TextOverflow.ellipsis)),
                          subtitle: Text('${_lang.taxPercent}: ${category.rate}%', style: const TextStyle(color: kGreyTextColor)),
                          value: subTaxList.contains(category),
                          onChanged: (isChecked) {
                            setNewState(() {
                              if (isChecked!) {
                                if (!subTaxList.contains(category)) {
                                  subTaxList.add(category); // Add only the TaxModel instance
                                }
                              } else {
                                subTaxList.remove(category);
                              }
                            });
                          },
                        ),
                        const Divider(
                          color: kBorderColorTextField,
                          height: 0.0,
                        )
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 45.0,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: kMainColor,
                      elevation: 1.0,
                      foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                      shadowColor: kMainColor,
                      animationDuration: const Duration(milliseconds: 300),
                      textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(_lang.done, style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return (isDone ?? false) ? subTaxList : oldList;
}
