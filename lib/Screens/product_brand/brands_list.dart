import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/product_brand/product_brand_provider/product_brand_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../Products/Widgets/widgets.dart';
import '../product_category/category_list_screen.dart';
import 'add_brans.dart';
import 'brand repo/brand_repo.dart';

// ignore: must_be_immutable
class BrandsList extends StatefulWidget {
  const BrandsList({super.key, required this.isFromProductList});

  final bool isFromProductList;

  @override  State<BrandsList> createState() => _BrandsListState();
}

class _BrandsListState extends State<BrandsList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).brands,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, __) {
            final brandData = ref.watch(brandsProvider);
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
                        const SizedBox(width: 10.0),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              const AddBrands().launch(context);
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
                  brandData.when(data: (data) {
                    return data.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              return (data[i].brandName ?? '').toLowerCase().contains(search.toLowerCase())
                                  ? ListCardWidget(
                                      onSelect: widget.isFromProductList
                                          ? () {}
                                          : () async {
                                              Navigator.pop(context, data[i]);
                                            },
                                      title: data[i].brandName ?? '',
                                      // Delete
                                      onDelete: () async {
                                        bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'brand');
                                        if (confirmDelete) {
                                          if (!context.mounted) return;
                                          EasyLoading.show();
                                          if (await BrandsRepo().deleteBrand(context: context, brandId: data[i].id ?? 0, ref: ref)) {
                                            ref.invalidate(brandsProvider);
                                          }
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      // Edit
                                      onEdit: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddBrands(
                                                brand: data[i],
                                              ),
                                            ));
                                      },
                                    )
                                  : const SizedBox.shrink();
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
          }),
        ),
      ),
    );
  }
}