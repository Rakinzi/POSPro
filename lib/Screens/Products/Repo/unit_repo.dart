// ignore_for_file: file_names, unused_element, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../../product_unit/model/unit_model.dart';
import '../../product_unit/provider/product_unit_provider.dart';

class UnitsRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:units';

  Future<List<Unit>> fetchAllUnits() async {
    final uri = Uri.parse('${APIConfig.url}/units');

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
          return maps.map((unit) => Unit.fromJson(unit)).toList();
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => Unit.fromJson(item)).toList();
  }

  Future<void> addUnit({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/units');

    final body = {'unitName': name};
    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return;
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name));
      ref.invalidate(unitsProvider);
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
        ref.invalidate(unitsProvider);
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
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name));
        ref.invalidate(unitsProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unit creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name));
      ref.invalidate(unitsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<num?> addUnitForBulk({
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/units');

    try {
      var responseData = await http.post(uri, headers: {
        "Accept": 'application/json',
        'Authorization': await getAuthToken(),
      }, body: {
        'unitName': name,
      });
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        return parsedData['data']['id'];
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  ///_______Edit_Add_________________________________________
  Future<void> editUnit({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/units/$id');

    final body = {
      'unitName': name,
      '_method': 'put',
    };
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name, id: id));
      ref.invalidate(unitsProvider);
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
        ref.invalidate(unitsProvider);
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name, id: id));
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name, id: id));
        ref.invalidate(unitsProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unit creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode(body),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlineUnitItem(name, id: id));
      ref.invalidate(unitsProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  ///_________delete_unit________________________
  Future<bool> deleteUnit({required BuildContext context, required num unitId, required WidgetRef ref}) async {
    final String apiUrl = '${APIConfig.url}/units/$unitId'; // Replace with your API URL

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return false;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: apiUrl,
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, unitId);
        ref.invalidate(unitsProvider);
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
        await _dbHelper.removeCachedListItem(_cacheKey, unitId);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete unit.')),
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

Map<String, dynamic> _offlineUnitItem(String name, {num? id}) {
  return {
    'id': id ?? -DateTime.now().millisecondsSinceEpoch,
    'unitName': name,
    'created_at': DateTime.now().toIso8601String(),
  };
}
