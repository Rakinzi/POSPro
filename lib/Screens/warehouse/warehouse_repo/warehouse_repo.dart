import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../add_new_warehouse.dart';
import '../warehouse_model/warehouse_list_model.dart';
import 'package:flutter/foundation.dart';

class WarehouseRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:warehouses';

  // Create Warehouse
  Future<bool> createWareHouse({required CreateWareHouseModel data}) async {
    EasyLoading.show(status: 'Creating Warehouse...');
    final url = Uri.parse('${APIConfig.url}/warehouses');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    request.fields['name'] = data.name.toString();
    request.fields['phone'] = data.phone.toString();
    request.fields['email'] = data.email.toString();
    request.fields['address'] = data.address.toString();
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _queueWarehouseMultipart(url, request.fields);
        await _upsertWarehouseCache(
          id: -DateTime.now().millisecondsSinceEpoch,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        EasyLoading.dismiss();
        return true;
      }

      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      debugPrint('warehouse create ${response.statusCode}');
      debugPrint('warehouse create ${response.request}');
      if (response.statusCode == 200) {
        final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertWarehouseCache(
          id: warehouseId,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        return true;
      } else if (response.statusCode >= 500) {
        await _queueWarehouseMultipart(url, request.fields);
        final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertWarehouseCache(
          id: warehouseId,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to create warehouse');
        debugPrint('Error: ${data['message']}');
        return false;
      }
    } catch (e) {
      await _queueWarehouseMultipart(url, request.fields);
      final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
      await _upsertWarehouseCache(
        id: warehouseId,
        name: data.name.toString(),
        phone: data.phone.toString(),
        email: data.email.toString(),
        address: data.address.toString(),
      );
      EasyLoading.dismiss();
      return true;
    }
  }

  // warehouse List
  Future<WarehouseListModel> fetchWareHouseList() async {
    final url = Uri.parse('${APIConfig.url}/warehouses');
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
          return WarehouseListModel.fromJson(jsonData);
        } else {
          var data = jsonDecode(response.body);
          EasyLoading.showError(data['message'] ?? 'Failed to fetch warehouse');
          throw Exception(data['message'] ?? 'Failed to fetch warehouse');
        }
      }
    } catch (e) {
      // fall through to cached
    }
    final cached = await _dbHelper.getCachedList(_cacheKey);
    EasyLoading.dismiss();
    return WarehouseListModel.fromJson({'message': 'cached', 'data': cached});
  }

  // Update Warehouse
  Future<bool> updateWareHouse({required CreateWareHouseModel data}) async {
    EasyLoading.show(status: 'Updating Warehouse...');
    final url = Uri.parse('${APIConfig.url}/warehouses/${data.warehouseId}');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    request.fields['name'] = data.name.toString();
    request.fields['phone'] = data.phone.toString();
    request.fields['email'] = data.email.toString();
    request.fields['address'] = data.address.toString();
    request.fields['_method'] = 'put';
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _queueWarehouseMultipart(url, request.fields);
        final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertWarehouseCache(
          id: warehouseId,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        EasyLoading.dismiss();
        return true;
      }

      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertWarehouseCache(
          id: warehouseId,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        return true;
      } else if (response.statusCode >= 500) {
        await _queueWarehouseMultipart(url, request.fields);
        final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
        await _upsertWarehouseCache(
          id: warehouseId,
          name: data.name.toString(),
          phone: data.phone.toString(),
          email: data.email.toString(),
          address: data.address.toString(),
        );
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to update');
        return false;
      }
    } catch (e) {
      await _queueWarehouseMultipart(url, request.fields);
      final warehouseId = num.tryParse(data.warehouseId ?? '') ?? -DateTime.now().millisecondsSinceEpoch;
      await _upsertWarehouseCache(
        id: warehouseId,
        name: data.name.toString(),
        phone: data.phone.toString(),
        email: data.email.toString(),
        address: data.address.toString(),
      );
      EasyLoading.dismiss();
      return true;
    }
  }

  // delete warehouse
  Future<bool> deleteWarehouse({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/warehouses/$id');
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

extension on WarehouseRepo {
  Future<void> _queueWarehouseMultipart(Uri url, Map<String, String> fields) async {
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

  Future<void> _upsertWarehouseCache({
    required num id,
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    await _dbHelper.upsertCachedListItem(WarehouseRepo._cacheKey, {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
