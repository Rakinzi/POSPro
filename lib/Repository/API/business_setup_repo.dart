import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Repository/constant_functions.dart';

import '../../Screens/Home/home.dart';

class BusinessSetupRepo {
  Future<void> businessSetup({
    required String name,
    String? phone,
    required String categoryId,
    String? address,
    String? openingBalance,
    String? vatGstTitle,
    String? vatGstNumber,
    File? image,
    required BuildContext context,
  }) async {
    EasyLoading.show(status: 'Loading...', dismissOnTap: false);

    final uri = Uri.parse('${APIConfig.url}/business');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = await getAuthToken()
      ..headers['Accept'] = 'application/json'
      ..fields['companyName'] = name
      ..fields['business_category_id'] = categoryId;

    // Only add fields if they're not null
    _addFieldIfNotNull(request, 'address', address);
    _addFieldIfNotNull(request, 'phoneNumber', phone);
    _addFieldIfNotNull(request, 'shopOpeningBalance', openingBalance);
    _addFieldIfNotNull(request, 'vat_name', vatGstTitle);
    _addFieldIfNotNull(request, 'vat_no', vatGstNumber);

    // Add image file if present
    if (image != null) {
      try {
        var picturePart = await _createImageFile(image);
        request.files.add(picturePart);
      } catch (e) {
        EasyLoading.dismiss();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
        return;
      }
    }

    try {
      var response = await request.send();
      if (!context.mounted) return;
      await _handleResponse(response, context);
    } catch (e) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    }
  }

  // Helper method to add fields if they're not null
  void _addFieldIfNotNull(http.MultipartRequest request, String field, String? value) {
    if (value != null && value.isNotEmpty) {
      request.fields[field] = value;
    }
  }

  // Helper method to create a MultipartFile from an image
  Future<http.MultipartFile> _createImageFile(File image) async {
    var imageBytes = await image.readAsBytes();
    return http.MultipartFile.fromBytes('pictureUrl', imageBytes, filename: image.path);
  }

  // Handle HTTP response and show appropriate messages
  Future<void> _handleResponse(http.StreamedResponse response, BuildContext context) async {
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile setup successful!')));
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
    } else {
      var responseData = await response.stream.bytesToString();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile setup failed: $responseData')));
    }
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_pos/Const/api_config.dart';
// import 'package:mobile_pos/Repository/constant_functions.dart';
// import '../../Screens/Home/home.dart';
//
// class BusinessSetupRepo {
//   Future<void> businessSetup({
//     required String name,
//     String? phone,
//     required String categoryId,
//     String? address,
//     String? openingBalance,
//     String? vatGstTitle,
//     String? vatGstNumber,
//     File? image,
//     required BuildContext context,
//   }) async {
//     EasyLoading.show(status: 'Loading...', dismissOnTap: false);
//
//     final uri = Uri.parse('${APIConfig.url}/business');
//
//     var request = http.MultipartRequest('POST', uri);
//     request.headers['Authorization'] = await getAuthToken();
//     request.headers['Accept'] = 'application/json';
//     request.fields['companyName'] = name;
//     request.fields['phoneNumber'] = phone ?? '';
//     request.fields['business_category_id'] = categoryId;
//     if (address != null) request.fields['address'] = address;
//     if (openingBalance != null) request.fields['shopOpeningBalance'] = openingBalance;
//     if (vatGstTitle != null) request.fields['shopOpeningBalance'] = vatGstTitle;
//     if (vatGstNumber != null) request.fields['shopOpeningBalance'] = vatGstNumber;
//     if (image != null) {
//       var picturePart = http.MultipartFile.fromBytes('pictureUrl', image.readAsBytesSync(), filename: image.path);
//       request.files.add(picturePart);
//     }
//
//     var response = await request.send();
//     // final responseData = await response.stream.bytesToString();
//     // debugPrint('Profile setup failed: ${response.statusCode}');
//     // debugPrint(responseData);
//
//     EasyLoading.dismiss();
//
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile setup successful!')));
//       Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile setup failed')));
//
//       // Handle error response
//     }
//   }
// }
