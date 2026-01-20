//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/Expense/Model/expanse_category.dart';
import 'package:mobile_pos/Screens/Expense/Providers/expense_category_proivder.dart';

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';

class ExpanseCategoryRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:expense_categories';

  Future<List<ExpenseCategory>> fetchAllExpanseCategory() async {
    final uri = Uri.parse('${APIConfig.url}/expense-categories');

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      try {
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        });

        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
          final categoryList = parsedData['data'] as List<dynamic>;
          final maps = categoryList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.setCachedList(_cacheKey, maps);
          return maps.map((category) => ExpenseCategory.fromJson(category)).toList();
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => ExpenseCategory.fromJson(item)).toList();
  }

  Future<void> addExpanseCategory({
    required WidgetRef ref,
    required BuildContext context,
    required String categoryName,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/expense-categories');

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    final body = {'categoryName': categoryName};
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineExpenseCategoryItem(categoryName));
      ref.invalidate(expanseCategoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    var responseData = await customHttpClient.post(url: uri, body: body);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    try {
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
        ref.invalidate(expanseCategoryProvider);
        if (parsedData is Map && parsedData['data'] is Map) {
          await _dbHelper.upsertCachedListItem(_cacheKey, Map<String, dynamic>.from(parsedData['data']));
        }
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineExpenseCategoryItem(categoryName));
        ref.invalidate(expanseCategoryProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineExpenseCategoryItem(categoryName));
      ref.invalidate(expanseCategoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }
}

Map<String, dynamic> _offlineExpenseCategoryItem(String name) {
  return {
    'id': -DateTime.now().millisecondsSinceEpoch,
    'categoryName': name,
    'created_at': DateTime.now().toIso8601String(),
  };
}
