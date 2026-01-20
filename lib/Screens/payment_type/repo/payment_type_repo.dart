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
import '../model/payment_type_model.dart';
import '../provider/payment_type_provider.dart';

class PaymentTypeRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:payment_types';

  Future<List<PaymentTypeModel>> fetchAllPaymentType() async {
    final uri = Uri.parse('${APIConfig.url}/payment-types');

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
          return maps.map((category) => PaymentTypeModel.fromJson(category)).toList();
        } else {
          debugPrint('Response: ${response.statusCode}');
          debugPrint('Response: ${response.body}');
          throw Exception('Failed to fetch categories: ${response.statusCode}');
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => PaymentTypeModel.fromJson(item)).toList();
  }

  Future<void> managePaymentType({
    required WidgetRef ref,
    required BuildContext context,
    required PaymentTypeModel data,
  }) async {
    final uri = Uri.parse(
      '${APIConfig.url}/payment-types${data.id != null ? '/${data.id}' : ''}',
    );
    CustomHttpClient customHttpClient = CustomHttpClient(
      client: http.Client(),
      context: context,
      ref: ref,
    );

    try {
      Map<String, String> body = {
        if (data.id != null) '_method': 'put',
        ...data.toJson(),
      };
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlinePaymentTypeItem(data));
        ref.invalidate(paymentTypeProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
        return;
      }

      var responseData = await customHttpClient.post(
        url: uri,
        body: body,
      );

      final parsedData = jsonDecode(responseData.body);

      if (!context.mounted) return;

      if (responseData.statusCode == 200) {
        debugPrint('eswyfgseuyfgseygfysegfseygfseygfseygfseygfseygfesgfsegfseygf');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added successful!'),
          ),
        );
        ref.invalidate(paymentTypeProvider);
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlinePaymentTypeItem(data));
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: jsonEncode(body),
        );
        await _dbHelper.upsertCachedListItem(_cacheKey, _offlinePaymentTypeItem(data));
        ref.invalidate(paymentTypeProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Category creation failed: ${parsedData['message']}',
            ),
          ),
        );
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: jsonEncode({
          if (data.id != null) '_method': 'put',
          ...data.toJson(),
        }),
      );
      await _dbHelper.upsertCachedListItem(_cacheKey, _offlinePaymentTypeItem(data));
      ref.invalidate(paymentTypeProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<bool> deletePaymentType({
    required BuildContext context,
    required int id,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/payment-types/$id';

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: apiUrl,
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        ref.invalidate(paymentTypeProvider);
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
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete payment type.')),
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
}

Map<String, dynamic> _offlinePaymentTypeItem(PaymentTypeModel data) {
  return {
    'id': data.id ?? -DateTime.now().millisecondsSinceEpoch,
    'name': data.name,
    'status': data.status,
    'created_at': DateTime.now().toIso8601String(),
  };
}
