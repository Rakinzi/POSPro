import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Database/database_helper.dart';
import 'package:mobile_pos/Repository/constant_functions.dart';
import 'package:mobile_pos/Services/connectivity_service.dart';
import 'package:mobile_pos/Const/api_config.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  void initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        debugPrint('Connection restored, starting auto-sync...');
        syncAll();
      }
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('No internet connection, skipping sync');
      return;
    }

    _isSyncing = true;
    debugPrint('Starting sync process...');

    try {
      // Sync in order: products, purchases, sales, then general queue
      await _syncProducts();
      await _syncPurchases();
      await _syncSales();
      await _syncGeneralQueue();

      debugPrint('Sync completed successfully');
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncSales() async {
    try {
      final unsyncedSales = await _dbHelper.getUnsyncedSales();
      debugPrint('Syncing ${unsyncedSales.length} offline sales...');

      for (var sale in unsyncedSales) {
        try {
          final uri = Uri.parse('${APIConfig.url}/sales');

          var request = http.MultipartRequest("POST", uri);
          request.headers.addAll({
            "Accept": 'application/json',
            'Authorization': await getAuthToken(),
            'Content-Type': 'multipart/form-data',
          });

          // Prepare fields
          request.fields.addAll({
            'party_id': sale['party_id']?.toString() ?? '',
            'customer_phone': sale['customer_phone'] ?? '',
            'saleDate': sale['sale_date'],
            'discountAmount': sale['discount_amount'].toString(),
            'discount_percent': sale['discount_percent'].toString(),
            'totalAmount': sale['total_amount'].toString(),
            'dueAmount': sale['due_amount'].toString(),
            'paidAmount': (sale['total_amount'] - sale['due_amount']).toString(),
            'change_amount': sale['change_amount'].toString(),
            'vat_amount': sale['vat_amount'].toString(),
            'vat_percent': sale['vat_percent'].toString(),
            'isPaid': (sale['is_paid'] == 1).toString(),
            'payment_type_id': sale['payment_type'],
            'discount_type': sale['discount_type'],
            'shipping_charge': sale['shipping_charge'].toString(),
            'rounding_option': sale['rounded_option'],
            'rounding_amount': sale['rounding_amount'].toString(),
            'actual_total_amount': sale['unrounded_total_amount'].toString(),
            'note': sale['note'] ?? '',
            'products': sale['products'],
          });

          if (sale['vat_id'] != null) {
            request.fields['vat_id'] = sale['vat_id'].toString();
          }
          final imagePath = sale['image_path'] as String?;
          if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
            request.files.add(await http.MultipartFile.fromPath('image', imagePath));
          }

          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            await _dbHelper.markSaleAsSynced(sale['id']);
            debugPrint('Sale ${sale['id']} synced successfully');
          } else {
            debugPrint('Failed to sync sale ${sale['id']}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error syncing sale ${sale['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _syncSales: $e');
    }
  }

  Future<void> _syncPurchases() async {
    try {
      final unsyncedPurchases = await _dbHelper.getUnsyncedPurchases();
      debugPrint('Syncing ${unsyncedPurchases.length} offline purchases...');

      for (var purchase in unsyncedPurchases) {
        try {
          final uri = Uri.parse('${APIConfig.url}/purchase');

          final body = {
            'party_id': purchase['party_id'],
            'vat_id': purchase['vat_id'],
            'purchaseDate': purchase['purchase_date'],
            'discountAmount': purchase['discount_amount'],
            'discount_percent': purchase['discount_percent'],
            'totalAmount': purchase['total_amount'],
            'vat_amount': purchase['vat_amount'],
            'vat_percent': purchase['vat_percent'],
            'dueAmount': purchase['due_amount'],
            'paidAmount': purchase['total_amount'] - purchase['due_amount'],
            'change_amount': purchase['change_amount'],
            'isPaid': purchase['is_paid'] == 1,
            'payment_type_id': purchase['payment_type'],
            'discount_type': purchase['discount_type'],
            'shipping_charge': purchase['shipping_charge'],
            'products': jsonDecode(purchase['products']),
          };

          final response = await http.post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': await getAuthToken(),
            },
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            await _dbHelper.markPurchaseAsSynced(purchase['id']);
            debugPrint('Purchase ${purchase['id']} synced successfully');
          } else {
            debugPrint('Failed to sync purchase ${purchase['id']}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error syncing purchase ${purchase['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _syncPurchases: $e');
    }
  }

  Future<void> _syncProducts() async {
    try {
      final unsyncedProducts = await _dbHelper.getUnsyncedProducts();
      debugPrint('Syncing ${unsyncedProducts.length} offline products...');

      for (var product in unsyncedProducts) {
        try {
          final payload = jsonDecode(product['product_data']) as Map<String, dynamic>;
          final endpoint = payload['endpoint']?.toString() ?? '${APIConfig.url}/products';
          final method = payload['method']?.toString() ?? 'POST';
          final fields = Map<String, dynamic>.from(payload['fields'] ?? {});
          final fileField = payload['file_field']?.toString() ?? 'productPicture';

          final request = http.MultipartRequest(method, Uri.parse(endpoint));
          request.headers.addAll({
            'Accept': 'application/json',
            'Authorization': await getAuthToken(),
          });
          fields.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });

          final imagePath = product['image_path'] as String?;
          if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
            request.files.add(await http.MultipartFile.fromPath(fileField, imagePath));
          }

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _dbHelper.markProductAsSynced(product['id']);
            debugPrint('Product ${product['id']} synced successfully');
          } else {
            debugPrint('Failed to sync product ${product['id']}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error syncing product ${product['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _syncProducts: $e');
    }
  }

  Future<void> _syncGeneralQueue() async {
    try {
      final pendingItems = await _dbHelper.getPendingSyncItems();
      debugPrint('Syncing ${pendingItems.length} queued items...');

      for (var item in pendingItems) {
        try {
          final uri = Uri.parse(item['endpoint']);
          final data = jsonDecode(item['data']);
          final isMultipart = data is Map && data['is_multipart'] == true;

          http.Response response;

          if (isMultipart) {
            final fields = Map<String, dynamic>.from(data['fields'] ?? {});
            final filePath = data['file_path']?.toString();
            final fileField = data['file_field']?.toString() ?? 'file';
            final request = http.MultipartRequest(item['operation_type'], uri);
            request.headers.addAll({
              'Accept': 'application/json',
              'Authorization': await getAuthToken(),
            });
            fields.forEach((key, value) {
              if (value != null) {
                request.fields[key] = value.toString();
              }
            });
            if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
              request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
            }
            final streamedResponse = await request.send();
            response = await http.Response.fromStream(streamedResponse);
          } else {
            switch (item['operation_type']) {
              case 'POST':
                response = await http.post(
                  uri,
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Authorization': await getAuthToken(),
                  },
                  body: jsonEncode(data),
                );
                break;
              case 'PUT':
                response = await http.put(
                  uri,
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Authorization': await getAuthToken(),
                  },
                  body: jsonEncode(data),
                );
                break;
              case 'DELETE':
                response = await http.delete(
                  uri,
                  headers: {
                    'Accept': 'application/json',
                    'Authorization': await getAuthToken(),
                  },
                );
                break;
              default:
                continue;
            }
          }

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _dbHelper.markSyncItemAsCompleted(item['id']);
            debugPrint('Queue item ${item['id']} synced successfully');
          } else {
            await _dbHelper.updateSyncItemRetry(item['id'], 'HTTP ${response.statusCode}');
            debugPrint('Failed to sync queue item ${item['id']}: ${response.statusCode}');
          }
        } catch (e) {
          await _dbHelper.updateSyncItemRetry(item['id'], e.toString());
          debugPrint('Error syncing queue item ${item['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _syncGeneralQueue: $e');
    }
  }

  Future<int> getPendingSyncCount() async {
    return await _dbHelper.getPendingSyncCount();
  }

  Future<void> clearSyncedData() async {
    await _dbHelper.clearSyncedData();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
