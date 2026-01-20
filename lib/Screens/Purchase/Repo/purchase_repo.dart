//ignore_for_file: prefer_typing_uninitialized_variables,unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/product_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../Model/purchase_transaction_model.dart';
import '../../../Database/database_helper.dart';
import '../../../Services/connectivity_service.dart';

class PurchaseRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String _cacheKey = 'cache:purchases';
  static const String _cacheReturnKey = 'cache:purchases_returned';

  Future<List<PurchaseTransaction>> fetchPurchaseList({bool? purchaseReturn}) async {
    final uri = Uri.parse('${APIConfig.url}/purchase${(purchaseReturn ?? false) ? "?returned-purchase=true" : ''}');
    final isConnected = await _connectivityService.checkConnectivity();
    final cacheKey = (purchaseReturn ?? false) ? _cacheReturnKey : _cacheKey;

    if (isConnected) {
      try {
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        });

        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
          final partyList = parsedData['data'] as List<dynamic>;
          final maps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.setCachedList(cacheKey, maps);
          final online = maps.map((category) => PurchaseTransaction.fromJson(category)).toList();
          final offline = await _getOfflinePurchases();
          return _mergePurchases(online, offline, purchaseReturn: purchaseReturn);
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cached = await _dbHelper.getCachedList(cacheKey);
    final cachedModels = cached.map((item) => PurchaseTransaction.fromJson(item)).toList();
    final offline = await _getOfflinePurchases();
    return _mergePurchases(cachedModels, offline, purchaseReturn: purchaseReturn);
  }

  Future<PurchaseTransaction?> createPurchase({
    required WidgetRef ref,
    required BuildContext context,
    required num partyId,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num? vatId,
    required num totalAmount,
    required num vatAmount,
    required num vatPercent,
    required num dueAmount,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required List<CartProductModelPurchase> products,
    required String discountType,
    required num shippingCharge,
  }) async {
    // Check internet connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return null;

    if (!isConnected) {
      await _savePurchaseOffline(
        ref: ref,
        context: context,
        partyId: partyId,
        purchaseDate: purchaseDate,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
        vatId: vatId,
        totalAmount: totalAmount,
        vatAmount: vatAmount,
        vatPercent: vatPercent,
        dueAmount: dueAmount,
        changeAmount: changeAmount,
        isPaid: isPaid,
        paymentType: paymentType,
        products: products,
        discountType: discountType,
        shippingCharge: shippingCharge,
      );
      return null;
    }

    final uri = Uri.parse('${APIConfig.url}/purchase');

    final body = {
      'party_id': partyId,
      'vat_id': vatId,
      'purchaseDate': purchaseDate,
      'discountAmount': discountAmount,
      'discount_percent': discountPercent,
      'totalAmount': totalAmount,
      'vat_amount': vatAmount,
      'vat_percent': vatPercent,
      'dueAmount': dueAmount,
      'paidAmount': totalAmount - dueAmount,
      'change_amount': changeAmount,
      'isPaid': isPaid,
      'payment_type_id': paymentType,
      'discount_type': discountType,
      'shipping_charge': shippingCharge,
      'products': products.map((e) => e.toJson()).toList(),
    };

    debugPrint('Purchase Posted data : ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': await getAuthToken(),
        },
        body: jsonEncode(body),
      );

      final parsed = jsonDecode(response.body);

      debugPrint('Purchase Response : ${response.statusCode}');
      debugPrint('Purchase Response : $parsed');

      if (!context.mounted) return null;

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Added successful!');

        // Refresh providers
        ref
          ..invalidate(productProvider)
          ..invalidate(partiesProvider)
          ..invalidate(purchaseTransactionProvider)
          ..invalidate(businessInfoProvider)
          ..invalidate(getExpireDateProvider(ref))
          ..invalidate(summaryInfoProvider);

        debugPrint('Purchase Response: ${parsed['data']}');
        if (parsed['data'] is Map) {
          await _dbHelper.upsertCachedListItem(_cacheKey, Map<String, dynamic>.from(parsed['data']));
        }
        return PurchaseTransaction.fromJson(parsed['data']);
      } else if (response.statusCode >= 500) {
        await _savePurchaseOffline(
          ref: ref,
          context: context,
          partyId: partyId,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          discountPercent: discountPercent,
          vatId: vatId,
          totalAmount: totalAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          dueAmount: dueAmount,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
          products: products,
          discountType: discountType,
          shippingCharge: shippingCharge,
        );
      } else {
        EasyLoading.dismiss();
        _showError(context, 'Purchase creation failed: ${parsed['message']}');
      }
    } catch (e) {
      await _savePurchaseOffline(
        ref: ref,
        context: context,
        partyId: partyId,
        purchaseDate: purchaseDate,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
        vatId: vatId,
        totalAmount: totalAmount,
        vatAmount: vatAmount,
        vatPercent: vatPercent,
        dueAmount: dueAmount,
        changeAmount: changeAmount,
        isPaid: isPaid,
        paymentType: paymentType,
        products: products,
        discountType: discountType,
        shippingCharge: shippingCharge,
      );
    }

    return null;
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<PurchaseTransaction?> updatePurchase({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required num partyId,
    required num? vatId,
    required num vatAmount,
    required num vatPercent,
    required String purchaseDate,
    required num discountAmount,
    required num totalAmount,
    required num dueAmount,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required List<CartProductModelPurchase> products,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/purchase/$id');
    final requestBody = jsonEncode({
      '_method': 'put',
      'party_id': partyId,
      'vat_id': vatId,
      'purchaseDate': purchaseDate,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'vat_amount': vatAmount,
      'vat_percent': vatPercent,
      'dueAmount': dueAmount,
      'paidAmount': totalAmount - dueAmount,
      'change_amount': changeAmount,
      'isPaid': isPaid,
      'payment_type_id': paymentType,
      'products': products.map((product) => product.toJson()).toList(),
    });

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!context.mounted) return null;
      if (!isConnected) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _updatePurchaseCache(
          id: id,
          partyId: partyId,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          dueAmount: dueAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
        );
        ref
          ..invalidate(productProvider)
          ..invalidate(partiesProvider)
          ..invalidate(purchaseTransactionProvider);
        if (!context.mounted) return null;
        Navigator.pop(context);
        return null;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      debugPrint(responseData.statusCode.toString());
      debugPrint(parsedData);

      if (!context.mounted) return null;

      if (responseData.statusCode == 200) {
        EasyLoading.showSuccess('Added successful!');
        ref
          ..invalidate(productProvider)
          ..invalidate(partiesProvider)
          ..invalidate(purchaseTransactionProvider)
          ..invalidate(businessInfoProvider)
          ..invalidate(getExpireDateProvider(ref));
        await _updatePurchaseCache(
          id: id,
          partyId: partyId,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          dueAmount: dueAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
        );
        if (!context.mounted) return null;
        Navigator.pop(context);
        return PurchaseTransaction.fromJson(parsedData);
      } else if (responseData.statusCode >= 500) {
        await _dbHelper.addToSyncQueue(
          operationType: 'POST',
          endpoint: uri.toString(),
          data: requestBody,
        );
        await _updatePurchaseCache(
          id: id,
          partyId: partyId,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          dueAmount: dueAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
        );
        ref
          ..invalidate(productProvider)
          ..invalidate(partiesProvider)
          ..invalidate(purchaseTransactionProvider);
        if (!context.mounted) return null;
        Navigator.pop(context);
        return null;
      } else {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase creation failed: ${parsedData['message']}')));
        return null;
      }
    } catch (error) {
      await _dbHelper.addToSyncQueue(
        operationType: 'POST',
        endpoint: uri.toString(),
        data: requestBody,
      );
      await _updatePurchaseCache(
        id: id,
        partyId: partyId,
        purchaseDate: purchaseDate,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        dueAmount: dueAmount,
        vatAmount: vatAmount,
        vatPercent: vatPercent,
        changeAmount: changeAmount,
        isPaid: isPaid,
        paymentType: paymentType,
      );
      ref
        ..invalidate(productProvider)
        ..invalidate(partiesProvider)
        ..invalidate(purchaseTransactionProvider);
      if (!context.mounted) return null;
      Navigator.pop(context);
      return null;
    }
  }

  Future<void> deletePurchase({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/purchase/$id';

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
        ref.invalidate(productProvider);
        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      }

      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      EasyLoading.dismiss();

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await _dbHelper.removeCachedListItem(_cacheKey, id);
        ref.invalidate(productProvider);

        if (!context.mounted) return;
        Navigator.pop(context); // Assuming you want to close the screen after deletion
        if (!context.mounted) return;
        Navigator.pop(context); // Assuming you want to close the screen after deletion
        // Navigator.pop(context); // Assuming you want to close the screen after deletion
      } else {
        final parsedData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: ${parsedData['message']}')));
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class CartProductModelPurchase {
  num productId;
  num? stockId;
  String productName;
  String productType;
  String vatType;
  num vatRate;
  num vatAmount;
  String? brandName;
  String? batchNumber;
  num? productDealerPrice;
  num? productPurchasePrice;
  String? expireDate;
  String? mfgDate;
  num? productSalePrice;
  num? profitPercent;
  num? productWholeSalePrice;
  num? quantities;
  num? stock;

  CartProductModelPurchase({
    required this.productId,
    this.stockId,
    required this.productName,
    required this.productType,
    required this.vatRate,
    required this.vatAmount,
    required this.vatType,
    this.brandName,
    this.stock,
    this.profitPercent,
    required this.productDealerPrice,
    required this.productPurchasePrice,
    required this.productSalePrice,
    required this.productWholeSalePrice,
    required this.quantities,
    this.batchNumber,
    this.mfgDate,
    this.expireDate,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'productDealerPrice': productDealerPrice,
        'productPurchasePrice': productPurchasePrice,
        'productSalePrice': productSalePrice,
        'productWholeSalePrice': productWholeSalePrice,
        'quantities': quantities,
        'batch_no': batchNumber,
        'profit_percent': profitPercent,
        'expire_date': expireDate,
        'mfg_date': mfgDate,
      };
}

extension on PurchaseRepo {
  Future<void> _savePurchaseOffline({
    required WidgetRef ref,
    required BuildContext context,
    required num partyId,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num? vatId,
    required num totalAmount,
    required num vatAmount,
    required num vatPercent,
    required num dueAmount,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required List<CartProductModelPurchase> products,
    required String discountType,
    required num shippingCharge,
  }) async {
    try {
      final purchaseData = {
        'party_id': partyId,
        'vat_id': vatId,
        'purchase_date': purchaseDate,
        'discount_amount': discountAmount,
        'discount_percent': discountPercent,
        'total_amount': totalAmount,
        'vat_amount': vatAmount,
        'vat_percent': vatPercent,
        'due_amount': dueAmount,
        'change_amount': changeAmount,
        'is_paid': isPaid ? 1 : 0,
        'payment_type': paymentType,
        'discount_type': discountType,
        'shipping_charge': shippingCharge,
        'products': jsonEncode(products.map((e) => e.toJson()).toList()),
      };

      await _dbHelper.saveOfflinePurchase(purchaseData);

      await _dbHelper.upsertCachedListItem(
        PurchaseRepo._cacheKey,
        _offlinePurchaseDisplay(
          partyId: partyId,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          discountPercent: discountPercent,
          vatId: vatId,
          totalAmount: totalAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          dueAmount: dueAmount,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
          products: products,
          discountType: discountType,
          shippingCharge: shippingCharge,
        ),
      );

      ref.invalidate(productProvider);
      ref.invalidate(partiesProvider);
      ref.invalidate(purchaseTransactionProvider);
    } catch (_) {}
  }

  Future<List<PurchaseTransaction>> _getOfflinePurchases() async {
    final rows = await _dbHelper.getUnsyncedPurchases();
    return rows.map(_offlinePurchaseToModel).toList();
  }

  PurchaseTransaction _offlinePurchaseToModel(Map<String, dynamic> row) {
    final productsJson = row['products'] as String?;
    final details = <PurchaseDetails>[];
    if (productsJson != null) {
      try {
        final list = jsonDecode(productsJson) as List<dynamic>;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          details.add(PurchaseDetails(
            productId: map['product_id'],
            productPurchasePrice: map['productPurchasePrice'],
            quantities: map['quantities'],
            productSalePrice: map['productSalePrice'],
            productDealerPrice: map['productDealerPrice'],
            productWholeSalePrice: map['productWholeSalePrice'],
          ));
        }
      } catch (_) {}
    }
    final localId = row['id'] as int?;
    return PurchaseTransaction()
      ..id = localId != null ? -localId : null
      ..partyId = row['party_id']
      ..party = Party(id: row['party_id'], name: 'Guest')
      ..purchaseDate = row['purchase_date']
      ..discountAmount = row['discount_amount']
      ..discountPercent = row['discount_percent']
      ..totalAmount = row['total_amount']
      ..dueAmount = row['due_amount']
      ..vatAmount = row['vat_amount']
      ..vatPercent = row['vat_percent']
      ..vatId = row['vat_id']
      ..changeAmount = row['change_amount']
      ..isPaid = (row['is_paid'] == 1)
      ..paymentTypeId = int.tryParse(row['payment_type']?.toString() ?? '')
      ..discountType = row['discount_type']
      ..shippingCharge = row['shipping_charge']
      ..invoiceNumber = localId?.toString()
      ..details = details;
  }

  List<PurchaseTransaction> _mergePurchases(
    List<PurchaseTransaction> online,
    List<PurchaseTransaction> offline, {
    bool? purchaseReturn,
  }) {
    final merged = <PurchaseTransaction>[...offline, ...online];
    if (purchaseReturn ?? false) {
      return merged.where((p) => p.purchaseReturns != null && p.purchaseReturns!.isNotEmpty).toList();
    }
    return merged;
  }

  Map<String, dynamic> _offlinePurchaseDisplay({
    required num partyId,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num? vatId,
    required num totalAmount,
    required num vatAmount,
    required num vatPercent,
    required num dueAmount,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required List<CartProductModelPurchase> products,
    required String discountType,
    required num shippingCharge,
  }) {
    final id = -DateTime.now().millisecondsSinceEpoch;
    return {
      'id': id,
      'party_id': partyId,
      'purchaseDate': purchaseDate,
      'discountAmount': discountAmount,
      'discount_percent': discountPercent,
      'totalAmount': totalAmount,
      'dueAmount': dueAmount,
      'vat_amount': vatAmount,
      'vat_percent': vatPercent,
      'vat_id': vatId,
      'change_amount': changeAmount,
      'isPaid': isPaid,
      'payment_type_id': paymentType,
      'discount_type': discountType,
      'shipping_charge': shippingCharge,
      'details': products.map((e) => e.toJson()).toList(),
      'invoiceNumber': id.toString(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _updatePurchaseCache({
    required num id,
    required num partyId,
    required String purchaseDate,
    required num discountAmount,
    required num totalAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
  }) async {
    final item = {
      'id': id,
      'party_id': partyId,
      'purchaseDate': purchaseDate,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'dueAmount': dueAmount,
      'vat_amount': vatAmount,
      'vat_percent': vatPercent,
      'change_amount': changeAmount,
      'isPaid': isPaid,
      'payment_type_id': paymentType,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _dbHelper.upsertCachedListItem(PurchaseRepo._cacheKey, item);
  }
}
