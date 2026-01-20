import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../Model/currency_model.dart';

class CurrencyRepo {
  Future<List<CurrencyModel>> fetchAllCurrency() async {
    final uri = Uri.parse('${APIConfig.url}/currencies');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final partyList = parsedData['data'] as List<dynamic>;

      // Filter and map the list
      return partyList
          .where((category) => category['status'] == true) // Filter by status
          .map((category) => CurrencyModel.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to fetch Currency');
    }
  }

  // Future<List<CurrencyModel>> fetchAllCurrency() async {
  //   final uri = Uri.parse('${APIConfig.url}/currencies');
  //
  //   final response = await http.get(uri, headers: {
  //     'Accept': 'application/json',
  //     'Authorization': await getAuthToken(),
  //   });
  //
  //   if (response.statusCode == 200) {
  //     final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
  //
  //     final partyList = parsedData['data'] as List<dynamic>;
  //     return partyList.map((category) => CurrencyModel.fromJson(category)).toList();
  //     // Parse into Party objects
  //   } else {
  //     throw Exception('Failed to fetch Currency');
  //   }
  // }

  Future<bool> setDefaultCurrency({required num id}) async {
    final uri = Uri.parse('${APIConfig.url}/currencies/$id');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
