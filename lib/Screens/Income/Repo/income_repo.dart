//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Income/Providers/all_income_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../Model/income_modle.dart';

class IncomeRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:incomes';

  Future<List<Income>> fetchIncome() async {
    final uri = Uri.parse('${APIConfig.url}/incomes');

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': await getAuthToken(),
      });

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
        final partyList = parsedData['data'] as List<dynamic>;
        final maps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        await _dbHelper.setCachedList(_cacheKey, maps);
        return maps.map((category) => Income.fromJson(category)).toList();
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => Income.fromJson(item)).toList();
  }

  Future<void> createIncome({
    required WidgetRef ref,
    required BuildContext context,
    required num amount,
    required num expenseCategoryId,
    required String expanseFor,
    required String paymentType,
    required String referenceNo,
    required String expenseDate,
    required String note,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/incomes');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    final requestBody = jsonEncode({
      'amount': amount,
      'income_category_id': expenseCategoryId,
      'incomeFor': expanseFor,
      'referenceNo': referenceNo,
      'incomeDate': expenseDate,
      'note': note,
      'payment_type_id': paymentType,
    });

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineIncomeItem(
          amount: amount,
          categoryId: expenseCategoryId,
          incomeFor: expanseFor,
          referenceNo: referenceNo,
          incomeDate: expenseDate,
          note: note,
          paymentType: paymentType,
        ));
        ref.invalidate(incomeProvider);
        ref.invalidate(businessInfoProvider);
        ref.invalidate(summaryInfoProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
        return;
      }

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);

      EasyLoading.dismiss();

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        ref.invalidate(incomeProvider);
        ref.invalidate(businessInfoProvider);
        ref.invalidate(summaryInfoProvider);
        if (parsedData is Map && parsedData['data'] is Map) {
          await _dbHelper.upsertCachedListItem(_cacheKey, Map<String, dynamic>.from(parsedData['data']));
        }
        if (!context.mounted) return;
        Navigator.pop(context);
        // return PurchaseTransaction.fromJson(parsedData);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineIncomeItem(
          amount: amount,
          categoryId: expenseCategoryId,
          incomeFor: expanseFor,
          referenceNo: referenceNo,
          incomeDate: expenseDate,
          note: note,
          paymentType: paymentType,
        ));
        ref.invalidate(incomeProvider);
        ref.invalidate(businessInfoProvider);
        ref.invalidate(summaryInfoProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Income creation failed: ${parsedData['message']}')));
        return;
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: requestBody,
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineIncomeItem(
        amount: amount,
        categoryId: expenseCategoryId,
        incomeFor: expanseFor,
        referenceNo: referenceNo,
        incomeDate: expenseDate,
        note: note,
        paymentType: paymentType,
      ));
      ref.invalidate(incomeProvider);
      ref.invalidate(businessInfoProvider);
      ref.invalidate(summaryInfoProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      // return null;
    }
  }
}

Map<String, dynamic> _offlineIncomeItem({
  required num amount,
  required num categoryId,
  required String incomeFor,
  required String referenceNo,
  required String incomeDate,
  required String note,
  required String paymentType,
}) {
  return {
    'id': -DateTime.now().millisecondsSinceEpoch,
    'amount': amount,
    'income_category_id': categoryId,
    'incomeFor': incomeFor,
    'referenceNo': referenceNo,
    'incomeDate': incomeDate,
    'note': note,
    'payment_type_id': paymentType,
    'created_at': DateTime.now().toIso8601String(),
  };
}
