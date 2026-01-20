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

import '../Screens/Due Calculation/Model/due_collection_model.dart';
import '../model/business_info_model.dart';
import 'pdf_common_functions.dart';

class DueInvoicePDF {
  static Future<void> generateDueDocument(DueCollection transactions, BusinessInformationModel personalInformation, BuildContext context, BusinessSettingModel businessSetting,
      {bool? isShare, bool? download}) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);
    // Load the image as bytes
    final String imageUrl = '${APIConfig.domain}${businessSetting.pictureUrl}';
    dynamic imageData = await PDFCommonFunctions().getNetworkImage(imageUrl);
    imageData ??= await PDFCommonFunctions().loadAssetImage('images/logo.png');
    EasyLoading.show(status: _lang.generatingPdf);

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
                  ]),
                  pw.Spacer(),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    height: 52,
                    width: 247,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.black,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(25),
                        bottomLeft: pw.Radius.circular(25),
                      ),
                    ),
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, right: 19, top: 8, bottom: 8),
                      child: getLocalizedPdfText(
                        _lang.moneyReceipt,
                        pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 30,
                          font: getFont(),
                          fontFallback: [englishFont],
                        ),
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
                        child: getLocalizedPdfText(
                            transactions.party?.name ?? '',
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: getLocalizedPdfText(
                            _lang.phone,
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
                            transactions.party?.phone ?? '',
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                    ]),
                  ]),
                  pw.Column(children: [
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            _lang.receipt,
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
                          '${transactions.invoiceNumber}',
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
                            DateFormat('d MMM,yyy').format(DateTime.parse(transactions.paymentDate ?? '')),
                            pw.TextStyle(
                              color: PdfColors.black,
                              font: getFont(),
                              fontFallback: [englishFont],
                            )),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 100.0,
                        child: getLocalizedPdfText(
                            _lang.collectedBy,
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
                          transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? '',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    if (personalInformation.vatNumber != null)
                      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.SizedBox(
                          width: 100.0,
                          child: pw.Text(
                            personalInformation.vatName ?? _lang.vatNumber,
                            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                          ),
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
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FlexColumnWidth(3),
                      3: const pw.FlexColumnWidth(3),
                    },
                    border: const pw.TableBorder(
                      verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
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
                              pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                              textAlignment: pw.TextAlign.left,
                            ),
                          ),
                          pw.Container(
                            color: const PdfColor.fromInt(0xffC52127), // Red background
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              _lang.totalDue,
                              pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                              textAlignment: pw.TextAlign.left,
                            ),
                          ),
                          pw.Container(
                            color: const PdfColor.fromInt(0xff000000), // Black background
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              _lang.paymentsAmount,
                              pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                              textAlignment: pw.TextAlign.left,
                            ),
                          ),
                          pw.Container(
                            color: const PdfColor.fromInt(0xff000000), // Black background
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              _lang.remainingDue,
                              pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: getFont(), fontFallback: [englishFont]),
                              textAlignment: pw.TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              '1',
                              textAlignment: pw.TextAlign.left,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              "${transactions.totalDue}",
                              textAlignment: pw.TextAlign.left,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              (transactions.totalDue!.toDouble() - transactions.dueAmountAfterPay!.toDouble()).toStringAsFixed(2),
                              textAlignment: pw.TextAlign.left,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: getLocalizedPdfText(
                              "${transactions.dueAmountAfterPay?.toStringAsFixed(2)}",
                              textAlignment: pw.TextAlign.left,
                              pw.TextStyle(font: getFont(), fontFallback: [englishFont]),
                            ),
                          ),
                        ],
                      ),
                    ]),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.SizedBox(height: 10.0),
                        pw.Container(
                          width: 570,
                          child: pw.Row(
                            children: [
                              pw.Row(children: [
                                getLocalizedPdfText(
                                  "${_lang.paidBy}:",
                                  pw.TextStyle(
                                    color: PdfColors.black,
                                    font: getFont(),
                                    fontFallback: [englishFont],
                                  ),
                                ),
                                pw.Text(
                                  transactions.paymentType?.name ?? 'N/A',
                                  style: const pw.TextStyle(
                                    color: PdfColors.black,
                                  ),
                                ),
                              ]),
                              pw.Spacer(),
                              pw.Row(children: [
                                getLocalizedPdfText(
                                  "${_lang.payableAmount}: ",
                                  pw.TextStyle(
                                    color: PdfColors.black,
                                    font: getFont(),
                                    fontFallback: [englishFont],
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                getLocalizedPdfText(
                                  "${transactions.totalDue?.toStringAsFixed(2) ?? 0}",
                                  pw.TextStyle(
                                    color: PdfColors.black,
                                    font: getFont(),
                                    fontFallback: [englishFont],
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ]),
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
                                child: pw.Row(children: [
                                  getLocalizedPdfText(
                                    "${_lang.amountsInWord}: ",
                                    pw.TextStyle(
                                      color: PdfColors.black,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                    ),
                                  ),
                                  pw.Text(
                                    PDFCommonFunctions().numberToWords(transactions.totalDue ?? 0),
                                    style: const pw.TextStyle(color: PdfColors.black),
                                    maxLines: 3,
                                  ),
                                ]),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  getLocalizedPdfText(
                                    "${_lang.receivedAmount} : ${(transactions.totalDue!.toDouble() - transactions.dueAmountAfterPay!.toDouble()).toStringAsFixed(2)}",
                                    pw.TextStyle(
                                      color: PdfColors.black,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  getLocalizedPdfText(
                                    "${_lang.dueAmount} : ${transactions.dueAmountAfterPay?.toStringAsFixed(2) ?? 0}",
                                    pw.TextStyle(
                                      color: PdfColors.black,
                                      font: getFont(),
                                      fontFallback: [englishFont],
                                      fontWeight: pw.FontWeight.bold,
                                    ),
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
