import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/model/business_info_model.dart';

import '../Screens/Settings/sales settings/model/amount_rounding_dropdown_model.dart';
import '../Screens/vat_&_tax/model/vat_model.dart';
import '../model/add_to_cart_model.dart';

final cartNotifier = ChangeNotifierProvider((ref) {
  return CartNotifier(businessInformation: ref.watch(businessInfoProvider).value);
});

class CartNotifier extends ChangeNotifier {
  final BusinessInformationModel? businessInformation;

  CartNotifier({required this.businessInformation});

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    roundedOption = businessInformation?.saleRoundingOption ?? roundingMethods[0].value;
  }

  List<SaleCartModel> cartItemList = [];
  TextEditingController discountTextControllerFlat = TextEditingController();
  TextEditingController vatAmountController = TextEditingController();
  TextEditingController shippingChargeController = TextEditingController();

  ///_________NEW_________________________________
  num totalAmount = 0;
  num discountAmount = 0;
  num discountPercent = 0;
  num roundingAmount = 0;
  num actualTotalAmount = 0;
  num totalPayableAmount = 0;
  VatModel? selectedVat;
  num vatAmount = 0;
  bool isFullPaid = false;
  num receiveAmount = 0;
  num changeAmount = 0;
  num dueAmount = 0;
  num finalShippingCharge = 0;
  String roundedOption = roundingMethods[0].value;

  void changeSelectedVat({VatModel? data}) {
    if (data != null) {
      selectedVat = data;
    } else {
      selectedVat = null;
      vatAmount = 0;
      vatAmountController.clear();
    }

    calculatePrice();
  }

  void calculateDiscount({required String value, bool? rebuilding, String? selectedTaxType}) {
    if (value.isEmpty) {
      discountAmount = 0;
      discountPercent = 0;
      discountTextControllerFlat.clear();
    } else {
      num discountValue = num.tryParse(value) ?? 0;

      if (selectedTaxType == null) {
        EasyLoading.showError('Please select a discount type');
        discountAmount = 0;
        discountPercent = 0;
      } else if (selectedTaxType == "Flat") {
        discountAmount = discountValue;
      } else if (selectedTaxType == "Percent") {
        discountPercent = num.tryParse(discountTextControllerFlat.text) ?? 0.0;
        discountAmount = (totalAmount * discountValue) / 100;

        if (discountAmount > totalAmount) {
          discountAmount = totalAmount;
        }
      } else {
        EasyLoading.showError('Invalid discount type selected');
        discountAmount = 0;
      }

      if (discountAmount > totalAmount) {
        discountTextControllerFlat.clear();
        discountAmount = 0;
        EasyLoading.showError('Enter a valid discount');
      }
    }

    if (rebuilding == false) return;
    calculatePrice();
  }

  void updateProduct({required num productId, required String price, required String qty}) {
    int index = cartItemList.indexWhere((element) => element.productId == productId);
    cartItemList[index].unitPrice = num.tryParse(price);
    cartItemList[index].quantity = num.tryParse(qty) ?? 0;
    calculatePrice();
  }

  void calculatePrice({String? receivedAmount, String? shippingCharge, bool? stopRebuild}) {
    totalAmount = 0;
    totalPayableAmount = 0;
    dueAmount = 0;
    for (var element in cartItemList) {
      totalAmount += element.quantity * (element.unitPrice ?? 0);
    }
    totalPayableAmount = totalAmount;

    if (discountAmount > totalAmount) {
      calculateDiscount(
        value: discountAmount.toString(),
        rebuilding: false,
      );
    }
    if (discountAmount >= 0) {
      totalPayableAmount -= discountAmount;
    }
    if (selectedVat?.rate != null) {
      vatAmount = (totalPayableAmount * selectedVat!.rate!) / 100;
      vatAmountController.text = vatAmount.toStringAsFixed(2);
    }

    totalPayableAmount += vatAmount;
    if (shippingCharge != null && shippingCharge.isNotEmpty) {
      finalShippingCharge = num.tryParse(shippingCharge) ?? 0;
    }
    totalPayableAmount += finalShippingCharge;
    actualTotalAmount = totalPayableAmount;
    num tempTotalPayable = roundNumber(value: totalPayableAmount, roundingType: roundedOption);
    roundingAmount = tempTotalPayable - totalPayableAmount;
    totalPayableAmount = tempTotalPayable;
    if (receivedAmount != null && receivedAmount.isNotEmpty) {
      receiveAmount = num.tryParse(receivedAmount) ?? 0;
    } else {
      receiveAmount = 0;
    }

    changeAmount = totalPayableAmount < receiveAmount ? receiveAmount - totalPayableAmount : 0;
    dueAmount = totalPayableAmount < receiveAmount ? 0 : totalPayableAmount - receiveAmount;
    if (dueAmount <= 0) isFullPaid = true;
    if (stopRebuild ?? false) return;
    notifyListeners();
  }

  void quantityIncrease(int index) {
    if ((cartItemList[index].stock ?? 0) > cartItemList[index].quantity) {
      if ((cartItemList[index].stock ?? 0) < cartItemList[index].quantity + 1) {
        cartItemList[index].quantity = (cartItemList[index].stock ?? 0);
      } else {
        cartItemList[index].quantity++;
      }

      calculatePrice();
    } else {
      EasyLoading.showError('Stock Overflow');
    }
  }

  void quantityDecrease(int index) {
    if (cartItemList[index].quantity > 1) {
      cartItemList[index].quantity--;
    }
    calculatePrice();
  }

  void addToCartRiverPod({
    required SaleCartModel cartItem,
    bool? fromEditSales,
    bool? isVariant,
  }) {
    final variantMode = isVariant ?? false;

    final index = cartItemList.indexWhere((element) => variantMode ? element.stockId == cartItem.stockId : element.productId == cartItem.productId);

    if (index != -1) {
      variantMode ? cartItemList[index].quantity = cartItem.quantity : cartItemList[index].quantity++;
    } else {
      cartItemList.add(cartItem);
    }

    if (!(fromEditSales ?? false)) {
      calculatePrice();
    }
  }

  void deleteToCart(int index) {
    cartItemList.removeAt(index);
    calculatePrice();
  }
  void deleteAllVariant({required num productId}){
    cartItemList.removeWhere((element) => element.productId==productId,);
    calculatePrice();
  }
}
