// ignore_for_file: file_names, unused_element, unused_local_variable

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/profile_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../Model/payment_credential_model.dart';
import '../Model/subscription_plan_model.dart';

class SubscriptionPlanRepo {
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<List<SubscriptionPlanModelNew>> fetchAllPlans() async {
    final uri = Uri.parse('${APIConfig.url}/plans');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final partyList = parsedData['data'] as List<dynamic>;
      return partyList.map((category) => SubscriptionPlanModelNew.fromJson(category)).toList();
      // Parse into Party objects
    } else {
      throw Exception('Failed to fetch Products');
    }
  }

  Future<List<SubscriptionPlanModel>> fetchAllPlansPrevious() async {
    final uri = Uri.parse('${APIConfig.url}/plans');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final partyList = parsedData['data'] as List<dynamic>;
      return partyList.map((category) => SubscriptionPlanModel.fromJson(category)).toList();
      // Parse into Party objects
    } else {
      throw Exception('Failed to fetch Products');
    }
  }

  Future<PaymentCredentialModel> getPaymentCredential() async {
    final uri = Uri.parse('${APIConfig.url}/gateways');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    debugPrint(response.statusCode.toString());
    debugPrint(response.body);
    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final data = parsedData['data'];
      return PaymentCredentialModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch credential');
    }
  }

  Future<void> subscribePlan({
    required WidgetRef ref,
    required BuildContext context,
    required int planId,
    required String paymentMethod,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/subscribes');

    var responseData = await http.post(uri, headers: {
      "Accept": 'application/json',
      'Authorization': await getAuthToken(),
    }, body: {
      'plan_id': planId.toString(),
      'subscriptionMethod': paymentMethod,
    });
    if (!context.mounted) return;

    try {
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribe successful!')));
        ref.invalidate(businessInfoProvider);
        ref.invalidate(getExpireDateProvider(ref));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscribe creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      // Handle unexpected errors gracefully
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }
}
