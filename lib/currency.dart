import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

///______APP_Default_currency________________________
const String appDefaultCurrency = '\$';
const String appDefaultCurrencyName = 'US Dollar';

///______Dynamic_currency_variables___________________
String currency = appDefaultCurrency;
String currencyName = appDefaultCurrencyName;

class CurrencyMethods {
  void removeCurrencyFromLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currency');
    await prefs.remove('currencyName');
  }

  Future<void> saveCurrencyDataInLocalDatabase({required String? selectedCurrencySymbol, required String? selectedCurrencyName}) async {
    debugPrint('This is currency from apis: $selectedCurrencyName - And symbol is : $selectedCurrencySymbol');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', selectedCurrencySymbol ?? appDefaultCurrency);
    await prefs.setString('currencyName', selectedCurrencyName ?? appDefaultCurrencyName);
    await getCurrencyFromLocalDatabase();
  }

  Future<void> getCurrencyFromLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency') ?? appDefaultCurrency;
    currencyName = prefs.getString('currencyName') ?? appDefaultCurrencyName;
  }
}
