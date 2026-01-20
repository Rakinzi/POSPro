// ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';

class InvoiceReturnRepo {
  ///__________Sales_return___________________________________________
  Future<bool?> createSalesReturn({
    required WidgetRef ref,
    required BuildContext context,
    required ReturnDataModel salesReturn,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/sales-return');

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      // Create a multipart request
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          "Accept": 'application/json',
          'Authorization': await getAuthToken(),
        });

      // Add the fields
      request.fields['sale_id'] = salesReturn.saleId.toString();
      request.fields['return_date'] = salesReturn.returnDate;

      // Assuming these are lists, add them with index suffixes to maintain array structure.
      for (int i = 0; i < salesReturn.saleDetailId.length; i++) {
        request.fields['sale_detail_id[$i]'] = salesReturn.saleDetailId[i].toString();
        request.fields['return_amount[$i]'] = salesReturn.returnAmount[i].toString();
        request.fields['return_qty[$i]'] = salesReturn.returnQty[i].toString();
        request.fields['lossProfit[$i]'] = salesReturn.lossProfit[i].toString();
      }

      // Add the remaining fields directly if they are single values
      request.fields['dueAmount'] = salesReturn.dueAmount.toString();
      request.fields['paidAmount'] = salesReturn.paidAmount.toString();
      request.fields['totalAmount'] = salesReturn.totalAmount.toString();
      request.fields['discountAmount'] = salesReturn.discountAmount.toString();

      // var response = await request.send();
      var response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      var responseData = await http.Response.fromStream(response);
      final parsedData = jsonDecode(responseData.body);
      debugPrint('Sales Return: ${response.statusCode}');
      debugPrint('Sales Return Response: $parsedData');

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Sales Return Added successfully!');
        ref.invalidate(salesTransactionProvider);
        ref.invalidate(summaryInfoProvider);
        ref.invalidate(partiesProvider);
        ref.invalidate(productProvider);

        return true;
      } else {
        EasyLoading.dismiss();
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sales Return failed: ${parsedData['message']}')),
        );
        return null;
      }
    } catch (error) {
      EasyLoading.dismiss();
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
      return null;
    }
  }

  ///_________Purchase_return__________________________________
  Future<bool?> createPurchaseReturn({
    required WidgetRef ref,
    required BuildContext context,
    required ReturnDataModel returnData,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/purchases-return');

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          "Accept": 'application/json',
          'Authorization': await getAuthToken(),
        });

      request.fields['purchase_id'] = returnData.saleId.toString();
      request.fields['return_date'] = returnData.returnDate;

      for (int i = 0; i < returnData.saleDetailId.length; i++) {
        request.fields['purchase_detail_id[$i]'] = returnData.saleDetailId[i].toString();
        request.fields['return_amount[$i]'] = returnData.returnAmount[i].toString();
        request.fields['return_qty[$i]'] = returnData.returnQty[i].toString();
      }
      request.fields['dueAmount'] = returnData.dueAmount.toString();
      request.fields['paidAmount'] = returnData.paidAmount.toString();
      request.fields['totalAmount'] = returnData.totalAmount.toString();
      request.fields['discountAmount'] = returnData.discountAmount.toString();

      // Send the request and get the response
      // var response = await request.send();
      var response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      var responseData = await http.Response.fromStream(response);
      final parsedData = jsonDecode(responseData.body);

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Purchase Return Added successfully!');
        ref.invalidate(purchaseTransactionProvider);
        ref.invalidate(summaryInfoProvider);
        ref.invalidate(partiesProvider);
        ref.invalidate(productProvider);
        return true;
      } else {
        EasyLoading.dismiss();
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase Return failed: ${parsedData['message']}')),
        );
        return null;
      }
    } catch (error) {
      EasyLoading.dismiss();
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
      return null;
    }
  }
}

class ReturnDataModel {
  final num saleId;
  final String returnDate;
  final List<num> saleDetailId;
  final List<num> returnAmount;
  final List<num> returnQty;
  final List<num> lossProfit;
  final num dueAmount;
  final num paidAmount;
  final num totalAmount;
  num discountAmount;

  ReturnDataModel({
    required this.saleId,
    required this.returnDate,
    required this.saleDetailId,
    required this.returnAmount,
    required this.returnQty,
    required this.lossProfit,
    required this.dueAmount,
    required this.paidAmount,
    required this.totalAmount,
    required this.discountAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'returnDate': returnDate,
      'saleDetailId': saleDetailId,
      'returnAmount': returnAmount,
      'returnQty': returnQty,
      'lossProfit': lossProfit,
      'dueAmount': dueAmount,
      'paidAmount': paidAmount,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
    };
  }
}
