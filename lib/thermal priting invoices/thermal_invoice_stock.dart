import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;
import '../Const/api_config.dart';
import '../Screens/Products/Model/product_total_stock_model.dart';
import '../constant.dart';
import '../model/business_info_model.dart';
import 'network_image.dart';

class StockThermalPrinterInvoice {
  ///________Sales____________________

  Future<void> printStockTicket({
    required BusinessInformationModel businessInformationModel,
    required List<ProductModel>? productList,
    required ProductListResponse stock,
  }) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      List<int> bytes = await getStockTicket(
          businessInformationModel: businessInformationModel, productList: productList, is80mm: businessInformationModel.invoiceSize == '3_inch_80mm', stockValue: stock);
      if (productList?.isNotEmpty ?? false) {
        await PrintBluetoothThermal.writeBytes(bytes);
        EasyLoading.showSuccess('Successfully Printed');
      } else {
        toast('No Product Found');
      }
    } else {
      EasyLoading.showError('Unable to connect with printer');
    }
  }

  Future<List<int>> getStockTicket(
      {required BusinessInformationModel businessInformationModel, required List<ProductModel>? productList, required bool is80mm, ProductListResponse? stockValue}) async {
    final _logo = await getNetworkImage("${APIConfig.domain}${businessInformationModel.invoiceLogo}");

    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(is80mm ? PaperSize.mm80 : PaperSize.mm58, profile);

    ///____________Image__________________________________
    if (_logo != null) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    bytes += generator.text(
      businessInformationModel.companyName ?? '',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    bytes += generator.text('Seller :${businessInformationModel.user?.role == "shop-owner" ? 'Admin' : businessInformationModel.user?.name}',
        styles: const PosStyles(align: PosAlign.center));
    if (businessInformationModel.address != null) {
      bytes += generator.text(businessInformationModel.address ?? '', styles: const PosStyles(align: PosAlign.center));
    }
    if (businessInformationModel.phoneNumber != null) {
      bytes += generator.text('Phone : ${businessInformationModel.phoneNumber ?? ''}', styles: const PosStyles(align: PosAlign.center));
    }
    if (businessInformationModel.vatNumber != null) {
      bytes += generator.text("${businessInformationModel.vatName ?? 'VAT No'}: ${businessInformationModel.vatNumber ?? ''}",
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.text('Stock List',
        styles: const PosStyles(
          align: PosAlign.center,
          underline: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text('Date : $formattedDate', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Time : $formattedTime', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item Name', width: is80mm ? 7 : 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: is80mm ? 2 : 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      final stokePrice = productList![index].stocks != null && productList[index].stocks!.isNotEmpty ? productList[index].stocks!.last.productPurchasePrice : 0;
      return bytes += generator.row([
        PosColumn(
            text: '${index + 1}',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '${productList[index].productName}',
            width: is80mm ? 7 : 6,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(text: '${productList[index].productStockSum}', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: (formatPointNumber(stokePrice ?? 0, addComma: true)), width: is80mm ? 2 : 3, styles: const PosStyles(align: PosAlign.right)),
      ]);
    });
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Total Stock value :',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(stockValue!.totalStockValue),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.text('');
    // bytes += generator.text('Developed By: $companyName', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    if (businessInformationModel.postSaleMassage != null) {
      bytes += generator.text(
        businessInformationModel.postSaleMassage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1,
      );
    }

    if (businessInformationModel.invoiceNoteLevel != null || businessInformationModel.invoiceNote != null) {
      bytes += generator.text(
        '${businessInformationModel.invoiceNoteLevel ?? ''}: ${businessInformationModel.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (businessInformationModel.companyWebsiteUrl != null) {
      bytes += generator.qrcode(
        businessInformationModel.companyWebsiteUrl ?? '',
      );
      bytes += generator.emptyLines(1);
    }
    if (businessInformationModel.developedByLevel != null || businessInformationModel.developedBy != null) {
      bytes += generator.text('${businessInformationModel.developedByLevel ?? ''}: ${businessInformationModel.developedBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }
}
