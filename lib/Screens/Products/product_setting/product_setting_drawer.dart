import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/product_setting/provider/setting_provider.dart';
import 'package:mobile_pos/Screens/Products/product_setting/repo/product_setting_repo.dart';
import 'package:mobile_pos/constant.dart';

import 'model/get_product_setting_model.dart';
import 'model/product_setting_model.dart';

class ProductSettingsDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onSave;
  final Modules? modules;

  const ProductSettingsDrawer({
    super.key,
    this.onSave,
    this.modules,
  });

  @override
  ConsumerState<ProductSettingsDrawer> createState() => _ProductSettingsDrawerState();
}

class _ProductSettingsDrawerState extends ConsumerState<ProductSettingsDrawer> {
  final Map<String, bool> _switchValues = {};

  @override
  void initState() {
    super.initState();
    final modules = widget.modules;

    _switchValues.addAll({
      'Product Code': modules?.showProductCode == '1',
      'Product Stock': modules?.showProductStock == '1',
      'Sale': modules?.showProductSalePrice == '1',
      'Dealer': modules?.showProductDealerPrice == '1',
      'Wholesale Price': modules?.showProductWholesalePrice == '1',
      'Unit': modules?.showProductUnit == '1',
      'Brand': modules?.showProductBrand == '1',
      'Category': modules?.showProductCategory == '1',
      'Manufacturer': modules?.showProductManufacturer == '1',
      'Image': modules?.showProductImage == '1',
      'Show Expire Date': modules?.showExpireDate == '1',
      'Alert Qty': modules?.showAlertQty == '1',
      'Vat Id': modules?.showVatId == '1',
      'Vat Type': modules?.showVatType == '1',
      'Exclusive Price': modules?.showExclusivePrice == '1',
      'Inclusive Price': modules?.showInclusivePrice == '1',
      'Profit Percent': modules?.showProfitPercent == '1',
      'Capacity': modules?.showCapacity == '1',
      'Size': modules?.showSize == '1',
      'Type': modules?.showType == '1',
      'Weight': modules?.showWeight == '1',
      'Color': modules?.showColor == '1',
      'Batch No': modules?.showBatchNo == '1',
      'Show Manufacture Date': modules?.showMfgDate == '1',
      'Model': modules?.showModelNo == '1',
      'Show Single': modules?.showProductTypeSingle == '1',
      'Show Variant': modules?.showProductTypeVariant == '1',
      'Show Action': modules?.showAction == '1',
      'Default ExpireDate': modules?.defaultExpiredDate == '1',
      'Default Manufacture Date': modules?.defaultMfgDate == '1',
      'ExpireDate type': modules?.expireDateType == '1',
      'ManufactureDate type': modules?.mfgDateType == '1',
      // 'Show batch no.': modules?.showProductBatchNo == '1',
    });

    _saleController.text = modules?.defaultSalePrice ?? '';
    _wholesaleController.text = modules?.defaultWholesalePrice ?? '';
    _dealerController.text = modules?.defaultDealerPrice ?? '';
  }

  final TextEditingController _saleController = TextEditingController();
  final TextEditingController _wholesaleController = TextEditingController();
  final TextEditingController _dealerController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String getStringFromBool(Map<String, bool> map, String key) {
    return map[key] == true ? '1' : '0';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            child: Form(
              key: globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 4, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Product Settings',
                          style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Color(0xffE6E6E6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Switches List
                          ..._switchValues.entries.map(_buildSwitchTile),
                          Divider(),
                          SizedBox(height: 16),

                          // Price Fields
                          // Text('PRICE SETTINGS', style: Theme.of(context).textTheme.bodyMedium),
                          // SizedBox(height: 14),
                          // _buildPriceField('Sale Price', _saleController),
                          // SizedBox(height: 8),
                          // _buildPriceField('Wholesale Price', _wholesaleController),
                          // SizedBox(height: 8),
                          // _buildPriceField('Dealer Price', _dealerController),

                          // SizedBox(height: 16),

                          // Save Button
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if ((globalKey.currentState?.validate() ?? false)) {
                                    ProductSettingRepo setting = ProductSettingRepo();
                                    bool success;
                                    // Prepare the data for the update
                                    UpdateProductSettingModel data = UpdateProductSettingModel(
                                      productCode: getStringFromBool(_switchValues, 'Product Code'),
                                      productStock: getStringFromBool(_switchValues, 'Product Stock'),
                                      salePrice: getStringFromBool(_switchValues, 'Sale'),
                                      dealerPrice: getStringFromBool(_switchValues, 'Dealer'),
                                      wholesalePrice: getStringFromBool(_switchValues, 'Wholesale Price'),
                                      unit: getStringFromBool(_switchValues, 'Unit'),
                                      brand: getStringFromBool(_switchValues, 'Brand'),
                                      category: getStringFromBool(_switchValues, 'Category'),
                                      manufacturer: getStringFromBool(_switchValues, 'Manufacturer'),
                                      image: getStringFromBool(_switchValues, 'Image'),
                                      showExpireDate: getStringFromBool(_switchValues, 'Show Expire Date'),
                                      alertQty: getStringFromBool(_switchValues, 'Alert Qty'),
                                      vatId: getStringFromBool(_switchValues, 'Vat Id'),
                                      vatType: getStringFromBool(_switchValues, 'Vat Type'),
                                      exclusivePrice: getStringFromBool(_switchValues, 'Exclusive Price'),
                                      inclusivePrice: getStringFromBool(_switchValues, 'Inclusive Price'),
                                      profitPercent: getStringFromBool(_switchValues, 'Profit Percent'),
                                      capacity: getStringFromBool(_switchValues, 'Capacity'),
                                      size: getStringFromBool(_switchValues, 'Size'),
                                      type: getStringFromBool(_switchValues, 'Type'),
                                      weight: getStringFromBool(_switchValues, 'Weight'),
                                      color: getStringFromBool(_switchValues, 'Color'),
                                      batchNo: getStringFromBool(_switchValues, 'Batch No'),
                                      showManufactureDate: getStringFromBool(_switchValues, 'Show Manufacture Date'),
                                      model: getStringFromBool(_switchValues, 'Model'),
                                      showSingle: getStringFromBool(_switchValues, 'Show Single'),
                                      showVariant: getStringFromBool(_switchValues, 'Show Variant'),
                                      showAction: getStringFromBool(_switchValues, 'Show Action'),
                                      defaultExpireDate: getStringFromBool(_switchValues, 'Default ExpireDate'),
                                      defaultManufactureDate: getStringFromBool(_switchValues, 'Default Manufacture Date'),
                                      expireDateType: getStringFromBool(_switchValues, 'ExpireDate type'),
                                      manufactureDateType: getStringFromBool(_switchValues, 'ManufactureDate type'),
                                      showBatchNo: getStringFromBool(_switchValues, 'Show batch no.'),
                                      // defaultSalePrice: _saleController.text,
                                      // defaultDealerPrice: _dealerController.text,
                                      // defaultWholeSalePrice: _wholesaleController.text,
                                    );
                                    success = await setting.updateProductSetting(data: data);
                                    if (success) {
                                      EasyLoading.showSuccess('Update Successfully');
                                      ref.invalidate(fetchSettingProvider);
                                      widget.onSave?.call();
                                    } else {
                                      EasyLoading.showError('Please Try Again!');
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(),
                                child: Text('SAVE SETTINGS'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(MapEntry<String, bool> entry) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      title: Text(entry.key),
      trailing: Transform.scale(
        scale: 0.7,
        child: SizedBox(
          height: 20,
          width: 40,
          child: CupertinoSwitch(
            applyTheme: true,
            value: entry.value,
            onChanged: (value) => setState(() => _switchValues[entry.key] = value),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Color(0xff999999),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saleController.dispose();
    _wholesaleController.dispose();
    _dealerController.dispose();
    super.dispose();
  }
}
