import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _pollTimer;

  void initialize() {
    // Check initial connectivity
    _checkInitialConnectivity();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final wasConnected = _isConnected;
      _isConnected = await _hasInternetAccess();

      if (_isConnected != wasConnected) {
        debugPrint('Connectivity Status Changed: $_isConnected');
        _connectivityController.add(_isConnected);

        if (_isConnected && !wasConnected) {
          debugPrint('Internet connection restored');
        }
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    _isConnected = await _hasInternetAccess();
    _connectivityController.add(_isConnected);
    debugPrint('Initial connectivity status: $_isConnected');
  }

  Future<bool> checkConnectivity() async {
    _isConnected = await _hasInternetAccess();
    return _isConnected;
  }

  void dispose() {
    _pollTimer?.cancel();
    _connectivityController.close();
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://example.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
