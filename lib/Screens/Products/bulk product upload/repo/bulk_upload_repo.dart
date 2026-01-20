import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/product_brand/product_brand_provider/product_brand_provider.dart';
import 'package:mobile_pos/Screens/product_category/provider/product_category_provider/product_unit_provider.dart';
import 'package:mobile_pos/Screens/product_unit/provider/product_unit_provider.dart';

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import '../../../../http_client/custome_http_client.dart';
import 'package:http/http.dart' as http;

class BulkUpLoadRepo {
  Future<void> uploadBulkFile({
    required WidgetRef ref,
    required BuildContext context,
    required File file,
  }) async {
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    final uri = Uri.parse('${APIConfig.url}/bulk-uploads');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.files.add(http.MultipartFile.fromBytes('file', file.readAsBytesSync(), filename: file.path));

    final response = await customHttpClient.uploadFile(url: uri, fileFieldName: 'file', file: file, fields: request.fields);
    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    if (response.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
      ref.invalidate(productProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(brandsProvider);
      ref.invalidate(unitsProvider);

      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${parsedData['message']}')));
    }
  }

  final String fileUrl = '${APIConfig.domain}assets/LeyanPOS_bulk_product_upload.xlsx';

  Future<void> downloadFile(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file!')),
        );
        return;
      }

      final downloadPath = '/storage/emulated/0/Download';
      final file = File('$downloadPath/LeyanPOS_bulk_product_upload.xlsx');

      await file.writeAsBytes(response.bodyBytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to: ${file.path}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    }
  }
}
