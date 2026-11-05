import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class NetworkService with WidgetsBindingObserver {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();
  
  bool _isConnected = false;
  bool _hasInternetAccess = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _heartbeatTimer;
  bool _isChecking = false;
  bool _isInitialized = false;
  
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  // Getters
  bool get isConnected => _isConnected;
  bool get hasInternetAccess => _hasInternetAccess;
  Stream<bool> get onConnectivityChanged => _connectionStatusController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Observe app lifecycle for instant refresh when returning from quick settings / notification shade
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}

    // Check initial connectivity
    try {
      final initialResults = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(initialResults);
    } catch (_) {
      _isConnected = false;
      _hasInternetAccess = false;
      _connectionStatusController.add(false);
    }
    
    // Listen for connectivity changes (Wi-Fi, Mobile Data on/off)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _updateConnectionStatus(results);
      },
    );

    // Heartbeat check every 6 seconds to detect silent disconnects/reconnects
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      if (_isChecking) return;
      _isChecking = true;
      try {
        final results = await _connectivity.checkConnectivity();
        final hasHardware = results.isNotEmpty &&
            !results.every((result) => result == ConnectivityResult.none);

        if (!hasHardware) {
          if (_isConnected || _hasInternetAccess) {
            _isConnected = false;
            _hasInternetAccess = false;
            _connectionStatusController.add(false);
          }
        } else {
          _isConnected = true;
          final currentAccess = await _checkInternetAccess();
          if (currentAccess != _hasInternetAccess) {
            _hasInternetAccess = currentAccess;
            _connectionStatusController.add(_hasInternetAccess);
          }
        }
      } catch (_) {
      } finally {
        _isChecking = false;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User returned to app after toggling Mobile Data / Wi-Fi
      checkConnectivity();
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> connectivityResults) async {
    final hasHardware = connectivityResults.isNotEmpty && 
                   !connectivityResults.every((result) => result == ConnectivityResult.none);
    
    _isConnected = hasHardware;
    
    if (!_isConnected) {
      // Immediate switch to offline mode (zero delay)
      _hasInternetAccess = false;
      _connectionStatusController.add(false);
      return;
    }

    // Hardware connected (mobile data or wifi turned on)
    // Perform fast verification with retries for routing stabilization
    final hasInternet = await _verifyInternetAccessWithRetries();
    _hasInternetAccess = hasInternet;
    _connectionStatusController.add(_hasInternetAccess);
  }

  Future<bool> _verifyInternetAccessWithRetries() async {
    // Attempt 1: Immediate check
    bool access = await _checkInternetAccess();
    if (access) return true;

    // Attempt 2: If mobile data/wifi just turned on, wait 500ms for network stack routing
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isConnected) return false;
    access = await _checkInternetAccess();
    if (access) return true;

    // Attempt 3: Final retry after 1 second
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!_isConnected) return false;
    return await _checkInternetAccess();
  }

  Future<bool> _checkInternetAccess() async {
    // 1. Fast native DNS lookup
    try {
      final lookupResult = await InternetAddress.lookup('clients3.google.com')
          .timeout(const Duration(milliseconds: 1500));
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    try {
      final lookupResult = await InternetAddress.lookup('openrouter.ai')
          .timeout(const Duration(milliseconds: 1500));
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    // 2. HTTP 204 ping (standard Android captive portal check)
    try {
      final response = await _dio.get(
        'https://clients3.google.com/generate_204',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          connectTimeout: const Duration(seconds: 2),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }
    } catch (_) {}

    // 3. Fallback to openrouter.ai
    try {
      final response = await _dio.get(
        'https://openrouter.ai',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          connectTimeout: const Duration(seconds: 2),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(connectivityResults);
    } catch (_) {
      _isConnected = false;
      _hasInternetAccess = false;
      _connectionStatusController.add(false);
    }
    return _hasInternetAccess;
  }

  String getConnectionType() {
    if (!_isConnected) return 'No Connection (Offline)';
    if (!_hasInternetAccess) return 'No Internet Access (Offline)';
    return 'Connected (Online)';
  }

  Future<bool> testApiConnection(String apiUrl) async {
    if (!_hasInternetAccess) return false;
    
    try {
      final response = await _dio.get(
        apiUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          connectTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    _heartbeatTimer?.cancel();
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}