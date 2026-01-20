import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../model/product_models_model.dart';
import '../add_products_models.dart';
import 'package:flutter/foundation.dart';

class ProductModelsRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:product_models';

  // Create Model
  Future<bool> createModels({required CreateModelsModel data}) async {
    EasyLoading.show(status: 'Creating Models...');
    final url = Uri.parse('${APIConfig.url}/product-models');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    request.fields['name'] = data.name.toString();
    request.fields['status'] = data.status.toString();
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _queueModelMultipart(url, request.fields);
        await _upsertModelCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        EasyLoading.dismiss();
        return true;
      }

      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      debugPrint('Model create ${response.statusCode}');
      debugPrint('Model create ${data.status}');

      if (response.statusCode == 200) {
        final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertModelCache(
          id: modelId,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        return true;
      } else if (response.statusCode >= 500) {
        await _queueModelMultipart(url, request.fields);
        final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertModelCache(
          id: modelId,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to create Model');
        debugPrint('Error: ${data['message']}');
        return false;
      }
    } catch (e) {
      await _queueModelMultipart(url, request.fields);
      final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
      await _upsertModelCache(
        id: modelId,
        name: data.name.toString(),
        status: num.tryParse(data.status.toString()),
      );
      EasyLoading.dismiss();
      return true;
    }
  }

  // models List
  Future<ProductModelsModel> fetchModelsList() async {
    final url = Uri.parse('${APIConfig.url}/product-models');
    final headers = {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    };
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (isConnected) {
        var response = await http.get(url, headers: headers);
        EasyLoading.dismiss();

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData is Map && jsonData['data'] is List) {
            final list = (jsonData['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            await _dbHelper.setCachedList(_cacheKey, list);
          }
          return ProductModelsModel.fromJson(jsonData);
        } else {
          var data = jsonDecode(response.body);
          EasyLoading.showError(data['message'] ?? 'Failed to fetch models');
          throw Exception(data['message'] ?? 'Failed to fetch models');
        }
      }
    } catch (e) {
      // fall through to cached
    }
    final cached = await _dbHelper.getCachedList(_cacheKey);
    EasyLoading.dismiss();
    return ProductModelsModel.fromJson({'message': 'cached', 'data': cached});
  }

  // Update Model
  Future<bool> updateModels({required CreateModelsModel data}) async {
    EasyLoading.show(status: 'Updating Model...');
    final url = Uri.parse('${APIConfig.url}/product-models/${data.modelId}');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    request.fields['name'] = data.name.toString();
    request.fields['status'] = data.status.toString();
    request.fields['_method'] = 'put';
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _queueModelMultipart(url, request.fields);
        final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertModelCache(
          id: modelId,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        EasyLoading.dismiss();
        return true;
      }

      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertModelCache(
          id: modelId,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        return true;
      } else if (response.statusCode >= 500) {
        await _queueModelMultipart(url, request.fields);
        final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertModelCache(
          id: modelId,
          name: data.name.toString(),
          status: num.tryParse(data.status.toString()),
        );
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to update');
        return false;
      }
    } catch (e) {
      await _queueModelMultipart(url, request.fields);
      final modelId = num.tryParse(data.modelId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
      await _upsertModelCache(
        id: modelId,
        name: data.name.toString(),
        status: num.tryParse(data.status.toString()),
      );
      EasyLoading.dismiss();
      return true;
    }
  }

  // delete warehouse
  Future<bool> deleteModel({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/product-models/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: url.toString(),
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        EasyLoading.dismiss();
        return true;
      }

      var response = await http.delete(
        url,
        headers: headers,
      );
      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        return true;
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to delete');
        debugPrint(data['message']);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      debugPrint(e.toString());
      return false;
    }
  }
}

extension on ProductModelsRepo {
  Future<void> _queueModelMultipart(Uri url, Map<String, String> fields) async {
    await _dbHelper.addToSyncQueue(
      operationType: 'POST',
      endpoint: url.toString(),
      data: jsonEncode({
        'is_multipart': true,
        'fields': fields,
        'file_path': null,
        'file_field': 'file',
      }),
    );
  }

  Future<void> _upsertModelCache({required num id, required String name, num? status}) async {
    await _dbHelper.upsertCachedListItem(ProductModelsRepo._cacheKey, {
      'id': id,
      'name': name,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
