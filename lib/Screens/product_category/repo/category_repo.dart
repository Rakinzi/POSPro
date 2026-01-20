//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../model/category_model.dart';
import '../provider/product_category_provider/product_unit_provider.dart';

class CategoryRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:categories';

  Future<List<CategoryModel>> fetchAllCategory() async {
    final uri = Uri.parse('${APIConfig.url}/categories');

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
          return maps.map((category) => CategoryModel.fromJson(category)).toList();
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => CategoryModel.fromJson(item)).toList();
  }

  Future<void> addCategory({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required bool variationSize,
    required bool variationColor,
    required bool variationCapacity,
    required bool variationType,
    required bool variationWeight,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/categories');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    final body = {
      'categoryName': name,
      'variationSize': variationSize.toString(),
      'variationColor': variationColor.toString(),
      'variationCapacity': variationCapacity.toString(),
      'variationType': variationType.toString(),
      'variationWeight': variationWeight.toString(),
    };
    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return;
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body));
      ref.invalidate(categoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    var responseData = await customHttpClient.post(url: uri, body: body);

    try {
      final parsedData = jsonDecode(responseData.body);

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        debugPrint('eswyfgseuyfgseygfysegfseygfseygfseygfseygfseygfesgfsegfseygf');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
        ref.invalidate(categoryProvider);
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
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body));
        ref.invalidate(categoryProvider);
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
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body));
      ref.invalidate(categoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> editCategory({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required bool variationSize,
    required bool variationColor,
    required bool variationCapacity,
    required bool variationType,
    required bool variationWeight,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/categories/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    final body = {
      '_method': 'put',
      'categoryName': name,
      'variationSize': variationSize.toString(),
      'variationColor': variationColor.toString(),
      'variationCapacity': variationCapacity.toString(),
      'variationType': variationType.toString(),
      'variationWeight': variationWeight.toString(),
    };
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body, id: id));
      ref.invalidate(categoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    var responseData = await customHttpClient.post(url: uri, body: body);

    try {
      // final response = await request.send();
      // final responseData = await response.stream.bytesToString();
      final parsedData = jsonDecode(responseData.body);

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
        ref.invalidate(categoryProvider);
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body, id: id));
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body, id: id));
        ref.invalidate(categoryProvider);
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
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineCategoryItem(name, body, id: id));
      ref.invalidate(categoryProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<bool> deleteCategory({required BuildContext context, required num categoryId, required WidgetRef ref}) async {
    final String apiUrl = '${APIConfig.url}/categories/$categoryId'; // Replace with your API URL

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return false;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: apiUrl,
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, categoryId);
        ref.invalidate(categoryProvider);
        return true;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

      if (!context.mounted) return false;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String message = responseData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, categoryId);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category.')),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
      return false;
    }
  }

  Future<num?> addCategoryForBulk({
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/categories');

    var responseData = await http.post(uri, headers: {
      "Accept": 'application/json',
      'Authorization': await getAuthToken(),
    }, body: {
      'categoryName': name,
      'variationSize': 'false',
      'variationColor': 'false',
      'variationCapacity': 'false',
      'variationType': 'false',
      'variationWeight': 'false',
    });

    try {
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        return parsedData['data']['id'];
      }
    } catch (error) {
      return null;
    }
    return null;
  }
}

Map<String, dynamic> _offlineCategoryItem(String name, Map<String, dynamic> body, {num? id}) {
  return {
    'id': id ?? -DateTime.now().millisecondsSinceEpoch,
    'categoryName': name,
    'variationSize': body['variationSize'] == 'true' || body['variationSize'] == true,
    'variationColor': body['variationColor'] == 'true' || body['variationColor'] == true,
    'variationCapacity': body['variationCapacity'] == 'true' || body['variationCapacity'] == true,
    'variationType': body['variationType'] == 'true' || body['variationType'] == true,
    'variationWeight': body['variationWeight'] == 'true' || body['variationWeight'] == true,
    'created_at': DateTime.now().toIso8601String(),
  };
}
