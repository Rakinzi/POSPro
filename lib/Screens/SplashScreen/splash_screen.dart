import 'package:flutter/material.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Repository/API/business_info_repo.dart';
import '../../currency.dart';
import '../Home/home.dart';
import '../language/language_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Future<void> getPermission() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }


  @override
  void initState() {
    super.initState();
    getPermission();
    CurrencyMethods().getCurrencyFromLocalDatabase();
    setLanguage();
    nextPage();
  }

  Future<void> setLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('lang') ?? 'en'; // Default to English code
    if (!mounted) return;
    setState(() {
      selectedLanguage = savedLanguageCode;
    });
    context.read<LanguageChangeProvider>().changeLocale(savedLanguageCode);
  }

  Future<void> nextPage() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 1));

    final token = prefs.getString('token');

    if (token == null) {
      CurrencyMethods().removeCurrencyFromLocalDatabase();
      return _goTo(const OnBoard());
    }

    final data = await BusinessRepository().checkBusinessData();
    if (!mounted) return;
    _goTo(data == null ? const OnBoard() : const Home());
  }

  void _goTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: kWhite,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 230,
              width: 230,
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(splashLogo))),
            ),
            const Spacer(),
            Center(
              child: Text(
                '${lang.S.of(context).poweredBy} $companyName',
                style: theme.textTheme.titleLarge?.copyWith(color: kTextColor, fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
            // Center(
            //   child: Text(
            //     'V $appVersion',
            //     style: theme.textTheme.titleLarge?.copyWith(
            //       color: Colors.white,
            //       fontWeight: FontWeight.w500,
            //       fontSize: 18,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
