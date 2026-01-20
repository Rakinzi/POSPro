import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/http_client/subscription_expire_provider.dart';

import '../Repository/constant_functions.dart';
import '../Screens/subscription/purchase_premium_plan_screen.dart';

class CustomHttpClient {
  final http.Client client;
  final WidgetRef ref;
  final BuildContext context;

  CustomHttpClient({required this.client, required this.ref, required this.context});

  Future<http.Response> post({required Uri url, Map<String, String>? headers, bool? addContentTypeInHeader, Object? body}) async {
    final subscriptionState = ref.read(subscriptionProvider);

    if (subscriptionState.isExpired) {
      EasyLoading.dismiss();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PurchasePremiumPlanScreen(
                    isExpired: true,
                    isCameBack: true,
                    enrolledPlan: null,
                    willExpire: DateTime(2025, 2, 28).toString(),
                  )));

      return http.Response(jsonEncode({'error': 'Subscription expired'}), 403);
    } else {
      return client.post(
        url,
        headers: (headers == null)
            ? {
                'Accept': 'application/json',
                'Authorization': await getAuthToken(), // Assuming Bearer token format
                if (addContentTypeInHeader ?? false) 'Content-Type': 'application/json',
              }
            : headers,
        body: body,
      );
    }
  }

  Future<http.Response> delete({required Uri url, Map<String, String>? headers}) async {
    final subscriptionState = ref.read(subscriptionProvider);

    if (subscriptionState.isExpired) {
      EasyLoading.dismiss();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchasePremiumPlanScreen(
            isExpired: true,
            isCameBack: true,
            enrolledPlan: null,
            willExpire: DateTime(2025, 2, 28).toString(),
          ),
        ),
      );

      return http.Response(jsonEncode({'error': 'Subscription expired'}), 403);
    } else {
      return client.delete(
        url,
        headers: headers ??
            {
              'Accept': 'application/json',
              'Authorization': await getAuthToken(), // Assuming Bearer token format
            },
      );
    }
  }

  Future<http.StreamedResponse> uploadFile({required Uri url, File? file, String? countentType, String? fileFieldName, Map<String, String>? fields}) async {
    final subscriptionState = ref.read(subscriptionProvider);

    if (subscriptionState.isExpired) {
      EasyLoading.dismiss();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchasePremiumPlanScreen(
            isExpired: true,
            isCameBack: true,
            enrolledPlan: null,
            willExpire: DateTime(2025, 2, 28).toString(),
          ),
        ),
      );
      throw Exception("Subscription Expired");
    }

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = await getAuthToken();
    request.headers['Accept'] = 'application/json';
    if (countentType != null) request.headers['Content-Type'] = countentType;
    request.fields.addAll(fields ?? {}); // Extra form data (optional)

    if (file != null && fileFieldName != null) {
      // Attach File
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(fileFieldName, stream, length, filename: (file.path));

      request.files.add(multipartFile);
    }

    return request.send(); // Returns Streamed Response
  }
}
