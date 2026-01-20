//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_total_stock_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Database/database_helper.dart';
import '../../../Repository/constant_functions.dart';
import '../../../Services/connectivity_service.dart';
import '../../../http_client/custome_http_client.dart';
import '../../Purchase/Repo/purchase_repo.dart';
import '../Model/product_model.dart';
import '../add_product.dart';

class ProductRepo {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<List<ProductModel>> fetchAllProducts() async {
    final uri = Uri.parse('${APIConfig.url}/products');
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
          final productMaps = partyList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.upsertCachedProducts(productMaps);
          final onlineProducts = productMaps.map((category) => ProductModel.fromJson(category)).toList();
          final offlineProducts = await _getOfflineProducts();
          return _mergeProducts(onlineProducts, offlineProducts);
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cachedProducts = await _getCachedProducts();
    final offlineProducts = await _getOfflineProducts();
    return _mergeProducts(cachedProducts, offlineProducts);
  }

  Future<ProductListResponse> fetchProducts() async {
    final uri = Uri.parse('${APIConfig.url}/products');
    final isConnected = await _connectivityService.checkConnectivity();

    if (isConnected) {
      try {
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        });

        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body);
          final data = parsedData['data'] as List<dynamic>;
          final productMaps = data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          await _dbHelper.upsertCachedProducts(productMaps);
          if (parsedData['total_stock_value'] != null) {
            await _dbHelper.setCachedMeta('products_total_stock_value', parsedData['total_stock_value'].toString());
          }
          return ProductListResponse.fromJson(parsedData);
        }
      } catch (_) {
        // Fall through to cached data
      }
    }

    final cachedProducts = await _getCachedProducts();
    final offlineProducts = await _getOfflineProducts();
    final totalStockValue = await _getCachedTotalStockValue();
    return ProductListResponse(
      totalStockValue: totalStockValue,
      products: _mergeProducts(cachedProducts, offlineProducts),
    );
  }

  // Fetch Product Details
  Future<ProductModel> fetchProductDetails({required String productID}) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/products/$productID');
    final headers = {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    };
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        final cached = await _findCachedProduct(productID);
        if (cached != null) return cached;
      }
      var response = await http.get(url, headers: headers);
      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to fetch details');
        throw Exception(data['message'] ?? 'Failed to fetch details');
      }
    } catch (e) {
      // Hide loading indicator and show error
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<bool> createProduct({required CreateProductModel data}) async {
    EasyLoading.show(status: 'Creating Product...');
    final url = Uri.parse('${APIConfig.url}/products');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    void addField(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
        request.fields[key] = value.toString();
      }
    }

    // Add standard fields
    addField('productName', data.name);
    addField('category_id', data.categoryId);
    addField('brand_id', data.brandId);
    addField('productCode', data.productCode);
    addField('unit_id', data.unitId);
    addField('productManufacturer', data.productManufacturer);
    addField('productDiscount', data.productDiscount);
    addField('vat_id', data.vatId);
    addField('vat_type', data.vatType);
    addField('vat_amount', data.vatAmount);
    addField('alert_qty', data.alertQty);
    addField('model_id', data.modelId);
    addField('product_type', data.productType);
    addField('size', data.size);
    addField('color', data.color);
    addField('weight', data.weight);
    addField('capacity', data.capacity);
    addField('type', data.type);

    if (data.productType?.toLowerCase() == 'single') {
      // For single products
      addField('productStock', data.productSingleStock);
      addField('productPurchasePrice', data.productPurchasePrice);
      addField('productSalePrice', data.productSalePrice);
      addField('productWholeSalePrice', data.productWholeSalePrice);
      addField('productDealerPrice', data.productDealerPrice);
      addField('profit_percent', data.profitPercent);
      addField('expire_date', data.expDate);
      addField('mfg_date', data.mfgDate);
    } else {
      // Batch numbers
      if (data.batchNo?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchNo!.length; index++) {
          request.fields['batch_no[$index]'] = data.batchNo![index];
        }
      }

      // Product stock
      if (data.productStock?.isNotEmpty ?? false) {
        for (int index = 0; index < data.productStock!.length; index++) {
          request.fields['productStock[$index]'] = data.productStock![index];
        }
      }

      // Purchase prices
      if (data.batchPurchasePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchPurchasePrice!.length; index++) {
          request.fields['productPurchasePrice[$index]'] = data.batchPurchasePrice![index];
        }
      }

      // Profit percentages
      if (data.batchProfitPercent?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchProfitPercent!.length; index++) {
          request.fields['profit_percent[$index]'] = data.batchProfitPercent![index];
        }
      }

      // Sale prices
      if (data.batchSalePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchSalePrice!.length; index++) {
          request.fields['productSalePrice[$index]'] = data.batchSalePrice![index];
        }
      }

      // Wholesale prices
      if (data.batchWholeSalePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchWholeSalePrice!.length; index++) {
          request.fields['productWholeSalePrice[$index]'] = data.batchWholeSalePrice![index];
        }
      }

      // Dealer prices
      if (data.batchDealerPrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchDealerPrice!.length; index++) {
          request.fields['productDealerPrice[$index]'] = data.batchDealerPrice![index];
        }
      }

      // Expire dates
      if (data.batchExpireDate?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchExpireDate!.length; index++) {
          request.fields['expire_date[$index]'] = data.batchExpireDate![index];
        }
      }

      // Manufacturing dates
      if (data.batchMfgDate?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchMfgDate!.length; index++) {
          request.fields['mfg_date[$index]'] = data.batchMfgDate![index];
        }
      }
    }

    debugPrint('--- Product Data Fields ---');
    debugPrint('Total fields: ${request.fields.length}');
    request.fields.forEach((key, value) {
      debugPrint('$key: $value');
    });

    if (data.image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'productPicture',
        data.image!.path,
        filename: data.image!.path.split('/').last,
      ));
      debugPrint('Image attached: ${data.image!.path}');
    }

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _saveProductOffline(data: data, fields: request.fields);
        return true;
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${responseData.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showSuccess(body['message'] ?? 'Product created successfully!');
          return true;
        } catch (e) {
          EasyLoading.showSuccess('Product created successfully!');
          return true;
        }
      } else if (response.statusCode >= 500) {
        await _saveProductOffline(data: data, fields: request.fields);
        return true;
      } else {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showError(body['message'] ?? 'Failed to create product');
          debugPrint('Error Response: ${responseData.body}');
        } catch (e) {
          EasyLoading.showError('Failed to create product. Status: ${response.statusCode}');
          debugPrint('Error Response (non-JSON): ${responseData.body}');
        }
        return false;
      }
    } catch (e) {
      await _saveProductOffline(data: data, fields: request.fields);
      debugPrint('Network Error: ${e.toString()}');
      return true;
    }
  }

  Future<void> addProduct({
    required WidgetRef ref,
    required BuildContext context,
    required String productName,
    required String categoryId,
    required String productCode,
    required String productStock,
    required String productSalePrice,
    required String productPurchasePrice,
    File? image,
    String? size,
    String? color,
    String? weight,
    String? capacity,
    String? type,
    String? brandId,
    String? unitId,
    String? productWholeSalePrice,
    String? productDealerPrice,
    String? productManufacturer,
    String? productDiscount,
    String? vatId,
    String? vatType,
    String? vatAmount,
    String? profitMargin,
    String? lowStock,
    String? expDate,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/products');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();
    request.fields.addAll({
      "productName": productName,
      "category_id": categoryId,
      "productCode": productCode,
      "productStock": productStock,
      "productSalePrice": productSalePrice,
      "productPurchasePrice": productPurchasePrice,
    });
    if (size != null) request.fields['size'] = size;
    if (color != null) request.fields['color'] = color;
    if (weight != null) request.fields['weight'] = weight;
    if (capacity != null) request.fields['capacity'] = capacity;
    if (type != null) request.fields['type'] = type;
    if (brandId != null) request.fields['brand_id'] = brandId.toString();
    if (unitId != null) request.fields['unit_id'] = unitId;
    if (vatId != null) request.fields['vat_id'] = vatId;
    if (vatType != null) request.fields['vat_type'] = vatType;
    if (vatAmount != null) request.fields['vat_amount'] = vatAmount;
    if (profitMargin != null) request.fields['profit_percent'] = profitMargin;
    if (productWholeSalePrice != null) request.fields['productWholeSalePrice'] = productWholeSalePrice;
    if (productDealerPrice != null) request.fields['productDealerPrice'] = productDealerPrice;
    if (productManufacturer != null) request.fields['productManufacturer'] = productManufacturer;
    if (productDiscount != null) request.fields['productDiscount'] = productDiscount;
    if (image != null) {
      request.files.add(http.MultipartFile.fromBytes('productPicture', image.readAsBytesSync(), filename: image.path));
    }
    if (lowStock != null) request.fields['alert_qty'] = lowStock;
    if (expDate != null) request.fields['expire_date'] = expDate;

    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await _saveProductOfflineFromFields(
        fields: request.fields,
        imagePath: image?.path,
        displayName: productName,
        productCode: productCode,
        productStock: productStock,
        productSalePrice: productSalePrice,
        productPurchasePrice: productPurchasePrice,
      );
      ref.invalidate(productProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    final response = await customHttpClient.uploadFile(url: uri, file: image, fileFieldName: 'productPicture', fields: request.fields);
    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
      ref.invalidate(productProvider);

      if (!context.mounted) return;
      Navigator.pop(context);
    } else if (response.statusCode >= 500) {
      await _saveProductOfflineFromFields(
        fields: request.fields,
        imagePath: image?.path,
        displayName: productName,
        productCode: productCode,
        productStock: productStock,
        productSalePrice: productSalePrice,
        productPurchasePrice: productPurchasePrice,
      );
      ref.invalidate(productProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product creation failed: ${parsedData['message']}')));
    }
  }

  Future<bool> addForBulkUpload({
    required String productName,
    required String categoryId,
    required String productCode,
    required String productStock,
    required String productSalePrice,
    required String productPurchasePrice,
    File? image,
    String? size,
    String? color,
    String? weight,
    String? capacity,
    String? type,
    String? brandId,
    String? unitId,
    String? productWholeSalePrice,
    String? productDealerPrice,
    String? productManufacturer,
    String? productDiscount,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/products');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();
    request.fields.addAll({
      "productName": productName,
      "category_id": categoryId,
      "productCode": productCode,
      "productStock": productStock,
      "productSalePrice": productSalePrice,
      "productPurchasePrice": productPurchasePrice,
    });
    if (size != null) request.fields['size'] = size;
    if (color != null) request.fields['color'] = color;
    if (weight != null) request.fields['weight'] = weight;
    if (capacity != null) request.fields['capacity'] = capacity;
    if (type != null) request.fields['type'] = type;
    if (brandId != null) request.fields['brand_id'] = brandId.toString();
    if (unitId != null) request.fields['unit_id'] = unitId;
    if (productWholeSalePrice != null) request.fields['productWholeSalePrice'] = productWholeSalePrice;
    if (productDealerPrice != null) request.fields['productDealerPrice'] = productDealerPrice;
    if (productManufacturer != null) request.fields['productManufacturer'] = productManufacturer;
    if (productDiscount != null) request.fields['productDiscount'] = productDiscount;
    if (image != null) {
      request.files.add(http.MultipartFile.fromBytes('productPicture', image.readAsBytesSync(), filename: image.path));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<void> deleteProduct({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/products/$id';

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));

        ref.invalidate(productProvider);
      } else {
        if (!context.mounted) return;
        final parsedData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: ${parsedData['message']}')));
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Future<void> updateProduct({
  //   required String productId,
  //   required WidgetRef ref,
  //   required BuildContext context,
  //   required String productName,
  //   required String productCode,
  //   String? categoryId,
  //   required String productSalePrice,
  //   required String productPurchasePrice,
  //   File? image,
  //   String? size,
  //   String? color,
  //   String? weight,
  //   String? capacity,
  //   String? type,
  //   String? brandId,
  //   String? unitId,
  //   String? productWholeSalePrice,
  //   String? productDealerPrice,
  //   String? productManufacturer,
  //   String? productDiscount,
  //   String? productStock,
  //   String? vatId,
  //   String? vatType,
  //   String? vatAmount,
  //   String? profitMargin,
  //   String? lowStock,
  //   String? expDate,
  // }) async {
  //   final uri = Uri.parse('${APIConfig.url}/products/$productId');
  //   CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
  //
  //   var request = http.MultipartRequest('POST', uri)
  //     ..headers['Accept'] = 'application/json'
  //     ..headers['Authorization'] = await getAuthToken();
  //
  //   request.fields['_method'] = 'put';
  //   request.fields.addAll({
  //     "productName": productName,
  //     "productCode": productCode,
  //     "productSalePrice": productSalePrice,
  //     "productPurchasePrice": productPurchasePrice,
  //   });
  //
  //   if (size != null) request.fields['size'] = size;
  //   if (color != null) request.fields['color'] = color;
  //   if (weight != null) request.fields['weight'] = weight;
  //   if (capacity != null) request.fields['capacity'] = capacity;
  //   if (type != null) request.fields['type'] = type;
  //   request.fields['brand_id'] = brandId != null ? brandId.toString() : '';
  //   request.fields['unit_id'] = unitId != null ? unitId.toString() : '';
  //   if (categoryId != null) request.fields['category_id'] = categoryId;
  //   if (vatId != null) request.fields['vat_id'] = vatId;
  //   if (vatType != null) request.fields['vat_type'] = vatType;
  //   if (vatAmount != null) request.fields['vat_amount'] = vatAmount;
  //   if (profitMargin != null) request.fields['profit_percent'] = profitMargin;
  //   if (productWholeSalePrice != null) request.fields['productWholeSalePrice'] = productWholeSalePrice;
  //   if (productDealerPrice != null) request.fields['productDealerPrice'] = productDealerPrice;
  //   if (productManufacturer != null) request.fields['productManufacturer'] = productManufacturer;
  //   if (productDiscount != null) request.fields['productDiscount'] = productDiscount;
  //   if (productStock != null) request.fields['productStock'] = productStock;
  //   if (image != null) {
  //     request.files.add(http.MultipartFile.fromBytes('productPicture', image.readAsBytesSync(), filename: image.path));
  //   }
  //   if (lowStock != null) request.fields['alert_qty'] = lowStock;
  //   if (expDate != null) request.fields['expire_date'] = expDate;
  //
  //   debugPrint('Update response : ${request.fields}');
  //   final response = await customHttpClient.uploadFile(
  //     url: uri,
  //     file: image,
  //     fileFieldName: 'productPicture',
  //     fields: request.fields,
  //   );
  //   final responseData = await response.stream.bytesToString();
  //
  //   final parsedData = jsonDecode(responseData);
  //
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated Successfully!')));
  //     var data1 = ref.refresh(productProvider);
  //
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product Update failed: ${parsedData['message']}')));
  //   }
  // }

  Future<bool> updateProduct({required CreateProductModel data}) async {
    EasyLoading.show(status: 'Updating Product...');
    final url = Uri.parse('${APIConfig.url}/products/${data.productId}');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    void addField(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
        request.fields[key] = value.toString();
      }
    }

    // Add standard fields
    addField('_method', 'put');
    addField('productName', data.name);
    addField('category_id', data.categoryId);
    addField('brand_id', data.brandId);
    addField('productCode', data.productCode);
    addField('unit_id', data.unitId);
    addField('productManufacturer', data.productManufacturer);
    addField('productDiscount', data.productDiscount);
    addField('vat_id', data.vatId);
    addField('vat_type', data.vatType);
    addField('vat_amount', data.vatAmount);
    addField('alert_qty', data.alertQty);
    addField('model_id', data.modelId);
    addField('product_type', data.productType);
    addField('size', data.size);
    addField('color', data.color);
    addField('weight', data.weight);
    addField('capacity', data.capacity);
    addField('type', data.type);

    if (data.productType?.toLowerCase() == 'single') {
      // For single products
      addField('productStock', data.productSingleStock);
      addField('productPurchasePrice', data.productPurchasePrice);
      addField('productSalePrice', data.productSalePrice);
      addField('productWholeSalePrice', data.productWholeSalePrice);
      addField('productDealerPrice', data.productDealerPrice);
      addField('profit_percent', data.profitPercent);
      addField('expire_date', data.expDate);
      addField('mfg_date', data.mfgDate);
    } else {
      // Batch numbers
      if (data.batchNo?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchNo!.length; index++) {
          request.fields['batch_no[$index]'] = data.batchNo![index];
        }
      }

      // Product stock
      if (data.productStock?.isNotEmpty ?? false) {
        for (int index = 0; index < data.productStock!.length; index++) {
          request.fields['productStock[$index]'] = data.productStock![index];
        }
      }

      // Purchase prices
      if (data.batchPurchasePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchPurchasePrice!.length; index++) {
          request.fields['productPurchasePrice[$index]'] = data.batchPurchasePrice![index];
        }
      }

      // Profit percentages
      if (data.batchProfitPercent?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchProfitPercent!.length; index++) {
          request.fields['profit_percent[$index]'] = data.batchProfitPercent![index];
        }
      }

      // Sale prices
      if (data.batchSalePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchSalePrice!.length; index++) {
          request.fields['productSalePrice[$index]'] = data.batchSalePrice![index];
        }
      }

      // Wholesale prices
      if (data.batchWholeSalePrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchWholeSalePrice!.length; index++) {
          request.fields['productWholeSalePrice[$index]'] = data.batchWholeSalePrice![index];
        }
      }

      // Dealer prices
      if (data.batchDealerPrice?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchDealerPrice!.length; index++) {
          request.fields['productDealerPrice[$index]'] = data.batchDealerPrice![index];
        }
      }

      // Expire dates
      if (data.batchExpireDate?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchExpireDate!.length; index++) {
          request.fields['expire_date[$index]'] = data.batchExpireDate![index];
        }
      }

      // Manufacturing dates
      if (data.batchMfgDate?.isNotEmpty ?? false) {
        for (int index = 0; index < data.batchMfgDate!.length; index++) {
          request.fields['mfg_date[$index]'] = data.batchMfgDate![index];
        }
      }
    }

    debugPrint('--- Product Data Fields ---');
    debugPrint('Total fields: ${request.fields.length}');
    request.fields.forEach((key, value) {
      debugPrint('$key: $value');
    });

    if (data.image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'productPicture',
        data.image!.path,
        filename: data.image!.path.split('/').last,
      ));
      debugPrint('Image attached: ${data.image!.path}');
    }

    try {
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${responseData.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showSuccess(body['message'] ?? 'Product update successfully!');
          return true;
        } catch (e) {
          EasyLoading.showSuccess('Product update successfully!');
          return true;
        }
      } else {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showError(body['message'] ?? 'Failed to update product');
          debugPrint('Error Response: ${responseData.body}');
        } catch (e) {
          EasyLoading.showError('Failed to update product. Status: ${response.statusCode}');
          debugPrint('Error Response (non-JSON): ${responseData.body}');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Network Error: ${e.toString()}');
      debugPrint('Network Error: ${e.toString()}');
      return false;
    }
  }

  // add product stock from details
  Future<bool> addStock({required String id, required String qty}) async {
    final url = Uri.parse('${APIConfig.url}/stocks');
    String token = await getAuthToken();

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    final requestBody = jsonEncode({
      "stock_id": id,
      "productStock": qty,
    });

    try {
      final response = await http.post(url, headers: headers, body: requestBody);
      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateVariation({required CartProductModelPurchase data}) async {
    EasyLoading.show(status: 'Updating Product...');
    final url = Uri.parse('${APIConfig.url}/stocks/${data.stockId}');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    void addField(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
        request.fields[key] = value.toString();
      }
    }

    // Add standard fields
    addField('_method', 'put');
    addField('batch_no', data.batchNumber);
    addField('productStock', data.quantities);
    addField('productPurchasePrice', data.productPurchasePrice);
    addField('profit_percent', data.profitPercent);
    addField('productSalePrice', data.productSalePrice);
    addField('productWholeSalePrice', data.productWholeSalePrice);
    addField('productDealerPrice', data.productDealerPrice);
    addField('mfg_date', data.mfgDate);
    addField('expire_date', data.expireDate);

    debugPrint('--- Product Data Fields ---');
    debugPrint('Total fields: ${request.fields.length}');
    debugPrint(data.mfgDate);
    request.fields.forEach((key, value) {
      debugPrint('$key: $value');
    });

    try {
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${responseData.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showSuccess(body['message'] ?? 'Product update successfully!');
          return true;
        } catch (e) {
          EasyLoading.showSuccess('Product update successfully!');
          return true;
        }
      } else {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showError(body['message'] ?? 'Failed to update product');
          debugPrint('Error Response: ${responseData.body}');
        } catch (e) {
          EasyLoading.showError('Failed to update product. Status: ${response.statusCode}');
          debugPrint('Error Response (non-JSON): ${responseData.body}');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Network Error: ${e.toString()}');
      debugPrint('Network Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteStock({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/stocks/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      var response = await http.delete(
        url,
        headers: headers,
      );
      EasyLoading.dismiss();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
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

extension on ProductRepo {
  Future<List<ProductModel>> _getCachedProducts() async {
    final rows = await _dbHelper.getCachedProducts();
    final products = <ProductModel>[];
    for (final row in rows) {
      final data = row['data'] as String?;
      if (data == null) continue;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        products.add(ProductModel.fromJson(json));
      } catch (_) {}
    }
    return products;
  }

  Future<List<ProductModel>> _getOfflineProducts() async {
    final rows = await _dbHelper.getUnsyncedProducts();
    final products = <ProductModel>[];
    for (final row in rows) {
      final data = row['product_data'] as String?;
      if (data == null) continue;
      try {
        final payload = jsonDecode(data) as Map<String, dynamic>;
        final display = Map<String, dynamic>.from(payload['display'] ?? payload);
        display['id'] = -(row['id'] as int);
        display['productPicture'] ??= row['image_path'];
        products.add(ProductModel.fromJson(display));
      } catch (_) {}
    }
    return products;
  }

  List<ProductModel> _mergeProducts(List<ProductModel> online, List<ProductModel> offline) {
    final merged = <ProductModel>[...offline];
    final offlineIds = offline.map((p) => p.id).toSet();
    for (final product in online) {
      if (!offlineIds.contains(product.id)) {
        merged.add(product);
      }
    }
    return merged;
  }

  Future<double> _getCachedTotalStockValue() async {
    final value = await _dbHelper.getCachedMeta('products_total_stock_value');
    if (value == null) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  Future<ProductModel?> _findCachedProduct(String productID) async {
    final id = num.tryParse(productID);
    if (id == null) return null;
    final cached = await _getCachedProducts();
    final offline = await _getOfflineProducts();
    for (final product in [...offline, ...cached]) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> _saveProductOffline({
    required CreateProductModel data,
    required Map<String, String> fields,
  }) async {
    final display = _buildDisplayProduct(
      name: data.name,
      productCode: data.productCode,
      productType: data.productType,
      productSalePrice: data.productSalePrice ?? (data.batchSalePrice?.isNotEmpty ?? false ? data.batchSalePrice!.first : null),
      productPurchasePrice: data.productPurchasePrice ?? (data.batchPurchasePrice?.isNotEmpty ?? false ? data.batchPurchasePrice!.first : null),
      productStock: data.productSingleStock ?? (data.productStock?.isNotEmpty ?? false ? data.productStock!.first : null),
      productWholeSalePrice: data.productWholeSalePrice,
      productDealerPrice: data.productDealerPrice,
      alertQty: data.alertQty,
      vatId: data.vatId,
      vatAmount: data.vatAmount,
      vatType: data.vatType,
      size: data.size,
      color: data.color,
      weight: data.weight,
      capacity: data.capacity,
      productManufacturer: data.productManufacturer,
      imagePath: data.image?.path,
    );

    final payload = {
      'endpoint': '${APIConfig.url}/products',
      'method': 'POST',
      'fields': fields,
      'file_field': 'productPicture',
      'display': display,
    };

    await _dbHelper.saveOfflineProduct(jsonEncode(payload), imagePath: data.image?.path);
  }

  Future<void> _saveProductOfflineFromFields({
    required Map<String, String> fields,
    String? imagePath,
    String? displayName,
    String? productCode,
    String? productStock,
    String? productSalePrice,
    String? productPurchasePrice,
  }) async {
    final display = _buildDisplayProduct(
      name: displayName,
      productCode: productCode,
      productType: fields['product_type'],
      productSalePrice: productSalePrice,
      productPurchasePrice: productPurchasePrice,
      productStock: productStock,
      alertQty: fields['alert_qty'],
      vatId: fields['vat_id'],
      vatAmount: fields['vat_amount'],
      vatType: fields['vat_type'],
      size: fields['size'],
      color: fields['color'],
      weight: fields['weight'],
      capacity: fields['capacity'],
      productManufacturer: fields['productManufacturer'],
      imagePath: imagePath,
    );

    final payload = {
      'endpoint': '${APIConfig.url}/products',
      'method': 'POST',
      'fields': fields,
      'file_field': 'productPicture',
      'display': display,
    };

    await _dbHelper.saveOfflineProduct(jsonEncode(payload), imagePath: imagePath);
  }

  Map<String, dynamic> _buildDisplayProduct({
    String? name,
    String? productCode,
    String? productType,
    dynamic productSalePrice,
    dynamic productPurchasePrice,
    dynamic productStock,
    dynamic productWholeSalePrice,
    dynamic productDealerPrice,
    dynamic alertQty,
    dynamic vatId,
    dynamic vatAmount,
    dynamic vatType,
    dynamic size,
    dynamic color,
    dynamic weight,
    dynamic capacity,
    dynamic productManufacturer,
    String? imagePath,
  }) {
    final stockEntry = {
      'productSalePrice': productSalePrice,
      'productPurchasePrice': productPurchasePrice,
      'productStock': productStock,
    };

    return {
      'productName': name,
      'productCode': productCode,
      'product_type': productType ?? 'single',
      'productSalePrice': productSalePrice,
      'productPurchasePrice': productPurchasePrice,
      'productWholeSalePrice': productWholeSalePrice,
      'productDealerPrice': productDealerPrice,
      'stocks_sum_product_stock': productStock,
      'alert_qty': alertQty,
      'vat_id': vatId,
      'vat_amount': vatAmount,
      'vat_type': vatType,
      'size': size,
      'color': color,
      'weight': weight,
      'capacity': capacity,
      'productManufacturer': productManufacturer,
      'productPicture': imagePath,
      'stocks': [stockEntry],
    };
  }
}
