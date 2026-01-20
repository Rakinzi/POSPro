import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/business_setting_model.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Screens/Products/add_product.dart';
import '../model/business_info_model.dart';
import 'pdf_common_functions.dart';

class SalesInvoicePdf {
  static Future<void> generateSaleDocument(
      SalesTransactionModel transactions, BusinessInformationModel personalInformation, BuildContext context, BusinessSettingModel businessSetting,
      {bool? share, bool? download}) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    ///-------returned_discount_amount
    num productPrice({required num detailsId}) {
      return transactions.salesDetails!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num returnedDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        total += (element.price ?? 0) * PDFCommonFunctions().getProductQuantity(detailsId: element.id ?? 0, transactions: transactions);
      }

      return total;
    }

    String productName({required num detailsId}) {
      final details = transactions.salesDetails?[transactions.salesDetails!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
    }

    final String imageUrl = '${APIConfig.domain}${businessSetting.pictureUrl}';
    dynamic imageData = await PDFCommonFunctions().getNetworkImage(imageUrl);
    imageData ??= await PDFCommonFunctions().loadAssetImage('images/logo.png');
    final englishFont = pw.Font.ttf(await rootBundle.load('fonts/NotoSans/NotoSans-Regular.ttf'));
    final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));
    final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
    final hindiFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Hind-Regular.ttf'));
    final frenchFont = pw.Font.ttf(await rootBundle.load('assets/fonts/GFSDidot-Regular.ttf'));

    getFont() {
      if (selectedLanguage == 'en') {
        return englishFont;
      } else if (selectedLanguage == 'bn') {
        return banglaFont;
      } else if (selectedLanguage == 'ar') {
        return arabicFont;
      } else if (selectedLanguage == 'hi') {
        return hindiFont;
      } else if (selectedLanguage == 'fr') {
        return frenchFont;
      } else {
        return englishFont;
      }
    }

    getFontWithLangMatching(String data) {
      String detectedLanguage = detectLanguageEnhanced(data);
      if (detectedLanguage == 'en') {
        return englishFont;
      } else if (detectedLanguage == 'bn') {
        return banglaFont;
      } else if (detectedLanguage == 'ar') {
        return arabicFont;
      } else if (detectedLanguage == 'hi') {
        return hindiFont;
      } else if (detectedLanguage == 'fr') {
        return frenchFont;
      } else {
        return englishFont;
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20.0),
            child: pw.Column(
              children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Row(children: [
                    // image section
                    if (imageData is Uint8List)
                      pw.Container(
                        height: 54.12,
                        width: 52,
                        child: pw.Image(
                          pw.MemoryImage(imageData),
                          fit: pw.BoxFit.cover,
                        ),
                      )
                    else if (imageData is String)
                      pw.Container(
                        height: 54.12,
                        width: 52,
                        child: pw.SvgImage(
                          svg: imageData,
                          fit: pw.BoxFit.cover,
                        ),
                      )
                    else
                      pw.Container(
                        height: 54.12,
                        width: 52,
                        child: pw.Image(pw.MemoryImage(imageData)),
                      ),
                    pw.SizedBox(width: 10.0),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      // getLocalizedPdfTextWithLanguage(
                      //     personalInformation.companyName ?? '',
                      //     pw.TextStyle(
                      //         color: PdfColors.black,
                      //         fontSize: 24.0,
                      //         fontWeight: pw.FontWeight.bold,
                      //         fontFallback: [englishFont],
                      //         font: getFontWithLangMatching(personalInformation.companyName ?? ''))),
                      getLocalizedPdfTextWithLanguage(
                          personalInformation.companyName ?? '',
                          pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 24.0,
                            fontWeight: pw.FontWeight.bold,
                            font: getFontWithLangMatching(personalInformation.companyName ?? ''), // ✅ Always set this
                            fontFallback: [englishFont, banglaFont, arabicFont, hindiFont, frenchFont], // ✅ fallback for safety
                          )),
                      getLocalizedPdfText(
                          '${_lang.mobile} ${personalInformation.phoneNumber ?? ''}',
                          pw.TextStyle(
                            color: PdfColors.black,
                            font: getFont(),
                            fontFallback: [englishFont],
                          )),
                    ]),
                  ]),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    height: 52,
                    width: 192,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.black,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(25),
                        bottomLeft: pw.Radius.circular(25),
                      ),
                    ),
                    child: getLocalizedPdfText(
                      _lang.INVOICE,
                      pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 35,
                        font: getFont(),
                        fontFallback: [englishFont],
                      ),
                    ),
                  ),
                ]),
                pw.SizedBox(height: 35.0),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Column(children: [
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: getLocalizedPdfText(
                            _lang.billTO,
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfTextWithLanguage(
                            transactions.party?.name ?? '',
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFontWithLangMatching(transactions.party?.name ?? ''),
                              fontFallback: [englishFont],
                            )),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: getLocalizedPdfText(
                            _lang.mobile,
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            transactions.party?.phone ?? (transactions.meta?.customerPhone ?? _lang.guest), pw.TextStyle(font: getFont(), fontFallback: [englishFont])),
                      ),
                    ]),
                  ]),
                  pw.Column(children: [
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            _lang.sellsBy,
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 70.0,
                        child: getLocalizedPdfTextWithLanguage(
                            transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? '',
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFontWithLangMatching(transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? ''),
                              fontFallback: [englishFont],
                            )),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            _lang.invoiceNumber,
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 70.0,
                        child: pw.Text(
                          '#${transactions.invoiceNumber}',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            _lang.date,
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 70.0,
                        child: getLocalizedPdfText(
                          DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.saleDate ?? '')),
                          // DateTimeFormat.format(DateTime.parse(transactions.saleDate ?? ''), format: 'D, M j'),
                          pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                        ),
                      ),
                    ]),
                    if (personalInformation.vatNumber != null)
                      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.SizedBox(
                          width: 100.0,
                          child: getLocalizedPdfTextWithLanguage(
                              personalInformation.vatName ?? _lang.vatNumber,
                              pw.TextStyle(
                                color: PdfColors.black,
                                font: getFontWithLangMatching(personalInformation.vatName ?? _lang.vatNumber),
                                fontFallback: [englishFont],
                              )),
                        ),
                        pw.SizedBox(
                          width: 10.0,
                          child: pw.Text(
                            ':',
                            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                          ),
                        ),
                        pw.SizedBox(
                          width: 70.0,
                          child: pw.Text(
                            personalInformation.vatNumber ?? '',
                            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                          ),
                        ),
                      ]),
                  ]),
                ]),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Column(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    getLocalizedPdfText(
                        _lang.customerSignature,
                        pw.TextStyle(
                          color: PdfColors.black,
                          font: getFont(),
                          fontFallback: [englishFont],
                        ))
                  ]),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    getLocalizedPdfText(
                        _lang.authorizedSignature,
                        pw.TextStyle(
                          color: PdfColors.black,
                          font: getFont(),
                          fontFallback: [englishFont],
                        ))
                  ]),
                ),
              ]),
            ),
            if (!personalInformation.postSaleMassage.isEmptyOrNull)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(bottom: 8.0),
                child: pw.Center(child: pw.Text(personalInformation.postSaleMassage ?? '',)),
              ),
            pw.Container(
              width: double.infinity,
              color: const PdfColor.fromInt(0xffC52127),
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Center(
                  child: pw.Text('${personalInformation.developedByLevel ?? ''} ${personalInformation.developedBy ?? ''}',
                      style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
            ),
          ]);
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                pw.Table(
                  border: const pw.TableBorder(
                    verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                  ),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(6),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    //pdf header
                    pw.TableRow(
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColor.fromInt(0xffC52127),
                          ), // Red background
                          padding: const pw.EdgeInsets.all(8.0),
                          child: getLocalizedPdfText(
                            _lang.sl,
                            pw.TextStyle(
                              color: PdfColors.white,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                            textAlignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xffC52127), // Red background
                          padding: const pw.EdgeInsets.all(8.0),
                          child: getLocalizedPdfText(
                            _lang.item,
                            pw.TextStyle(
                              color: PdfColors.white,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                            textAlignment: pw.TextAlign.left,
                          ),
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xff000000), // Black background
                          padding: const pw.EdgeInsets.all(8.0),
                          child: getLocalizedPdfText(
                            _lang.quantity,
                            pw.TextStyle(
                              color: PdfColors.white,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                            textAlignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xff000000), // Black background
                          padding: const pw.EdgeInsets.all(8.0),
                          child: getLocalizedPdfText(
                            _lang.unitPrice,
                            pw.TextStyle(
                              color: PdfColors.white,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                            textAlignment: pw.TextAlign.right,
                          ),
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xff000000), // Black background
                          padding: const pw.EdgeInsets.all(8.0),
                          child: getLocalizedPdfText(
                            _lang.totalPrice,
                            pw.TextStyle(
                              color: PdfColors.white,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                            textAlignment: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < transactions.salesDetails!.length; i++)
                      pw.TableRow(
                        decoration: i % 2 == 0
                            ? const pw.BoxDecoration(
                                color: PdfColors.white,
                              ) // Odd row color
                            : const pw.BoxDecoration(
                                color: PdfColors.red50,
                              ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${i + 1}', textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfTextWithLanguage(
                                "${transactions.salesDetails!.elementAt(i).product?.productName.toString() ?? ''}${transactions.salesDetails?.elementAt(i).product?.productType == ProductType.variant.name ? ' [${transactions.salesDetails?.elementAt(i).stock?.batchNo ?? ''}]' : ''}",
                                pw.TextStyle(
                                    font: getFontWithLangMatching(transactions.salesDetails!.elementAt(i).product?.productName.toString() ?? ''), fontFallback: [englishFont]),
                                textAlignment: pw.TextAlign.left),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              formatPointNumber(PDFCommonFunctions().getProductQuantity(detailsId: transactions.salesDetails![i].id ?? 0, transactions: transactions)),
                              textAlignment: pw.TextAlign.center,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              formatPointNumber(transactions.salesDetails!.elementAt(i).price ?? 0),
                              textAlignment: pw.TextAlign.right,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              formatPointNumber((transactions.salesDetails![i].price ?? 0) *
                                  (PDFCommonFunctions().getProductQuantity(detailsId: transactions.salesDetails![i].id ?? 0, transactions: transactions))),
                              textAlignment: pw.TextAlign.right,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Subtotal, VAT, Discount, and Total Amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.SizedBox(height: 10.0),
                        getLocalizedPdfText(
                            "${_lang.subTotal}: ${formatPointNumber(getTotalForOldInvoice())}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                        pw.SizedBox(height: 5.0),
                        getLocalizedPdfText(
                            "${_lang.discount}: ${formatPointNumber((transactions.discountAmount ?? 0) + returnedDiscountAmount())}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                        pw.SizedBox(height: 5.0),
                        getLocalizedPdfText(
                            "${transactions.vat?.name ?? _lang.vat}: ${formatPointNumber(transactions.vatAmount ?? 0.00)}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                        pw.SizedBox(height: 5.0),
                        getLocalizedPdfText(
                            "${_lang.shippingCharge}: ${formatPointNumber((transactions.shippingCharge ?? 0))}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                        pw.SizedBox(height: 5.0),

                        ///______Rounded_amount__________________________________
                        if (transactions.roundingAmount != 0)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              getLocalizedPdfText(
                                  "${_lang.amount}: ${formatPointNumber((transactions.actualTotalAmount ?? 0))}",
                                  pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    font: getFont(),
                                    fontFallback: [englishFont],
                                  )),
                              pw.SizedBox(height: 5.0),
                              getLocalizedPdfText(
                                  "${_lang.rounding}: ${!(transactions.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber((transactions.roundingAmount ?? 0))}",
                                  pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    font: getFont(),
                                    fontFallback: [englishFont],
                                  )),
                              pw.SizedBox(height: 5.0),
                            ],
                          ),
                        getLocalizedPdfText(
                            "${_lang.totalAmount}: ${formatPointNumber((transactions.totalAmount ?? 0) + getTotalReturndAmount())}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                        pw.SizedBox(height: 10.0),
                      ],
                    ),
                  ],
                ),

                // Return table
                (transactions.salesReturns != null && transactions.salesReturns!.isNotEmpty)
                    ? pw.Column(children: [
                        pw.Table(
                          border: const pw.TableBorder(
                            verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                          ),
                          columnWidths: <int, pw.TableColumnWidth>{
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(3),
                            2: const pw.FlexColumnWidth(4),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            //table header
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  color: const PdfColor.fromInt(0xffC52127),
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.sl,
                                    pw.TextStyle(
                                      color: PdfColors.white,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                    textAlignment: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xffC52127),
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.date,
                                    pw.TextStyle(
                                      color: PdfColors.white,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                    textAlignment: pw.TextAlign.left,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.returnedItem,
                                    pw.TextStyle(
                                      color: PdfColors.white,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                    textAlignment: pw.TextAlign.left,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.quantity,
                                    pw.TextStyle(
                                      color: PdfColors.white,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                    textAlignment: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.totalReturned,
                                    pw.TextStyle(
                                      color: PdfColors.white,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                    textAlignment: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            // Data rows for returns
                            for (int i = 0; i < (transactions.salesReturns?.length ?? 0); i++)
                              for (int j = 0; j < (transactions.salesReturns?[i].salesReturnDetails?.length ?? 0); j++)
                                pw.TableRow(
                                  decoration: PDFCommonFunctions().serialNumber.isOdd
                                      ? const pw.BoxDecoration(color: PdfColors.white) // Odd row color
                                      : const pw.BoxDecoration(color: PdfColors.red50),
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: getLocalizedPdfText(
                                        '${PDFCommonFunctions().serialNumber++}',
                                        pw.TextStyle(
                                          color: PdfColors.black,
                                          font: getFont(),
                                          fontFallback: [englishFont],
                                        ),
                                        textAlignment: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: getLocalizedPdfText(
                                        DateFormat.yMMMd().format(DateTime.parse(transactions.salesReturns?[i].returnDate ?? '0')),
                                        pw.TextStyle(
                                          color: PdfColors.black,
                                          font: getFont(),
                                          fontFallback: [englishFont],
                                        ),
                                        textAlignment: pw.TextAlign.left,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: getLocalizedPdfTextWithLanguage(
                                        productName(detailsId: transactions.salesReturns?[i].salesReturnDetails?[j].saleDetailId ?? 0),
                                        pw.TextStyle(
                                          color: PdfColors.black,
                                          font: getFontWithLangMatching(productName(detailsId: transactions.salesReturns?[i].salesReturnDetails?[j].saleDetailId ?? 0)),
                                          fontFallback: [englishFont],
                                        ),
                                        textAlignment: pw.TextAlign.left,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: getLocalizedPdfText(
                                        formatPointNumber(transactions.salesReturns?[i].salesReturnDetails?[j].returnQty ?? 0),
                                        pw.TextStyle(
                                          color: PdfColors.black,
                                          font: getFont(),
                                          fontFallback: [englishFont],
                                        ),
                                        textAlignment: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: getLocalizedPdfText(
                                        formatPointNumber(transactions.salesReturns?[i].salesReturnDetails?[j].returnAmount ?? 0),
                                        pw.TextStyle(
                                          color: PdfColors.black,
                                          font: getFont(),
                                          fontFallback: [englishFont],
                                        ),
                                        textAlignment: pw.TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        )
                      ])
                    : pw.SizedBox.shrink(),

                // Total returned amount and payable amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        (transactions.salesReturns != null && transactions.salesReturns!.isNotEmpty)
                            ? pw.Column(
                                children: [
                                  pw.SizedBox(height: 10),
                                  pw.RichText(
                                    text: pw.TextSpan(
                                      text: '${_lang.totalReturnAmount}: ',
                                      style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                                      children: [pw.TextSpan(text: formatPointNumber(getTotalReturndAmount()))],
                                    ),
                                  ),
                                  pw.SizedBox(height: 5.0),
                                ],
                              )
                            : pw.SizedBox(),

                        ///____________Payable_amount_________________________________________
                        pw.Container(
                          width: 570,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "${_lang.paidVia}: ${transactions.paymentType?.name ?? 'N/A'}",
                                style: const pw.TextStyle(color: PdfColors.black),
                              ),
                              pw.Container(
                                color: const PdfColor.fromInt(0xffC52127),
                                padding: const pw.EdgeInsets.all(5.0),
                                child: pw.Text(
                                  "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                                  style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 5.0),
                        pw.Container(
                          width: 570,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 350,
                                height: 20,
                                child: pw.Text(
                                  "${_lang.amountsInWord}: ${PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0)}",
                                  style: const pw.TextStyle(color: PdfColors.black),
                                  maxLines: 3,
                                ),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(
                                    "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                                    style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  pw.Text(
                                    (transactions.dueAmount ?? 0) > 0
                                        ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                        : (transactions.changeAmount ?? 0) > 0
                                            ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                            : '',
                                    style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 10.0),
                      ],
                    ),
                  ],
                ),
                if (transactions.meta?.note?.isNotEmpty ?? false)
                  pw.Column(children: [
                    pw.SizedBox(height: 5.0),
                    pw.Align(
                      alignment: pw.AlignmentDirectional.centerStart,
                      child: pw.Text(
                        "${_lang.note}: ${(transactions.meta?.note ?? '')}",
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),

                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    await PDFCommonFunctions.savePdfAndShowPdf(
      context: context,
      shopName: personalInformation.companyName ?? '',
      invoice: transactions.invoiceNumber ?? '',
      doc: doc,
      isShare: share,
      download: download,
    );
  }
}

class SalesInvoiceExcel {
  static Future<void> generateSaleDocument(
      SalesTransactionModel transactions, BusinessInformationModel personalInformation, BuildContext context, BusinessSettingModel businessSetting,
      {bool? share, bool? download}) async {
    final _lang = l.S.of(context);

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num productPrice({required num detailsId}) {
      return transactions.salesDetails!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num returnedDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        total += (element.price ?? 0) * PDFCommonFunctions().getProductQuantity(detailsId: element.id ?? 0, transactions: transactions);
      }
      return total;
    }

    String productName({required num detailsId}) {
      return transactions
              .salesDetails?[transactions.salesDetails!.indexWhere(
            (element) => element.id == detailsId,
          )]
              .product
              ?.productName ??
          '';
    }

    // Create Excel document
    final excel = Excel.createExcel();
    final sheet = excel['Sales Invoice'];

    // Add header information
    sheet.appendRow([
      TextCellValue('Company: ${personalInformation.companyName ?? ''}'),
    ]);
    sheet.appendRow([
      TextCellValue('Mobile: ${personalInformation.phoneNumber ?? ''}'),
    ]);
    sheet.appendRow([
      TextCellValue('Invoice: #${transactions.invoiceNumber}'),
    ]);
    sheet.appendRow([
      TextCellValue('Date: ${DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.saleDate ?? ''))}'),
    ]);
    sheet.appendRow([]);

    // Add customer information
    sheet.appendRow([
      TextCellValue('Bill To: ${transactions.party?.name ?? ''}'),
    ]);
    sheet.appendRow([
      TextCellValue('Mobile: ${transactions.party?.phone ?? (transactions.meta?.customerPhone ?? _lang.guest)}'),
    ]);
    sheet.appendRow([]);

    // Add sales details header
    sheet.appendRow([
      TextCellValue(_lang.sl),
      TextCellValue(_lang.item),
      TextCellValue(_lang.quantity),
      TextCellValue(_lang.unitPrice),
      TextCellValue(_lang.totalPrice),
    ]);

    // Add sales details
    for (int i = 0; i < transactions.salesDetails!.length; i++) {
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(transactions.salesDetails![i].product?.productName ?? ''),
        TextCellValue(formatPointNumber(PDFCommonFunctions().getProductQuantity(detailsId: transactions.salesDetails![i].id ?? 0, transactions: transactions))),
        TextCellValue(formatPointNumber(transactions.salesDetails![i].price ?? 0)),
        TextCellValue(
          formatPointNumber(
              (transactions.salesDetails![i].price ?? 0) * (PDFCommonFunctions().getProductQuantity(detailsId: transactions.salesDetails![i].id ?? 0, transactions: transactions))),
        )
      ]);
    }

    sheet.appendRow([]);

    // Add totals
    sheet.appendRow([
      TextCellValue('${_lang.subTotal}:'),
      TextCellValue(formatPointNumber(getTotalForOldInvoice())),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.discount}:'),
      TextCellValue(formatPointNumber((transactions.discountAmount ?? 0) + returnedDiscountAmount())),
    ]);
    sheet.appendRow([
      TextCellValue('${transactions.vat?.name ?? _lang.vat}:'),
      TextCellValue(formatPointNumber(transactions.vatAmount ?? 0.00)),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.shippingCharge}:'),
      TextCellValue(formatPointNumber((transactions.shippingCharge ?? 0))),
    ]);

    if (transactions.roundingAmount != 0) {
      sheet.appendRow([
        TextCellValue('${_lang.amount}:'),
        TextCellValue(formatPointNumber((transactions.actualTotalAmount ?? 0))),
      ]);
      sheet.appendRow([
        TextCellValue('${_lang.rounding}:'),
        TextCellValue('${!(transactions.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber((transactions.roundingAmount ?? 0))}'),
      ]);
    }

    sheet.appendRow([
      TextCellValue('${_lang.totalAmount}:'),
      TextCellValue(formatPointNumber((transactions.totalAmount ?? 0) + getTotalReturndAmount())),
    ]);
    sheet.appendRow([]);

    // Add returns if any
    if (transactions.salesReturns != null && transactions.salesReturns!.isNotEmpty) {
      sheet.appendRow([
        TextCellValue(_lang.sl),
        TextCellValue(_lang.date),
        TextCellValue(_lang.returnedItem),
        TextCellValue(_lang.quantity),
        TextCellValue(_lang.totalReturned),
      ]);

      int returnIndex = 1;
      for (int i = 0; i < transactions.salesReturns!.length; i++) {
        for (int j = 0; j < (transactions.salesReturns![i].salesReturnDetails?.length ?? 0); j++) {
          sheet.appendRow([
            TextCellValue('${returnIndex++}'),
            TextCellValue(DateFormat.yMMMd().format(DateTime.parse(transactions.salesReturns![i].returnDate ?? '0'))),
            TextCellValue(productName(detailsId: transactions.salesReturns![i].salesReturnDetails?[j].saleDetailId ?? 0)),
            TextCellValue(formatPointNumber(transactions.salesReturns![i].salesReturnDetails?[j].returnQty ?? 0)),
            TextCellValue(formatPointNumber(transactions.salesReturns![i].salesReturnDetails?[j].returnAmount ?? 0)),
          ]);
        }
      }

      sheet.appendRow([
        TextCellValue('${_lang.totalReturnAmount}:'),
        TextCellValue(formatPointNumber(getTotalReturndAmount())),
      ]);
      sheet.appendRow([]);
    }

    // Add payment information
    sheet.appendRow([
      TextCellValue('${_lang.paidVia}: ${transactions.paymentType?.name ?? 'N/A'}'),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}'),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}'),
    ]);

    if ((transactions.dueAmount ?? 0) > 0) {
      sheet.appendRow([
        TextCellValue('${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}'),
      ]);
    } else if ((transactions.changeAmount ?? 0) > 0) {
      sheet.appendRow([
        TextCellValue('${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}'),
      ]);
    }

    sheet.appendRow([
      TextCellValue('${_lang.amountsInWord}: ${PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0)}'),
    ]);

    if (transactions.meta?.note?.isNotEmpty ?? false) {
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('${_lang.note}: ${(transactions.meta?.note ?? '')}'),
      ]);
    }

    // Save the Excel file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Sales_Invoice_${transactions.invoiceNumber}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // Open the Excel file
    await OpenFile.open(filePath);

    // Optionally share or download
    if (share == true) {
      await FilePicker.platform.saveFile(
        fileName: 'Sales_Invoice_${transactions.invoiceNumber}.xlsx',
        // bytes: excel.encode(),
      );
    }
  }
}
