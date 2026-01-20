import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Screens/product_category/provider/product_category_provider/product_unit_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../Products/Widgets/widgets.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';
import 'repo/category_repo.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.isFromProductList});

  final bool isFromProductList;

  @override
  CategoryListState createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).categories,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          final categoryData = ref.watch(categoryProvider);
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
                      const SizedBox(width: 10.0),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            const AddCategory().launch(context);
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
                      // const SizedBox(width: 20.0),
                    ],
                  ),
                ),
                Expanded(
                  child: categoryData.when(data: (data) {
                    return SingleChildScrollView(
                      child: data.isNotEmpty
                          ? ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, i) {
                                return (data[i].categoryName ?? '').toLowerCase().contains(search.toLowerCase())
                                    ? ListCardWidget(
                                        onSelect: widget.isFromProductList
                                            ? () {}
                                            : () {
                                                Navigator.pop(context, data[i]);
                                              },
                                        title: data[i].categoryName.toString(),
                                        // Delete
                                        onDelete: () async {
                                          bool confirmDelete = await showDeleteAlert(context: context, itemsName: 'category');
                                          if (confirmDelete) {
                                            if (!context.mounted) return;
                                            EasyLoading.show();
                                            if (await CategoryRepo().deleteCategory(context: context, categoryId: data[i].id ?? 0, ref: ref)) {
                                              ref.invalidate(categoryProvider);
                                            }
                                            EasyLoading.dismiss();
                                          }
                                        },
                                        // Edit
                                        onEdit: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditCategory(
                                                categoryModel: data[i],
                                              ),
                                            ),
                                          );
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
          }, error: (e, stack) {
            return Text(e.toString());
          }, loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
        }),
      ),
    );
  }
}

class ListCardWidget extends StatelessWidget {
  const ListCardWidget({
    super.key,
    this.onEdit,
    this.onDelete,
    required this.title,
    this.onSelect,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;
  final void Function()? onSelect;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xffD8D8D8)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                  iconSize: 20,
                  icon: const Icon(
                    IconlyLight.edit,
                    color: DAppColors.kSecondary,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                  iconSize: 20,
                  icon: const Icon(
                    IconlyLight.delete,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            // const Spacer(),
          ],
        ),
      ),
    );
  }
}
