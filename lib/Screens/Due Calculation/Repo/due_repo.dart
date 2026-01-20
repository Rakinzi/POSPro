// ignore_for_file: unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../Model/due_collection_invoice_model.dart';
import '../Model/due_collection_model.dart';
import '../Providers/due_provider.dart';

class DueRepo {
  Future<List<DueCollection>> fetchDueCollectionList() async {
    final uri = Uri.parse('${APIConfig.url}/dues');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final dueList = parsedData['data'] as List<dynamic>;
      return dueList.map((due) => DueCollection.fromJson(due)).toList();
    } else {
      throw Exception('Failed to fetch Due List');
    }
  }

  Future<DueCollectionInvoice> fetchDueInvoiceList({required int id}) async {
    final uri = Uri.parse('${APIConfig.url}/invoices?party_id=$id');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return DueCollectionInvoice.fromJson(parsedData['data']);
    } else {
      throw Exception('Failed to fetch Sales List');
    }
  }

  Future<DueCollection?> dueCollect({
    required WidgetRef ref,
    required BuildContext context,
    required num partyId,
    required String? invoiceNumber,
    required String paymentDate,
    required String paymentType,
    required num payDueAmount,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/dues');
    final requestBody = jsonEncode({
      'party_id': partyId,
      'invoiceNumber': invoiceNumber,
      'paymentDate': paymentDate,
      'payment_type_id': paymentType,
      'payDueAmount': payDueAmount,
    });

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(
          url: uri, headers: {"Accept": 'application/json', 'Authorization': await getAuthToken(), 'Content-Type': 'application/json'}, body: requestBody);
      final parsedData = jsonDecode(responseData.body);
      debugPrint("Print Due data: ${parsedData['data']}");

      if (responseData.statusCode == 200) {
        EasyLoading.showSuccess('Collected successful!');

        ref.invalidate(partiesProvider);
        ref.invalidate(purchaseTransactionProvider);
        ref.invalidate(salesTransactionProvider);
        ref.invalidate(businessInfoProvider);
        ref.invalidate(getExpireDateProvider(ref));

        // ref.invalidate(dueInvoiceListProvider(partyId.round()));
        ref.invalidate(dueCollectionListProvider);
        ref.invalidate(summaryInfoProvider);

        return DueCollection.fromJson(parsedData['data']);
        // Navigator.pop(context);
        // return PurchaseTransaction.fromJson(parsedData);
      } else {
        EasyLoading.dismiss();
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase creation failed: ${parsedData['message']}')));
        return null;
      }
    } catch (error) {
      EasyLoading.dismiss();
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
      return null;
    }
  }
}
