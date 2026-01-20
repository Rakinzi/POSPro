import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Authentication/forgot_password.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Authentication/register_screen.dart';
import 'package:mobile_pos/Screens/Customers/customer_list.dart';
import 'package:mobile_pos/Screens/Expense/expense_list.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/Screens/Products/product_list_screen.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Sales/add_discount.dart';
import 'package:mobile_pos/Screens/Sales/add_promo_code.dart';
import 'package:mobile_pos/Screens/Sales/sales_contact.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/Screens/SplashScreen/splash_screen.dart';
import 'package:mobile_pos/Screens/pos_sale/pos_sale.dart';
import 'package:mobile_pos/Screens/vat_&_tax/tax_report.dart';
import 'package:provider/provider.dart' as pro;

import 'Screens/Due Calculation/due_list_screen.dart';
import 'Screens/Income/income_list.dart';
import 'Screens/Loss_Profit/loss_profit_screen.dart';
import 'Screens/Purchase List/purchase_list_screen.dart';
import 'Screens/Purchase/choose_supplier_screen.dart';
import 'Screens/Sales List/sales_list_screen.dart';
import 'Screens/custom_print/custom_print.dart';
import 'Screens/language/language_provider.dart';
import 'Screens/stock_list/stock_list_main.dart';
import 'core/theme/theme.dart';
import 'generated/l10n.dart';
import 'Services/connectivity_service.dart';
import 'Services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline services
  final connectivityService = ConnectivityService();
  final syncService = SyncService();

  connectivityService.initialize();
  syncService.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return pro.ChangeNotifierProvider<LanguageChangeProvider>(
      create: (context) => LanguageChangeProvider(),
      child: Builder(
          builder: (context) => MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                title: 'LeyanPOS',
                initialRoute: '/',
                builder: EasyLoading.init(),
                routes: {
                  '/': (context) => const SplashScreen(),
                  '/onBoard': (context) => const OnBoard(),
                  '/loginForm': (context) => const LoginForm(isEmailLogin: true),
                  '/signup': (context) => const RegisterScreen(),
                  '/forgotPassword': (context) => const ForgotPassword(),
                  '/home': (context) => const Home(),
                  '/AddProducts': (context) => const AddProduct(),
                  '/Products': (context) => const ProductList(),
                  '/salesCustomer': (context) => const SalesContact(),
                  '/addPromoCode': (context) => const AddPromoCode(),
                  '/customPrint': (context) => const CustomPrintScreen(),
                  '/addDiscount': (context) => const AddDiscount(),
                  '/Sales': (context) => const SalesContact(),
                  '/Parties': (context) => const CustomerList(),
                  '/Expense': (context) => const ExpenseList(),
                  '/Income': (context) => const IncomeList(),
                  '/tax': (context) => const TaxReport(),
                  '/Stock': (context) => const StockList(isFromReport: false),
                  '/Purchase': (context) => const PurchaseContacts(),
                  '/Reports': (context) => const Reports(),
                  '/Due List': (context) => const DueCalculationContactScreen(),
                  '/Sales List': (context) => const SalesListScreen(),
                  '/Purchase List': (context) => const PurchaseListScreen(),
                  '/Loss/Profit': (context) => const LossProfitScreen(),
                  // '/warehouse': (context) => const WarehouseScreen(),
                  '/Pos Sale': (context) => const PosSaleScreen(),
                },
                theme: LeyanTheme.kLightTheme(context),
              )),
    );
  }
}
