//ignore_for_file: avoid_print,unused_local_variable
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';

import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../Model/parties_model.dart';
import '../Provider/customer_provider.dart';

class PartyRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:parties';

  Future<List<Party>> fetchAllParties() async {
    final uri = Uri.parse('${APIConfig.url}/parties');
    final isConnected = await _connectivityService.checkConnectivity();

    if (isConnected) {
      try {
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        });

        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
          final partyList = parsedData['data'] as List<dynamic>;
          final partyMaps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.setCachedList(_cacheKey, partyMaps);
          return partyMaps.map((category) => Party.fromJson(category)).toList();
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(_cacheKey);
    return cached.map((item) => Party.fromJson(item)).toList();
  }

  Future<void> addParty({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String phone,
    required String type,
    File? image,
    String? email,
    String? address,
    String? due,
  }) async {
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    final uri = Uri.parse('${APIConfig.url}/parties');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['type'] = type;
    if (email != null) request.fields['email'] = email;
    if (address != null) request.fields['address'] = address;
    if (due != null) request.fields['due'] = due; // Convert due to string
    if (image != null) {
      request.files.add(http.MultipartFile.fromBytes('image', image.readAsBytesSync(), filename: image.path));
    }

    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return;
    if (!isConnected) {
      await _queuePartyMultipart(uri: uri, fields: request.fields, imagePath: image?.path);
      await _upsertPartyCache(
        id: _tempId(),
        name: name,
        phone: phone,
        type: type,
        email: email,
        address: address,
        due: due,
        imagePath: image?.path,
      );
      ref.invalidate(partiesProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    final response = await customHttpClient.uploadFile(url: uri, fileFieldName: 'image', file: image, fields: request.fields);
    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    if (!context.mounted) return;

    if (response.statusCode == 200) {
      ref.invalidate(partiesProvider);
      final data = parsedData is Map<String, dynamic> ? parsedData['data'] : null;
      if (data is Map) {
        await _dbHelper.upsertCachedListItem(_cacheKey, Map<String, dynamic>.from(data));
      }
      if (!context.mounted) return;
      Navigator.pop(context);
    } else if (response.statusCode >= 500) {
      await _queuePartyMultipart(uri: uri, fields: request.fields, imagePath: image?.path);
      await _upsertPartyCache(
        id: _tempId(),
        name: name,
        phone: phone,
        type: type,
        email: email,
        address: address,
        due: due,
        imagePath: image?.path,
      );
      ref.invalidate(partiesProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Party creation failed: ${parsedData['message']}')));
    }
  }

  Future<void> updateParty({
    required String id,
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String phone,
    required String type,
    File? image,
    String? email,
    String? address,
    String? due,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/parties/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields['_method'] = 'put';
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['type'] = type;
    if (email != null) request.fields['email'] = email;
    if (address != null) request.fields['address'] = address;
    if (due != null) request.fields['due'] = due; // Convert due to string
    if (image != null) {
      request.files.add(http.MultipartFile.fromBytes('image', image.readAsBytesSync(), filename: image.path));
    }

    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _queuePartyMultipart(uri: uri, fields: request.fields, imagePath: image?.path);
      await _upsertPartyCache(
        id: id,
        name: name,
        phone: phone,
        type: type,
        email: email,
        address: address,
        due: due,
        imagePath: image?.path,
      );
      ref.invalidate(partiesProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }

    final response = await customHttpClient.uploadFile(url: uri, fields: request.fields, file: image, fileFieldName: 'image');
    final responseData = await response.stream.bytesToString();

    final parsedData = jsonDecode(responseData);

    if (!context.mounted) return;

    if (response.statusCode == 200) {
      ref.invalidate(partiesProvider);
      final data = parsedData is Map<String, dynamic> ? parsedData['data'] : null;
      if (data is Map) {
        await _dbHelper.upsertCachedListItem(_cacheKey, Map<String, dynamic>.from(data));
      } else {
        await _upsertPartyCache(
          id: id,
          name: name,
          phone: phone,
          type: type,
          email: email,
          address: address,
          due: due,
          imagePath: image?.path,
        );
      }
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else if (response.statusCode >= 500) {
      await _queuePartyMultipart(uri: uri, fields: request.fields, imagePath: image?.path);
      await _upsertPartyCache(
        id: id,
        name: name,
        phone: phone,
        type: type,
        email: email,
        address: address,
        due: due,
        imagePath: image?.path,
      );
      ref.invalidate(partiesProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Party Update failed: ${parsedData['message']}')));
    }
  }

  Future<void> deleteParty({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/parties/$id';

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'DELETE',
          endpoint: apiUrl,
          data: jsonEncode({}),
        );
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        ref.invalidate(partiesProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
        return;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        ref.invalidate(partiesProvider);

        if (!context.mounted) return;
        Navigator.pop(context); // Assuming you want to close the screen after deletion
        // Navigator.pop(context); // Assuming you want to close the screen after deletion
      } else {
        final parsedData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete party: ${parsedData['message']}')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> sendCustomerUdeSms({required num id, required BuildContext context}) async {
    final uri = Uri.parse('${APIConfig.url}/parties/$id');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['message'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${jsonDecode((response.body))['message']}')));
    }
  }
}

extension on PartyRepository {
  int _tempId() => -DateTime.now().millisecondsSinceEpoch;

  Future<void> _queuePartyMultipart({
    required Uri uri,
    required Map<String, String> fields,
    String? imagePath,
  }) async {
    await _dbHelper.addToSyncQueue(
      operationType: 'POST',
      endpoint: uri.toString(),
      data: jsonEncode({
        'is_multipart': true,
        'fields': fields,
        'file_path': imagePath,
        'file_field': 'image',
      }),
    );
  }

  Future<void> _upsertPartyCache({
    required dynamic id,
    required String name,
    required String phone,
    required String type,
    String? email,
    String? address,
    String? due,
    String? imagePath,
  }) async {
    final party = {
      'id': id is num ? id : (num.tryParse(id.toString()) ?? id),
      'name': name,
      'phone': phone,
      'type': type,
      'email': email,
      'address': address,
      'due': due != null ? num.tryParse(due) ?? due : null,
      'image': imagePath,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _dbHelper.upsertCachedListItem(PartyRepository._cacheKey, party);
  }
}
