import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../currency.dart';

class LogOutRepo {
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("hasShownExpiredDialog");
    CurrencyMethods().removeCurrencyFromLocalDatabase();
    EasyLoading.showSuccess('Successfully Logged Out');
    Restart.restartApp();
  }

  Future<void> signOutApi({required BuildContext context, required WidgetRef ref}) async {
    final uri = Uri.parse('${APIConfig.url}/sign-out');

    await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    await signOut();
  }
}
