import 'dart:async';
import '../models/chat_session.dart';
import '../models/location_info.dart';
import '../models/query_analysis.dart';
import '../constants/app_constants.dart';
import 'ai_service.dart';
import 'offline_ai_service.dart';
import 'network_service.dart';
import 'query_agent_service.dart';

class HybridAIService {
  static final HybridAIService _instance = HybridAIService._internal();
  factory HybridAIService() => _instance;
  HybridAIService._internal();

  final AIService _onlineAIService = AIService();
  final OfflineAIService _offlineAIService = OfflineAIService();
  final NetworkService _networkService = NetworkService();
  final QueryAgentService _queryAgent = QueryAgentService();

  bool _forceOfflineMode = false;
  bool _lastResponseWasOnlineModel = false;

  // Getters
  bool get isOnline => _networkService.hasInternetAccess && !_forceOfflineMode;
  bool get isOffline => !isOnline;
  bool get lastResponseWasOnlineModel => _lastResponseWasOnlineModel;

  Future<void> initialize() async {
    await _networkService.initialize();

    // Auto-switch: whenever network connectivity physically transitions,
    // clear manual override so automatic switching seamlessly takes over!
    _networkService.onConnectivityChanged.listen((_) {
      _forceOfflineMode = false;
    });
  }

  Future<String> generateResponse({
    required String userMessage,
    required ChatSession session,
    LocationInfo? locationInfo,
    String responseLanguage = 'hi',
  }) async {
    _lastResponseWasOnlineModel = false;
    
    try {
      // ═══════════════════════════════════════════════════════════════
      // STEP 1: QUERY AGENT ANALYSIS
      // Analyze and reformulate query for optimal AI response
      // ═══════════════════════════════════════════════════════════════
      print('[HybridAI] 🧠 Invoking Query Agent for analysis...');
      final QueryAnalysis analysis = await _queryAgent.analyzeQuery(
        userQuery: userMessage,
        session: session,
        locationInfo: locationInfo,
      );

      print('[HybridAI] ✅ Query Agent Analysis Complete:');
      print('  - Intent: ${analysis.intent.primaryIntent}');
      print('  - Complexity: ${analysis.complexity}');
      print('  - Confidence: ${(analysis.confidenceScore * 100).toStringAsFixed(1)}%');
      print('  - Requires Location: ${analysis.requiresLocation}');
      print('  - Language: ${analysis.language}');

      // Use reformulated query for better AI responses
      final String queryToProcess = analysis.reformulatedQuery;
      
      print('[HybridAI] 📝 Original Query: "$userMessage"');
      print('[HybridAI] 🔄 Reformulated Query: "$queryToProcess"');

      final hasConnection = _networkService.hasInternetAccess;
      final isApiKeyConfigured = _isApiKeyConfigured();

      // ═══════════════════════════════════════════════════════════════
      // STEP 2: ROUTE TO APPROPRIATE AI SERVICE
      // Use reformulated query with enhanced context
      // ═══════════════════════════════════════════════════════════════
      
      // Online mode sends the reformulated query to the AI model
      if (hasConnection && !_forceOfflineMode && isApiKeyConfigured) {
        try {
          print('[HybridAI] 🌐 Attempting online AI with enhanced query...');
          final response = await _onlineAIService
              .generateResponse(
                userMessage: queryToProcess, // Use reformulated query
                session: session,
                locationInfo: locationInfo,
                responseLanguage: analysis.language ?? responseLanguage,
              )
              .timeout(
                const Duration(seconds: 12),
                onTimeout: () => throw TimeoutException(
                  'Online service timeout',
                ),
              );
          _lastResponseWasOnlineModel = true;
          return response;
        } catch (_) {
          return responseLanguage.toLowerCase().startsWith('hi')
              ? 'ऑनलाइन AI से जवाब नहीं मिल पाया। कृपया फिर कोशिश करें।'
              : 'The online AI could not respond. Please try again.';
        }
      }

      // ═══════════════════════════════════════════════════════════════
      // STEP 3: OFFLINE FALLBACK
      // Use original query for offline processing (it has its own NLP)
      // Pass analysis for additional context
      // ═══════════════════════════════════════════════════════════════
      print('[HybridAI] 📴 Using offline AI service with agent analysis...');
      
      // Check if it's a distance query first
      final distanceResponse = await _offlineAIService
          .generateDistanceResponseForChat(
            userMessage: userMessage,
            locationInfo: locationInfo,
            responseLanguage: responseLanguage,
          );
      if (distanceResponse != null) {
        print('[HybridAI] 📍 Distance query handled by offline service');
        return distanceResponse;
      }

      // Use offline AI with query analysis context
      return await _offlineAIService.generateOfflineResponse(
        userMessage: userMessage,
        session: session,
        locationInfo: locationInfo,
        responseLanguage: analysis.language ?? responseLanguage,
        queryAnalysis: analysis, // Pass analysis for enhanced context
      );
    } catch (e) {
      // Final fallback to offline
      try {
        return await _offlineAIService.generateOfflineResponse(
          userMessage: userMessage,
          session: session,
          locationInfo: locationInfo,
          responseLanguage: responseLanguage,
        );
      } catch (_) {
        return 'I\'m having trouble processing your request right now. ${_getConnectionStatusMessage()}';
      }
    }
  }

  // Check if API key is actually configured (not empty/placeholder)
  bool _isApiKeyConfigured() {
    final key = AppConstants.openAiApiKey.trim();
    return key.isNotEmpty &&
        key != 'YOUR_OPENAI_API_KEY' &&
        key != '' &&
        !key.contains('your_') &&
        !key.contains('_api_');
  }

  String _getConnectionStatusMessage() {
    if (!_networkService.isConnected) {
      return 'Please check your network connection.';
    } else if (!_networkService.hasInternetAccess) {
      return 'You appear to be connected to a network but don\'t have internet access.';
    } else {
      return 'There might be a temporary issue with the AI service.';
    }
  }

  void setOfflineMode(bool forceOffline) {
    _forceOfflineMode = forceOffline;
  }

  void resetManualOverride() {
    _forceOfflineMode = false;
  }

  Future<void> refreshConnectivity() async {
    _forceOfflineMode = false;
    await _networkService.checkConnectivity();
  }

  String getConnectionStatus() {
    if (_forceOfflineMode) return 'Offline Mode (Manual)';
    return _networkService.getConnectionType();
  }

  Stream<bool> get onConnectivityChanged =>
      _networkService.onConnectivityChanged;

  void dispose() {
    _networkService.dispose();
  }
}
