import '../agents/ujjain_guide_agent.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/chat_session.dart';
import '../models/location_info.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Dio _dio = Dio();
  String? _dynamicKnowledgeContext;

  void setKnowledgeContext(String context) {
    if (context.trim().isNotEmpty) {
      _dynamicKnowledgeContext = context;
    }
  }

  Future<String> generateResponse({
    required String userMessage,
    required ChatSession session,
    LocationInfo? locationInfo,
    String responseLanguage = 'hi',
  }) async {
    // If a Google Gemini API key is configured, use official Gemini REST API
    if (AppConstants.isGemini) {
      return _generateGeminiResponse(
        userMessage: userMessage,
        session: session,
        locationInfo: locationInfo,
        responseLanguage: responseLanguage,
      );
    }

    try {
      // Prepare conversation context for OpenAI / OpenRouter
      final conversationHistory = _buildConversationHistory(session);
      final systemMessage = _buildSystemMessage(
        locationInfo,
        responseLanguage: responseLanguage,
      );

      final messages = [
        {'role': 'system', 'content': systemMessage},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final isOpenRouter = AppConstants.isOpenRouter;
      final apiUrl = AppConstants.apiUrl;
      final headers = <String, dynamic>{
        'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        'Content-Type': 'application/json',
      };
      if (isOpenRouter) {
        headers['HTTP-Referer'] = 'https://ujjain-live.app';
        headers['X-Title'] = 'Ujjain Live';
      }

      // Exclusively use the NVIDIA free model for OpenRouter as configured
      final selectedModel = isOpenRouter ? AppConstants.openRouterModel : 'gpt-3.5-turbo';

      DioException? lastDioError;
      const int maxRetries = 2;

      for (int attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          if (attempt > 0) {
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            print('[AIService] 🔄 Retrying $selectedModel (attempt ${attempt + 1})...');
          }

          final payload = <String, dynamic>{
            'model': selectedModel,
            'messages': messages,
            'max_tokens': 650,
            'temperature': 0.4,
          };
          if (!isOpenRouter) {
            payload['presence_penalty'] = 0.6;
            payload['frequency_penalty'] = 0.3;
          }

          final response = await _dio.post(
            apiUrl,
            options: Options(
              headers: headers,
              receiveTimeout: AppConstants.responseTimeoutDuration,
            ),
            data: jsonEncode(payload),
          );

          if (response.statusCode == 200) {
            final dynamic rawData = response.data;
            final data = rawData is String ? jsonDecode(rawData) : rawData;

            // Handle OpenRouter error payload returned with HTTP 200
            if (data is Map && data['error'] != null) {
              final errMsg = data['error']['message'] ?? data['error'].toString();
              print('[AIService] ⚠️ OpenRouter error: $errMsg');
              throw Exception('OpenRouter: $errMsg');
            }

            final choices = data['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final firstChoice = choices[0];
              final message = firstChoice['message'];
              final content = message?['content']?.toString().trim();
              if (content != null && content.isNotEmpty && content != 'null') {
                return content;
              }
              final reasoning = message?['reasoning']?.toString().trim();
              if (reasoning != null &&
                  reasoning.isNotEmpty &&
                  reasoning != 'null') {
                return reasoning;
              }
              final text = firstChoice['text']?.toString().trim();
              if (text != null && text.isNotEmpty && text != 'null') {
                return text;
              }
            }
          }
        } on DioException catch (e) {
          lastDioError = e;
          print('[AIService] ⚠️ DioException on $selectedModel (attempt ${attempt + 1}): ${e.response?.statusCode} - ${e.message}');
          // If rate limited or server temporarily overloaded on free tier, retry with delay
          if ((e.response?.statusCode == 429 || e.response?.statusCode == 503) && attempt < maxRetries) {
            continue;
          }
          break;
        } catch (e) {
          print('[AIService] ⚠️ Error on $selectedModel: $e');
          if (attempt < maxRetries) continue;
          rethrow;
        }
      }

      if (lastDioError != null) throw lastDioError;
      throw Exception('Failed to get response from AI model ($selectedModel)');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception(
          'Invalid API key. Please check your API configuration.',
        );
      } else if (e.response?.statusCode == 402) {
        throw Exception('Payment required. Please check your API credits.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again in a moment.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Official Google Gemini REST API implementation
  Future<String> _generateGeminiResponse({
    required String userMessage,
    required ChatSession session,
    LocationInfo? locationInfo,
    required String responseLanguage,
  }) async {
    final apiKey = AppConstants.openAiApiKey;
    final systemMessage = _buildSystemMessage(
      locationInfo,
      responseLanguage: responseLanguage,
    );

    // Format conversation history for Gemini: 'user' / 'model'
    final contents = <Map<String, dynamic>>[];
    final recentMessages = session.messages.reversed
        .take(AppConstants.maxConversationHistory)
        .toList()
        .reversed
        .toList();

    for (final message in recentMessages) {
      if (message.content.isNotEmpty) {
        contents.add({
          'role': message.isFromUser ? 'user' : 'model',
          'parts': [
            {'text': message.content},
          ],
        });
      }
    }

    // Add current user prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage},
      ],
    });

    final payload = <String, dynamic>{
      'system_instruction': {
        'parts': [
          {'text': systemMessage},
        ],
      },
      'contents': contents,
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 650},
    };

    // Candidate Gemini models (in order of verified reliability)
    final candidateModels = [
      'gemini-3.5-flash-lite',
      'gemini-3.8-flash',
      'gemini-flash-latest',
      'gemini-3.5-flash',
    ];

    DioException? lastDioError;
    for (final model in candidateModels) {
      try {
        final url =
            '${AppConstants.geminiApiBaseUrl}/$model:generateContent?key=$apiKey';
        final response = await _dio.post(
          url,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            receiveTimeout: AppConstants.responseTimeoutDuration,
            sendTimeout: const Duration(seconds: 15),
          ),
          data: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final dynamic rawData = response.data;
          final data = rawData is String ? jsonDecode(rawData) : rawData;
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text']?.toString().trim();
              if (text != null && text.isNotEmpty) {
                return text;
              }
            }
          }
        }
      } on DioException catch (e) {
        lastDioError = e;
        // If 404 (model not found), 429 (rate limit), or 503 (overloaded), try fallback model
        if (e.response?.statusCode == 404 ||
            e.response?.statusCode == 429 ||
            e.response?.statusCode == 503) {
          continue;
        }
        rethrow;
      }
    }

    if (lastDioError != null) {
      if (lastDioError.type == DioExceptionType.connectionTimeout ||
          lastDioError.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      } else if (lastDioError.response?.statusCode == 400) {
        final msg =
            lastDioError.response?.data?['error']?['message'] ??
            lastDioError.message;
        throw Exception('Gemini API Error: $msg');
      } else if (lastDioError.response?.statusCode == 403) {
        throw Exception('Invalid Gemini API key or unauthorized project.');
      } else if (lastDioError.response?.statusCode == 429) {
        throw Exception(
          'Gemini rate limit exceeded. Please try again in a moment.',
        );
      }
      throw lastDioError;
    }

    throw Exception('Failed to receive response from Gemini AI');
  }

  List<Map<String, String>> _buildConversationHistory(ChatSession session) {
    final history = <Map<String, String>>[];

    // Get recent messages (limit to prevent token overflow)
    final recentMessages = session.messages.reversed
        .take(AppConstants.maxConversationHistory)
        .toList()
        .reversed
        .toList();

    for (final message in recentMessages) {
      if (message.content.isNotEmpty) {
        history.add({
          'role': message.isFromUser ? 'user' : 'assistant',
          'content': message.content,
        });
      }
    }

    return history;
  }

  String _buildSystemMessage(
    LocationInfo? locationInfo, {
    required String responseLanguage,
  }) {
    final systemPrompt = StringBuffer();
    
    // Directness and conciseness directive
    systemPrompt.writeln('''
## CRITICAL INSTRUCTION: DIRECT, CONCISE & ON-POINT ANSWERS
- **Answer ONLY what was asked**: Do NOT provide unprompted extra history, unrelated background, unrequested timings, or extraneous details.
- **Speciality or Significance Queries**: If the user asks about the speciality, importance, or significance of Mahakal (or any place/temple), provide ONLY the unique specialities in 3 to 4 crisp, direct bullet points. Do NOT add hotel recommendations, food, transport, or full day schedules unless specifically requested.
- **No Fluff or Long Greetings**: Do NOT start with conversational pleasantries like "Namaste! I am your Ujjain guide...". Start directly with the on-point answer.
- **Length**: Keep answers concise, clear, and focused (under 4-5 sentences or short bullet points), ideal for quick mobile reading.

## GOOGLE MAPS NAVIGATION & PLACE SEARCH (ACCURATE PLACE-BASED LINKS):
- For all Google Maps links, do NOT use hardcoded numerical latitude/longitude numbers (as static coordinates can be inaccurate or drop a pin on an open street).
- Instead, ALWAYS format the Google Maps link using the official Place Name query with `+` replacing spaces so Google Maps opens the 100% accurate, verified business profile with real photos, live reviews, and turn-by-turn routing directly to the entrance:
  1. **For Hotels, Dharamshalas & Accommodations**:
     For EVERY single hotel/dharamshala listed, provide its clickable Google Maps search link immediately below it:
     Format: `Google Maps: https://www.google.com/maps/search/?api=1&query={Place+Name}+Ujjain`
     Examples:
     • Google Maps: https://www.google.com/maps/search/?api=1&query=MPT+Shipra+Residency+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Shri+Mahakaleshwar+Bhakt+Niwas+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Anjushree+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Rudraksh+Club+Resort+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Sharda+Inn+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Ganraj+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Shri+Gujarati+Samaj+Dharamshala+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Rudra+Palace+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Hotel+Narmada+Palace+Ujjain
     (NEVER omit the Google Maps link for any hotel in the list!)

  2. **For Distance & Directions**:
     Provide direct distance and estimated travel times (auto/walking).
     And provide the Google Maps direction route:
     Format: `Google Maps: https://www.google.com/maps/dir/?api=1&destination={Destination+Place}+Ujjain`
     Or if between two specific landmarks:
     Format: `Google Maps: https://www.google.com/maps/dir/?api=1&origin={Origin+Place}+Ujjain&destination={Destination+Place}+Ujjain`
     Examples:
     • Google Maps: https://www.google.com/maps/dir/?api=1&destination=Mahakaleshwar+Jyotirlinga+Temple+Ujjain
     • Google Maps: https://www.google.com/maps/dir/?api=1&origin=Ujjain+Junction+Railway+Station&destination=Mahakaleshwar+Temple+Ujjain
     • Google Maps: https://www.google.com/maps/dir/?api=1&origin=Mahakaleshwar+Temple+Ujjain&destination=Kal+Bhairav+Temple+Ujjain

  3. **For Restaurants & Food**:
     Format: `Google Maps: https://www.google.com/maps/search/?api=1&query={Restaurant+Name}+Ujjain`
     Examples:
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Mahakaleshwar+Annakshetra+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Swadeshi+Pure+Veg+Restaurant+Ujjain
     • Google Maps: https://www.google.com/maps/search/?api=1&query=Apna+Sweets+Dewas+Gate+Ujjain
''');

    // Language instruction
    systemPrompt.writeln(
      responseLanguage == 'hi'
          ? 'Always answer in Hindi (हिन्दी), regardless of the language of the question. Keep URLs and proper names unchanged.'
          : 'Always answer in English, regardless of the language of the question. Keep URLs and proper names unchanged.',
    );

    // Core Identity & Comprehensive Knowledge Base (Backend dynamic context prioritized)
    final contextToUse = (_dynamicKnowledgeContext != null && _dynamicKnowledgeContext!.trim().isNotEmpty)
        ? _dynamicKnowledgeContext!
        : UjjainGuideAgent.systemInstructions;
    systemPrompt.writeln(contextToUse);

    // Add live GPS context if available
    if (locationInfo != null) {
      systemPrompt.writeln('''

## CURRENT USER LIVE GPS LOCATION
- **Latitude**: ${locationInfo.latitude}
- **Longitude**: ${locationInfo.longitude}
- **City**: ${locationInfo.city ?? 'Unknown'}
- **Country**: ${locationInfo.country ?? 'Unknown'}  
- **Address**: ${locationInfo.address ?? 'Not available'}

### CRITICAL INSTRUCTION FOR DISTANCE & LOCATION:
When user asks about distance, "how far", travel time, nearest places, or "where am I", ALWAYS use their actual live GPS coordinates (${locationInfo.latitude}, ${locationInfo.longitude}). Calculate real distance from their current position.

### Temple GPS Coordinates for Distance Calculation:
- Mahakaleshwar Temple: 23.18312°N, 75.76819°E
- Kal Bhairav Temple: 23.2108°N, 75.7767°E
- Harsiddhi Temple: 23.1819°N, 75.7656°E
- Ram Ghat: 23.1867°N, 75.7744°E
- Chintaman Ganesh Temple: 23.1610°N, 75.7280°E
- Gadkalika Mata Temple: 23.2085°N, 75.7725°E
- Sandipani Ashram: 23.2030°N, 75.7760°E
- Ujjain Railway Station: 23.17954°N, 75.78195°E

Provide distance in km and estimated travel time (walking: 4 km/hr, auto: 20 km/hr).
''');
    }

    return systemPrompt.toString();
  }

}
