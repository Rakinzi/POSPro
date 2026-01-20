import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import '../../../../currency.dart';
import '../../../../Database/database_helper.dart';
import '../../../../Services/connectivity_service.dart';
import '../../../Home/home.dart';
import '../../Sign Up/verify_email.dart';
import '../../profile_setup_screen.dart';

class LogInRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> logIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final passwordHash = _hashPassword(password);
    final isConnected = await _connectivityService.checkConnectivity();

    // Try online login first if connected
    if (isConnected) {
      try {
        final success = await _attemptOnlineLogin(email, password, passwordHash, context);
        if (success) return true;
        // If online login fails, fall through to offline login
      } catch (error) {
        debugPrint('Online login error: $error');
        // Continue to offline login without showing error to user
      }
    }

    // Attempt offline login
    return await _attemptOfflineLogin(email, passwordHash, context);
  }

  Future<bool> _attemptOnlineLogin(
    String email,
    String password,
    String passwordHash,
    BuildContext context,
  ) async {
    final url = Uri.parse('${APIConfig.url}/sign-in');

    final body = {
      'email': email,
      'password': password,
    };
    final headers = {
      'Accept': 'application/json',
    };

    final response = await http.post(url, headers: headers, body: body);
    final responseData = jsonDecode(response.body);
    EasyLoading.dismiss();

    debugPrint('Signin ${response.statusCode}');

    if (response.statusCode == 200) {
      bool isSetupDone = responseData['data']['is_setup'];
      String? currencySymbol;
      String? currencyName;

      try {
        currencySymbol = responseData['data']['currency']['symbol'];
        currencyName = responseData['data']['currency']['name'];
        await CurrencyMethods().saveCurrencyDataInLocalDatabase(
          selectedCurrencySymbol: currencySymbol,
          selectedCurrencyName: currencyName,
        );
      } catch (error) {
        debugPrint(error.toString());
      }

      // Save credentials locally for offline access
      await _dbHelper.saveUserCredentials(
        email: email,
        passwordHash: passwordHash,
        token: responseData['data']['token'],
        userData: jsonEncode(responseData['data']),
        isSetup: isSetupDone ? 1 : 0,
        currencySymbol: currencySymbol,
        currencyName: currencyName,
      );

      if (!context.mounted) return false;

      if (!isSetupDone) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetup()),
        );
      } else {
        await saveUserData(token: responseData['data']['token']);
        if (!context.mounted) return false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }

      return true;
    } else if (response.statusCode == 201) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmail(
            email: email,
            isFormForgotPass: false,
          ),
        ),
      );
      return true;
    } else {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
      return false;
    }
  }

  Future<bool> _attemptOfflineLogin(
    String email,
    String passwordHash,
    BuildContext context,
  ) async {
    // Check if credentials exist locally
    final isValid = await _dbHelper.validateOfflineCredentials(email, passwordHash);

    if (!isValid) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
      return false;
    }

    // Get user data from local database
    final userData = await _dbHelper.getUserCredentials(email);
    if (userData == null) return false;

    // Update last login
    await _dbHelper.updateLastLogin(email);

    // Restore currency settings if available
    if (userData['currency_symbol'] != null && userData['currency_name'] != null) {
      try {
        await CurrencyMethods().saveCurrencyDataInLocalDatabase(
          selectedCurrencySymbol: userData['currency_symbol'],
          selectedCurrencyName: userData['currency_name'],
        );
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    // Save token if available
    if (userData['token'] != null) {
      await saveUserData(token: userData['token']);
    }

    if (!context.mounted) return false;

    // Navigate based on setup status
    if (userData['is_setup'] == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetup()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }

    return true;
  }
}
