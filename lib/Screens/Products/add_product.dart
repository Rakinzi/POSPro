import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/Repo/product_repo.dart';
import 'package:mobile_pos/Screens/Products/product_setting/product_setting_drawer.dart';
import 'package:mobile_pos/Screens/Products/product_setting/provider/setting_provider.dart';
import 'package:mobile_pos/Screens/product_category/category_list_screen.dart';
import 'package:mobile_pos/Screens/product_unit/model/unit_model.dart' as unit;
import 'package:mobile_pos/Screens/product_unit/unit_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../../widgets/dotted_border/custom_dotted_border.dart';
import '../product_brand/brands_list.dart';
import '../product_brand/model/brands_model.dart' as brand;
import '../product_category/model/category_model.dart';
import '../product_model/model/product_models_model.dart' as model;
import '../product_model/product_model_list.dart';
import '../vat_&_tax/model/vat_model.dart';
import '../vat_&_tax/provider/text_repo.dart';

class AddProduct extends ConsumerStatefulWidget {
  const AddProduct({super.key, this.productModel});

  final ProductModel? productModel;
  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends ConsumerState<AddProduct> {
  CategoryModel? selectedCategory;
  brand.Brand? selectedBrand;
  model.Data? selectedModel;
  unit.Unit? selectedUnit;
  late String productName, productStock, productSalePrice, productPurchasePrice, productCode;
  String? selectedExpireDate;
  String? selectedManufactureDate;
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController productUnitController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController discountPriceController = TextEditingController();
  TextEditingController purchaseExclusivePriceController = TextEditingController();
  TextEditingController profitMarginController = TextEditingController();
  TextEditingController purchaseInclusivePriceController = TextEditingController();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController wholeSalePriceController = TextEditingController();
  TextEditingController dealerPriceController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController stockAlertController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController manufactureDateController = TextEditingController();
  TextEditingController productBatchNumberController = TextEditingController();
  TextEditingController modelController = TextEditingController();

  void initializeControllers() {
    if (widget.productModel != null) {
      nameController = TextEditingController(text: widget.productModel?.productName ?? '');
      if (widget.productModel?.category != null) {
        final givenCategory = widget.productModel;
        categoryController = TextEditingController(text: widget.productModel?.category?.categoryName ?? '');
        selectedCategory = CategoryModel(
          id: widget.productModel?.category?.id,
          variationCapacity: givenCategory?.capacity != null,
          variationColor: givenCategory?.color != null,
          variationSize: givenCategory?.size != null,
          variationType: givenCategory?.type != null,
          variationWeight: givenCategory?.weight != null,
        );
      }
      if (widget.productModel?.brand != null) {
        brandController = TextEditingController(text: widget.productModel?.brand?.brandName ?? '');
        selectedBrand = brand.Brand(id: widget.productModel?.brand?.id);
      }
      if (widget.productModel?.unit != null) {
        productUnitController = TextEditingController(text: widget.productModel?.unit?.unitName ?? '');
        selectedUnit = unit.Unit(id: widget.productModel?.unit?.id);
      }
      if (widget.productModel?.modelId != null) {
        modelController = TextEditingController(text: widget.productModel?.productModel?.modelName ?? '');
        selectedModel = model.Data(id: widget.productModel?.modelId);
      }

      productStockController = TextEditingController(text: widget.productModel?.productStockSum?.toString() ?? '');

      selectedTaxType = widget.productModel?.vatType ?? "Exclusive";
      if (widget.productModel?.vatType?.toLowerCase() == 'exclusive' && widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        purchaseExclusivePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productPurchasePrice?.toStringAsFixed(2));
        purchaseInclusivePriceController =
            TextEditingController(text: ((widget.productModel?.stocks?.first.productPurchasePrice ?? 0) + (widget.productModel?.vatAmount ?? 0)).toStringAsFixed(2));
      } else if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        purchaseInclusivePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productPurchasePrice?.toStringAsFixed(2));
        purchaseExclusivePriceController =
            TextEditingController(text: ((widget.productModel?.stocks?.first.productPurchasePrice ?? 0) - (widget.productModel?.vatAmount ?? 0)).toStringAsFixed(2));
      }
      if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        profitMarginController = TextEditingController(text: widget.productModel?.stocks?.first.profitPercent?.toStringAsFixed(2) ?? '');
      }

      productCodeController = TextEditingController(text: widget.productModel?.productCode ?? '');
      // if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
      //   salePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productSalePrice?.toString() ?? '');
      // } else if (settingData?.defaultSalePrice != null && (settingData?.defaultSalePrice?.isNotEmpty ?? false)) {
      //   salePriceController = TextEditingController(text: settingData?.defaultSalePrice);
      // }
      //
      // if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
      //   wholeSalePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productWholeSalePrice?.toString() ?? '');
      // } else if (settingData?.defaultWholesalePrice != null && (settingData?.defaultWholesalePrice?.isNotEmpty ?? false)) {
      //   wholeSalePriceController = TextEditingController(text: settingData?.defaultWholesalePrice);
      // }
      //
      // if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
      //   dealerPriceController = TextEditingController(text: widget.productModel?.stocks?.first.productDealerPrice?.toString() ?? '');
      // } else if (settingData?.defaultDealerPrice != null && (settingData?.defaultDealerPrice?.isNotEmpty ?? false)) {
      //   dealerPriceController = TextEditingController(text: settingData?.defaultDealerPrice);
      // }
      if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        salePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productSalePrice?.toString() ?? '');
      }
      if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        wholeSalePriceController = TextEditingController(text: widget.productModel?.stocks?.first.productWholeSalePrice?.toStringAsFixed(2) ?? '');
      }
      if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        dealerPriceController = TextEditingController(text: widget.productModel?.stocks?.first.productDealerPrice?.toStringAsFixed(2) ?? '');
      }
      manufacturerController = TextEditingController(text: widget.productModel?.productManufacturer ?? '');
      sizeController = TextEditingController(text: widget.productModel?.size ?? '');
      colorController = TextEditingController(text: widget.productModel?.color ?? '');
      weightController = TextEditingController(text: widget.productModel?.weight ?? '');
      typeController = TextEditingController(text: widget.productModel?.type ?? '');
      capacityController = TextEditingController(text: widget.productModel?.capacity ?? '');
      stockAlertController = TextEditingController(text: widget.productModel?.alertQty.toString() ?? '');
      if (widget.productModel?.expireDate != null) {
        expireDateController.text = DateFormat.yMd().format(DateTime.parse(widget.productModel?.expireDate.toString() ?? ''));
        selectedExpireDate = widget.productModel?.expireDate?.toString();
      }
      if (widget.productModel?.stocks != null && widget.productModel!.stocks!.isNotEmpty) {
        productData = CreateProductModel(
          batchNo: widget.productModel!.stocks!.map((e) => e.batchNo ?? '').toList(),
          productStock: widget.productModel!.stocks!.map((e) => e.productStock?.toString() ?? '0').toList(),
          batchPurchasePrice: widget.productModel!.stocks!.map((e) => e.productPurchasePrice?.toString() ?? '0').toList(),
          batchProfitPercent: widget.productModel!.stocks!.map((e) => e.profitPercent?.toString() ?? '0').toList(),
          batchSalePrice: widget.productModel!.stocks!.map((e) => e.productSalePrice?.toString() ?? '0').toList(),
          batchWholeSalePrice: widget.productModel!.stocks!.map((e) => e.productWholeSalePrice?.toString() ?? '0').toList(),
          batchDealerPrice: widget.productModel!.stocks!.map((e) => e.productDealerPrice?.toString() ?? '0').toList(),
          batchExpireDate: widget.productModel!.stocks!.map((e) => e.expireDate ?? '').toList(),
          batchMfgDate: widget.productModel!.stocks!.map((e) => e.mfgDate ?? '').toList(),
        );

        _selectedType = widget.productModel?.productType == 'variant' ? ProductType.variant : ProductType.single;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    brandController.dispose();
    productUnitController.dispose();
    productStockController.dispose();
    salePriceController.dispose();
    discountPriceController.dispose();
    purchaseExclusivePriceController.dispose();
    profitMarginController.dispose();
    purchaseInclusivePriceController.dispose();
    productCodeController.dispose();
    wholeSalePriceController.dispose();
    dealerPriceController.dispose();
    manufacturerController.dispose();
    sizeController.dispose();
    colorController.dispose();
    weightController.dispose();
    typeController.dispose();
    capacityController.dispose();
    modelController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  VatModel? selectedTax;
  String selectedTaxType = 'exclusive';
  List<String> codeList = [];
  String promoCodeHint = 'Enter Product Code';

  void calculatePurchaseAndMrp({String? from}) {
    num taxRate = selectedTax?.rate ?? 0;
    num purchaseExc = 0;
    num purchaseInc = 0;
    num profitMargin = num.tryParse(profitMarginController.text) ?? 0;
    num salePrice = 0;

    // Calculate Purchase Exclusive Price if input is 'purchase_inc'
    if (from == 'purchase_inc') {
      purchaseExc = (num.tryParse(purchaseInclusivePriceController.text) ?? 0) / (1 + taxRate / 100);
      purchaseExclusivePriceController.text = purchaseExc.toStringAsFixed(2);
    } else {
      purchaseExc = num.tryParse(purchaseExclusivePriceController.text) ?? 0;
      // Calculate Purchase Inclusive Price if not 'purchase_inc'
      purchaseInc = purchaseExc + (purchaseExc * taxRate / 100);
      purchaseInclusivePriceController.text = purchaseInc.toStringAsFixed(2);
    }

    purchaseInc = num.tryParse(purchaseInclusivePriceController.text) ?? 0;

    // If input is 'mrp', recalculate profit margin based on sale price
    if (from == 'mrp') {
      salePrice = num.tryParse(salePriceController.text) ?? 0;

      // Calculate profit margin as a percentage
      profitMargin =
          ((salePrice - (selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) / (selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) *
              100;

      // Update the profit margin text field with percentage
      profitMarginController.text = profitMargin.toStringAsFixed(2);
    } else {
      // Calculate Sale Price based on Tax Type
      salePrice = (selectedTaxType.toLowerCase() == 'exclusive') ? purchaseExc + (purchaseExc * profitMargin / 100) : purchaseInc + (purchaseInc * profitMargin / 100);

      // Update the sale price text field
      salePriceController.text = salePrice.toStringAsFixed(2);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  GlobalKey<FormState> key = GlobalKey();

  bool isAlreadyBuild = false;

  // key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProductType _selectedType = ProductType.single;

  CreateProductModel productData = CreateProductModel();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingData = ref.watch(fetchSettingProvider);
    return GlobalPopup(
        child: settingData.when(data: (snapShot) {
      // initializeControllers(snapShot.data?.modules);
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: kWhite,
        appBar: AppBar(
            surfaceTintColor: kWhite,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              widget.productModel != null ? lang.S.of(context).updateProduct : lang.S.of(context).addNewProduct,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 16),
                icon: Icon(
                  FeatherIcons.settings,
                  color: Color(0xff4B5563),
                ),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                tooltip: 'Open Settings',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                height: 1,
                thickness: 1,
                color: kBottomBorder,
              ),
            )),
        endDrawer: ProductSettingsDrawer(
          onSave: () => Navigator.of(context).pop(),
          modules: snapShot.data?.modules,
        ),
        body: Consumer(builder: (context, ref, __) {
          final taxesData = ref.watch(taxProvider);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // product image
                    if (snapShot.data?.modules?.showProductImage == '1')
                      Column(
                        children: [
                          Text(
                            'Image',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kTitleColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          pickedImage == null
                              ? InkWell(
                                  onTap: () {
                                    uploadImageDialog(context, theme);
                                  },
                                  child: CustomDottedBorder(
                                    color: const Color(0xFFB7B7B7),
                                    borderType: BorderType.rRect,
                                    radius: const Radius.circular(8),
                                    padding: const EdgeInsets.all(6),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                      child: SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(IconlyLight.camera, color: kNeutralColor),
                                            Text(
                                              'Upload',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: kNeutralColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    uploadImageDialog(context, theme);
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        height: 70,
                                        width: 70,
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          border: Border.all(color: kBorderColorTextField),
                                        ),
                                        child: Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: FileImage(File(pickedImage!.path)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              pickedImage = null;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: kMainColor,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),

                    ///___________Name_____________________________
                    SizedBox(height: 24),
                    _buildTextField(
                      controller: nameController,
                      label: lang.S.of(context).productName,
                      hint: lang.S.of(context).enterProductName,
                      validator: (value) => value!.isEmpty ? lang.S.of(context).pleaseEnterAValidProductName : null,
                    ),

                    ///__________Code__________________________
                    if (snapShot.data?.modules?.showProductCode == '1')
                      Column(
                        children: [
                          SizedBox(height: 24),
                          TextFormField(
                            controller: productCodeController,
                            onChanged: (value) {
                              setState(() {
                                productCode = value;
                                promoCodeHint = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              if (codeList.contains(value)) {
                                EasyLoading.showError(
                                  lang.S.of(context).thisProductAlreadyAdded,
                                  // 'This Product Already added!'
                                );
                                productCodeController.clear();
                              } else {
                                setState(() {
                                  productCode = value;
                                  promoCodeHint = value;
                                });
                              }
                            },
                            decoration: kInputDecoration.copyWith(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              // labelText: lang.S.of(context).productCode,
                              labelText: 'SKU / Code',
                              hintText: lang.S.of(context).enterProductCode,
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(left: 8),
                              suffixIcon: InkWell(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BarcodeScannerWidget(
                                      onBarcodeFound: (String code) {
                                        productCodeController.text = code;
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  height: 48,
                                  width: 44,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                      color: Color(0xffD8D8D8).withValues(alpha: 0.3)),
                                  child: SvgPicture.asset(height: 28, 'assets/qr_new.svg'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ///_______Category__________________________________

                    /// ___________ Category Section _____________________
                    if (snapShot.data?.modules?.showProductCategory == '1')
                      Column(
                        children: [
                          SizedBox(height: 24),
                          TextFormField(
                            readOnly: true,
                            controller: categoryController,
                            onTap: () async {
                              selectedCategory = await const CategoryList(
                                isFromProductList: false,
                              ).launch(context);
                              setState(() {
                                categoryController.text = selectedCategory?.categoryName ?? '';
                              });
                            },
                            decoration: kInputDecoration.copyWith(
                              suffixIcon: selectedCategory != null
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          categoryController.clear();
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    )
                                  : const Icon(Icons.keyboard_arrow_down),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Category',
                              hintText: lang.S.of(context).selectProductCategory,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),

                    /// ___________ Size & Color Section _____________________
                    Visibility(
                      visible: ((selectedCategory?.variationSize ?? false) && snapShot.data?.modules?.showSize == '1') ||
                          ((selectedCategory?.variationColor ?? false) && snapShot.data?.modules?.showColor == '1'),
                      child: SizedBox(height: 24),
                    ),

                    Row(
                      children: [
                        if ((selectedCategory?.variationSize ?? false) && snapShot.data?.modules?.showSize == '1')
                          Expanded(
                            child: _buildTextField(
                              controller: sizeController,
                              label: lang.S.of(context).size,
                              hint: lang.S.of(context).enterSize,
                            ),
                          ),
                        if ((selectedCategory?.variationSize ?? false) &&
                            (selectedCategory?.variationColor ?? false) &&
                            ((snapShot.data?.modules?.showSize == '1') && (snapShot.data?.modules?.showColor == '1')))
                          const SizedBox(width: 14),
                        if ((selectedCategory?.variationColor ?? false) && snapShot.data?.modules?.showColor == '1')
                          Expanded(
                            child: _buildTextField(
                              controller: colorController,
                              label: lang.S.of(context).color,
                              hint: lang.S.of(context).enterColor,
                            ),
                          ),
                      ],
                    ),

                    /// ___________ Weight & Capacity Section _____________________
                    Visibility(
                      visible: ((selectedCategory?.variationWeight ?? false) && snapShot.data?.modules?.showWeight == '1') ||
                          ((selectedCategory?.variationCapacity ?? false) && snapShot.data?.modules?.showCapacity == '1'),
                      child: SizedBox(height: 24),
                    ),

                    Row(
                      children: [
                        if ((selectedCategory?.variationWeight ?? false) && snapShot.data?.modules?.showWeight == '1')
                          Expanded(
                            child: _buildTextField(
                              controller: weightController,
                              label: lang.S.of(context).weight,
                              hint: lang.S.of(context).enterWeight,
                            ),
                          ),
                        if ((selectedCategory?.variationWeight ?? false) &&
                            (selectedCategory?.variationCapacity ?? false) &&
                            (snapShot.data?.modules?.showWeight == '1') &&
                            (snapShot.data?.modules?.showCapacity == '1'))
                          const SizedBox(width: 14),
                        if ((selectedCategory?.variationCapacity ?? false) && snapShot.data?.modules?.showCapacity == '1')
                          Expanded(
                            child: _buildTextField(
                              controller: capacityController,
                              label: lang.S.of(context).capacity,
                              hint: lang.S.of(context).enterCapacity,
                            ),
                          ),
                      ],
                    ),

                    ///___________Type______________________________________
                    if ((selectedCategory?.variationType ?? false) && (snapShot.data?.modules?.showType == '1')) ...[
                      SizedBox(height: 24),
                      _buildTextField(
                        controller: typeController,
                        label: lang.S.of(context).type,
                        hint: lang.S.of(context).enterType,
                      ),
                    ],

                    ///_______Brand__________________________________
                    if (snapShot.data?.modules?.showProductBrand == '1') ...[
                      SizedBox(height: 24),
                      TextFormField(
                        readOnly: true,
                        controller: brandController,
                        validator: (value) {
                          return null;
                        },
                        onTap: () async {
                          selectedBrand = await const BrandsList(
                            isFromProductList: false,
                          ).launch(context);
                          setState(() {
                            brandController.text = selectedBrand?.brandName ?? '';
                          });
                        },
                        decoration: kInputDecoration.copyWith(
                          suffixIcon: selectedBrand != null
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedBrand = null;
                                      brandController.clear();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                )
                              : const Icon(Icons.keyboard_arrow_down),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Brand',
                          hintText: lang.S.of(context).selectABrand,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],

                    ///_______Model/Unit__________________________________
                    if ((snapShot.data?.modules?.showModelNo == '1') || (snapShot.data?.modules?.showProductUnit == '1')) SizedBox(height: 24),

                    Row(
                      children: [
                        if (snapShot.data?.modules?.showModelNo == '1')
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: modelController,
                              validator: (value) => null,
                              onTap: () async {
                                selectedModel = await const ProductModelList(
                                  fromProductList: false,
                                ).launch(context);
                                setState(() {
                                  modelController.text = selectedModel?.name ?? '';
                                });
                              },
                              decoration: kInputDecoration.copyWith(
                                suffixIcon: selectedModel != null
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedModel = null;
                                            modelController.clear();
                                          });
                                        },
                                        child: const Icon(Icons.close, color: Colors.red, size: 16),
                                      )
                                    : const Icon(Icons.keyboard_arrow_down),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Model',
                                hintText: 'Select Model',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        if ((snapShot.data?.modules?.showModelNo == '1') && (snapShot.data?.modules?.showProductUnit == '1')) const SizedBox(width: 14),
                        if (snapShot.data?.modules?.showProductUnit == '1')
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: productUnitController,
                              validator: (value) => null,
                              onTap: () async {
                                selectedUnit = await const UnitList(
                                  isFromProductList: false,
                                ).launch(context);
                                setState(() {
                                  productUnitController.text = selectedUnit?.unitName ?? '';
                                });
                              },
                              decoration: kInputDecoration.copyWith(
                                suffixIcon: selectedUnit != null
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedUnit = null;
                                            productUnitController.clear();
                                          });
                                        },
                                        child: const Icon(Icons.close, color: Colors.red, size: 16),
                                      )
                                    : const Icon(Icons.keyboard_arrow_down),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Unit',
                                hintText: lang.S.of(context).selectProductUnit,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                      ],
                    ),

                    ///_____________Stock__&_low_stock__________________________
                    if (_selectedType == ProductType.single) ...[
                      if ((snapShot.data?.modules?.showProductStock == '1') || (snapShot.data?.modules?.showAlertQty == '1')) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (snapShot.data?.modules?.showProductStock == '1')
                              Expanded(
                                child: TextFormField(
                                  controller: productStockController,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  keyboardType: TextInputType.number,
                                  decoration: kInputDecoration.copyWith(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: lang.S.of(context).stock,
                                    hintText: lang.S.of(context).enterStock,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            if (snapShot.data?.modules?.showProductStock == '1' && snapShot.data?.modules?.showAlertQty == '1') const SizedBox(width: 14),
                            if (snapShot.data?.modules?.showAlertQty == '1')
                              Expanded(
                                child: TextFormField(
                                  controller: stockAlertController,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  keyboardType: TextInputType.number,
                                  decoration: kInputDecoration.copyWith(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: 'Low Stock',
                                    hintText: 'Enter low stock',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if ((snapShot.data?.modules?.showMfgDate == '1') || (snapShot.data?.modules?.showProductExpireDate == '1')) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (snapShot.data?.modules?.showMfgDate == '1')
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  controller: manufactureDateController,
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Manufacture. Date',
                                    hintText: 'Select Date',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015, 8),
                                          lastDate: DateTime(2101),
                                          context: context,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            manufactureDateController.text = DateFormat.yMd().format(picked);
                                            selectedManufactureDate = picked.toString();
                                          });
                                        }
                                      },
                                      icon: const Icon(IconlyLight.calendar, size: 22),
                                    ),
                                  ),
                                ),
                              ),
                            if (snapShot.data?.modules?.showMfgDate == '1' && snapShot.data?.modules?.showExpireDate == '1') const SizedBox(width: 14),
                            if (snapShot.data?.modules?.showExpireDate == '1')
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  controller: expireDateController,
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Exp. Date',
                                    hintText: 'Select Date',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015, 8),
                                          lastDate: DateTime(2101),
                                          context: context,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            expireDateController.text = DateFormat.yMd().format(picked);
                                            selectedExpireDate = picked.toString();
                                          });
                                        }
                                      },
                                      icon: const Icon(IconlyLight.calendar, size: 22),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ] else if (snapShot.data?.modules?.showAlertQty == '1') ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: TextFormField(
                          controller: stockAlertController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          keyboardType: TextInputType.number,
                          decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Low Stock',
                            hintText: 'Enter low stock',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],

                    // Radio buttons
                    RadioGroup<ProductType>(
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value == null) return;
                        final allowSingle = snapShot.data?.modules?.showProductTypeSingle == '1';
                        final allowVariant = snapShot.data?.modules?.showProductTypeVariant == '1';
                        if (value == ProductType.single && !allowSingle) return;
                        if (value == ProductType.variant && !allowVariant) return;
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio<ProductType>(
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            value: ProductType.single,
                          ),
                          Text(
                            'Single',
                            style: TextStyle(
                              color: (snapShot.data?.modules?.showProductTypeSingle == '1') ? kTitleColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Radio<ProductType>(
                            value: ProductType.variant,
                          ),
                          Text(
                            'Batch',
                            style: TextStyle(
                              color: (snapShot.data?.modules?.showProductTypeVariant == '1') ? kTitleColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //todo : have to change here for batch Tahmid Tarongo.
                    //----------add variant button
                    if (_selectedType != ProductType.single)
                      TextButton.icon(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            Color(0xffFEF0F1),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            isScrollControlled: true,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.only(start: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Add Variant Details',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.close, size: 18),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(color: kBorderColor, height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16),

                                      /// Batch No. & Stock
                                      if (snapShot.data?.modules?.showBatchNo == '1' || snapShot.data?.modules?.showProductStock == '1') ...[
                                        Row(
                                          children: [
                                            if (snapShot.data?.modules?.showBatchNo == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: productBatchNumberController,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Batch No.',
                                                    hintText: 'Enter Batch No.',
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            if (snapShot.data?.modules?.showBatchNo == '1' && snapShot.data?.modules?.showProductStock == '1') SizedBox(width: 14),
                                            if (snapShot.data?.modules?.showProductStock == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: productStockController,
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).stock,
                                                    hintText: lang.S.of(context).enterStock,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],

                                      /// Purchase Price Exc. & Inc.
                                      if (snapShot.data?.modules?.showExclusivePrice == '1' || snapShot.data?.modules?.showInclusivePrice == '1') ...[
                                        SizedBox(height: 24),
                                        Row(
                                          children: [
                                            if (snapShot.data?.modules?.showExclusivePrice == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: purchaseExclusivePriceController,
                                                  onChanged: (value) => calculatePurchaseAndMrp(),
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Purchase Price Exc.',
                                                    hintText: lang.S.of(context).enterPurchasePrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            if (snapShot.data?.modules?.showExclusivePrice == '1' && snapShot.data?.modules?.showInclusivePrice == '1') SizedBox(width: 14),
                                            if (snapShot.data?.modules?.showInclusivePrice == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: purchaseInclusivePriceController,
                                                  onChanged: (value) => calculatePurchaseAndMrp(from: "purchase_inc"),
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: "Purchase Price Inc.",
                                                    hintText: lang.S.of(context).enterSaltingPrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],

                                      /// Profit Margin & MRP
                                      if (snapShot.data?.modules?.showProfitPercent == '1' || snapShot.data?.modules?.showProductSalePrice == '1') ...[
                                        SizedBox(height: 24),
                                        Row(
                                          children: [
                                            if (snapShot.data?.modules?.showProfitPercent == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: profitMarginController,
                                                  onChanged: (value) => calculatePurchaseAndMrp(),
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Profit Margin (%)',
                                                    hintText: lang.S.of(context).enterPurchasePrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            if (snapShot.data?.modules?.showProfitPercent == '1' && snapShot.data?.modules?.showProductSalePrice == '1') SizedBox(width: 14),
                                            if (snapShot.data?.modules?.showProductSalePrice == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: salePriceController,
                                                  onChanged: (value) => calculatePurchaseAndMrp(from: 'mrp'),
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).mrp,
                                                    hintText: lang.S.of(context).enterSaltingPrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],

                                      /// Wholesale & Dealer Price
                                      if (snapShot.data?.modules?.showProductWholesalePrice == '1' || snapShot.data?.modules?.showProductDealerPrice == '1') ...[
                                        SizedBox(height: 24),
                                        Row(
                                          children: [
                                            if (snapShot.data?.modules?.showProductWholesalePrice == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: wholeSalePriceController,
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).wholeSalePrice,
                                                    hintText: lang.S.of(context).enterWholesalePrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            if (snapShot.data?.modules?.showProductWholesalePrice == '1' && snapShot.data?.modules?.showProductDealerPrice == '1')
                                              SizedBox(width: 14),
                                            if (snapShot.data?.modules?.showProductDealerPrice == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  controller: dealerPriceController,
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                                  keyboardType: TextInputType.number,
                                                  decoration: kInputDecoration.copyWith(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).dealerPrice,
                                                    hintText: lang.S.of(context).enterDealerPrice,
                                                    border: const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],

                                      /// Manufacture & Expiry Date
                                      if (snapShot.data?.modules?.showMfgDate == '1' || snapShot.data?.modules?.showExpireDate == '1') ...[
                                        SizedBox(height: 24),
                                        Row(
                                          children: [
                                            if (snapShot.data?.modules?.showMfgDate == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  keyboardType: TextInputType.name,
                                                  readOnly: true,
                                                  controller: manufactureDateController,
                                                  decoration: kInputDecoration.copyWith(
                                                    labelText: 'Manufacture. Date',
                                                    hintText: 'Select Date',
                                                    border: const OutlineInputBorder(),
                                                    suffixIcon: IconButton(
                                                      onPressed: () async {
                                                        final DateTime? picked = await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now(),
                                                          firstDate: DateTime(2015, 8),
                                                          lastDate: DateTime(2101),
                                                        );
                                                        if (picked != null) {
                                                          setState(() {
                                                            manufactureDateController.text = DateFormat.yMd().format(picked);
                                                            selectedManufactureDate = picked.toString();
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(IconlyLight.calendar, size: 22),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (snapShot.data?.modules?.showMfgDate == '1' && snapShot.data?.modules?.showExpireDate == '1') SizedBox(width: 14),
                                            if (snapShot.data?.modules?.showExpireDate == '1')
                                              Expanded(
                                                child: TextFormField(
                                                  keyboardType: TextInputType.name,
                                                  readOnly: true,
                                                  controller: expireDateController,
                                                  decoration: kInputDecoration.copyWith(
                                                    labelText: 'Exp. Date',
                                                    hintText: 'Select Date',
                                                    border: const OutlineInputBorder(),
                                                    suffixIcon: IconButton(
                                                      onPressed: () async {
                                                        final DateTime? picked = await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now(),
                                                          firstDate: DateTime(2015, 8),
                                                          lastDate: DateTime(2101),
                                                        );
                                                        if (picked != null) {
                                                          setState(() {
                                                            expireDateController.text = DateFormat.yMd().format(picked);
                                                            selectedExpireDate = picked.toString();
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(IconlyLight.calendar, size: 22),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],

                                      /// Save / Cancel Buttons
                                      SizedBox(height: 24),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  productBatchNumberController.clear();
                                                  productStockController.clear();
                                                  purchaseExclusivePriceController.clear();
                                                  purchaseInclusivePriceController.clear();
                                                  profitMarginController.clear();
                                                  salePriceController.clear();
                                                  wholeSalePriceController.clear();
                                                  dealerPriceController.clear();
                                                  expireDateController.clear();
                                                  manufactureDateController.clear();
                                                  selectedExpireDate = null;
                                                  selectedManufactureDate = null;
                                                  Navigator.pop(context);
                                                },
                                                style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: Color(0xffF68A3D)))),
                                                child: Text(
                                                  'Cancel',
                                                  style: theme.textTheme.bodyMedium?.copyWith(color: Color(0xffF68A3D)),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Add data and clear fields
                                                  productData.batchNo ??= [];
                                                  productData.productStock ??= [];
                                                  productData.batchPurchasePrice ??= [];
                                                  productData.batchProfitPercent ??= [];
                                                  productData.batchSalePrice ??= [];
                                                  productData.batchWholeSalePrice ??= [];
                                                  productData.batchDealerPrice ??= [];
                                                  productData.batchExpireDate ??= [];
                                                  productData.batchMfgDate ??= [];

                                                  setState(() {
                                                    productData.batchNo!.add(productBatchNumberController.text);
                                                    productData.productStock!.add(productStockController.text);
                                                    productData.batchPurchasePrice!.add(purchaseExclusivePriceController.text);
                                                    productData.batchProfitPercent!.add(profitMarginController.text);
                                                    productData.batchSalePrice!.add(salePriceController.text);
                                                    productData.batchWholeSalePrice!.add(wholeSalePriceController.text);
                                                    productData.batchDealerPrice!.add(dealerPriceController.text);
                                                    productData.batchExpireDate!.add(selectedExpireDate ?? '');
                                                    productData.batchMfgDate!.add(selectedManufactureDate ?? '');
                                                  });

                                                  productBatchNumberController.clear();
                                                  productStockController.clear();
                                                  purchaseExclusivePriceController.clear();
                                                  purchaseInclusivePriceController.clear();
                                                  profitMarginController.clear();
                                                  salePriceController.clear();
                                                  wholeSalePriceController.clear();
                                                  dealerPriceController.clear();
                                                  expireDateController.clear();
                                                  manufactureDateController.clear();
                                                  selectedExpireDate = null;
                                                  selectedManufactureDate = null;

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Variant added successfully!')),
                                                  );

                                                  Navigator.pop(context);
                                                },
                                                child: Text('Save Variant'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.add, color: kMainColor),
                        label: Text(
                          'Add Variant',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: kMainColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    // variants list
                    if (_selectedType != ProductType.single && (productData.batchNo?.isNotEmpty ?? false))
                      ListView.separated(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: productData.batchNo?.length ?? 0,
                        separatorBuilder: (context, index) => Divider(
                          thickness: 0.3,
                          color: kBorderColorTextField,
                        ),
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: ValueKey('${productData.batchNo?[index]}_$index'),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              extentRatio: 0.3,
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _editBatch(index),
                                  backgroundColor: Color(0xffFEF0F1),
                                  foregroundColor: Color(0xff34C759),
                                  icon: Icons.mode_edit_outline_outlined,
                                  padding: EdgeInsets.zero,
                                ),
                                SlidableAction(
                                  padding: EdgeInsets.zero,
                                  onPressed: (context) {
                                    setState(() {
                                      productData.batchNo?.removeAt(index);
                                      productData.productStock?.removeAt(index);
                                      productData.batchPurchasePrice?.removeAt(index);
                                      productData.batchProfitPercent?.removeAt(index);
                                      productData.batchSalePrice?.removeAt(index);
                                      productData.batchWholeSalePrice?.removeAt(index);
                                      productData.batchDealerPrice?.removeAt(index);
                                      productData.batchExpireDate?.removeAt(index);
                                      productData.batchMfgDate?.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Variant deleted successfully!')),
                                    );
                                  },
                                  backgroundColor: Color(0xffFEF0F1),
                                  foregroundColor: kMainColor,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Batch: ${productData.batchNo?[index] ?? 'N/A'}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: kTitleColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Sale: \$${productData.batchSalePrice?[index] ?? '0'}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: kTitleColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Stock: ',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: kNeutralColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: productData.productStock?[index] ?? '0',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Color(0xff34C759),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Purchase: \$${productData.batchPurchasePrice?[index] ?? '0'}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: kTitleColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    ///-----------Applicable tax and Type-----------------------------
                    if (snapShot.data?.modules?.showVatType == '1' || snapShot.data?.modules?.showVatId == '1') SizedBox(height: 16),

                    if (snapShot.data?.modules?.showVatType == '1' || snapShot.data?.modules?.showVatId == '1')
                      Row(
                        children: [
                          if (snapShot.data?.modules?.showVatType == '1')
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                hint: const Text('Select Type'),
                                decoration: kInputDecoration.copyWith(labelText: "Tax Type"),
                                initialValue: selectedTaxType,
                                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                items: ["inclusive", "exclusive"]
                                    .map((type) => DropdownMenuItem<String?>(
                                          value: type,
                                          child: Text(type, style: const TextStyle(fontWeight: FontWeight.normal)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  selectedTaxType = value!;
                                  calculatePurchaseAndMrp();
                                },
                              ),
                            ),
                          if (snapShot.data?.modules?.showVatType == '1' && snapShot.data?.modules?.showVatId == '1') const SizedBox(width: 14),
                          if (snapShot.data?.modules?.showVatId == '1')
                            Expanded(
                              child: taxesData.when(
                                data: (dataList) {
                                  if (widget.productModel != null && widget.productModel?.vatId != null && !isAlreadyBuild) {
                                    final matched = dataList.firstWhere(
                                      (element) => element.id == widget.productModel?.vatId,
                                      orElse: () => VatModel(),
                                    );
                                    if (matched.id != null) selectedTax = matched;
                                    isAlreadyBuild = true;
                                  }
                                  return DropdownButtonFormField<VatModel>(
                                    hint: const Text(
                                      'Select Tax',
                                      style: TextStyle(fontWeight: FontWeight.normal, color: kGreyTextColor),
                                    ),
                                    icon: selectedTax != null
                                        ? GestureDetector(
                                            onTap: () {
                                              selectedTax = null;
                                              calculatePurchaseAndMrp();
                                            },
                                            child: const Icon(Icons.close, color: Colors.red, size: 16),
                                          )
                                        : const Icon(Icons.keyboard_arrow_down_outlined),
                                    decoration: kInputDecoration.copyWith(labelText: "Select Tax"),
                                    initialValue: selectedTax,
                                    items: dataList
                                        .where((vat) => vat.status == true)
                                        .map((vat) => DropdownMenuItem<VatModel>(
                                              value: vat,
                                              child: Text('${vat.name ?? ''} ${vat.rate}%', style: const TextStyle(fontWeight: FontWeight.normal)),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      selectedTax = value!;
                                      calculatePurchaseAndMrp();
                                    },
                                  );
                                },
                                error: (error, stackTrace) => Text(error.toString()),
                                loading: () => Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: DropdownButtonFormField<VatModel>(
                                    hint: const Text(
                                      'Select Tax',
                                      style: TextStyle(fontWeight: FontWeight.normal, color: kGreyTextColor),
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                    decoration: kInputDecoration.copyWith(labelText: "Select Tax"),
                                    items: const [],
                                    onChanged: (value) {},
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                    if (_selectedType == ProductType.single)
                      Column(
                        children: [
                          ///_________Purchase_price_exclusive_&&_Inclusive____________________
                          if (snapShot.data?.modules?.showExclusivePrice == '1' || snapShot.data?.modules?.showInclusivePrice == '1') ...[
                            SizedBox(height: 24),
                            Row(
                              children: [
                                if (snapShot.data?.modules?.showExclusivePrice == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: purchaseExclusivePriceController,
                                      onChanged: (value) => calculatePurchaseAndMrp(),
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return lang.S.of(context).pleaseEnterAValidProductName;
                                      //   }
                                      //   return null;
                                      // },
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: 'Purchase Price Exc.',
                                        hintText: lang.S.of(context).enterPurchasePrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                if (snapShot.data?.modules?.showExclusivePrice == '1' && snapShot.data?.modules?.showInclusivePrice == '1') SizedBox(width: 14),
                                if (snapShot.data?.modules?.showInclusivePrice == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: purchaseInclusivePriceController,
                                      onChanged: (value) => calculatePurchaseAndMrp(from: "purchase_inc"),
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return lang.S.of(context).pleaseEnterAValidSalePrice;
                                      //   }
                                      //   return null;
                                      // },
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: "Purchase Price Inc.",
                                        hintText: lang.S.of(context).enterSaltingPrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          ///_________Purchase_price__&&______mrp_____________________
                          if (snapShot.data?.modules?.showProfitPercent == '1' || snapShot.data?.modules?.showProductSalePrice == '1') ...[
                            SizedBox(height: 24),
                            Row(
                              children: [
                                if (snapShot.data?.modules?.showProfitPercent == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: profitMarginController,
                                      onChanged: (value) => calculatePurchaseAndMrp(),
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return lang.S.of(context).pleaseEnterAValidProductName;
                                      //   }
                                      //   return null;
                                      // },
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: 'Profit Margin (%)',
                                        hintText: lang.S.of(context).enterPurchasePrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                if (snapShot.data?.modules?.showProfitPercent == '1' && snapShot.data?.modules?.showProductSalePrice == '1') SizedBox(width: 14),
                                if (snapShot.data?.modules?.showProductSalePrice == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: salePriceController,
                                      onChanged: (value) => calculatePurchaseAndMrp(from: 'mrp'),
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return lang.S.of(context).pleaseEnterAValidSalePrice;
                                      //   }
                                      //   return null;
                                      // },
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).mrp,
                                        hintText: lang.S.of(context).enterSaltingPrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          ///_______-wholesalePrice_dealerprice_________________
                          if (snapShot.data?.modules?.showProductWholesalePrice == '1' || snapShot.data?.modules?.showProductDealerPrice == '1') ...[
                            SizedBox(height: 24),
                            Row(
                              children: [
                                if (snapShot.data?.modules?.showProductWholesalePrice == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: wholeSalePriceController,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).wholeSalePrice,
                                        hintText: lang.S.of(context).enterWholesalePrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                if (snapShot.data?.modules?.showProductWholesalePrice == '1' && snapShot.data?.modules?.showProductDealerPrice == '1') SizedBox(width: 14),
                                if (snapShot.data?.modules?.showProductDealerPrice == '1')
                                  Expanded(
                                    child: TextFormField(
                                      controller: dealerPriceController,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).dealerPrice,
                                        hintText: lang.S.of(context).enterDealerPrice,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          ///_______manufacturer_________________
                          if (snapShot.data?.modules?.showProductManufacturer == '1') ...[
                            SizedBox(height: 24),
                            TextFormField(
                              controller: manufacturerController,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).manufacturer,
                                hintText: lang.S.of(context).enterManufacturerName,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () async {
                        if ((key.currentState?.validate() ?? false)) {
                          ProductRepo product = ProductRepo();
                          bool success;

                          // Create the product data model
                          CreateProductModel submitData = CreateProductModel(
                            productId: widget.productModel?.id.toString(),
                            name: nameController.text,
                            categoryId: selectedCategory?.id.toString(),
                            size: sizeController.text,
                            color: colorController.text,
                            weight: weightController.text,
                            capacity: capacityController.text,
                            type: typeController.text,
                            brandId: selectedBrand?.id.toString(),
                            productCode: productCodeController.text,
                            productSingleStock: productStockController.text,
                            alertQty: stockAlertController.text,
                            unitId: selectedUnit?.id.toString(),
                            productSalePrice: salePriceController.text,
                            productPurchasePrice: selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExclusivePriceController.text : purchaseInclusivePriceController.text,
                            productWholeSalePrice: wholeSalePriceController.text,
                            productDealerPrice: dealerPriceController.text,
                            productManufacturer: manufacturerController.text,
                            productDiscount: discountPriceController.text,
                            image: pickedImage == null ? null : File(pickedImage!.path),
                            vatId: selectedTax?.id.toString(),
                            vatType: selectedTaxType,
                            vatAmount: ((num.tryParse(purchaseInclusivePriceController.text) ?? 0) - (num.tryParse(purchaseExclusivePriceController.text) ?? 0)).toString(),
                            profitPercent: profitMarginController.text,
                            modelId: selectedModel?.id.toString(),
                            expDate: selectedExpireDate,
                            mfgDate: selectedManufactureDate,
                            productType: _selectedType.name.toString(),
                            // variantData
                            batchNo: productData.batchNo,
                            productStock: productData.productStock,
                            batchPurchasePrice: productData.batchPurchasePrice,
                            batchProfitPercent: productData.batchProfitPercent,
                            batchSalePrice: productData.batchSalePrice,
                            batchWholeSalePrice: productData.batchWholeSalePrice,
                            batchDealerPrice: productData.batchDealerPrice,
                            batchExpireDate: productData.batchExpireDate,
                            batchMfgDate: productData.batchMfgDate,
                          );

                          // Update Procut
                          if (widget.productModel != null) {
                            debugPrint('update');
                            success = await product.updateProduct(data: submitData);
                          } else {
                            debugPrint('create');
                            success = await product.createProduct(data: submitData);
                          }
                          if (success) {
                            EasyLoading.showSuccess(widget.productModel != null ? 'Product Updated Successfully!' : 'Product created successfully!');
                            if (widget.productModel != null) {
                              ref.invalidate(fetchProductDetails(widget.productModel?.id.toString() ?? ''));
                            }
                            ref.invalidate(productProvider);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(
                        widget.productModel != null ? lang.S.of(context).update : lang.S.of(context).saveNPublish,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    }, error: (e, stack) {
      return Text(e.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }));
  }

  Future<dynamic> uploadImageDialog(BuildContext context, ThemeData theme) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.clear,
                      color: kNeutral800,
                    ),
                  ),
                ),
                Text(
                  'Choose',
                  style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontWeight: FontWeight.w400, fontSize: 18),
                ),
                SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                          setState(() {});
                          if (!mounted) return;
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 40.0,
                              color: kMainColor,
                            ),
                            Text(
                              lang.S.of(context).gallery,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: kMainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 50.0),
                      GestureDetector(
                        onTap: () async {
                          pickedImage = await _picker.pickImage(source: ImageSource.camera);
                          setState(() {});
                          if (!mounted) return;
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 40.0,
                              color: kGreyTextColor,
                            ),
                            Text(
                              lang.S.of(context).camera,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: kGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editBatch(int index) {
    productBatchNumberController.text = productData.batchNo?[index] ?? '';
    productStockController.text = productData.productStock?[index] ?? '';
    purchaseExclusivePriceController.text = productData.batchPurchasePrice?[index] ?? '';
    purchaseInclusivePriceController.text = productData.batchPurchasePrice?[index] ?? '';
    profitMarginController.text = productData.batchProfitPercent?[index] ?? '';
    salePriceController.text = productData.batchSalePrice?[index] ?? '';
    wholeSalePriceController.text = productData.batchWholeSalePrice?[index] ?? '';
    dealerPriceController.text = productData.batchDealerPrice?[index] ?? '';
    expireDateController.text = productData.batchExpireDate?[index].isNotEmpty ?? false ? DateFormat.yMd().format(DateTime.parse(productData.batchExpireDate?[index] ?? '')) : '';
    manufactureDateController.text = productData.batchMfgDate?[index].isNotEmpty ?? false ? DateFormat.yMd().format(DateTime.parse(productData.batchMfgDate?[index] ?? '')) : '';
    selectedExpireDate = productData.batchExpireDate?[index];
    selectedManufactureDate = productData.batchMfgDate?[index];

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(builder: (BuildContext context, StateSetter setNewState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, size: 18),
                        )
                      ],
                    ),
                  ),
                  Divider(color: kBorderColor, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        ///_________Purchase_price_exclusive_&&_Inclusive____________________
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: productBatchNumberController,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Batch No.',
                                  hintText: 'Enter Batch No.',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: productStockController,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).stock,
                                  hintText: lang.S.of(context).enterStock,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchaseExclusivePriceController,
                                onChanged: (value) => calculatePurchaseAndMrp(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Price Cannot be Empty';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Purchase Price Exc.',
                                  hintText: lang.S.of(context).enterPurchasePrice,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: purchaseInclusivePriceController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Price Cannot be Empty';
                                  }
                                  return null;
                                },
                                onChanged: (value) => calculatePurchaseAndMrp(from: "purchase_inc"),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: "Purchase Price Inc.",
                                  hintText: 'Price Cannot be Empty',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        ///_________Purchase_price__&&______mrp_____________________
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: profitMarginController,
                                onChanged: (value) => calculatePurchaseAndMrp(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return lang.S.of(context).pleaseEnterAValidProductName;
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Profit Margin (%)',
                                  hintText: lang.S.of(context).enterPurchasePrice,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: salePriceController,
                                onChanged: (value) => calculatePurchaseAndMrp(from: 'mrp'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return lang.S.of(context).pleaseEnterAValidSalePrice;
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).mrp,
                                  //hintText: 'Enter selling price',
                                  hintText: lang.S.of(context).enterSaltingPrice,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        ///________wholesalePrice_dealer_price_________________
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: wholeSalePriceController,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).wholeSalePrice,
                                  hintText: lang.S.of(context).enterWholesalePrice,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: dealerPriceController,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).dealerPrice,
                                  hintText: lang.S.of(context).enterDealerPrice,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                readOnly: true,
                                controller: manufactureDateController,
                                decoration: kInputDecoration.copyWith(
                                  labelText: 'Manufacture. Date',
                                  hintText: 'Select Date',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    onPressed: () async {
                                      final DateTime? picked = await showDatePicker(
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101),
                                        context: context,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          manufactureDateController.text = DateFormat.yMd().format(picked);
                                          selectedManufactureDate = picked.toString();
                                        });
                                      }
                                    },
                                    icon: const Icon(IconlyLight.calendar, size: 22),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                readOnly: true,
                                controller: expireDateController,
                                decoration: kInputDecoration.copyWith(
                                  labelText: 'Exp. Date',
                                  hintText: 'Select Date',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    onPressed: () async {
                                      final DateTime? picked = await showDatePicker(
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101),
                                        context: context,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          expireDateController.text = DateFormat.yMd().format(picked);
                                          selectedExpireDate = picked.toString();
                                        });
                                      }
                                    },
                                    icon: const Icon(IconlyLight.calendar, size: 22),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: Color(0xffF68A3D)))),
                                  child: Text(
                                    'Cancel',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Color(0xffF68A3D),
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      productData.batchNo?[index] = productBatchNumberController.text;
                                      productData.productStock?[index] = productStockController.text;
                                      productData.batchPurchasePrice?[index] = purchaseExclusivePriceController.text;
                                      productData.batchProfitPercent?[index] = profitMarginController.text;
                                      productData.batchSalePrice?[index] = salePriceController.text;
                                      productData.batchWholeSalePrice?[index] = wholeSalePriceController.text;
                                      productData.batchDealerPrice?[index] = dealerPriceController.text;
                                      productData.batchExpireDate?[index] = selectedExpireDate ?? '';
                                      productData.batchMfgDate?[index] = selectedManufactureDate ?? '';

                                      // Clear the input fields
                                      productBatchNumberController.clear();
                                      productStockController.clear();
                                      purchaseExclusivePriceController.clear();
                                      profitMarginController.clear();
                                      salePriceController.clear();
                                      wholeSalePriceController.clear();
                                      dealerPriceController.clear();
                                      expireDateController.clear();
                                      manufactureDateController.clear();
                                      selectedExpireDate = null;
                                      selectedManufactureDate = null;
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  bool readOnly = false,
  bool? icon,
  VoidCallback? onTap,
}) {
  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    validator: validator,
    keyboardType: keyboardType,
    decoration: kInputDecoration.copyWith(
      labelText: label,
      hintText: hint,
      suffixIcon: (icon ?? false) ? const Icon(Icons.keyboard_arrow_down_outlined) : null,
      border: const OutlineInputBorder(),
    ),
  );
}

enum ProductType { single, variant }

class CreateProductModel {
  CreateProductModel({
    this.productId,
    this.name,
    this.categoryId,
    this.size,
    this.color,
    this.weight,
    this.capacity,
    this.type,
    this.brandId,
    this.productCode,
    this.productSingleStock,
    this.alertQty,
    this.unitId,
    this.productSalePrice,
    this.productPurchasePrice,
    this.productWholeSalePrice,
    this.productDealerPrice,
    this.productManufacturer,
    this.productDiscount,
    this.image,
    this.vatId,
    this.vatType,
    this.vatAmount,
    this.profitPercent,
    this.modelId,
    this.expDate,
    this.mfgDate,
    this.productType,
    this.batchNo, // List<String> for batch numbers
    this.productStock, // List<String> for stock quantities
    this.batchPurchasePrice, // List<String> for purchase prices
    this.batchProfitPercent, // List<String> for profit percentages
    this.batchSalePrice, // List<String> for sale prices
    this.batchWholeSalePrice, // List<String> for wholesale prices
    this.batchDealerPrice, // List<String> for dealer prices
    this.batchExpireDate, // List<String> for expire dates
    this.batchMfgDate, // List<String> for mfg dates
  });

  String? productId;
  String? name;
  String? categoryId;
  String? size;
  String? color;
  String? weight;
  String? capacity;
  String? type;
  String? brandId;
  String? productCode;
  String? productSingleStock;
  String? alertQty;
  String? unitId;
  String? productSalePrice;
  String? productPurchasePrice;
  String? productWholeSalePrice;
  String? productDealerPrice;
  String? productManufacturer;
  String? productDiscount;
  File? image;
  String? vatId;
  String? vatType;
  String? vatAmount;
  String? profitPercent;
  String? modelId;
  String? expDate;
  String? mfgDate;
  String? productType;
  List<String>? batchNo;
  List<String>? productStock;
  List<String>? batchPurchasePrice;
  List<String>? batchProfitPercent;
  List<String>? batchSalePrice;
  List<String>? batchWholeSalePrice;
  List<String>? batchDealerPrice;
  List<String>? batchExpireDate;
  List<String>? batchMfgDate;
}
