//ignore_for_file: unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../model/brands_model.dart';
import '../product_brand_provider/product_brand_provider.dart';

class BrandsRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:brands';

  Future<List<Brand>> fetchAllBrands() async {
    final uri = Uri.parse('${APIConfig.url}/brands');

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
          return maps.map((category) => Brand.fromJson(category)).toList();
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => Brand.fromJson(item)).toList();
  }

  Future<void> addBrand({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/brands');

    final body = {'brandName': name};
    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return;
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name));
      ref.invalidate(brandsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(url: uri, body: body);
      final parsedData = jsonDecode(responseData.body);

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
        ref.invalidate(brandsProvider);
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
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name));
        ref.invalidate(brandsProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Brand creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name));
      ref.invalidate(brandsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<num?> addBrandForBulkUpload({
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/brands');

    try {
      var responseData = await http.post(uri, headers: {
        "Accept": 'application/json',
        'Authorization': await getAuthToken(),
      }, body: {
        'brandName': name,
      });
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        return parsedData['data']['id'];
      }
    } catch (error) {
      return null;
    }
    return null;
  }

  ///_________Edit_brand_________________________
  Future<void> editBrand({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/brands/$id');

    final body = {
      'brandName': name,
      '_method': 'put',
    };
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name, id: id));
      ref.invalidate(brandsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(url: uri, body: body);
      final parsedData = jsonDecode(responseData.body);

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('update successful!')));
        ref.invalidate(brandsProvider);
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name, id: id));
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name, id: id));
        ref.invalidate(brandsProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Brand update failed: ${parsedData['message']}')));
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineBrandItem(name, id: id));
      ref.invalidate(brandsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  ///_________delete_brand________________________
  Future<bool> deleteBrand({required BuildContext context, required num brandId, required WidgetRef ref}) async {
    final String apiUrl = '${APIConfig.url}/brands/$brandId'; // Replace with your API URL

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return false;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: apiUrl,
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, brandId);
        ref.invalidate(brandsProvider);
        return true;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      if (!context.mounted) return false;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String message = responseData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, brandId);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete brand.')),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
      return false;
    }
  }
}

Map<String, dynamic> _offlineBrandItem(String name, {num? id}) {
  return {
    'id': id ?? -DateTime.now().millisecondsSinceEpoch,
    'brandName': name,
    'created_at': DateTime.now().toIso8601String(),
  };
}
