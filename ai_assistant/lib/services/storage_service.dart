import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/chat_session.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  // Chat Sessions Management
  Future<List<ChatSession>> getAllChatSessions() async {
    await _ensureInitialized();
    
    try {
      final sessionsJson = _prefs!.getStringList(AppConstants.chatSessionsKey) ?? [];
      return sessionsJson
          .map((json) => ChatSession.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated)); // Sort by most recent
    } catch (e) {
      print('Error loading chat sessions: $e');
      return [];
    }
  }

  Future<ChatSession?> getChatSession(String sessionId) async {
    final sessions = await getAllChatSessions();
    try {
      return sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveChatSession(ChatSession session) async {
    await _ensureInitialized();
    
    try {
      final sessions = await getAllChatSessions();
      
      // Remove existing session with same ID if it exists
      sessions.removeWhere((s) => s.id == session.id);
      
      // Add updated session
      sessions.add(session);
      
      // Keep only the most recent sessions (limit to prevent storage bloat)
      if (sessions.length > 50) {
        sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        sessions.removeRange(50, sessions.length);
      }

      final sessionsJson = sessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();

      return await _prefs!.setStringList(AppConstants.chatSessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving chat session: $e');
      return false;
    }
  }

  Future<bool> deleteChatSession(String sessionId) async {
    await _ensureInitialized();
    
    try {
      final sessions = await getAllChatSessions();
      sessions.removeWhere((session) => session.id == sessionId);

      final sessionsJson = sessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();

      return await _prefs!.setStringList(AppConstants.chatSessionsKey, sessionsJson);
    } catch (e) {
      print('Error deleting chat session: $e');
      return false;
    }
  }

  Future<bool> clearAllChatSessions() async {
    await _ensureInitialized();
    
    try {
      return await _prefs!.remove(AppConstants.chatSessionsKey);
    } catch (e) {
      print('Error clearing all chat sessions: $e');
      return false;
    }
  }

  // User Preferences Management
  Future<Map<String, dynamic>> getUserPreferences() async {
    await _ensureInitialized();
    
    try {
      final prefsJson = _prefs!.getString(AppConstants.userPreferencesKey);
      if (prefsJson != null) {
        return jsonDecode(prefsJson) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error loading user preferences: $e');
      return {};
    }
  }

  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _ensureInitialized();
    
    try {
      final prefsJson = jsonEncode(preferences);
      return await _prefs!.setString(AppConstants.userPreferencesKey, prefsJson);
    } catch (e) {
      print('Error saving user preferences: $e');
      return false;
    }
  }

  Future<T?> getUserPreference<T>(String key) async {
    final preferences = await getUserPreferences();
    return preferences[key] as T?;
  }

  Future<bool> setUserPreference(String key, dynamic value) async {
    final preferences = await getUserPreferences();
    preferences[key] = value;
    return await saveUserPreferences(preferences);
  }

  // Permission Status Management
  Future<bool> isLocationPermissionGranted() async {
    await _ensureInitialized();
    return _prefs!.getBool(AppConstants.locationPermissionKey) ?? false;
  }

  Future<void> setLocationPermissionGranted(bool granted) async {
    await _ensureInitialized();
    await _prefs!.setBool(AppConstants.locationPermissionKey, granted);
  }

  Future<bool> isSpeechPermissionGranted() async {
    await _ensureInitialized();
    return _prefs!.getBool(AppConstants.speechPermissionKey) ?? false;
  }

  Future<void> setSpeechPermissionGranted(bool granted) async {
    await _ensureInitialized();
    await _prefs!.setBool(AppConstants.speechPermissionKey, granted);
  }

  // General Key-Value Storage
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs!.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return await _prefs!.setDouble(key, value);
  }

  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }
// ═══════════════════════════════════════════════════════════════════
  // Knowledge Context Storage (for Mahakal & Pilgrimage Guide)
  // ═══════════════════════════════════════════════════════════════════
  Future<bool> saveKnowledgeContext(String id, String contextText) async {
    await _ensureInitialized();
    try {
      return await _prefs!.setString('knowledge_context_$id', contextText);
    } catch (e) {
      print('Error saving knowledge context ($id): $e');
      return false;
    }
  }

  Future<String?> getKnowledgeContext(String id) async {
    await _ensureInitialized();
    try {
      return _prefs!.getString('knowledge_context_$id');
    } catch (e) {
      print('Error reading knowledge context ($id): $e');
      return null;
    }
  }
}
