import 'package:bijoy_helper/bijoy_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

const kMainColor = Color(0xffC52127);
const kMainColor100 = Color(0xffFDE7F2);
const kMainColor50 = Color(0xffFEF0F1);
const kGreyTextColor = Color(0xFF828282);
const kBackgroundColor = Color(0xffF5F3F3);
const kBorderColorTextField = Color(0xFFC2C2C2);
const kDarkWhite = Color(0xFFF1F7F7);
const kWhite = Color(0xFFffffff);
const kBottomBorder = Color(0xffE6E6E6);
const kBorderColor = Color(0xffD8D8D8);
const kPeraColor = Color(0xff4B5563);
const kTextColor = Color(0xff121535);
const kSubPeraColor = Color(0xff999999);
const kSuccessColor = Colors.green;
const kPremiumPlanColor = Color(0xFF8752EE);
const kPremiumPlanColor2 = Color(0xFFFF5F00);
const kSecondayColor = Color(0xffF68A3D);
const kTitleColor = Color(0xFF000000);
const kNeutral800 = Color(0xff4B5563);
const kNeutralColor = Color(0xFF4D4D4D);
const kBorder = Color(0xFF999999);
const updateBorderColor = Color(0xffD8D8D8);
bool isPrintEnable = false;
String noProductImageUrl = 'images/no_product_image.png';

///---------update information---------------

const String splashLogo = 'images/splash_logo.jpeg';
const String onboard1 = 'images/onbord1.png';
const String onboard2 = 'images/onbord2.png';
const String onboard3 = 'images/onbord3.png';
const String logo = 'images/logo.png';
const String appsName = 'LeyanPOS';
const String companyWebsite = 'https://leyansoftware.com';
const String companyName = 'Leyan Software';

bool connected = false;

const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

const kInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: kGreyTextColor),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kBorderColor, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    borderSide: BorderSide(color: kBorderColor, width: 1),
  ),
);
OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(1.0),
    borderSide: const BorderSide(color: kBorderColorTextField),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

///__________Language________________________________
Map<String, String> languageMap = {
  'English': 'en',
  'Afrikaans': 'af',
  'Amharic': 'am',
  'Arabic': 'ar',
  'Assamese': 'as',
  'Azerbaijani': 'az',
  'Belarusian': 'be',
  'Bulgarian': 'bg',
  'Bengali': 'bn',
  'Bosnian': 'bs',
  'Catalan Valencian': 'ca',
  'Czech': 'cs',
  'Welsh': 'cy',
  'Danish': 'da',
  'German': 'de',
  'Modern Greek': 'el',
  'Spanish Castilian': 'es',
  'Estonian': 'et',
  'Basque': 'eu',
  'Persian': 'fa',
  'Finnish': 'fi',
  'Filipino Pilipino': 'fil',
  'French': 'fr',
  'Galician': 'gl',
  'Swiss German Alemannic Alsatian': 'gsw',
  'Gujarati': 'gu',
  'Hebrew': 'he',
  'Hindi': 'hi',
  'Croatian': 'hr',
  'Hungarian': 'hu',
  'Armenian': 'hy',
  'Indonesian': 'id',
  'Icelandic': 'is',
  'Italian': 'it',
  'Japanese': 'ja',
  'Georgian': 'ka',
  'Kazakh': 'kk',
  'Khmer Central Khmer': 'km',
  'Kannada': 'kn',
  'Korean': 'ko',
  'Kirghiz Kyrgyz': 'ky',
  'Lao': 'lo',
  'Lithuanian': 'lt',
  'Latvian': 'lv',
  'Macedonian': 'mk',
  'Malayalam': 'ml',
  'Mongolian': 'mn',
  'Marathi': 'mr',
  'Malay': 'ms',
  'Burmese': 'my',
  'Norwegian Bokmål': 'nb',
  'Nepali': 'ne',
  'Dutch Flemish': 'nl',
  'Norwegian': 'no',
  'Oriya': 'or',
  'Panjabi Punjabi': 'pa',
  'Polish': 'pl',
  'Pushto Pashto': 'ps',
  'Portuguese': 'pt',
  'Romanian Moldavian Moldovan': 'ro',
  'Russian': 'ru',
  'Sinhala Sinhalese': 'si',
  'Slovak': 'sk',
  'Slovenian': 'sl',
  'Albanian': 'sq',
  'Serbian': 'sr',
  'Swedish': 'sv',
  'Swahili': 'sw',
  'Tamil': 'ta',
  'Telugu': 'te',
  'Thai': 'th',
  'Tagalog': 'tl',
  'Turkish': 'tr',
  'Ukrainian': 'uk',
  'Urdu': 'ur',
  'Uzbek': 'uz',
  'Vietnamese': 'vi',
  'Chinese': 'zh',
  'Hausa': 'ha',
  'Tatar': 'tt',
  'Zulu': 'zu',
};

String formatPointNumber(num value, {bool addComma = false}) {
  String formatted;

  if (value % 1 == 0) {
    formatted = value.toInt().toString();
  } else {
    formatted = value.toStringAsFixed(2);
  }

  if (addComma) {
    // NumberFormat from intl package is used here
    final formatter = NumberFormat.decimalPattern();
    formatted = formatter.format(num.parse(formatted));
  }

  return formatted;
}
// String formatPointNumber(num value) {
//   if (value % 1 == 0) {
//     return value.toInt().toString();
//   } else {
//     return value.toStringAsFixed(2);
//   }
// }

String? selectedLanguage = languageMap['English'];

extension ColorExt on Color {
  Color withValues({required double alpha}) {
    final r = (this.r * 255).round().clamp(0, 255).toInt();
    final g = (this.g * 255).round().clamp(0, 255).toInt();
    final b = (this.b * 255).round().clamp(0, 255).toInt();
    return Color.fromARGB((alpha * 255).toInt(), r, g, b);
  }
}

pw.Widget getLocalizedPdfText(String text, pw.TextStyle textStyle, {pw.TextAlign? textAlignment}) {
  debugPrint('Current Language: $selectedLanguage, Text: $text');
  return pw.Text(
    selectedLanguage == "bn" ? unicodeToBijoy(text) : text,
    textAlign: textAlignment,
    style: textStyle,
  );
}

pw.Widget getLocalizedPdfTextWithLanguage(String text, pw.TextStyle textStyle, {pw.TextAlign? textAlignment}) {
  debugPrint('Current Language: $selectedLanguage, Text: $text');
  String detectedLanguage = detectLanguageEnhanced(text);
  return pw.Text(
    detectedLanguage == "bn" ? unicodeToBijoy(text) : text,
    textAlign: textAlignment,
    style: textStyle,
  );
}

String detectLanguageEnhanced(String text, {double threshold = 0.7}) {
  final cleanedText = text.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
  if (cleanedText.isEmpty) return 'en';

  // Count matches for each script
  final Map<String, int> counts = {
    'bn': RegExp(r'[\u0980-\u09FF]').allMatches(cleanedText).length,
    'hi': RegExp(r'[\u0900-\u097F]').allMatches(cleanedText).length,
    'ar': RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').allMatches(cleanedText).length,
    'fr': RegExp(r'[a-zA-Zéèêëàâîïôùûç]').allMatches(cleanedText).length,
  };

  // Calculate ratios
  final total = cleanedText.length;
  final ratios = counts.map((lang, count) => MapEntry(lang, count / total));

  // Determine dominant language
  for (final entry in ratios.entries) {
    if (entry.value >= threshold) return entry.key;
  }

  return 'en';
}

String formatAmount(String value, {bool isCurrency = false, String currencySymbol = ''}) {
  final number = double.tryParse(value) ?? 0;
  return formatNumber(number, isCurrency: isCurrency, currencySymbol: currencySymbol);
}

String formatNumber(double number, {int decimals = 2, bool isCurrency = false, String currencySymbol = '\$'}) {
  String removeTrailingZeros(double num, int dec) {
    String fixed = num.toStringAsFixed(dec);
    return fixed.contains('.') ? fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : fixed;
  }

  String formatted;
  if (number >= 1e9) {
    formatted = '${removeTrailingZeros(number / 1e9, decimals)}B';
  } else if (number >= 1e6) {
    formatted = '${removeTrailingZeros(number / 1e6, decimals)}M';
  } else if (number >= 1e3) {
    formatted = '${removeTrailingZeros(number / 1e3, decimals)}K';
  } else {
    formatted = removeTrailingZeros(number, decimals);
  }

  return isCurrency ? '$currencySymbol$formatted' : formatted;
}

Widget getFieldLabelText({required String label, required BuildContext context}) {
  final theme = Theme.of(context);
  return label.contains('*')
      ? RichText(
          text: TextSpan(text: label.replaceAll('*', ''), style: theme.textTheme.bodyLarge, children: [
          TextSpan(
              text: '*',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Color(0xffF68A3D),
              ))
        ]))
      : Text(label);
}
