import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../model/vat_model.dart';
import '../provider/text_repo.dart';

class TaxRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<List<VatModel>> fetchAllTaxes({String? taxType}) async {
    final uri = Uri.parse('${APIConfig.url}/vats?type=$taxType');

    final isConnected = await _connectivityService.checkConnectivity();
    final cacheKey = _cacheKeyFor(taxType);
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': await getAuthToken(),
      });

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
        final partyList = parsedData['data'] as List<dynamic>;
        final maps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        await _dbHelper.setCachedList(cacheKey, maps);
        return maps.map((category) => VatModel.fromJson(category)).toList();
      }
    }

    final cached = await _dbHelper.getCachedList(cacheKey);
    return cached.map((item) => VatModel.fromJson(item)).toList();
  }

  Future<void> createSingleTax({
    required WidgetRef ref,
    required BuildContext context,
    required num taxRate,
    required String taxName,
    required bool status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats');
    final requestBody = jsonEncode({
      'name': taxName,
      'rate': taxRate,
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
        await _upsertTaxCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: taxName,
          rate: taxRate,
          status: status,
        );
        ref.invalidate(taxProvider);
        return;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );
      if (!context.mounted) return;

      final parsedData = jsonDecode(responseData.body);

      EasyLoading.dismiss();
      if (responseData.statusCode == 200) {
        ref.invalidate(taxProvider);
        if (parsedData is Map && parsedData['data'] is Map) {
          await _dbHelper.upsertCachedListItem(_cacheKeyFor(null), Map<String, dynamic>.from(parsedData['data']));
        }
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _upsertTaxCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: taxName,
          rate: taxRate,
          status: status,
        );
        ref.invalidate(taxProvider);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tax creation failed: $parsedData')));
        return;
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: requestBody,
      );
      await _upsertTaxCache(
        id: -DateTime.now().millisecondsSinceEpoch,
        name: taxName,
        rate: taxRate,
        status: status,
      );
      ref.invalidate(taxProvider);
    }
  }

  Future<void> createGroupTax({
    required WidgetRef ref,
    required BuildContext context,
    required String taxName,
    required List<num> taxIds,
    required bool status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();
    request.fields.addAll({
      'name': taxName,
    });

    if (taxIds.isNotEmpty) {
      int index = 0;
      for (var element in taxIds) {
        request.fields['vat_ids[$index]'] = element.toString();
        index++;
      }
    }

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return;
      if (!isConnected) {
        await _queueTaxMultipart(uri, request.fields);
        await _upsertTaxCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: taxName,
          status: status,
          subVatIds: taxIds,
        );
        ref.invalidate(taxProvider);
        return;
      }

      final response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      // final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final parsedData = jsonDecode(responseData);
      if (!context.mounted) return;

      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      debugPrint(responseData);
      if (response.statusCode == 200) {
        debugPrint('45235');
        ref.invalidate(taxProvider);
      } else if (response.statusCode >= 500) {
        await _queueTaxMultipart(uri, request.fields);
        await _upsertTaxCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: taxName,
          status: status,
          subVatIds: taxIds,
        );
        ref.invalidate(taxProvider);
      } else if (response.statusCode == 403) {
        throw Exception('Failed to update tax');
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tax creation failed: ${parsedData['message']}')));
        return;
      }
    } catch (error) {
      await _queueTaxMultipart(uri, request.fields);
      await _upsertTaxCache(
        id: -DateTime.now().millisecondsSinceEpoch,
        name: taxName,
        status: status,
        subVatIds: taxIds,
      );
      ref.invalidate(taxProvider);
    }
  }

  ///________Update_Single_Tax__________________________________________
  Future<void> updateSingleTax({
    required num id,
    required String name,
    required num rate,
    required bool status,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats/$id');
    final requestBody = jsonEncode({
      'rate': rate,
      'name': name,
      'status': status,
      '_method': 'put',
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
        await _upsertTaxCache(id: id, name: name, rate: rate, status: status);
        ref.invalidate(taxProvider);
        return;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      final response = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        ref.invalidate(taxProvider);
        await _upsertTaxCache(id: id, name: name, rate: rate, status: status);
      } else if (response.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _upsertTaxCache(id: id, name: name, rate: rate, status: status);
        ref.invalidate(taxProvider);
      } else {
        throw Exception('Failed to update tax. Status Code: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: requestBody,
      );
      await _upsertTaxCache(id: id, name: name, rate: rate, status: status);
      ref.invalidate(taxProvider);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateGroupTax({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String taxName,
    required List<num> taxIds,
    required bool status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();
    request.fields.addAll({
      'name': taxName,
      'status': status ? '1' : "0",
      '_method': 'put',
    });

    if (taxIds.isNotEmpty) {
      int index = 0;
      for (var element in taxIds) {
        request.fields['vat_ids[$index]'] = element.toString();
        index++;
      }
    }

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return;
      if (!isConnected) {
        await _queueTaxMultipart(uri, request.fields);
        await _upsertTaxCache(id: id, name: taxName, status: status, subVatIds: taxIds);
        ref.invalidate(taxProvider);
        return;
      }

      final response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      // final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final parsedData = jsonDecode(responseData);
      if (!context.mounted) return;

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.invalidate(taxProvider);
        await _upsertTaxCache(id: id, name: taxName, status: status, subVatIds: taxIds);
      } else if (response.statusCode >= 500) {
        await _queueTaxMultipart(uri, request.fields);
        await _upsertTaxCache(id: id, name: taxName, status: status, subVatIds: taxIds);
        ref.invalidate(taxProvider);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tax creation failed: ${parsedData['message']}')));
        return;
      }
    } catch (error) {
      await _queueTaxMultipart(uri, request.fields);
      await _upsertTaxCache(id: id, name: taxName, status: status, subVatIds: taxIds);
      ref.invalidate(taxProvider);
    }
  }

  ///________Delete_Tax______________________________________________________
  Future<bool> deleteTax({required String id, required BuildContext context, required WidgetRef ref}) async {
    try {
      final token = await getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }
      if (!context.mounted) return false;

      final url = Uri.parse('${APIConfig.url}/vats/$id');
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: url.toString(),
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKeyFor(null), id);
        ref.invalidate(taxProvider);
        return true;
      }
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      if (response.statusCode == 200) {
        await _dbHelper.removeCachedListItem(_cacheKeyFor(null), id);
        return true;
      } else {
        debugPrint('Error deleting tax: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error during delete operation: $error');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

extension on TaxRepo {
  String _cacheKeyFor(String? taxType) => 'cache:vats:${taxType ?? 'all'}';

  Future<void> _queueTaxMultipart(Uri uri, Map<String, String> fields) async {
    await _dbHelper.addToSyncQueue(
      operationType: 'POST',
      endpoint: uri.toString(),
      data: jsonEncode({
        'is_multipart': true,
        'fields': fields,
        'file_path': null,
        'file_field': 'file',
      }),
    );
  }

  Future<void> _upsertTaxCache({
    required num id,
    required String name,
    num? rate,
    bool? status,
    List<num>? subVatIds,
  }) async {
    final item = {
      'id': id,
      'name': name,
      'rate': rate,
      'status': status,
      'sub_vat': subVatIds?.map((e) => {'id': e}).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _dbHelper.upsertCachedListItem(_cacheKeyFor(null), item);
  }
}
