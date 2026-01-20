import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/business_setting_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Screens/Products/add_product.dart';
import '../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../model/business_info_model.dart';
import 'pdf_common_functions.dart';

class PurchaseInvoicePDF {
  static Future<void> generatePurchaseDocument(
      PurchaseTransaction transactions, BusinessInformationModel personalInformation, BuildContext context, BusinessSettingModel businessSetting,
      {bool? isShare, bool? download}) async {
    final pw.Document doc = pw.Document();

    final _lang = l.S.of(context);

    String productName({required num detailsId}) {
      final details = transactions.details?[transactions.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}";
    }

    num productPrice({required num detailsId}) {
      return transactions.details!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.purchaseDetailId ?? 0) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = transactions.details?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
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

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.details!) {
        num productPrice = element.productPurchasePrice ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    EasyLoading.show(status: _lang.generatingPdf);

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
                pw.Row(
                  children: [
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
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        getLocalizedPdfTextWithLanguage(
                          personalInformation.companyName ?? '',
                          pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 24.0,
                            fontWeight: pw.FontWeight.bold,
                            fontFallback: [englishFont],
                            font: getFontWithLangMatching(personalInformation.companyName ?? ''),
                          ),
                        ),
                        getLocalizedPdfText(
                            '${_lang.mobile}: ${personalInformation.phoneNumber ?? ''}',
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ],
                    ),
                    pw.Spacer(),
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
                  ],
                ),
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
                        child: getLocalizedPdfText(transactions.party?.phone ?? '', pw.TextStyle(font: getFont(), fontFallback: [englishFont])),
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
                          DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.purchaseDate ?? '')),
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
                    columnWidths: <int, pw.TableColumnWidth>{
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(6),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                    },
                    border: const pw.TableBorder(
                      verticalInside: pw.BorderSide(
                        color: PdfColor.fromInt(0xffD9D9D9),
                      ),
                      left: pw.BorderSide(
                        color: PdfColor.fromInt(0xffD9D9D9),
                      ),
                      right: pw.BorderSide(
                        color: PdfColor.fromInt(0xffD9D9D9),
                      ),
                      bottom: pw.BorderSide(
                        color: PdfColor.fromInt(0xffD9D9D9),
                      ),
                    ),
                    children: [
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
                      for (int i = 0; i < transactions.details!.length; i++)
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
                                  "${transactions.details!.elementAt(i).product?.productName.toString()}${transactions.details!.elementAt(i).product?.productType == ProductType.variant.name ? ' [${transactions.details!.elementAt(i).stock?.batchNo ?? ''}]' : ''}",
                                  pw.TextStyle(
                                      font: getFontWithLangMatching(transactions.details!.elementAt(i).product?.productName.toString() ?? ''), fontFallback: [englishFont]),
                                  textAlignment: pw.TextAlign.left),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: getLocalizedPdfText(
                                (getProductQuantity(detailsId: transactions.details!.elementAt(i).id ?? 0)).toString(),
                                textAlignment: pw.TextAlign.center,
                                pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: getLocalizedPdfText(
                                formatPointNumber(transactions.details!.elementAt(i).productPurchasePrice ?? 0),
                                textAlignment: pw.TextAlign.right,
                                pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: getLocalizedPdfText(
                                ((transactions.details!.elementAt(i).productPurchasePrice ?? 0) * getProductQuantity(detailsId: transactions.details!.elementAt(i).id ?? 0))
                                    .toStringAsFixed(2),
                                textAlignment: pw.TextAlign.right,
                                pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                              ),
                            ),
                          ],
                        ),
                    ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                    pw.SizedBox(height: 10.0),
                    getLocalizedPdfText(
                      "${_lang.subTotal}: ${getTotalForOldInvoice().toStringAsFixed(2)}",
                      pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                    ),
                    pw.SizedBox(height: 5.0),
                    getLocalizedPdfText(
                      "${_lang.discount}: ${((transactions.discountAmount ?? 0) + getReturndDiscountAmount()).toStringAsFixed(2)}",
                      pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                    ),
                    pw.SizedBox(height: 5.0),
                    getLocalizedPdfText(
                      "${transactions.vat?.name ?? _lang.vat}: ${((transactions.vatAmount ?? 0)).toStringAsFixed(2)}",
                      pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                    ),
                    pw.SizedBox(height: 5.0),
                    getLocalizedPdfText(
                      "${_lang.shippingCharge}: ${((transactions.shippingCharge ?? 0)).toStringAsFixed(2)}",
                      pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                    ),
                    pw.SizedBox(height: 5.0),
                    getLocalizedPdfText(
                      "${_lang.totalAmount}: ${((transactions.totalAmount ?? 0) + getTotalReturndAmount()).toStringAsFixed(2)}",
                      pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                    ),
                  ]),
                ]),
                (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty) ? pw.Container(height: 10) : pw.Container(),

                ///-----return_table-----
                (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty)
                    ? pw.Column(children: [
                        pw.Table(
                          border: const pw.TableBorder(
                            verticalInside: pw.BorderSide(
                              color: PdfColor.fromInt(0xffD9D9D9),
                            ),
                            left: pw.BorderSide(
                              color: PdfColor.fromInt(0xffD9D9D9),
                            ),
                            right: pw.BorderSide(
                              color: PdfColor.fromInt(0xffD9D9D9),
                            ),
                            bottom: pw.BorderSide(
                              color: PdfColor.fromInt(0xffD9D9D9),
                            ),
                          ),
                          columnWidths: <int, pw.TableColumnWidth>{
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(3),
                            2: const pw.FlexColumnWidth(4),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    color: PdfColor.fromInt(0xffC52127),
                                  ), // Red background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.sl,
                                    pw.TextStyle(font: getFont(), fontFallback: [englishFont], color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                                    textAlignment: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xffC52127), // Red background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.date,
                                    pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                                    textAlignment: pw.TextAlign.left,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.returnedItem,
                                    pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                                    textAlignment: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.quantity,
                                    pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                                    textAlignment: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Container(
                                  color: const PdfColor.fromInt(0xff000000), // Black background
                                  padding: const pw.EdgeInsets.all(8.0),
                                  child: getLocalizedPdfText(
                                    _lang.totalReturned,
                                    pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                                    textAlignment: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            for (int i = 0; i < (transactions.purchaseReturns?.length ?? 0); i++)
                              for (int j = 0; j < (transactions.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0); j++)
                                pw.TableRow(
                                  decoration: PDFCommonFunctions().serialNumber.isOdd
                                      ? const pw.BoxDecoration(
                                          color: PdfColors.white,
                                        ) // Odd row color
                                      : const pw.BoxDecoration(
                                          color: PdfColors.red50,
                                        ),
                                  children: [
                                    //serial number
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: getLocalizedPdfText(
                                        '${PDFCommonFunctions().serialNumber++}',
                                        pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                                        textAlignment: pw.TextAlign.center,
                                      ),
                                    ),
                                    //Date
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: getLocalizedPdfText(
                                        DateFormat.yMMMd().format(DateTime.parse(
                                          transactions.purchaseReturns?[i].returnDate ?? '0',
                                        )),
                                        pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                                        textAlignment: pw.TextAlign.left,
                                      ),
                                    ),
                                    //Total return
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: getLocalizedPdfTextWithLanguage(
                                        productName(detailsId: transactions.purchaseReturns?[i].purchaseReturnDetails?[j].purchaseDetailId ?? 0),
                                        pw.TextStyle(
                                            font: getFontWithLangMatching(productName(detailsId: transactions.purchaseReturns?[i].purchaseReturnDetails?[j].purchaseDetailId ?? 0)),
                                            fontFallback: [englishFont]),
                                        textAlignment: pw.TextAlign.center,
                                      ),
                                    ),
                                    //Quantity
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: getLocalizedPdfText(
                                        transactions.purchaseReturns?[i].purchaseReturnDetails?[j].returnQty?.toString() ?? '0',
                                        pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                                        textAlignment: pw.TextAlign.right,
                                      ),
                                    ),
                                    //Total Return
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: getLocalizedPdfText(
                                        transactions.purchaseReturns?[i].purchaseReturnDetails?[j].returnAmount?.toStringAsFixed(2) ?? '0',
                                        pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                                        textAlignment: pw.TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ])
                    : pw.SizedBox.shrink(),

                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                    (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty)
                        ? pw.Column(
                            children: [
                              pw.SizedBox(height: 10.0),
                              getLocalizedPdfText(
                                "${_lang.totalReturnAmount} : ${getTotalReturndAmount().toStringAsFixed(2)}",
                                pw.TextStyle(
                                  color: PdfColors.black,
                                  fontWeight: pw.FontWeight.bold,
                                  font: getFont(),
                                  fontFallback: [englishFont],
                                ),
                              ),
                            ],
                          )
                        : pw.Container(),
                    pw.SizedBox(height: 5.0),

                    ///____________Payable_amount_________________________________________
                    pw.Container(
                      width: 570,
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          getLocalizedPdfText(
                            "${_lang.paidVia}: ${transactions.paymentType?.name ?? 'N/A'}",
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            ),
                          ),
                          pw.Container(
                            color: const PdfColor.fromInt(0xffC52127),
                            padding: const pw.EdgeInsets.all(5.0),
                            child: getLocalizedPdfText(
                              "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                              pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                font: getFont(),
                                fontFallback: [englishFont],
                              ),
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
                              "Amount In Word: ${PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0)}",
                              style: const pw.TextStyle(color: PdfColors.black),
                              maxLines: 3,
                            ),
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              getLocalizedPdfText(
                                "${_lang.paidAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                                pw.TextStyle(
                                  color: PdfColors.black,
                                  fontWeight: pw.FontWeight.bold,
                                  font: getFont(),
                                  fontFallback: [englishFont],
                                ),
                              ),
                              pw.SizedBox(height: 5.0),
                              getLocalizedPdfText(
                                (transactions.dueAmount ?? 0) > 0
                                    ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                    : (transactions.changeAmount ?? 0) > 0
                                        ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                        : '',
                                pw.TextStyle(
                                  color: PdfColors.black,
                                  fontWeight: pw.FontWeight.bold,
                                  font: getFont(),
                                  fontFallback: [englishFont],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
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
        context: context, shopName: personalInformation.companyName ?? '', invoice: transactions.invoiceNumber ?? '', doc: doc, isShare: isShare, download: download);
  }
}
