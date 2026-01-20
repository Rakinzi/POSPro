import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/vat_&_tax/add_group_tax.dart';
import 'package:mobile_pos/Screens/vat_&_tax/creating_single_tax.dart';
import 'package:mobile_pos/Screens/vat_&_tax/provider/text_repo.dart';
import 'package:mobile_pos/Screens/vat_&_tax/repo/tax_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../Products/Widgets/widgets.dart';
import 'model/vat_model.dart';

class TaxReport extends ConsumerStatefulWidget {
  const TaxReport({super.key});

  @override
  ConsumerState<TaxReport> createState() => _TaxReportState();
}

class _TaxReportState extends ConsumerState<TaxReport> {
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.invalidate(taxProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final taxes = ref.watch(taxProvider);
    final businessProviderData = ref.watch(businessInfoProvider);
    ref.watch(getExpireDateProvider(ref));
    return businessProviderData.when(data: (details) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            title: Text(
              _lang.taxRates,
            ),
            centerTitle: true,
            backgroundColor: kWhite,
            elevation: 0.0,
          ),
          body: taxes.when(
            data: (data) {
              List<VatModel> singleTaxes = [];
              List<VatModel> groupTaxes = [];
              for (var element in data) {
                if (element.subTax == null) {
                  singleTaxes.add(element);
                } else {
                  groupTaxes.add(element);
                }
              }
              return RefreshIndicator(
                onRefresh: () => refreshData(ref),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //___________________________________Tax Rates______________________________
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _lang.taxRatesMangeYourTaxRates,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(left: 2, right: 2),
                              minimumSize: Size(60, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              backgroundColor: kSuccessColor,
                              elevation: 1.0,
                              foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                              shadowColor: kMainColor,
                              animationDuration: const Duration(milliseconds: 300),
                              textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateSingleTax(),
                                ),
                              );
                            },
                            label: Text(
                              _lang.add,
                              style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              FeatherIcons.plus,
                              size: 15,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
                          border: TableBorder.all(borderRadius: BorderRadius.circular(2.0), color: kBorderColorTextField),
                          dividerThickness: 1.0,
                          sortAscending: true,
                          showCheckboxColumn: false,
                          horizontalMargin: 5.0,
                          columnSpacing: 10,
                          dataRowMinHeight: 45,
                          showBottomBorder: true,
                          checkboxHorizontalMargin: 0.0,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                lang.S.of(context).name,
                                // 'Name',
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                _lang.taxRates,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                _lang.status,
                              ),
                            ),
                            DataColumn(
                              headingRowAlignment: MainAxisAlignment.center,
                              label: Text(
                                _lang.actions,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          rows: List.generate(
                            singleTaxes.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * .30,
                                    child: Text(
                                      '${singleTaxes[index].name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                DataCell(Center(
                                  child: Text(
                                    singleTaxes[index].rate.toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                                DataCell(Center(
                                  child: Text(
                                    (singleTaxes[index].status ?? false) ? _lang.active : _lang.disable,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                                DataCell(
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(50, 25),
                                          padding: const EdgeInsets.only(left: 2, right: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          backgroundColor: kSuccessColor,
                                          elevation: 1.0,
                                          foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                                          shadowColor: kMainColor,
                                          animationDuration: const Duration(milliseconds: 300),
                                          textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CreateSingleTax(taxModel: singleTaxes[index]),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              FeatherIcons.edit,
                                              size: 15,
                                              color: kWhite,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              lang.S.of(context).edit,
                                              //'Edit',
                                              style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(50, 25),
                                          padding: const EdgeInsets.only(left: 2, right: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          backgroundColor: Colors.red,
                                          elevation: 1.0,
                                          foregroundColor: Colors.white.withValues(alpha: 0.1),
                                          shadowColor: Colors.red,
                                          animationDuration: const Duration(milliseconds: 300),
                                        ),
                                        onPressed: () async {
                                          bool result = await showDeleteAlert(context: context, itemsName: 'vat_&_tax');
                                          if (!context.mounted) return;
                                          if (result) {
                                            EasyLoading.show(status: _lang.deleting);
                                            final repo = TaxRepo();
                                            try {
                                              final result = await repo.deleteTax(id: singleTaxes[index].id.toString(), ref: ref, context: context);
                                              if (!context.mounted) return;
                                              if (result) {
                                                ref.invalidate(taxProvider);
                                                EasyLoading.showSuccess(_lang.deletedSuccessFully);
                                              } else {
                                                EasyLoading.showError(_lang.failedToDeleteTheTax);
                                              }
                                            } catch (e) {
                                              EasyLoading.showError('${_lang.errorDeletingTax}: $e');
                                            } finally {
                                              EasyLoading.dismiss();
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              size: 17,
                                              color: kWhite,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(lang.S.of(context).delete, style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              color: WidgetStateColor.resolveWith(
                                (Set<WidgetState> states) {
                                  // Use index to determine whether the row is even or odd
                                  return index % 2 == 0 ? Colors.grey.shade100 : Colors.white;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      //___________________________________Tax Group______________________________
                      const SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_lang.taxGroup, style: TextStyle(color: kTitleColor, fontWeight: FontWeight.bold)),
                                Text('(${_lang.combinationOfTheMultipleTaxes})', style: TextStyle(color: kGreyTextColor)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(left: 2, right: 2),
                              minimumSize: Size(60, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              backgroundColor: kSuccessColor,
                              elevation: 1.0,
                              foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                              shadowColor: kMainColor,
                              animationDuration: const Duration(milliseconds: 300),
                              textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddGroupTax()),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.plus,
                                  size: 15,
                                  color: kWhite,
                                ),
                                SizedBox(width: 4),
                                Text(_lang.add, style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
                          border: TableBorder.all(borderRadius: BorderRadius.circular(2.0), color: kBorderColorTextField),
                          dividerThickness: 1.0,
                          sortAscending: true,
                          showCheckboxColumn: false,
                          horizontalMargin: 5.0,
                          columnSpacing: 10,
                          dataRowMinHeight: 45,
                          showBottomBorder: true,
                          checkboxHorizontalMargin: 0.0,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                lang.S.of(context).name,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                '${_lang.taxRates} %',
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                _lang.subTaxes,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataColumn(
                              headingRowAlignment: MainAxisAlignment.center,
                              label: Text(
                                _lang.action,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          rows: List.generate(
                            groupTaxes.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    groupTaxes[index].name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(color: kGreyTextColor),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      groupTaxes[index].rate.toString(),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: kGreyTextColor),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Wrap(
                                    children: List.generate(
                                      groupTaxes[index].subTax?.length ?? 0,
                                      (i) {
                                        return Text(
                                          "${groupTaxes[index].subTax?[i].name ?? 'n/a'}, ",
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: kGreyTextColor),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(50, 25),
                                          padding: const EdgeInsets.only(left: 2, right: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          backgroundColor: Colors.green,
                                          elevation: 1.0,
                                          foregroundColor: kGreyTextColor.withValues(alpha: 0.1),
                                          shadowColor: kMainColor,
                                          animationDuration: const Duration(milliseconds: 300),
                                          textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => AddGroupTax(taxModel: groupTaxes[index])),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              FeatherIcons.edit,
                                              size: 15,
                                              color: kWhite,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              lang.S.of(context).edit,
                                              //'Edit',
                                              style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.only(left: 2, right: 2),
                                            minimumSize: Size(50, 25),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            backgroundColor: Colors.red,
                                            elevation: 1.0,
                                            foregroundColor: Colors.white.withValues(alpha: 0.1),
                                            shadowColor: Colors.red,
                                            animationDuration: const Duration(milliseconds: 300),
                                            textStyle: const TextStyle(color: kWhite)),
                                        onPressed: () async {
                                          bool result = await showDeleteAlert(context: context, itemsName: 'vat_&_tax');
                                          if (!context.mounted) return;
                                          if (result) {
                                            EasyLoading.show(status: _lang.deleting);
                                            final repo = TaxRepo();
                                            try {
                                              final result = await repo.deleteTax(id: groupTaxes[index].id.toString(), context: context, ref: ref);
                                              if (!context.mounted) return;
                                              if (result) {
                                                ref.invalidate(taxProvider);
                                                EasyLoading.showSuccess(_lang.deletedSuccessFully);
                                              } else {
                                                EasyLoading.showError(_lang.failedToDeleteTheTax);
                                              }
                                            } catch (e) {
                                              EasyLoading.showError('${_lang.errorDeletingTax}: $e');
                                            } finally {
                                              EasyLoading.dismiss();
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              size: 17,
                                              color: kWhite,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              lang.S.of(context).delete,
                                              //'Delete',
                                              style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              color: WidgetStateColor.resolveWith(
                                (Set<WidgetState> states) {
                                  // Use index to determine whether the row is even or odd
                                  return index % 2 == 0 ? Colors.grey.shade100 : Colors.white;
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            error: (e, stackTrace) {
              return Center(
                child: Text(e.toString()),
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ));
    }, error: (e, stack) {
      return Text(e.toString());
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
