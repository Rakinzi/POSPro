import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Const/api_config.dart';
import '../Screens/Products/add_product.dart';
import '../constant.dart';
import '../model/sale_transaction_model.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';

class SalesThermalPrinterInvoice {
  ///________Sales____________________

  Future<void> printSalesTicket({required PrintSalesTransactionModel printTransactionModel, required List<SalesDetails>? productList}) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      List<int> bytes = (printTransactionModel.personalInformationModel.invoiceSize == '3_inch_80mm' && printTransactionModel.personalInformationModel.invoiceSize != null)
          ? await getSalesTicket80mm(printTransactionModel: printTransactionModel, productList: productList)
          : await getSalesTicket58mm(printTransactionModel: printTransactionModel, productList: productList);
      if (printTransactionModel.transitionModel?.salesDetails?.isNotEmpty ?? false) {
        await PrintBluetoothThermal.writeBytes(bytes);
        EasyLoading.showSuccess('Successfully Printed');
      } else {
        toast('No Product Found');
      }
    } else {
      EasyLoading.showError('Unable to connect with printer');
    }
  }

  Future<List<int>> getSalesTicket58mm({required PrintSalesTransactionModel printTransactionModel, required List<SalesDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    String productName({required num detailsId}) {
      final details = productList?[productList.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList!.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              if (details.saleDetailId == detailsId) {
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
        total += (element.price ?? 0) * getProductQuantity(detailsId: element.id ?? 0);
      }

      return total;
    }

    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    List<int> bytes = [];
    final _logo = await getNetworkImage("${APIConfig.domain}${printTransactionModel.personalInformationModel.invoiceLogo}");
    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm58, profile);

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
    if (_logo != null) bytes += generator.text(' ');

    bytes += generator.text('Seller :${printTransactionModel.transitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.transitionModel!.user?.name}',
        styles: const PosStyles(align: PosAlign.center));
    if (printTransactionModel.personalInformationModel.address != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.address ?? '', styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printTransactionModel.personalInformationModel.vatName ?? 'VAT No :'}${printTransactionModel.personalInformationModel.vatNumber ?? ''}",
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text('Tel: ${printTransactionModel.personalInformationModel.phoneNumber ?? ''}', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.text('Name: ${printTransactionModel.transitionModel?.party?.name ?? 'Guest'}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('mobile: ${printTransactionModel.transitionModel?.party?.phone ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Sales By: ${printTransactionModel.transitionModel?.user?.name ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Invoice: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Price', width: 3, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Amount', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      return bytes += generator.row([
        PosColumn(
            text:
                "${productList?[index].product?.productName ?? ''}${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}",
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '${productList?[index].price}',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0)), width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: "${(productList?[index].price ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0)}", width: 3, styles: const PosStyles(align: PosAlign.right)),
      ]);
    });
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Sub-total',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(getTotalForOldInvoice(), addComma: true),
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
          text: formatPointNumber((printTransactionModel.transitionModel?.discountAmount ?? 0) + getReturndDiscountAmount()),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: printTransactionModel.transitionModel?.vat?.name ?? 'VAT',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '${printTransactionModel.transitionModel?.vatAmount ?? 0}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Shipping Charge',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '${printTransactionModel.transitionModel?.shippingCharge ?? 0}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if (printTransactionModel.transitionModel?.roundingAmount != 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Total',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: (formatPointNumber(printTransactionModel.transitionModel?.actualTotalAmount ?? 0)),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Rounding',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text:
                ("${!(printTransactionModel.transitionModel?.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber(printTransactionModel.transitionModel?.roundingAmount ?? 0)}"),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    ///_____Return_table_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.transitionModel?.salesReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) =>
            element.isAtSameMomentAs(DateTime.tryParse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now()))) {
          bytes += generator.row([
            PosColumn(
                text: 'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 7,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now());
          final product = printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?[index];
          return bytes += generator.row([
            PosColumn(text: productName(detailsId: product?.saleDetailId ?? 0), width: 7, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: product?.returnQty.toString() ?? 'Not Defined', width: 2, styles: const PosStyles(align: PosAlign.center)),
            PosColumn(text: "${(product?.returnAmount ?? 0)}", width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
        });
        //
      });
    }
    bytes += generator.hr();

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
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
      PosColumn(text: printTransactionModel.transitionModel?.totalAmount.toString() ?? '', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(((printTransactionModel.transitionModel?.totalAmount ?? 0) - (printTransactionModel.transitionModel?.dueAmount ?? 0)) +
              (printTransactionModel.transitionModel?.changeAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.transitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Due Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.dueAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.transitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.changeAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    bytes += generator.hr();

    bytes += generator.text(
      'Payment Type: ${printTransactionModel.transitionModel?.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );

    if (printTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printTransactionModel.transitionModel!.saleDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

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

  Future<List<int>> getSalesTicket80mm({required PrintSalesTransactionModel printTransactionModel, required List<SalesDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    String productName({required num detailsId}) {
      final details = productList?[productList.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList!.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              if (details.saleDetailId == detailsId) {
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
        total += (element.price ?? 0) * getProductQuantity(detailsId: element.id ?? 0);
      }

      return total;
    }

    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
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

    ///__________Customer_and_time_section_______________________
    bytes += generator.row([
      PosColumn(text: 'Invoice: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Date: ${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.saleDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Name: ${printTransactionModel.transitionModel?.party?.name ?? ''}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Time: ${DateFormat.jm().format(DateTime.parse(printTransactionModel.transitionModel?.saleDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Mobile: ${printTransactionModel.transitionModel?.party?.phone ?? ''}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Sales By: ${printTransactionModel.transitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.transitionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);

    ///____________Products_Section_________________________________
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Amount', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
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
            text: formatPointNumber(productList?[index].price ?? 0, addComma: true),
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: formatPointNumber((productList?[index].price ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0), addComma: true),
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    });
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
          text: formatPointNumber((printTransactionModel.transitionModel?.discountAmount ?? 0) + getReturndDiscountAmount(), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '${printTransactionModel.transitionModel?.vat?.name ?? 'VAT'}:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printTransactionModel.transitionModel?.vatAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Shipping Charge:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printTransactionModel.transitionModel?.shippingCharge ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if (printTransactionModel.transitionModel?.roundingAmount != 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Total:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: (formatPointNumber(printTransactionModel.transitionModel?.actualTotalAmount ?? 0, addComma: true)),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Rounding:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text:
                ("${!(printTransactionModel.transitionModel?.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber(printTransactionModel.transitionModel?.roundingAmount ?? 0, addComma: true)}"),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    ///_____Return_table_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.transitionModel?.salesReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) =>
            element.isAtSameMomentAs(DateTime.tryParse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now()))) {
          bytes += generator.row([
            PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text: 'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 6,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ?? DateTime.now());
          final product = printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?[index];
          return bytes += generator.row([
            PosColumn(
                text: '${index + 1}',
                width: 1,
                styles: const PosStyles(
                  align: PosAlign.left,
                )),
            PosColumn(text: productName(detailsId: product?.saleDetailId ?? 0), width: 6, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: product?.returnQty.toString() ?? 'Not Defined', width: 2, styles: const PosStyles(align: PosAlign.center)),
            PosColumn(text: formatPointNumber(product?.returnAmount ?? 0, addComma: true), width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
        });
        //
      });
    }

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(getTotalReturndAmount(), addComma: true),
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
          text: formatPointNumber(printTransactionModel.transitionModel?.totalAmount ?? 0, addComma: true), width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
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
              ((printTransactionModel.transitionModel?.totalAmount ?? 0) - (printTransactionModel.transitionModel?.dueAmount ?? 0)) +
                  (printTransactionModel.transitionModel?.changeAmount ?? 0),
              addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.transitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Due Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.dueAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.transitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.changeAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    bytes += generator.hr();

    bytes += generator.text(
      'Payment Type: ${printTransactionModel.transitionModel?.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );

    if (printTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));

      bytes += generator.text(printTransactionModel.transitionModel!.saleDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
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
