import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/Screens/Sales/Repo/sales_repo.dart';
import 'package:mobile_pos/Screens/Sales/sales_add_to_cart_sales_widget.dart';
import 'package:mobile_pos/Screens/Sales/sales_products_list_screen.dart';
import 'package:mobile_pos/Screens/Settings/sales%20settings/model/amount_rounding_dropdown_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Repository/API/future_invoice.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';
import '../../widgets/payment_type/_payment_type_dropdown.dart';
import '../Customers/Model/parties_model.dart';
import '../Home/home.dart';
import '../invoice_details/sales_invoice_details_screen.dart';
import '../vat_&_tax/model/vat_model.dart';
import '../vat_&_tax/provider/text_repo.dart';

class AddSalesScreen extends ConsumerStatefulWidget {
  const AddSalesScreen({
    super.key,
    required this.customerModel,
    this.transitionModel,
    this.isFromPos,
  });

  final Party? customerModel;
  final SalesTransactionModel? transitionModel;
  final bool? isFromPos;

  @override
  AddSalesScreenState createState() => AddSalesScreenState();
}

class AddSalesScreenState extends ConsumerState<AddSalesScreen> {
  int? paymentType;

  bool isProcessing = false;

  DateTime selectedDate = DateTime.now();

  TextEditingController dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
  TextEditingController phoneController = TextEditingController();
  TextEditingController recevedAmountController = TextEditingController();

  TextEditingController noteController = TextEditingController();
  Party? _customerModel;
  bool? _isFromPos;

  @override
  void initState() {
    _customerModel = widget.customerModel;
    _isFromPos = widget.isFromPos;
    if (widget.transitionModel != null) {
      final editedSales = widget.transitionModel;
      dateController.text = editedSales?.saleDate?.substring(0, 10) ?? '';
      recevedAmountController.text = editedSales?.paidAmount.toString() ?? '';
      _customerModel = Party(
        id: widget.transitionModel?.party?.id,
        name: widget.transitionModel?.party?.name,
      );
      if (widget.transitionModel?.discountType == 'flat') {
        discountType = 'Flat';
      } else {
        discountType = 'Percent';
      }
      paymentType = widget.transitionModel?.paymentTypeId;
      addProductsInCartFromEditList();
    }
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    phoneController.dispose();
    recevedAmountController.dispose();
    super.dispose();
  }

  void addProductsInCartFromEditList() {
    final cart = ref.read(cartNotifier);
    cart.roundedOption = widget.transitionModel?.roundingOption ?? roundingMethods[0].value;

    if (widget.transitionModel?.salesDetails?.isNotEmpty ?? false) {
      for (var detail in widget.transitionModel!.salesDetails!) {
        debugPrint('Stock id: ${detail.stock?.id}');
        debugPrint('Stock Type: ${detail.product?.productType}');
        SaleCartModel cartItem = SaleCartModel(
            productType: detail.product?.productType,
            productName: detail.product?.productName,
            unitPrice: detail.price,
            batchName: detail.stock?.batchNo ?? '',
            lossProfit: detail.lossProfit,
            quantity: detail.quantities ?? 0,
            productCode: detail.product?.productCode,
            productPurchasePrice: detail.product?.productPurchasePrice,
            stock: detail.product?.productStock,
            productId: detail.productId!,
            stockId: detail.stock?.id ?? 0);
        cart.addToCartRiverPod(cartItem: cartItem, fromEditSales: true, isVariant: detail.product?.productType == ProductType.variant.name);
      }
    }

    cart.discountAmount = widget.transitionModel?.discountAmount ?? 0;
    noteController.text = widget.transitionModel?.meta?.note?.toString() ?? '';
    if (widget.transitionModel?.discountType == 'flat') {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountAmount.toString() ?? '';
    } else {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountPercent?.toString() ?? '';
    }

    cart.finalShippingCharge = widget.transitionModel?.shippingCharge ?? 0;
    cart.shippingChargeController.text = widget.transitionModel?.shippingCharge.toString() ?? '';
    cart.vatAmountController.text = widget.transitionModel?.vatAmount.toString() ?? '';

    cart.calculatePrice(receivedAmount: widget.transitionModel?.paidAmount.toString(), stopRebuild: true);
  }

  bool hasPreselected = false; // Flag to ensure preselection happens only once

  String discountType = 'Flat';

  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final providerData = ref.watch(cartNotifier);
    final personalData = ref.watch(businessInfoProvider);
    final taxesData = ref.watch(taxProvider);
    return personalData.when(data: (data) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).addSales,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 2.0,
            surfaceTintColor: kWhite,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ///_______Invoice_And_Date_____________________________________________________
                  Row(
                    children: [
                      widget.transitionModel == null
                          ? FutureBuilder(
                              future: FutureInvoice().getFutureInvoice(tag: 'sales'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Expanded(
                                    child: AppTextField(
                                      textFieldType: TextFieldType.NAME,
                                      initialValue: snapshot.data.toString(),
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).inv,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).inv,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                initialValue: widget.transitionModel?.invoiceNumber,
                                readOnly: true,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).inv,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: dateController,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).date,
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                  context: context,
                                );
                                if (picked != null && picked != selectedDate) {
                                  setState(() {
                                    selectedDate = picked;
                                    dateController.text = selectedDate.toString().substring(0, 10);
                                  });
                                }
                              },
                              icon: const Icon(FeatherIcons.calendar),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  ///______Selected_Due_And_Customer___________________________________________
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(lang.S.of(context).dueAmount),
                          Text(
                            _customerModel?.due == null ? '$currency 0' : '$currency${_customerModel?.due}',
                            style: const TextStyle(color: Color(0xFFFF8C34)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        readOnly: true,
                        initialValue: _customerModel?.name ?? 'Guest',
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).customerName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Visibility(
                        visible: _customerModel == null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: AppTextField(
                            controller: phoneController,
                            textFieldType: TextFieldType.PHONE,
                            decoration: kInputDecoration.copyWith(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              //labelText: 'Customer Phone Number',
                              labelText: lang.S.of(context).customerPhoneNumber,
                              //hintText: 'Enter customer phone number',
                              hintText: lang.S.of(context).enterCustomerPhoneNumber,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ///_______Added_Items_List_________________________________________________
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          border: Border.all(width: 1, color: const Color(0xffEAEFFA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xffEAEFFA),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: context.width() / 1.35,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          lang.S.of(context).itemAdded,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          lang.S.of(context).quantity,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: providerData.cartItemList.length,
                                itemBuilder: (context, index) {
                                  // providerData.controllers[index].text = (providerData.cartItemList[index].quantity.toString());
                                  // providerData.focus[index].addListener(
                                  //   () {
                                  //     if (!providerData.focus[index].hasFocus) {
                                  //       setState(() {
                                  //         vatAmount = (vatPercentageEditingController.text.toDouble() / 100) * providerData.getTotalAmount().toDouble();
                                  //         vatAmountEditingController.text = vatAmount.toStringAsFixed(2);
                                  //       });
                                  //     }
                                  //   },
                                  // );
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: ListTile(
                                      onTap: () => showModalBottomSheet(
                                        context: context,
                                        builder: (context2) {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      lang.S.of(context).updateProduct,
                                                    ),
                                                    CloseButton(
                                                      onPressed: () => Navigator.pop(context2),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Divider(thickness: 1, color: kBorderColorTextField),
                                              Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: SalesAddToCartForm(
                                                  batchWiseStockModel: providerData.cartItemList[index],
                                                  previousContext: context2,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(providerData.cartItemList[index].productName.toString()),
                                      subtitle: Text(
                                          '${formatPointNumber(providerData.cartItemList[index].quantity)} X ${providerData.cartItemList[index].unitPrice} = ${formatPointNumber(((providerData.cartItemList[index].unitPrice ?? 0) * providerData.cartItemList[index].quantity))} ${providerData.cartItemList[index].productType == ProductType.variant.name ? "[${providerData.cartItemList[index].batchName}]" : ''}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 90,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
                                                GestureDetector(
                                                  onTap: () => providerData.quantityDecrease(index),
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: const BoxDecoration(
                                                      color: kMainColor,
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.remove, size: 14, color: Colors.white),
                                                      // child: Text(
                                                      //   '-',
                                                      //   style: TextStyle(fontSize: 14, color: Colors.white),
                                                      // ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  width: 40,
                                                  child: Center(
                                                    child: Text(
                                                      formatPointNumber(providerData.cartItemList[index].quantity),
                                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                            color: kGreyTextColor,
                                                          ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                GestureDetector(
                                                  onTap: () => providerData.quantityIncrease(index),
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: const BoxDecoration(
                                                      color: kMainColor,
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.add, size: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () => providerData.deleteToCart(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              color: Colors.red.withValues(alpha: 0.1),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      )).visible(providerData.cartItemList.isNotEmpty),

                  ///_______Add_Button__________________________________________________
                  if (_isFromPos != true)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SaleProductsList(
                              customerModel: _customerModel,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(color: kMainColor.withValues(alpha: 0.1), borderRadius: const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Text(
                            lang.S.of(context).addItems,
                            style: const TextStyle(color: kMainColor, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  ///_____Total_Section_____________________________
                  Container(
                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), border: Border.all(color: Colors.grey.shade300, width: 1)),
                    child: Column(
                      children: [
                        ///________Total_title_reader_________________________
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Color(0xffFEF0F1), borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).subTotal,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatPointNumber(providerData.totalAmount),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        ///_________Discount___________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text for "Discount"
                              Text(
                                lang.S.of(context).discount,
                                style: const TextStyle(fontSize: 16),
                              ),

                              Spacer(),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: kBorder, width: 1)),
                                  ),
                                  child: DropdownButton<String?>(
                                    icon: const Icon(Icons.keyboard_arrow_down, color: kGreyTextColor),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    isDense: true,
                                    padding: EdgeInsets.zero,
                                    hint: Text(
                                      'Select',
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        color: kGreyTextColor,
                                      ),
                                    ),
                                    value: discountType,
                                    items: [
                                      "Flat",
                                      "Percent",
                                    ]
                                        .map((type) => DropdownMenuItem<String?>(
                                              value: type,
                                              child: Text(
                                                type,
                                                style: _theme.textTheme.bodyMedium?.copyWith(color: kNeutralColor),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        discountType = value!;
                                        providerData.calculateDiscount(
                                          value: providerData.discountTextControllerFlat.text,
                                          selectedTaxType: discountType,
                                        );
                                        debugPrint(providerData.discountPercent.toString());
                                        debugPrint(providerData.discountAmount.toString());
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: providerData.discountTextControllerFlat,
                                  onChanged: (value) {
                                    setState(() {
                                      providerData.calculateDiscount(
                                        value: value,
                                        selectedTaxType: discountType,
                                      );
                                    });
                                  },
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(color: kNeutralColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///_________Vat_Dropdown_______________________________
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Vat',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),

                              const Spacer(),
                              taxesData.when(
                                data: (data) {
                                  List<VatModel> dataList = data.where((tax) => tax.status == true).toList();
                                  if (widget.transitionModel != null && widget.transitionModel?.vatId != null && !hasPreselected) {
                                    VatModel matched = dataList.firstWhere(
                                      (element) => element.id == widget.transitionModel?.vatId,
                                      orElse: () => VatModel(),
                                    );
                                    if (matched.id != null) {
                                      hasPreselected = true;
                                      providerData.selectedVat = matched;
                                    }
                                  }
                                  return SizedBox(
                                    width: context.width() / 4,
                                    height: 30,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: kBorder, width: 1)),
                                      ),
                                      child: DropdownButton<VatModel?>(
                                        icon: providerData.selectedVat != null
                                            ? GestureDetector(
                                                onTap: () => providerData.changeSelectedVat(data: null),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              )
                                            : const Icon(Icons.keyboard_arrow_down, color: kGreyTextColor),
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        isDense: true,
                                        padding: EdgeInsets.zero,
                                        hint: Text(
                                          'Select one',
                                          style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                                        ),
                                        value: providerData.selectedVat,
                                        items: dataList.map((VatModel tax) {
                                          return DropdownMenuItem<VatModel>(
                                            value: tax,
                                            child: Text(
                                              tax.name ?? '',
                                              maxLines: 1,
                                              style: _theme.textTheme.bodyMedium?.copyWith(color: kNeutralColor),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (VatModel? newValue) => providerData.changeSelectedVat(data: newValue),
                                      ),
                                    ),
                                  );
                                },
                                error: (error, stackTrace) {
                                  return Text(error.toString());
                                },
                                loading: () {
                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(width: 10),

                              // VAT Amount Input Field
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextFormField(
                                  controller: providerData.vatAmountController,
                                  readOnly: true,
                                  onChanged: (value) => providerData.calculateDiscount(value: value, selectedTaxType: discountType.toString()),
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(color: kNeutralColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Shipping Charge',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: providerData.shippingChargeController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => providerData.calculatePrice(shippingCharge: value, stopRebuild: false),
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(color: kNeutralColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________Total_______________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).total,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatPointNumber(providerData.actualTotalAmount),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        ///________Rounded Total_______________________________________
                        Visibility(
                          visible: providerData.roundingAmount != 0,
                          child: Column(
                            children: [
                              ///________Rounded Amount_______________________________________
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rounding (+/-)',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      formatPointNumber(providerData.roundingAmount),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rounded Total',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      formatPointNumber(providerData.totalPayableAmount),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________paid_Amount__________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).receivedAmount,
                                style: const TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: recevedAmountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => providerData.calculatePrice(receivedAmount: value),
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(color: kNeutralColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________Change amount_________________________________
                        Visibility(
                          visible: providerData.changeAmount > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change Amount',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  formatPointNumber(providerData.changeAmount),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ///_______Due_amount_____________________________________
                        Visibility(
                          visible: providerData.dueAmount > 0 || (providerData.changeAmount == 0 && providerData.dueAmount == 0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).dueAmount,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  formatPointNumber(providerData.dueAmount),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///_______Payment_Type_______________________________
                  const Divider(height: 0),
                  const SizedBox(height: 5),
                  PaymentTypeSelectorDropdown(
                    value: paymentType,
                    onChanged: (value) => setState(
                      () => paymentType = value,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(height: 0),

                  const SizedBox(height: 30),
                  SizedBox(
                    height: 56, // Set a fixed height for the Row
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          // Use Expanded to allow the TextFormField to take available space
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                            ),
                            child: TextFormField(
                              controller: noteController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Enter your opinion',
                              ),
                              style: _theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _imageFile == null
                            ? widget.transitionModel?.image?.isNotEmpty ?? false
                                ? InkWell(
                                    onTap: () {
                                      showImagePickerDialog(context, _theme.textTheme);
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 48,
                                        minHeight: 48,
                                        maxWidth: 107,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: const Color(0xffF5F3F3),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              '${APIConfig.domain}${widget.transitionModel?.image.toString()}',
                                            ),
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      showImagePickerDialog(context, _theme.textTheme);
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 48,
                                        minHeight: 48,
                                        maxWidth: 107,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: const Color(0xffF5F3F3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(IconlyLight.camera),
                                          SizedBox(width: 4.0),
                                          Text('Image'),
                                        ],
                                      ),
                                    ),
                                  )
                            : InkWell(
                                onTap: () {
                                  showImagePickerDialog(context, _theme.textTheme);
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 48,
                                    minHeight: 48,
                                    maxWidth: 107,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  ///_____Action_Button_____________________________________
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            maximumSize: const Size(double.infinity, 48),
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                          onPressed: () async {
                            const Home().launch(context, isNewTask: true);
                          },
                          child: Text(
                            lang.S.of(context).cancel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: _theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            maximumSize: const Size(double.infinity, 48),
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                          onPressed: () async {
                            if (providerData.cartItemList.isEmpty) {
                              EasyLoading.showError(lang.S.of(context).addProductFirst);
                              return;
                            }
                            if (_customerModel == null && providerData.dueAmount > 0) {
                              EasyLoading.showError('Sales on due are not allowed for walk-in customers.');
                              return;
                            }
                            if (paymentType == null) {
                              EasyLoading.showError('Please select a payment type');
                              return;
                            }

                            ///_______ Prevent multiple clicks________________
                            if (isProcessing) return;

                            setState(() {
                              isProcessing = true; // Disable button while processing
                            });

                            try {
                              EasyLoading.show(status: lang.S.of(context).loading, dismissOnTap: false);

                              // Prepare the list of selected products
                              List<CartSaleProducts> selectedProductList = providerData.cartItemList.map((element) {
                                debugPrint('Stock Id: ${element.stockId}');
                                debugPrint('Stock Id: ${element.batchName}');
                                return CartSaleProducts(
                                  productName: element.productName ?? '',
                                  stockId: element.stockId.toInt(),
                                  quantities: element.quantity,
                                  price: num.tryParse(element.unitPrice.toString()) ?? 0,
                                  lossProfit: (element.quantity * (num.tryParse(element.unitPrice.toString()) ?? 0)) -
                                      (element.quantity * (num.tryParse(element.productPurchasePrice.toString()) ?? 0)),
                                );
                              }).toList();

                              // image
                              File? imageFile;
                              if (_imageFile != null) {
                                imageFile = File(_imageFile!.path);
                              }
                              // Create the sale
                              SaleRepo repo = SaleRepo();
                              if (widget.transitionModel == null) {
                                SalesTransactionModel? saleData = await repo.createSale(
                                  ref: ref,
                                  context: context,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: selectedDate.toString(),
                                  products: selectedProductList,
                                  paymentType: paymentType?.toString() ?? '',
                                  partyId: _customerModel?.id,
                                  customerPhone: _customerModel == null ? phoneController.text : null,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat != null ? providerData.selectedVat!.rate! : 0,
                                  vatId: providerData.selectedVat?.id,
                                  isPaid: providerData.isFullPaid,
                                  dueAmount: providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                  changeAmount: providerData.changeAmount,
                                  discountType: discountType.toLowerCase(),
                                  roundedOption: providerData.roundedOption,
                                  roundingAmount: providerData.roundingAmount,
                                  unRoundedTotalAmount: providerData.actualTotalAmount,
                                  note: noteController.text,
                                  shippingCharge: providerData.finalShippingCharge,
                                  image: imageFile,
                                  discountPercent: providerData.discountPercent,
                                );

                                if (!context.mounted) return;
                                if (saleData != null) {
                                  SalesInvoiceDetails(
                                    businessInfo: personalData.value!,
                                    saleTransaction: saleData,
                                    fromSale: true,
                                  ).launch(context);
                                }
                              } else {
                                await repo.updateSale(
                                  id: widget.transitionModel?.id ?? 0,
                                  ref: ref,
                                  context: context,
                                  roundingAmount: providerData.roundingAmount,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: selectedDate.toString(),
                                  products: selectedProductList,
                                  paymentType: paymentType?.toString() ?? '',
                                  partyId: widget.transitionModel?.party?.id,
                                  roundedOption: providerData.roundedOption,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat != null ? providerData.selectedVat!.rate! : 0,
                                  vatId: providerData.selectedVat?.id,
                                  isPaid: providerData.isFullPaid,
                                  dueAmount: providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                  unRoundedTotalAmount: providerData.actualTotalAmount,
                                  changeAmount: providerData.changeAmount,
                                  discountType: discountType.toLowerCase(),
                                  note: noteController.text,
                                  shippingCharge: providerData.finalShippingCharge,
                                  image: imageFile,
                                  discountPercent: providerData.discountPercent,
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            } finally {
                              EasyLoading.dismiss();
                              if (mounted) {
                                setState(() {
                                  isProcessing = false; // Re-enable button after processing
                                });
                              }
                            }
                          },
                          child: Text(
                            lang.S.of(context).save,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: _theme.colorScheme.primaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }, error: (e, stack) {
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }

  Future<dynamic> showImagePickerDialog(BuildContext context, TextTheme textTheme) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext contexts) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: Text(
            'Upload Image',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          // content: const Text('Are you sure you want to delete this account? This will permanently erase this account.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.image, size: 30.0),
                  Text(
                    'Use gallery',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () async {
                _pickImage(ImageSource.gallery);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              },
            ),
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.camera, size: 30.0),
                  Text(
                    'Open Camera',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () async {
                _pickImage(ImageSource.camera);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
