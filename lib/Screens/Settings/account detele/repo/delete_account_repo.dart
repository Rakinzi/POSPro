import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import 'package:flutter/foundation.dart';

class DeleteAccountRepository {
  Future<bool> deleteAccount({
    required String businessId,
    required String password,
  }) async {
    EasyLoading.show();
    final url = Uri.parse('${APIConfig.url}/business-delete');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': await getAuthToken(),
      });

      request.fields['password'] = password;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await EasyLoading.showSuccess('Account deleted successfully', duration: Duration(seconds: 2));
        return true;
      } else {
        final result = jsonDecode(response.body);
        EasyLoading.showError(result['message']);
        return false;
      }
    } catch (e) {
      debugPrint('Delete exception: $e');
      EasyLoading.showError('Something went wrong');
      return false;
    }
  }
}
