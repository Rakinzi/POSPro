import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';

class ChangePassRepo {
  Future<bool> changePass({required String oldPass, required String newPass, required BuildContext context}) async {
    final url = Uri.parse('${APIConfig.url}/change-password');

    final body = {
      'current_password': oldPass,
      'password': newPass,
    };
    final headers = {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (!context.mounted) return false;

      final responseData = jsonDecode(response.body);
      debugPrint('ChangePass: $responseData');
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (error) {
      debugPrint(error.toString());
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }

    return false;
  }
}
