import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Screens/product_model/provider/models_provider.dart';
import 'package:mobile_pos/Screens/product_model/repo/product_models_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';

import '../../GlobalComponents/glonal_popup.dart';
import 'add_products_models.dart';

class ProductModelList extends StatefulWidget {
  const ProductModelList({super.key, required this.fromProductList});

  final bool fromProductList;

  @override
  ProductModelListState createState() => ProductModelListState();
}

class ProductModelListState extends State<ProductModelList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text('Models'),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          final modelData = ref.watch(fetchModelListProvider);
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProductModel()),
                          );
                        },
                        child: Container(
                          height: 48.0,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kMainColor),
                          ),
                          child: const Icon(Icons.add, color: kMainColor),
                        ),
                      ),
                    ],
                  ),
                ),
                modelData.when(
                  data: (snapshot) {
                    final allModels = snapshot.data ?? [];
                    final filteredModels = allModels.where((model) {
                      final name = (model.name ?? '').toLowerCase();
                      return name.contains(search.toLowerCase());
                    }).toList();

                    if (filteredModels.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                        child: EmptyWidgetUpdated(
                          message: TextSpan(text: lang.S.of(context).noDataFound),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredModels.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        final model = filteredModels[i];
                        return ListCardWidget(
                          onSelect: widget.fromProductList
                              ? () {}
                              : () {
                                  Navigator.pop(context, model);
                                },
                          title: model.name?.toString() ?? 'n/a',
                          onDelete: () async {
                            ProductModelsRepo repo = ProductModelsRepo();
                            bool success = await repo.deleteModel(id: model.id?.toString() ?? '');
                            if (success) {
                              ref.invalidate(fetchModelListProvider);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted Successfully')),
                              );
                            }
                          },
                          onEdit: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProductModel(editData: model),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  error: (_, __) => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          );
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
