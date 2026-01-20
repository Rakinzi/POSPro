import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/model/business_setting_model.dart';
import 'package:mobile_pos/model/dashboard_overview_model.dart';
import 'package:mobile_pos/model/todays_summary_model.dart';

import '../../Database/database_helper.dart';
import '../../Services/connectivity_service.dart';
import '../../http_client/subscription_expire_provider.dart';
import '../../model/business_info_model.dart';
import '../constant_functions.dart';
import 'package:flutter/foundation.dart';

class BusinessRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<BusinessInformationModel> fetchBusinessData() async {
    final uri = Uri.parse('${APIConfig.url}/business');
    final token = await getAuthToken(); // Replace with your token retrieval logic

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Assuming Bearer token format
      });
      if (response.statusCode == 200) {
        await _dbHelper.setCachedMeta('cache:business', response.body);
        final parsedData = jsonDecode(response.body);
        final BusinessInformationModel businessInformation = BusinessInformationModel.fromJson(parsedData['data']);

        return businessInformation;
      }
    }
    final cached = await _dbHelper.getCachedMeta('cache:business');
    if (cached != null) {
      final parsedData = jsonDecode(cached);
      return BusinessInformationModel.fromJson(parsedData['data']);
    }
    throw Exception('Failed to fetch business data');
  }

  Future<void> fetchSubscriptionExpireDate({required WidgetRef ref}) async {
    final uri = Uri.parse('${APIConfig.url}/business');
    final token = await getAuthToken(); // Replace with your token retrieval logic

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Assuming Bearer token format
      });
      if (response.statusCode == 200) {
        await _dbHelper.setCachedMeta('cache:business', response.body);
        final parsedData = jsonDecode(response.body);
        final BusinessInformationModel businessInformation = BusinessInformationModel.fromJson(parsedData['data']);
        ref.read(subscriptionProvider.notifier).updateSubscription(businessInformation.willExpire);
        return;
      }
    }
    final cached = await _dbHelper.getCachedMeta('cache:business');
    if (cached != null) {
      final parsedData = jsonDecode(cached);
      final BusinessInformationModel businessInformation = BusinessInformationModel.fromJson(parsedData['data']);
      ref.read(subscriptionProvider.notifier).updateSubscription(businessInformation.willExpire);
      return;
    }
    throw Exception('Failed to fetch business data');
  }

  Future<BusinessSettingModel> businessSettingData() async {
    final uri = Uri.parse('${APIConfig.url}/business-settings');
    final token = await getAuthToken();
    BusinessSettingModel businessSettingModel = BusinessSettingModel(message: null, pictureUrl: null);
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        await _dbHelper.setCachedMeta('cache:business_settings', response.body);
        final parseData = jsonDecode(response.body);
        businessSettingModel = BusinessSettingModel.fromJson(parseData);
      }
      return businessSettingModel;
    }
    final cached = await _dbHelper.getCachedMeta('cache:business_settings');
    if (cached != null) {
      final parseData = jsonDecode(cached);
      businessSettingModel = BusinessSettingModel.fromJson(parseData);
    }
    return businessSettingModel;
  }

  Future<BusinessInformationModel?> checkBusinessData() async {
    final uri = Uri.parse('${APIConfig.url}/business');
    final token = await getAuthToken(); // Replace with your token retrieval logic

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Assuming Bearer token format
      });
      if (response.statusCode == 200) {
        await _dbHelper.setCachedMeta('cache:business', response.body);
        final parsedData = jsonDecode(response.body);
        return BusinessInformationModel.fromJson(parsedData['data']); // Extract the "data" object from the response
      } else {
        return null;
      }
    }
    final cached = await _dbHelper.getCachedMeta('cache:business');
    if (cached != null) {
      final parsedData = jsonDecode(cached);
      return BusinessInformationModel.fromJson(parsedData['data']);
    }
    return null;
  }

  Future<TodaysSummaryModel> fetchTodaySummaryData() async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final uri = Uri.parse('${APIConfig.url}/summary?date=$date');
    final token = await getAuthToken(); // Replace with your token retrieval logic

    final isConnected = await _connectivityService.checkConnectivity();
    final cacheKey = 'cache:summary:$date';
    if (isConnected) {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Assuming Bearer token format
      });
      debugPrint('------------dashboard------${response.statusCode}--------------');
      if (response.statusCode == 200) {
        debugPrint(response.body);
        await _dbHelper.setCachedMeta(cacheKey, response.body);
        return TodaysSummaryModel.fromJson(jsonDecode(response.body)); // Extract the "data" object from the response
      } else {
        throw Exception('Failed to fetch business data');
      }
    }
    final cached = await _dbHelper.getCachedMeta(cacheKey);
    if (cached != null) {
      return TodaysSummaryModel.fromJson(jsonDecode(cached));
    }
    throw Exception('Failed to fetch business data');
  }

  // Future<DashboardOverviewModel> dashboardData(String type) async {
  //   final uri = Uri.parse('${APIConfig.url}/dashboard?duration=$type');
  //   final token = await getAuthToken(); // Replace with your token retrieval logic
  //
  //   final response = await http.get(uri, headers: {
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer $token', // Assuming Bearer token format
  //   });
  //   if (response.statusCode == 200) {
  //     debugPrint(response.body);
  //     return DashboardOverviewModel.fromJson(jsonDecode(response.body)); // Extract the "data" object from the response
  //   } else {
  //     // await LogOutRepo().signOut();
  //
  //     throw Exception('Failed to fetch business data ${response.statusCode}');
  //   }
  // }

  Future<DashboardOverviewModel> dashboardData(String type) async {
    final token = await getAuthToken();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Uri uri;

    if (type.startsWith('custom_date&')) {
      final uriParams = Uri.splitQueryString(type.replaceFirst('custom_date&', ''));
      final fromDate = uriParams['from_date'];
      final toDate = uriParams['to_date'];

      uri = Uri.parse('${APIConfig.url}/dashboard?duration=custom_date&from_date=$fromDate&to_date=$toDate');
    } else {
      uri = Uri.parse('${APIConfig.url}/dashboard?duration=$type');
    }

    final isConnected = await _connectivityService.checkConnectivity();
    final cacheKey = 'cache:dashboard:$type';
    if (isConnected) {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        await _dbHelper.setCachedMeta(cacheKey, response.body);
        return DashboardOverviewModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch business data ${response.statusCode}');
      }
    }
    final cached = await _dbHelper.getCachedMeta(cacheKey);
    if (cached != null) {
      return DashboardOverviewModel.fromJson(jsonDecode(cached));
    }
    throw Exception('Failed to fetch business data');
  }
}
