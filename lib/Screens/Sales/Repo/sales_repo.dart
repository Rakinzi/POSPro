import 'dart:convert';
import 'dart:io';

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
import '../../../model/sale_transaction_model.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../../../Database/database_helper.dart';
import '../../../Services/connectivity_service.dart';

class SaleRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<List<SalesTransactionModel>> fetchSalesList({bool? salesReturn}) async {
    final isConnected = await _connectivityService.checkConnectivity();
    final uri = Uri.parse('${APIConfig.url}/sales${(salesReturn ?? false) ? "?returned-sales=true" : ''}');

    if (isConnected) {
      try {
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        });

        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
          final partyList = parsedData['data'] as List<dynamic>;
          final saleMaps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.upsertCachedSales(saleMaps);
          final onlineSales = saleMaps.map((category) => SalesTransactionModel.fromJson(category)).toList();
          final offlineSales = await _getOfflineSales();
          return _mergeSales(onlineSales, offlineSales, salesReturn: salesReturn);
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cachedSales = await _getCachedSales();
    final offlineSales = await _getOfflineSales();
    return _mergeSales(cachedSales, offlineSales, salesReturn: salesReturn);
  }

  Future<SalesTransactionModel?> createSale({
    required WidgetRef ref,
    required BuildContext context,
    required num? partyId,
    required String? customerPhone,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num unRoundedTotalAmount,
    required num totalAmount,
    required num roundingAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num? vatId,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required String roundedOption,
    required List<CartSaleProducts> products,
    required String discountType,
    required num shippingCharge,
    String? note,
    File? image,
  }) async {
    // Check internet connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    if (!context.mounted) return null;

    if (!isConnected) {
      // Save to offline database
      try {
        final saleData = {
          'party_id': partyId,
          'customer_phone': customerPhone,
          'sale_date': purchaseDate,
          'discount_amount': discountAmount,
          'discount_percent': discountPercent,
          'total_amount': totalAmount,
          'due_amount': dueAmount,
          'vat_amount': vatAmount,
          'vat_percent': vatPercent,
          'vat_id': vatId,
          'change_amount': changeAmount,
          'is_paid': isPaid ? 1 : 0,
          'payment_type': paymentType,
          'rounded_option': roundedOption,
          'rounding_amount': roundingAmount,
          'unrounded_total_amount': unRoundedTotalAmount,
          'discount_type': discountType,
          'shipping_charge': shippingCharge,
          'note': note,
          'products': jsonEncode(products.map((e) => e.toJson()).toList()),
          'image_path': image?.path,
        };

        await _dbHelper.saveOfflineSale(saleData);

        if (!context.mounted) return null;

        // Still invalidate providers to refresh UI
        ref.invalidate(productProvider);
        ref.invalidate(partiesProvider);
        ref.invalidate(salesTransactionProvider);

        return null;
      } catch (e) {
        EasyLoading.dismiss();
        if (!context.mounted) return null;
        return null;
      }
    }

    final uri = Uri.parse('${APIConfig.url}/sales');

    try {
      var request = http.MultipartRequest("POST", uri);

      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), ref: ref, context: context);
      request.headers.addAll({
        "Accept": 'application/json',
        'Authorization': await getAuthToken(),
        'Content-Type': 'multipart/form-data',
      });

      // JSON data fields
      request.fields.addAll({
        'party_id': partyId?.toString() ?? '',
        'customer_phone': customerPhone ?? '',
        'saleDate': purchaseDate,
        'discountAmount': discountAmount.toString(),
        'discount_percent': discountPercent.toString(),
        'totalAmount': totalAmount.toString(),
        'dueAmount': dueAmount.toString(),
        'paidAmount': (totalAmount - dueAmount).toString(),
        'change_amount': changeAmount.toString(),
        'vat_amount': vatAmount.toString(),
        'vat_percent': vatPercent.toString(),
        'isPaid': isPaid.toString(),
        'payment_type_id': paymentType,
        'discount_type': discountType,
        'shipping_charge': shippingCharge.toString(),
        'rounding_option': roundedOption,
        'rounding_amount': roundingAmount.toStringAsFixed(2),
        'actual_total_amount': unRoundedTotalAmount.toString(),
        'note': note ?? '',
        'products': jsonEncode(
          products.map((product) => product.toJson()).toList(),
        ),
      });
      if (vatId != null) {
        request.fields.addAll({
          'vat_id': vatId.toString(),
        });
      }
      // If an image is provided, attach it to the request
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var streamedResponse = await customHttpClient.uploadFile(url: uri, file: image, fileFieldName: 'image', fields: request.fields, countentType: 'multipart/form-data');
      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      debugPrint('Sales Post: ${response.statusCode}');
      debugPrint('Sales Post: ${response.body}');

      if (response.statusCode == 200) {
        ref.invalidate(productProvider);
        ref.invalidate(partiesProvider);
        ref.invalidate(salesTransactionProvider);
        ref.invalidate(businessInfoProvider);
        ref.invalidate(getExpireDateProvider(ref));
        ref.invalidate(summaryInfoProvider);
        debugPrint('${parsedData['data']}');
        final data = SalesTransactionModel.fromJson(parsedData['data']);
        return data;
      } else if (response.statusCode >= 500) {
        await _saveSaleOffline(
          context: context,
          ref: ref,
          partyId: partyId,
          customerPhone: customerPhone,
          purchaseDate: purchaseDate,
          discountAmount: discountAmount,
          discountPercent: discountPercent,
          unRoundedTotalAmount: unRoundedTotalAmount,
          totalAmount: totalAmount,
          roundingAmount: roundingAmount,
          dueAmount: dueAmount,
          vatAmount: vatAmount,
          vatPercent: vatPercent,
          vatId: vatId,
          changeAmount: changeAmount,
          isPaid: isPaid,
          paymentType: paymentType,
          roundedOption: roundedOption,
          products: products,
          discountType: discountType,
          shippingCharge: shippingCharge,
          note: note,
          image: image,
          errorMessage: 'Upload failed. Saved offline and will sync when online.',
        );
        return null;
      } else {
        EasyLoading.dismiss();
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sales creation failed: ${parsedData['message']}',
            ),
          ),
        );
        return null;
      }
    } catch (error) {
      await _saveSaleOffline(
        context: context,
        ref: ref,
        partyId: partyId,
        customerPhone: customerPhone,
        purchaseDate: purchaseDate,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
        unRoundedTotalAmount: unRoundedTotalAmount,
        totalAmount: totalAmount,
        roundingAmount: roundingAmount,
        dueAmount: dueAmount,
        vatAmount: vatAmount,
        vatPercent: vatPercent,
        vatId: vatId,
        changeAmount: changeAmount,
        isPaid: isPaid,
        paymentType: paymentType,
        roundedOption: roundedOption,
        products: products,
        discountType: discountType,
        shippingCharge: shippingCharge,
        note: note,
        image: image,
        errorMessage: 'Upload failed. Saved offline and will sync when online.',
      );
      return null;
    }
  }

  Future<void> updateSale({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required num? partyId,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num unRoundedTotalAmount,
    required num totalAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num? vatId,
    required num changeAmount,
    required num roundingAmount,
    required bool isPaid,
    required String paymentType,
    required String roundedOption,
    required List<CartSaleProducts> products,
    required String discountType,
    required num shippingCharge,
    String? note,
    File? image,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/sales/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = await getAuthToken()
      ..headers['Content-Type'] = 'application/json'
      ..fields['_method'] = 'put'
      ..fields['party_id'] = partyId.toString()
      ..fields['saleDate'] = purchaseDate
      ..fields['discountAmount'] = discountAmount.toString()
      ..fields['discount_percent'] = discountPercent.toString()
      ..fields['totalAmount'] = totalAmount.toString()
      ..fields['dueAmount'] = dueAmount.toString()
      ..fields['paidAmount'] = (totalAmount - dueAmount).toString()
      ..fields['change_amount'] = changeAmount.toString()
      ..fields['vat_amount'] = vatAmount.toString()
      ..fields['vat_percent'] = vatPercent.toString()
      ..fields['isPaid'] = isPaid.toString()
      ..fields['payment_type_id'] = paymentType
      ..fields['discount_type'] = discountType
      ..fields['shipping_charge'] = shippingCharge.toString()
      ..fields['note'] = note ?? ''
      ..fields['rounding_option'] = roundedOption
      ..fields['rounding_amount'] = roundingAmount.toStringAsFixed(2)
      ..fields['actual_total_amount'] = unRoundedTotalAmount.toString();

    // Convert the list of products to a JSON string
    String productJson = jsonEncode(products.map((product) => product.toJson()).toList());
    request.fields['products'] = productJson;

    if (vatId != null) {
      request.fields.addAll({'vat_id': vatId.toString()});
    }

    // Add image if it exists
    if (image != null) {
      var imageFile = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(imageFile);
    }

    try {
      var response = await customHttpClient.uploadFile(url: uri, fields: request.fields, fileFieldName: 'image', file: image);
      var responseData = await http.Response.fromStream(response);
      final parsedData = jsonDecode(responseData.body);
      debugPrint('SalesUpdate: ${responseData.statusCode}');
      debugPrint('SalesUpdate: $parsedData');
      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Added successful!');
        if (!context.mounted) return;
        ref.read(productProvider);
        ref.read(partiesProvider);
        ref.read(salesTransactionProvider);
        ref.read(businessInfoProvider);
        ref.read(getExpireDateProvider(ref));
        Navigator.pop(context);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sales creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }
}

extension on SaleRepo {
  Future<List<SalesTransactionModel>> _getCachedSales() async {
    final rows = await _dbHelper.getCachedSales();
    final sales = <SalesTransactionModel>[];
    for (final row in rows) {
      final data = row['data'] as String?;
      if (data == null) continue;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        sales.add(SalesTransactionModel.fromJson(json));
      } catch (_) {}
    }
    return sales;
  }

  Future<List<SalesTransactionModel>> _getOfflineSales() async {
    final rows = await _dbHelper.getUnsyncedSales();
    return rows.map(_offlineSaleToModel).toList();
  }

  SalesTransactionModel _offlineSaleToModel(Map<String, dynamic> row) {
    final productsJson = row['products'] as String?;
    final salesDetails = <SalesDetails>[];
    if (productsJson != null) {
      try {
        final list = jsonDecode(productsJson) as List<dynamic>;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final productName = map['product_name']?.toString() ?? 'Item';
          final details = SalesDetails(
            stockId: map['stock_id'],
            price: map['price'],
            lossProfit: map['lossProfit'],
            quantities: map['quantities'],
            product: SalesProduct(productName: productName),
          );
          salesDetails.add(details);
        }
      } catch (_) {}
    }
    final localId = row['id'] as int?;
    return SalesTransactionModel()
      ..id = localId != null ? -localId : null
      ..partyId = row['party_id']
      ..party = SalesParty(id: row['party_id'], name: 'Guest', type: 'Guest')
      ..saleDate = row['sale_date']
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
      ..roundingOption = row['rounded_option']
      ..roundingAmount = row['rounding_amount']
      ..actualTotalAmount = row['unrounded_total_amount']
      ..invoiceNumber = localId?.toString()
      ..salesDetails = salesDetails
      ..meta = Meta(customerPhone: row['customer_phone'], note: row['note'])
      ..image = row['image_path'];
  }

  List<SalesTransactionModel> _mergeSales(List<SalesTransactionModel> online, List<SalesTransactionModel> offline, {bool? salesReturn}) {
    final merged = <SalesTransactionModel>[...offline, ...online];
    if (salesReturn ?? false) {
      return merged.where((sale) => sale.salesReturns != null && sale.salesReturns!.isNotEmpty).toList();
    }
    return merged;
  }

  Future<void> _saveSaleOffline({
    required WidgetRef ref,
    required BuildContext context,
    required num? partyId,
    required String? customerPhone,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num unRoundedTotalAmount,
    required num totalAmount,
    required num roundingAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num? vatId,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required String roundedOption,
    required List<CartSaleProducts> products,
    required String discountType,
    required num shippingCharge,
    String? note,
    File? image,
    String? errorMessage,
  }) async {
    try {
      final saleData = {
        'party_id': partyId,
        'customer_phone': customerPhone,
        'sale_date': purchaseDate,
        'discount_amount': discountAmount,
        'discount_percent': discountPercent,
        'total_amount': totalAmount,
        'due_amount': dueAmount,
        'vat_amount': vatAmount,
        'vat_percent': vatPercent,
        'vat_id': vatId,
        'change_amount': changeAmount,
        'is_paid': isPaid ? 1 : 0,
        'payment_type': paymentType,
        'rounded_option': roundedOption,
        'rounding_amount': roundingAmount,
        'unrounded_total_amount': unRoundedTotalAmount,
        'discount_type': discountType,
        'shipping_charge': shippingCharge,
        'note': note,
        'products': jsonEncode(products.map((e) => e.toJson()).toList()),
        'image_path': image?.path,
      };
      await _dbHelper.saveOfflineSale(saleData);

      EasyLoading.dismiss();

      ref.invalidate(productProvider);
      ref.invalidate(partiesProvider);
      ref.invalidate(salesTransactionProvider);
    } catch (e) {
      EasyLoading.dismiss();
    }
  }
}

class CartSaleProducts {
  final int stockId;
  final num? price;
  final String productName;
  final num? lossProfit;
  final num? quantities;

  CartSaleProducts({
    required this.productName,
    required this.stockId,
    required this.price,
    required this.quantities,
    required this.lossProfit,
  });

  Map<String, dynamic> toJson() => {
        'stock_id': stockId,
        'product_name': productName,
        'price': price,
        'lossProfit': lossProfit,
        'quantities': quantities,
      };
}
