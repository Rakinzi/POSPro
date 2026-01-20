import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class StickerData {
  final String businessName;
  final String name;
  final num price;
  final String code;
  final String mfg;
  final bool isTwoIch;
  final bool showBusinessName;
  final bool showName;
  final bool showPrice;
  final bool showCode;
  final bool showMfg;
  final double nameFontSize;
  final double priceFontSize;
  final double mfgFontSize;
  final double codeFontSize;

  StickerData({
    required this.businessName,
    required this.name,
    required this.price,
    required this.code,
    required this.mfg,
    required this.isTwoIch,
    required this.showBusinessName,
    required this.showName,
    required this.showPrice,
    required this.showCode,
    required this.showMfg,
    required this.nameFontSize,
    required this.priceFontSize,
    required this.mfgFontSize,
    required this.codeFontSize,
  });
}

class StickerWidget extends StatelessWidget {
  final StickerData data;

  const StickerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final barcode = Barcode.code128();
    final svg = barcode.toSvg(data.code, width: data.isTwoIch ? 300 : 200, height: 40, drawText: false);

    String formatDateString(String? dateString) {
      if (dateString == null) return 'N/A';
      try {
        final parsed = DateTime.parse(dateString);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (e) {
        return 'N/A';
      }
    }

    return Container(
      width: data.isTwoIch ? 350 : 280,
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.showBusinessName)
            Text(
              data.businessName,
              style: TextStyle(fontSize: data.nameFontSize, color: Colors.black),
            ),
          if (data.showName)
            Text(
              data.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: data.nameFontSize, color: Colors.black),
            ),
          if (data.showPrice) const SizedBox(height: 2),
          if (data.showPrice)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Price: ', style: TextStyle(fontSize: data.priceFontSize, color: Colors.black)),
                Text(
                  NumberFormat.currency(symbol: '€').format(data.price),
                  style: TextStyle(fontSize: data.priceFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          const SizedBox(height: 2),
          if (data.showMfg)
            Text(
              'Packing Date: ${formatDateString(data.mfg)}',
              style: TextStyle(fontSize: data.mfgFontSize, color: Colors.black),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: SvgPicture.string(
              svg,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 2),
          if (data.showCode) Text(data.code, style: TextStyle(fontSize: data.codeFontSize, color: Colors.black)),
        ],
      ),
    );
  }
}
