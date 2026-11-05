import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/temple_darshan_info.dart';
import '../models/simhastha_event.dart';
import '../models/simhastha_place.dart';
import '../constants/app_constants.dart';

class SimhasthaBackendService {
  static final SimhasthaBackendService _instance = SimhasthaBackendService._internal();
  factory SimhasthaBackendService() => _instance;
  SimhasthaBackendService._internal();

  // Backend URL - now configured from AppConstants
  // Supports multiple environments:
  // - Local development (emulator): http://10.0.2.2:3000
  // - Local development (physical device on WiFi): http://192.168.x.x:3000
  // - ngrok testing (physical device over internet): https://xxxx.ngrok-free.app
  // - Production: https://your-api.com
  static String get initialBaseUrl {
    final configured = AppConstants.backendBaseUrl.trim();
    if (configured.isNotEmpty) {
      // If configured for localhost but running on Android emulator, route to 10.0.2.2
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && configured.contains('localhost')) {
        return configured.replaceAll('localhost', '10.0.2.2');
      }
      return configured;
    }
    // Smart local environment defaults
    if (kIsWeb) return 'http://localhost:3000';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  String _baseUrl = initialBaseUrl;

  String get baseUrl => _baseUrl;
  
  /// Dynamically change the backend URL at runtime
  /// Useful for testing different environments without rebuilding
  void setBaseUrl(String url) {
    _baseUrl = url;
    print('[Backend] 🔄 Backend URL changed to: $_baseUrl');
  }

  // ══════════════════════════════════════════════════════════════════════
  // 1. TEMPLE GUIDE CRUD
  // ══════════════════════════════════════════════════════════════════════
  Future<List<TempleDarshanInfo>> fetchTemples() async {
    try {
      print('[Backend] 🔄 Fetching temples from $_baseUrl/api/temples...');
      
      final res = await http.get(
        Uri.parse('$_baseUrl/api/temples'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Bypass ngrok browser warning
        },
      ).timeout(const Duration(seconds: 10));
      
      print('[Backend] 📥 Response status: ${res.statusCode}');
      
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        print('[Backend] ✅ Got ${list.length} temples from backend MySQL!');
        
        return list.map((json) {
          final aartisList = (json['aartis'] as List? ?? []).map((a) {
            return AartiSchedule(
              name: a['name'] ?? '',
              hindiName: a['hindiName'] ?? '',
              timingSummer: a['timingSummer'] ?? '',
              timingWinter: a['timingWinter'] ?? '',
              description: a['description'] ?? '',
            );
          }).toList();

          return TempleDarshanInfo(
            templeId: json['templeId'] ?? json['id'] ?? '',
            templeName: json['templeName'] ?? json['name'] ?? '',
            hindiName: json['hindiName'] ?? '',
            deity: json['deity'] ?? '',
            significance: json['significance'] ?? '',
            timing: json['timing'] ?? '',
            imageUrl: json['imageUrl'],
            aartis: aartisList,
            entryGates: List<String>.from(json['entryGates'] ?? []),
            darshanRoutes: List<String>.from(json['darshanRoutes'] ?? []),
            vipFastTrackRules: json['vipFastTrackRules'] ?? '',
            bookingWebsite: json['bookingWebsite'] ?? '',
            dressCode: json['dressCode'] ?? '',
            prasadDetails: json['prasadDetails'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      print('[Backend] ❌ ERROR fetching temples: $e');
      print('[Backend] 🔙 Falling back to embedded offline data...');
    }
    return TempleGuideData.temples;
  }

  // ══════════════════════════════════════════════════════════════════════
  // 2. SNAN CALENDAR & EVENTS CRUD
  // ══════════════════════════════════════════════════════════════════════
  Future<List<SnanEvent>> fetchEvents() async {
    try {
      print('[Backend] 🔄 Fetching events from $_baseUrl/api/events...');
      
      final res = await http.get(
        Uri.parse('$_baseUrl/api/events'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('[Backend] 📥 Response status: ${res.statusCode}');
      
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        print('[Backend] ✅ Got ${list.length} Simhastha events from backend MySQL!');
        
        return list.map((json) {
          return SnanEvent(
            title: json['title'] ?? '',
            hindiTitle: json['hindiTitle'] ?? '',
            date: json['date'] ?? '',
            tithi: json['tithi'] ?? '',
            significance: json['significance'] ?? '',
            hindiSignificance: json['hindiSignificance'] ?? '',
            location: json['location'] ?? '',
            isShahiSnan: json['isShahiSnan'] == true,
            type: json['type'] ?? 'parva_snan',
          );
        }).toList();
      }
    } catch (e) {
      print('[Backend] ❌ ERROR fetching events: $e');
      print('[Backend] 🔙 Falling back to embedded offline data...');
    }
    return SimhasthaCalendarData.events;
  }

  // ══════════════════════════════════════════════════════════════════════
  // 3. STAYS, DHARAMSHALAS & TRANSIT CRUD
  // ══════════════════════════════════════════════════════════════════════
  Future<List<SimhasthaPlace>> fetchStaysAndTransit() async {
    try {
      print('[Backend] 🔄 Fetching stays/transport from $_baseUrl/api/stays...');
      
      final res = await http.get(
        Uri.parse('$_baseUrl/api/stays'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('[Backend] 📥 Response status: ${res.statusCode}');
      
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        print('[Backend] ✅ Got ${list.length} places from backend MySQL!');
        
        final dynamicStays = list.map((json) {
          // Fix: Handle lat/lon/rating that come as strings from MySQL DECIMAL fields
          double parseDouble(dynamic value, double defaultValue) {
            if (value == null) return defaultValue;
            if (value is num) return value.toDouble();
            if (value is String) return double.tryParse(value) ?? defaultValue;
            return defaultValue;
          }
          
          return SimhasthaPlace(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            hindiName: json['hindiName'] ?? '',
            category: json['category'] ?? 'hotel',
            lat: parseDouble(json['lat'], 23.18),
            lon: parseDouble(json['lon'], 75.77),
            icon: json['icon'] ?? '🏨',
            area: json['area'] ?? '',
            description: json['description'] ?? '',
            hindiDescription: json['hindiDescription'] ?? '',
            contact: json['contact'],
            timing: json['timing'],
            gates: json['gates'],
            pricing: json['pricing'],
            rating: parseDouble(json['rating'], 4.5),
            tags: List<String>.from(json['tags'] ?? []),
          );
        }).toList();

        // Also merge static facilities (hospitals, toilets, etc.) so user can view all
        final staticOthers = SimhasthaPlacesData.allPlaces.where((p) {
          return p.category != 'hotel' && p.category != 'dharamshala' && p.category != 'tent' && p.category != 'transport' && p.category != 'parking';
        }).toList();

        return [...dynamicStays, ...staticOthers];
      }
    } catch (e) {
      print('[Backend] ❌ ERROR fetching stays: $e');
      print('[Backend] 🔙 Falling back to embedded offline data...');
    }
    return SimhasthaPlacesData.allPlaces;
  }
// ══════════════════════════════════════════════════════════════════════
  // 4. KNOWLEDGE CONTEXT (MAHAKAL & SIMHASTHA)
  // ══════════════════════════════════════════════════════════════════════
  Future<String?> fetchKnowledgeContext(String contextId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/context/$contextId'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is Map && data['content'] != null) {
          return data['content'].toString();
        }
      }
    } catch (e) {
      print('[Backend] ❌ ERROR fetching context: $e');
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════
  // 5. CHAT LOGGING (Record User Questions & AI Answers to MySQL)
  // ══════════════════════════════════════════════════════════════════════
  Future<bool> logChatInteraction({
    String? sessionId,
    required String question,
    required String answer,
    String? language,
    bool isVoice = false,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/chat-logs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'question': question,
          'answer': answer,
          'language': language ?? 'hi',
          'isVoice': isVoice,
        }),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 201 || res.statusCode == 200) {
        print('[Backend] ✅ Logged chat Q&A to MySQL successfully!');
        return true;
      } else {
        print('[Backend] ⚠️ Chat log responded with status ${res.statusCode}');
      }
    } catch (e) {
      print('[Backend] ⚠️ Failed to log chat interaction to MySQL: $e');
    }
    return false;
  }
}
