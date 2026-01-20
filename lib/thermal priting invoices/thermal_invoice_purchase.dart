import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Const/api_config.dart';
import '../Screens/Products/add_product.dart';
import '../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../constant.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';
import 'package:image/image.dart' as img;

class PurchaseThermalPrinterInvoice {
  ///__________Purchase________________
  Future<void> printPurchaseThermalInvoice(
      {required PrintPurchaseTransactionModel printTransactionModel, required List<PurchaseDetails>? productList, required String? invoiceSize}) async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      List<int> bytes = (printTransactionModel.personalInformationModel.invoiceSize == '3_inch_80mm' && printTransactionModel.personalInformationModel.invoiceSize != null)
          ? await getPurchaseTicket80mm(printTransactionModel: printTransactionModel, productList: productList)
          : await getPurchaseTicket58mm(printTransactionModel: printTransactionModel, productList: productList);
      if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
        await PrintBluetoothThermal.writeBytes(bytes);
      } else {
        toast('No Product Found');
      }
      // if (invoiceSize != null && invoiceSize == '3_inch_80mm') {
      //   List<int> bytes = await getPurchaseTicket80mm(printTransactionModel: printTransactionModel, productList: productList);
      //   if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
      //     await PrintBluetoothThermal.writeBytes(bytes);
      //   } else {
      //     toast('No Product Found');
      //   }
      // } else {
      //   List<int> bytes = await getPurchaseTicket58mm(printTransactionModel: printTransactionModel, productList: productList,is80mm: invoiceSize == '3_inch_80mm');
      //   if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
      //     await PrintBluetoothThermal.writeBytes(bytes);
      //   } else {
      //     toast('No Product Found');
      //   }
      // }
    } else {
      EasyLoading.showError('Unable to connect with printer');
    }
  }

  Future<List<int>> getPurchaseTicket58mm({
    required PrintPurchaseTransactionModel printTransactionModel,
    required List<PurchaseDetails>? productList,
  }) async {
    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.purchaseDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    String productName({required num detailsId}) {
      final details =
          printTransactionModel.purchaseTransitionModel?.details?[printTransactionModel.purchaseTransitionModel!.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}";
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              if (details.purchaseDetailId == detailsId) {
                totalQuantity += details.returnQty ?? 0;
              }
            }
          }
        }
      }

      return totalQuantity;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in productList!) {
        // Calculate the total for each item without VAT
        num productPrice = element.productPurchasePrice ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.text(printTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        'Seller :${printTransactionModel.purchaseTransitionModel?.user?.role == "shop-owner" ? "Admin" : printTransactionModel.purchaseTransitionModel?.user?.name}',
        styles: const PosStyles(align: PosAlign.center));

    if (printTransactionModel.personalInformationModel.address != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.address ?? '', styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printTransactionModel.personalInformationModel.vatName ?? 'VAT No :'}${printTransactionModel.personalInformationModel.vatNumber ?? ''}",
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text('Tel: ${printTransactionModel.personalInformationModel.phoneNumber ?? ''}', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.text('Name: ${printTransactionModel.purchaseTransitionModel?.party?.name ?? 'Guest'}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('mobile: ${printTransactionModel.purchaseTransitionModel?.party?.phone ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Purchase By: ${printTransactionModel.purchaseTransitionModel?.user?.name ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left));
    bytes +=
        generator.text('Invoice: ${printTransactionModel.purchaseTransitionModel?.invoiceNumber ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left), linesAfter: 1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Price', width: 3, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      return bytes += generator.row([
        PosColumn(
            text:
                "${productList?[index].product?.productName ?? 'Not Defined'}${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}",
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(productList?[index].productPurchasePrice ?? 0),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0)), width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: "${(productList?[index].productPurchasePrice ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0)}",
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    });

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Subtotal',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '${getTotalForOldInvoice()}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber((printTransactionModel.purchaseTransitionModel?.discountAmount ?? 0) + getReturndDiscountAmount()),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: printTransactionModel.purchaseTransitionModel?.vat?.name ?? 'Vat',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber((printTransactionModel.purchaseTransitionModel?.vatAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Total',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: formatPointNumber((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) + getTotalReturndAmount()),
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);
    List<DateTime> returnedDates = [];

    ///_____Return_table_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) =>
            element.isAtSameMomentAs(DateTime.tryParse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now()))) {
          bytes += generator.row([
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 7,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now());
          final product = printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?[index];
          return bytes += generator.row([
            PosColumn(text: productName(detailsId: product?.purchaseDetailId ?? 0), width: 7, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: product?.returnQty.toString() ?? 'Not Defined', width: 2, styles: const PosStyles(align: PosAlign.center)),
            PosColumn(text: "${(product?.returnAmount ?? 0)}", width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
        });
        //
      });
    }
    bytes += generator.hr();

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '${getTotalReturndAmount()}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    bytes += generator.row([
      PosColumn(text: 'Total Payable', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0), width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) - (printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0)) +
              (printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Due Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Payment Type:',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: printTransactionModel.purchaseTransitionModel?.paymentType?.name ?? 'N/A',
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);

    bytes += generator.hr();
    bytes += generator.text(
      'Payment Type: ${printTransactionModel.purchaseTransitionModel?.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );

    // ticket.feed(2);
    if (printTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printTransactionModel.purchaseTransitionModel!.purchaseDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if (printTransactionModel.personalInformationModel.invoiceNoteLevel != null || printTransactionModel.personalInformationModel.invoiceNote != null) {
      bytes += generator.text('${printTransactionModel.personalInformationModel.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.invoiceNote ?? ''}',
          styles: const PosStyles(align: PosAlign.left, bold: false), linesAfter: 1);
    }
    if (printTransactionModel.personalInformationModel.companyWebsiteUrl != null) {
      bytes += generator.qrcode(
        printTransactionModel.personalInformationModel.companyWebsiteUrl ?? '',
      );
      bytes += generator.emptyLines(1);
    }
    if (printTransactionModel.personalInformationModel.developedByLevel != null || printTransactionModel.personalInformationModel.developedBy != null) {
      bytes += generator.text(
          '${printTransactionModel.personalInformationModel.developedByLevel ?? 'Developed By'}: ${printTransactionModel.personalInformationModel.developedBy ?? companyName}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getPurchaseTicket80mm({required PrintPurchaseTransactionModel printTransactionModel, required List<PurchaseDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.purchaseDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    String productName({required num detailsId}) {
      final details =
          printTransactionModel.purchaseTransitionModel?.details?[printTransactionModel.purchaseTransitionModel!.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}";
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              if (details.purchaseDetailId == detailsId) {
                totalQuantity += details.returnQty ?? 0;
              }
            }
          }
        }
      }
      return totalQuantity;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in productList!) {
        num productPrice = element.productPurchasePrice ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);
        total += productPrice * productQuantity;
      }
      return total;
    }

    List<int> bytes = [];
    final _logo = await getNetworkImage("${APIConfig.domain}${printTransactionModel.personalInformationModel.invoiceLogo}");
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    ///____________Image__________________________________
    if (_logo != null) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    ///____________Header_____________________________________
    bytes += generator.text(printTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    if (printTransactionModel.personalInformationModel.address != null) {
      bytes += generator.text('Address: ${printTransactionModel.personalInformationModel.address}', styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.phoneNumber != null) {
      bytes += generator.text('Mobile: ${printTransactionModel.personalInformationModel.phoneNumber}', styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printTransactionModel.personalInformationModel.vatName ?? 'VAT No'}: ${printTransactionModel.personalInformationModel.vatNumber}",
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('INVOICE',
        styles: const PosStyles(
          bold: true,
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    if (printTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printTransactionModel.personalInformationModel.vatName ?? 'VAT No :'}${printTransactionModel.personalInformationModel.vatNumber}",
          styles: const PosStyles(align: PosAlign.center));
    }

    ///__________Customer_and_time_section_______________________
    bytes += generator.row([
      PosColumn(text: 'Invoice: ${printTransactionModel.purchaseTransitionModel?.invoiceNumber ?? 'Not Provided'}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Date: ${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Name: ${printTransactionModel.purchaseTransitionModel?.party?.name ?? 'Guest'}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Time: ${DateFormat.jm().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Mobile: ${printTransactionModel.purchaseTransitionModel?.party?.phone ?? ''}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Purchase By: ${printTransactionModel.purchaseTransitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.purchaseTransitionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    List.generate(productList?.length ?? 1, (index) {
      return bytes += generator.row([
        PosColumn(
            text: '${index + 1}',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text:
                "${productList?[index].product?.productName ?? ''}${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}",
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0), addComma: true), width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: formatPointNumber(productList?[index].productPurchasePrice ?? 0, addComma: true),
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: formatPointNumber((productList?[index].productPurchasePrice ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0), addComma: true),
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    });

    // for (var item in productList ?? []) {
    //   final qty = getProductQuantity(detailsId: item.id ?? 0);
    //   final price = item.productPurchasePrice ?? 0;
    //   bytes += generator.row([
    //     PosColumn(text: item.product?.productName ?? '', width: 5),
    //     PosColumn(text: formatPointNumber(price), width: 2, styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(text: formatPointNumber(qty), width: 2, styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(text: formatPointNumber(price * qty), width: 3, styles: const PosStyles(align: PosAlign.right)),
    //   ]);
    // }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Sub-total:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(getTotalForOldInvoice(), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber((printTransactionModel.purchaseTransitionModel?.discountAmount ?? 0) + getReturndDiscountAmount(), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '${printTransactionModel.purchaseTransitionModel?.vat?.name ?? 'VAT'}:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.vatAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    ///_____Return_table_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) =>
            element.isAtSameMomentAs(DateTime.tryParse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now()))) {
          bytes += generator.row([
            PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 6,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now());
          final product = printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?[index];
          return bytes += generator.row([
            PosColumn(
                text: '${index + 1}',
                width: 1,
                styles: const PosStyles(
                  align: PosAlign.left,
                )),
            PosColumn(text: productName(detailsId: product?.purchaseDetailId ?? 0), width: 6, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: product?.returnQty.toString() ?? 'Not Defined', width: 2, styles: const PosStyles(align: PosAlign.center)),
            PosColumn(text: formatPointNumber(product?.returnAmount ?? 0, addComma: true), width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
        });
        //
      });
    }

    final returnedAmount = getTotalReturndAmount();

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(returnedAmount, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    } else {
      bytes += generator.text('                    ----------------------------');
    }

    bytes += generator.row([
      PosColumn(text: 'Total Payable:', width: 9, styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(
              ((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) - (printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0)) +
                  (printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0),
              addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if ((printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Due Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    if ((printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.text(
      'Payment Type: ${printTransactionModel.purchaseTransitionModel?.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );
    if (printTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printTransactionModel.purchaseTransitionModel?.purchaseDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.text(printTransactionModel.purchaseTransitionModel!.purchaseDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    if (printTransactionModel.personalInformationModel.invoiceNoteLevel != null || printTransactionModel.personalInformationModel.invoiceNote != null) {
      bytes += generator.text(
        '${printTransactionModel.personalInformationModel.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printTransactionModel.personalInformationModel.companyWebsiteUrl != null) {
      bytes += generator.qrcode(
        printTransactionModel.personalInformationModel.companyWebsiteUrl ?? '',
      );
      bytes += generator.emptyLines(1);
    }
    if (printTransactionModel.personalInformationModel.developedByLevel != null || printTransactionModel.personalInformationModel.developedBy != null) {
      bytes += generator.text('${printTransactionModel.personalInformationModel.developedByLevel ?? ''}: ${printTransactionModel.personalInformationModel.developedBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }
}
