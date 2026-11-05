import '../services/simhastha_backend_service.dart';
import '../agents/ujjain_guide_agent.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../models/location_info.dart';
import '../services/hybrid_ai_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/place_search_service.dart';
import '../utils/app_utils.dart';

class ChatProvider with ChangeNotifier {
  final HybridAIService _aiService = HybridAIService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isGeneratingResponse = false;
  String? _error;
  LocationInfo? _currentLocation;
  bool _isOnline = true;

  // Getters
  bool get isInitialized => _isInitialized;
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isGeneratingResponse => _isGeneratingResponse;
  String? get error => _error;
  LocationInfo? get currentLocation => _currentLocation;
  List<Message> get currentMessages => _currentSession?.messages ?? [];
  bool get isOnline => _isOnline;
  String get connectionStatus => _aiService.getConnectionStatus();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _setLoading(true);
    try {
      await _storageService.initialize();
      await _aiService.initialize();
      await _loadChatSessions();
      await _getCurrentLocation();

      // Seed / verify Mahakaleshwar knowledge context in local storage
      final cachedContext = await _storageService.getKnowledgeContext('mahakaleshwar_temple');
      if (cachedContext == null || cachedContext.isEmpty) {
        await _storageService.saveKnowledgeContext(
          'mahakaleshwar_temple',
          UjjainGuideAgent.systemInstructions,
        );
      }

      // Sync latest knowledge contexts from Node.js MySQL backend in background
      for (final ctxId in ['mahakaleshwar_temple', 'harsiddhi_temple', 'kal_bhairav_temple', 'chintaman_ganesh_temple', 'gadkalika_temple', 'sandipani_ashram']) {
        SimhasthaBackendService().fetchKnowledgeContext(ctxId).then((remote) {
          if (remote != null && remote.trim().isNotEmpty) {
            _storageService.saveKnowledgeContext(ctxId, remote);
            print('[ChatProvider] ✅ Synced latest $ctxId context from MySQL backend');
          }
        }).catchError((e) {
          print('[ChatProvider] ℹ️ Using local $ctxId context ($e)');
        });
      }

      // Sync initial online/offline state directly from the service
      _isOnline = _aiService.isOnline;

      // Listen for connectivity changes - use the flag-aware getter so that
      // auto-offline (data off) is treated identically to Force Offline Mode button.
      _aiService.onConnectivityChanged.listen((_) {
        _isOnline = _aiService.isOnline; // respects _forceOfflineMode flag
        notifyListeners();
      });
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadChatSessions() async {
    try {
      _chatSessions = await _storageService.getAllChatSessions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat sessions: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      print('Could not get current location: $e');
      // Don't set error for location as it's optional
    }
  }

  Future<ChatSession> createNewChatSession({String? title}) async {
    final newSession = ChatSession(title: title);
    _chatSessions.insert(0, newSession);
    _currentSession = newSession;

    await _storageService.saveChatSession(newSession);
    notifyListeners();

    return newSession;
  }

  Future<void> selectChatSession(String sessionId) async {
    try {
      _currentSession = _chatSessions.firstWhere(
        (session) => session.id == sessionId,
      );
      notifyListeners();
    } catch (e) {
      _setError('Chat session not found');
    }
  }

  Future<void> sendMessage(
    String content, {
    MessageType type = MessageType.text,
    String responseLanguage = 'hi',
  }) async {
    if (content.trim().isEmpty) return;

    _currentSession ??= await createNewChatSession();

    // Create user message
    final userMessage = Message(content: content, type: type, isFromUser: true);

    // Add user message to session
    _currentSession = _currentSession!.addMessage(userMessage);
    _updateSessionInList(_currentSession!);
    await _storageService.saveChatSession(_currentSession!);
    notifyListeners();

    // Generate AI response
    await _generateAIResponse(
      content,
      responseLanguage: responseLanguage,
      isVoice: type == MessageType.voice,
    );
  }

  Future<void> _generateAIResponse(
    String userMessage, {
    String responseLanguage = 'hi',
    bool isVoice = false,
  }) async {
    if (_currentSession == null) return;

    _setGeneratingResponse(true);
    _clearError();

    // Create temporary assistant message to show loading
    final tempMessage = Message(
      content: '',
      type: MessageType.text,
      isFromUser: false,
      status: MessageStatus.sending,
    );

    _currentSession = _currentSession!.addMessage(tempMessage);
    notifyListeners();

    try {
      // If user asks anything related to distance/location, actively capture fresh live GPS coordinates
      final isLocationQuery = _isLocationOrDistanceQuery(userMessage);
      if (isLocationQuery) {
        // A distance answer must use a newly acquired fix, never an old cached
        // position. If GPS cannot provide one, leave the location unavailable.
        _currentLocation = await _locationService.getCurrentLocation(
          forceRefresh: true,
        );
      } else if (_currentLocation == null) {
        _currentLocation = await _locationService.getCurrentLocation(
          forceRefresh: true,
        );
      }

      final rawResponse = await _aiService.generateResponse(
        userMessage: userMessage,
        session: _currentSession!,
        locationInfo: _currentLocation,
        responseLanguage: responseLanguage,
      );
      final responseText = _aiService.lastResponseWasOnlineModel
          ? rawResponse
          : AppUtils.cleanAssistantResponse(rawResponse);
      final response = _appendGoogleMapsLink(
        responseText,
        userMessage,
        _currentLocation,
      );

      // Update the temporary message with the actual response
      final responseMessage = tempMessage.copyWith(
        content: response,
        status: MessageStatus.delivered,
      );

      _currentSession = _currentSession!.updateMessage(
        tempMessage.id,
        responseMessage,
      );
      _updateSessionInList(_currentSession!);
      await _storageService.saveChatSession(_currentSession!);

      // Asynchronously log Q&A to backend database (MySQL chat_logs)
      SimhasthaBackendService().logChatInteraction(
        sessionId: _currentSession?.id,
        question: userMessage,
        answer: response,
        language: responseLanguage,
        isVoice: isVoice,
      ).catchError((err) {
        print('[ChatProvider] Chat logging error: $err');
        return false;
      });

      // Update session title if it's the first exchange
      if (_currentSession!.messages.length == 2 &&
          _currentSession!.title == 'New Chat') {
        final title = _generateSessionTitle(userMessage);
        _currentSession = _currentSession!.copyWith(title: title);
        _updateSessionInList(_currentSession!);
        await _storageService.saveChatSession(_currentSession!);
      }
    } catch (e) {
      // Update the temporary message to show error
      final errorMessage = tempMessage.copyWith(
        content: 'Sorry, I encountered an error: ${e.toString()}',
        status: MessageStatus.error,
      );

      _currentSession = _currentSession!.updateMessage(
        tempMessage.id,
        errorMessage,
      );
      _setError(e.toString());
    } finally {
      _setGeneratingResponse(false);
      notifyListeners();
    }
  }

  String _generateSessionTitle(String firstMessage) {
    if (firstMessage.length <= 30) return firstMessage;

    // Try to find a natural break point
    final words = firstMessage.split(' ');
    String title = '';

    for (final word in words) {
      if (title.length + word.length + 1 <= 30) {
        title += title.isEmpty ? word : ' $word';
      } else {
        break;
      }
    }

    return title.isEmpty ? firstMessage.substring(0, 30) + '...' : title;
  }

  void _updateSessionInList(ChatSession session) {
    final index = _chatSessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _chatSessions[index] = session;

      // Move to top if not already there
      if (index != 0) {
        _chatSessions.removeAt(index);
        _chatSessions.insert(0, session);
      }
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _storageService.deleteChatSession(sessionId);
      _chatSessions.removeWhere((session) => session.id == sessionId);

      if (_currentSession?.id == sessionId) {
        _currentSession = _chatSessions.isNotEmpty ? _chatSessions.first : null;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete chat session: $e');
    }
  }

  Future<void> clearAllChatSessions() async {
    try {
      await _storageService.clearAllChatSessions();
      _chatSessions.clear();
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear chat sessions: $e');
    }
  }

  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  Future<void> refreshConnectivity() async {
    await _aiService.refreshConnectivity();
    _isOnline = _aiService.isOnline;
    notifyListeners();
  }

  void toggleOfflineMode() {
    _aiService.setOfflineMode(!_aiService.isOffline);
    _isOnline = _aiService.isOnline;
    notifyListeners();
  }

  void retryMessage(String messageId, {String responseLanguage = 'hi'}) async {
    if (_currentSession == null) return;

    final message = _currentSession!.messages.firstWhere(
      (m) => m.id == messageId,
    );
    if (message.isFromUser) {
      await _generateAIResponse(
        message.content,
        responseLanguage: responseLanguage,
        isVoice: message.type == MessageType.voice,
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
    notifyListeners();
  }

  void _setGeneratingResponse(bool generating) {
    _isGeneratingResponse = generating;
    if (generating) _clearError();
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _appendGoogleMapsLink(
    String response,
    String userMessage,
    LocationInfo? location,
  ) {
    if (!_shouldIncludeGoogleMapsLink(userMessage) ||
        RegExp(r'(?:google\.[^/\s]+/maps|maps\.app\.goo\.gl)',
                caseSensitive: false)
            .hasMatch(response)) {
      return response;
    }

    final parsedRoute = _extractRouteEndpoints(userMessage);
    final lowerMessage = userMessage.toLowerCase();
    final isCurrentLocationQuery = _containsAny(lowerMessage, const [
      'where am i',
      'my location',
      'current location',
      'mera location',
      'meri location',
    ]);
    final hasNearbySearchWithoutDestination = parsedRoute.destination == null &&
        _containsAny(lowerMessage, const [
          'near me',
          'nearby',
          'nearest',
          'closest',
        ]);
    final destination = parsedRoute.destination ??
        (isCurrentLocationQuery && location != null
            ? '${location.latitude},${location.longitude}'
            : userMessage.trim());
    final origin = parsedRoute.origin ??
        (location == null ? null : '${location.latitude},${location.longitude}');
    final isMapSearch = hasNearbySearchWithoutDestination ||
        isCurrentLocationQuery ||
        _containsAny(lowerMessage, const [
      'map of',
      'show on map',
      'location of',
      'where is',
      'naksha',
    ]);

    final Uri mapUri;
    if (isMapSearch) {
      mapUri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': hasNearbySearchWithoutDestination && location != null
            ? '$userMessage near ${location.latitude},${location.longitude}'
            : destination,
      });
    } else {
      mapUri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        if (origin != null && origin.isNotEmpty) 'origin': origin,
        'destination': destination,
        'travelmode': 'driving',
      });
    }

    return '$response\n\n[Open in Google Maps]($mapUri)';
  }

  bool _shouldIncludeGoogleMapsLink(String text) {
    final lower = text.toLowerCase();
    const mapIntentWords = [
      'distance',
      'how far',
      'how can i get to',
      'take me to',
      'reach',
      'get to',
      'directions',
      'direction',
      'route',
      'navigate',
      'go to',
      'drive to',
      'walk to',
      'travel time',
      'google maps',
      'open in maps',
      'map',
      'map of',
      'show on map',
      'where is',
      'near me',
      'nearby',
      'nearest',
      'closest',
      'kitni dur',
      'kitna door',
      'kitne km',
      'kaise pahuch',
      'kaise pahunch',
      'rasta',
      'raasta',
      'duri',
      'location of',
      'naksha',
    ];
    return mapIntentWords.any(lower.contains);
  }

  _RouteEndpoints _extractRouteEndpoints(String text) {
    RegExpMatch? match;

    match = RegExp(
      r'\bbetween\s+(.+?)\s+and\s+(.+?)(?:[?.!,]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      return _RouteEndpoints(match.group(2)?.trim(), match.group(1)?.trim());
    }

    match = RegExp(
      r'\bfrom\s+(.+?)\s+to\s+(.+?)(?:[?.!,]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      final source = match.group(1)!.trim();
      final isUserOrigin = RegExp(
        r'^(?:me|here|my(?: current)? location)$',
        caseSensitive: false,
      ).hasMatch(source);
      return _RouteEndpoints(
        match.group(2)?.trim(),
        isUserOrigin ? null : source,
      );
    }

    match = RegExp(
      r'\bto\s+(.+?)\s+from\s+(.+?)(?:[?.!,]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      final source = match.group(2)!.trim();
      final isUserOrigin = RegExp(
        r'^(?:me|here|my(?: current)? location)$',
        caseSensitive: false,
      ).hasMatch(source);
      return _RouteEndpoints(
        match.group(1)?.trim(),
        isUserOrigin ? null : source,
      );
    }

    match = RegExp(
      r'(?:how far is|distance between)\s+(.+?)\s+from\s+(.+?)(?:[?.!,]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      final source = match.group(2)!.trim();
      final isUserOrigin = RegExp(
        r'^(?:me|here|my(?: current)? location)$',
        caseSensitive: false,
      ).hasMatch(source);
      return _RouteEndpoints(
        match.group(1)?.trim(),
        isUserOrigin ? null : source,
      );
    }

    match = RegExp(
      r'(?:how far is|distance to|distance of|distance from|how can i get to|take me to|reach|go to|get to|drive to|walk to|travel to|directions? to|route to|navigate to|map of|maps of|location of)\s+(.+?)(?:\s+from\s+(?:me|here|my(?: current)? location))?(?:[?.!,]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      return _RouteEndpoints(match.group(1)?.trim(), null);
    }

    match = RegExp(
      r'^(.+?)\s+(?:is\s+)?(?:how far|distance|kitni dur|kitna door|kitne km)(?:\s+hai)?[?.!,]*$',
      caseSensitive: false,
    ).firstMatch(text.trim());
    if (match != null) {
      var destination = match.group(1)!.trim();
      destination = destination.replaceFirst(
        RegExp(r'^(?:what is the distance to|what is the distance from|tell me the distance to)\s+', caseSensitive: false),
        '',
      );
      return _RouteEndpoints(destination, null);
    }

    return const _RouteEndpoints(null, null);
  }

  bool _containsAny(String text, List<String> values) =>
      values.any(text.contains);

  bool _isLocationOrDistanceQuery(String text) {
    if (PlaceSearchService.shouldSearch(text)) return true;
    final lower = text.toLowerCase();
    final locationKeywords = [
      'how far',
      'distance',
      'where am i',
      'my location',
      'coordinates',
      'cords',
      'cord',
      'current location',
      'my position',
      'nearest',
      'closest',
      'near me',
      'nearby',
      'reach',
      'get to',
      'travel time',
      'route',
      'navigate',
      'drive to',
      'take me to',
      'go to',
      'walk to',
      'how can i get to',
      'map',
      'maps',
      'directions',
      'google maps',
      'kitni dur',
      'kitna door',
      'kahan hu',
      'kahan hoon',
      'kahan hai',
      'mera location',
      'meri location',
      'paas',
      'duri',
      'raasta',
      'direction',
      'directions',
      'à¤¦à¥‚à¤°à¥€',
      'à¤•à¤¿à¤¤à¤¨à¥€ à¤¦à¥‚à¤°',
      'à¤•à¤¿à¤¤à¤¨à¤¾ à¤¦à¥‚à¤°',
      'à¤•à¤¹à¤¾à¤ à¤¹à¥‚à¤',
      'à¤•à¤¹à¤¾à¤ à¤¹à¥ˆ',
      'à¤ªà¤¾à¤¸',
      'à¤²à¥‹à¤•à¥‡à¤¶à¤¨',
      'à¤¨à¤¿à¤°à¥à¤¦à¥‡à¤¶à¤¾à¤‚à¤•',
      'à¤°à¤¾à¤¸à¥à¤¤à¤¾',
    ];
    return locationKeywords.any((k) => lower.contains(k));
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

class _RouteEndpoints {
  const _RouteEndpoints(this.destination, this.origin);

  final String? destination;
  final String? origin;
}
