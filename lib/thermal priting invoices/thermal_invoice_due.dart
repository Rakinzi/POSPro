import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Const/api_config.dart';
import '../constant.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';
import 'package:image/image.dart' as img;

class DueThermalPrinterInvoice {
  ///_________Due________________________
  Future<void> printDueTicket({required PrintDueTransactionModel printDueTransactionModel, required String? invoiceSize}) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      List<int> bytes = (printDueTransactionModel.personalInformationModel.invoiceSize == '3_inch_80mm' && printDueTransactionModel.personalInformationModel.invoiceSize != null)
          ? await getDueTicket80mm(printDueTransactionModel: printDueTransactionModel)
          : await getDueTicket50mm(printDueTransactionModel: printDueTransactionModel);
      await PrintBluetoothThermal.writeBytes(bytes);
      // if (invoiceSize != null && invoiceSize == '3_inch_80mm') {
      //   List<int> bytes = await getDueTicket80mm(printDueTransactionModel: printDueTransactionModel);
      //   await PrintBluetoothThermal.writeBytes(bytes);
      // } else {
      //   List<int> bytes = await getDueTicket56mm(printDueTransactionModel: printDueTransactionModel);
      //   await PrintBluetoothThermal.writeBytes(bytes);
      // }
    } else {}
  }

  Future<List<int>> getDueTicket50mm({required PrintDueTransactionModel printDueTransactionModel}) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    // final ByteData data = await rootBundle.load('images/logo.png');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final Image? imagez = decodeImage(imageBytes);
    // bytes += generator.image(imagez!);
    bytes += generator.text(printDueTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        'Seller :${printDueTransactionModel.dueTransactionModel?.user?.role == "shop-owner" ? 'Admin' : printDueTransactionModel.dueTransactionModel?.user?.name ?? ''}',
        styles: const PosStyles(align: PosAlign.center));

    if (printDueTransactionModel.personalInformationModel.address != null) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.address ?? '', styles: const PosStyles(align: PosAlign.center));
    }
    if (printDueTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printDueTransactionModel.personalInformationModel.vatName ?? 'VAT No :'}${printDueTransactionModel.personalInformationModel.vatNumber ?? ''}",
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text(printDueTransactionModel.personalInformationModel.phoneNumber ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.text('Received From: ${printDueTransactionModel.dueTransactionModel?.party?.name} ', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Mobile: ${printDueTransactionModel.dueTransactionModel?.party?.phone}', styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Received By: ${printDueTransactionModel.dueTransactionModel?.user?.name}', styles: const PosStyles(align: PosAlign.left));
    bytes +=
        generator.text('Invoice: ${printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Invoice', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Due', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? '',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.totalDue.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.payDueAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Remaining Due:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.dueAmountAfterPay.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.hr();
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Payment Type:',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: printDueTransactionModel.dueTransactionModel!.paymentType?.name ?? 'N/A',
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);

    bytes += generator.text(
      'Payment Type: ${printDueTransactionModel.dueTransactionModel!.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );

    // ticket.feed(2);
    if (printDueTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printDueTransactionModel.dueTransactionModel!.paymentDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if (printDueTransactionModel.personalInformationModel.invoiceNoteLevel != null || printDueTransactionModel.personalInformationModel.invoiceNote != null) {
      bytes += generator.text(
        '${printDueTransactionModel.personalInformationModel.invoiceNoteLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printDueTransactionModel.personalInformationModel.companyWebsiteUrl != null) {
      bytes += generator.qrcode(
        printDueTransactionModel.personalInformationModel.companyWebsiteUrl ?? '',
      );
      bytes += generator.emptyLines(1);
    }
    if (printDueTransactionModel.personalInformationModel.developedByLevel != null || printDueTransactionModel.personalInformationModel.developedBy != null) {
      bytes += generator.text('${printDueTransactionModel.personalInformationModel.developedByLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.developedBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getDueTicket80mm({required PrintDueTransactionModel printDueTransactionModel}) async {
    List<int> bytes = [];
    final _logo = await getNetworkImage("${APIConfig.domain}${printDueTransactionModel.personalInformationModel.invoiceLogo}");
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
    bytes += generator.text(printDueTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    if (printDueTransactionModel.personalInformationModel.address != null) {
      bytes += generator.text('Address: ${printDueTransactionModel.personalInformationModel.address}', styles: const PosStyles(align: PosAlign.center));
    }
    if (printDueTransactionModel.personalInformationModel.phoneNumber != null) {
      bytes += generator.text('Mobile: ${printDueTransactionModel.personalInformationModel.phoneNumber}', styles: const PosStyles(align: PosAlign.center));
    }
    if (printDueTransactionModel.personalInformationModel.vatNumber != null) {
      bytes += generator.text("${printDueTransactionModel.personalInformationModel.vatName ?? 'VAT No'}: ${printDueTransactionModel.personalInformationModel.vatNumber}",
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('Receipt',
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
      PosColumn(text: 'Invoice: ${printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? 'Not Provided'}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Date: ${DateFormat.yMd().format(DateTime.parse(printDueTransactionModel.dueTransactionModel?.paymentDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Name: ${printDueTransactionModel.dueTransactionModel?.party?.name ?? ''}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Time: ${DateFormat.jm().format(DateTime.parse(printDueTransactionModel.dueTransactionModel?.paymentDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Mobile: ${printDueTransactionModel.dueTransactionModel?.party?.phone ?? ''}', width: 6, styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'Received By: ${printDueTransactionModel.dueTransactionModel?.user?.role == "shop-owner" ? 'Admin' : printDueTransactionModel.dueTransactionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Invoice', width: 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Due', width: 5, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: '1', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? '', width: 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: formatPointNumber(printDueTransactionModel.dueTransactionModel?.totalDue ?? 0, addComma: true), width: 5, styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printDueTransactionModel.dueTransactionModel?.payDueAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Remaining Due:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber((printDueTransactionModel.dueTransactionModel?.dueAmountAfterPay ?? 0), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    // bytes += generator.hr();
    bytes += generator.text(
      '-----------------------------',
      styles: const PosStyles(align: PosAlign.right),
    );
    bytes += generator.text(
      'Payment Type: ${printDueTransactionModel.dueTransactionModel?.paymentType?.name ?? 'N/A'}',
      linesAfter: 1,
    );

    if (printDueTransactionModel.personalInformationModel.postSaleMassage != null) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.postSaleMassage ?? '', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printDueTransactionModel.dueTransactionModel!.paymentDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if (printDueTransactionModel.personalInformationModel.invoiceNoteLevel != null || printDueTransactionModel.personalInformationModel.invoiceNote != null) {
      bytes += generator.text(
        '${printDueTransactionModel.personalInformationModel.invoiceNoteLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printDueTransactionModel.personalInformationModel.companyWebsiteUrl != null) {
      bytes += generator.qrcode(
        printDueTransactionModel.personalInformationModel.companyWebsiteUrl ?? '',
      );
      bytes += generator.emptyLines(1);
    }

    if (printDueTransactionModel.personalInformationModel.developedByLevel != null || printDueTransactionModel.personalInformationModel.developedBy != null) {
      bytes += generator.text('${printDueTransactionModel.personalInformationModel.developedByLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.developedBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }
}
