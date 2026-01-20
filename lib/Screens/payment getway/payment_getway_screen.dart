import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../Const/api_config.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.planId, required this.businessId});

  final String planId;
  final String businessId;

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

String paymentUrl = '${APIConfig.domain}payments-gateways/plan_id/business_id?platform=app';
const String successUrl = 'order-status?status=success';
const String failureUrl = 'order-status?status=failed';

class PaymentScreenState extends State<PaymentScreen> {
  late WebViewController controller;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    paymentUrl = paymentUrl.replaceAll(APIConfig.domain, APIConfig.domain).replaceAll('plan_id', widget.planId).replaceAll('business_id', widget.businessId);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains(successUrl)) {
              Navigator.pop(context, true);
              return;
            }
            if (url.contains(failureUrl)) {
              Navigator.pop(context, false);
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    // For image picker
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector(_androidImagePicker);
    }
  }

  Future<List<String>> _androidImagePicker(FileSelectorParams params) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      String filePath = pickedFile.path;
      final fileUri = Uri.file(filePath);
      return [fileUri.toString()];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).paymentGateway,
          // 'Payment Gateway'
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).paymentSuccess,
          // 'Payment Success'
        ),
      ),
      body: Center(
        child: Text(
          lang.S.of(context).paymentWasSuccessful,
          // 'Payment was successful!'
        ),
      ),
    );
  }
}

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.S.of(context).paymentFailed),
      ),
      body: Center(
        child: Text(
          lang.S.of(context).paymentFailedPleaseTryAgain,
        ),
      ),
    );
  }
}
