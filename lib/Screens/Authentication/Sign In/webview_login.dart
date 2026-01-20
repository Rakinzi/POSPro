import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../Repository/constant_functions.dart'; // Adjust path accordingly
import '../../../../currency.dart'; // Adjust path accordingly
import '../../Home/home.dart';
import '../profile_setup_screen.dart'; // Adjust path accordingly

class WebViewLogin extends StatefulWidget {
  final String loginUrl;

  const WebViewLogin({super.key, required this.loginUrl});

  @override
  WebViewLoginState createState() => WebViewLoginState();
}

class WebViewLoginState extends State<WebViewLogin> {
  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: 'Loading...');
  }

  void _handleRedirect(String url) async {
    if (url.contains('/app-login-or-signup')) {
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      final token = queryParams['token'];
      final isSetup = queryParams['is_setup'] == '1';
      final status = queryParams['status'];
      final currency = queryParams['currency'] ?? queryParams['currency_id'];
      if (status == 'success' && token != null) {
        await saveUserData(token: token); // Save token
        if (currency != null) {
          try {
            await CurrencyMethods().saveCurrencyDataInLocalDatabase(
              selectedCurrencySymbol: currency,
              selectedCurrencyName: currency,
            );
          } catch (e) {
            debugPrint('Error saving currency: $e');
          }
        }

        if (mounted) {
          if (isSetup) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSetup()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed. Please try again.")),
          );
          Navigator.pop(context); // Close WebView
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                // Intercept all navigation requests and load within WebView
                onNavigationRequest: (request) {
                  return NavigationDecision.navigate;
                },
                onPageFinished: (url) {
                  EasyLoading.dismiss();
                },
                onPageStarted: (url) {
                  _handleRedirect(url);
                },
                onWebResourceError: (error) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Something went wrong with the web page.")),
                  );
                },
              ),
            )
            // Set user agent to mimic a browser
            ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
            ..loadRequest(Uri.parse(widget.loginUrl)),
        ),
      ),
    );
  }
}
