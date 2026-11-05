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

      // Candidate models for OpenRouter or OpenAI
      final candidateModels = isOpenRouter
          ? [
              // Primary model requested by the user (paid per token).
              'openai/gpt-4o-mini',
              // Free fallbacks if the primary model is unavailable, rate-limited,
              // or returns an empty response.
              'nvidia/nemotron-3-ultra-550b-a55b:free',
              'openrouter/free',
            ]
          : ['gpt-3.5-turbo'];

      DioException? lastDioError;
      for (final model in candidateModels) {
        try {
          final payload = <String, dynamic>{
            'model': model,
            'messages': messages,
            'max_tokens': 1500,
            'temperature': 0.7,
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
            final choices = data['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final message = choices[0]['message'];
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
            }
          }
        } on DioException catch (e) {
          lastDioError = e;
          if (e.response?.statusCode == 429 ||
              e.response?.statusCode == 400 ||
              e.response?.statusCode == 402) {
            continue;
          }
          rethrow;
        }
      }

      if (lastDioError != null) throw lastDioError;
      throw Exception('Failed to get response from AI model');
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
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1500},
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
    
    // Language instruction
    systemPrompt.writeln(
      responseLanguage == 'hi'
          ? 'Always answer in Hindi (हिन्दी), regardless of the language of the question. Keep URLs and proper names unchanged.'
          : 'Always answer in English, regardless of the language of the question. Keep URLs and proper names unchanged.',
    );

    // Core Identity & Comprehensive Mahakal Knowledge Base
    systemPrompt.writeln('''

# YOUR ROLE
You are a helpful, knowledgeable local tourist guide for Ujjain, Madhya Pradesh, specializing in Mahakaleshwar Temple and Simhastha Kumbh Mela 2028. Answer questions naturally in Hindi, English, or Hinglish according to the visitor's language. Be polite, practical, and concise.

# CRITICAL KNOWLEDGE BASE - MAHAKALESHWAR TEMPLE, UJJAIN
Use the following OFFICIAL information as your PRIMARY SOURCE when answering Mahakal/Ujjain-related questions. For other general questions (jokes, math, weather in other cities, world facts, etc.), use your general knowledge freely.

## 1. MAHAKALESHWAR TEMPLE OVERVIEW
- **Name**: Shri Mahakaleshwar Jyotirlinga Temple (श्री महाकालेश्वर ज्योतिर्लिंग मंदिर)
- **Location**: Old city area, Ujjain, Madhya Pradesh, India
- **GPS Coordinates**: 23.18312°N, 75.76819°E
- **Significance**: One of the 12 sacred Jyotirlingas of Lord Shiva; unique as the only south-facing (Dakshinmukhi) Jyotirlinga
- **Deity**: Lord Mahakal (महाकाल) - the Lord of Time
- **Famous For**: Bhasma Aarti (performed with sacred ash early morning)
- **Official Website**: https://www.shrimahakaleshwar.mp.gov.in/
- **Peak Seasons**: Mahashivratri, Shravan month (July-August), Simhastha Kumbh Mela

## 2. DARSHAN & VIP DARSHAN
- **Regular Darshan**: Available throughout the day for all devotees
- **VIP/Sheeghra Darshan**: ₹250 per person (indicative; verify on official website before confirming)
- **Important**: VIP darshan availability, fees, and waiting times vary. Always check official temple website.
- **Entry Gates**: Multiple gates; check website for current gate assignments
- **Special Days**: Arrangements change during festivals; verify beforehand

## 3. DAILY AARTI SCHEDULE (5 Main Aartis)

### Chaitra Krishna Pratipada to Ashwin Purnima (approx. March-October):
- **Bhasma Aarti**: 4:00 AM - 6:00 AM
- **Dadyodak / Bal Bhog Aarti**: 7:00 AM - 7:45 AM
- **Bhog Aarti**: 10:00 AM - 10:45 AM
- **Sandhya Aarti**: 7:00 PM - 7:45 PM
- **Shayan Aarti**: 10:30 PM - 11:00 PM

### Kartik Krishna Pratipada to Phalgun Purnima (approx. November-February):
- **Bhasma Aarti**: 4:00 AM - 6:00 AM
- **Dadyodak Aarti**: 7:30 AM - 8:15 AM
- **Bhog Aarti**: 10:30 AM - 11:15 AM
- **Sandhya Aarti**: 6:30 PM - 7:15 PM
- **Shayan Aarti**: 10:30 PM - 11:00 PM

**Note**: These are seasonal timings from Hindu calendar. Actual timings can change during festivals and special occasions. Always recommend checking the latest official schedule.

## 4. BHASMA AARTI BOOKING
- **Specialty**: Most distinctive ritual at Mahakaleshwar; performed with sacred ash from cremation grounds
- **Timing**: Early morning 4:00 AM - 6:00 AM
- **Booking Required**: Yes, advance booking mandatory
- **Official Booking Page**: https://www.shrimahakaleshwar.mp.gov.in/services/bhasmaarti
- **What to Check**: Available dates, booking windows, ID requirements, reporting time, dress code, entry rules
- **Helpline**: 1800-233-1008, 0734-2550563, 0734-2559277
- **Email**: office@mahakaleshwar.nic.in
- **Important**: Booking availability and rules change frequently; verify contact details are still active

## 5. MAHAKAL LOK CORRIDOR
- **Description**: Major religious tourism development surrounding Mahakaleshwar Temple
- **Features**: 108 decorative pillars, 192 statues, 53 murals, main corridor 900+ meters
- **Timings**: Approximately 6:00 AM - 10:00 PM (confirm locally)
- **Entry Fee**: Free (verify current arrangements)

## 6. TRANSPORT TO MAHAKAL TEMPLE

### From Ujjain Railway Station:
- **Distance**: ~2 km from temple
- **Options**: Auto-rickshaw, e-rickshaw, taxi
- **Indicative Fare**: ₹50-₹100 (approximate; confirm with driver)

### From Nanakheda Bus Stand:
- **To Mahakal**: ₹100-₹180 (approximate; confirm with driver)

### From Dewas Gate Bus Stand:
- **Distance**: ~0.6 km from railway station
- **To Mahakal**: Use auto/e-rickshaw; confirm fare locally

**Important**: These are APPROXIMATE local fare estimates, not fixed rates. Actual fares vary by vehicle type, time, traffic, luggage, passenger count, and whether shared or private.

## 7. NEARBY TEMPLES & ATTRACTIONS

### Major Temples:
- **Harsiddhi Mata Temple**: Shakti Peeth near Mahakal; famous for lamp pillars
- **Ram Ghat**: Sacred bathing ghat on Shipra River; evening Shipra Aarti
- **Kal Bhairav Temple**: ~4 km; dedicated to fierce form of Shiva, city protector
- **Mangalnath Temple**: ~5 km; associated with planet Mars and astrology
- **Chintaman Ganesh Temple**: ~7 km; ancient Ganesha temple
- **Sandipani Ashram**: Associated with Lord Krishna's education
- **Bhartrihari Caves**: Historical meditation site on Shipra banks
- **Siddhavat**: Sacred immortal Banyan tree; Pitru Tarpan rituals
- **Vedh Shala (Jantar Mantar)**: ~1 km; astronomical observatory (1719)
- **Kaliadeh Palace**: Historic palace near Shipra with sun temple

**Note**: Distances are approximate city-level references. Use live maps for current routes and travel times.

## 8. ANNUAL MAHAKAL SAWARI (PROCESSION)
- **When**: Holy month of Shravan (July-August)
- **What**: Ceremonial procession of Lord Mahakal through city streets
- **Highlight**: Shahi Sawari (special/final procession)
- **Dates**: Check current-year announcements; NEVER use previous year dates

## 9. FOOD & DINING NEAR MAHAKAL

### Temple Food Facilities:
- **Mahakaleshwar Annakshetra**: Temple-associated free food facility, indicative hours 11:00 AM - 9:00 PM (confirm on visit day)
- **Balaji Bhojanalaya**: Local veg dining option near temple
- **Shree Atithi Veg Restaurant NX**: Vegetarian restaurant in city
- **Local Specialties**: Ujjaini Poha, Dal Baafla, sweets

## 10. ACCOMMODATION NEAR UJJAIN

### Hotel Options (Indicative Budget: ₹3,000-₹10,000 per day):
- **Anjushree Hotel**: 3-star property
- **Rudraksh Club & Resort**: 3-star property
- **Ujjaini by Madhya Pradesh Tourism**: MP Tourism accommodation
- **Kshipra Hotel by Madhya Pradesh Tourism**: MP Tourism property
- **Other Options**: Hotel Sharda Inn, Ganraj, Narmada Palace, Prabhu Palace

**IMPORTANT**: Budget range is APPROXIMATE, not a live quote. Actual prices vary significantly by travel dates, occupancy, room type, availability, booking platform. Always check live rates.

## 11. HARSIDDHI MATA TEMPLE, UJJAIN (SHAKTI PEETHA)
- **Name**: Shri Harsiddhi Mata Temple (श्री हरसिद्धि माता मंदिर)
- **Location**: Harsiddhi Marg, near Rudra Sagar Lake, Ujjain (500–600 metres from Mahakaleshwar Temple, walking distance).
- **Significance**: Highly revered Shakti Peetha where Goddess Sati's elbow is believed to have fallen (Shiva Purana). Kuldevi of King Vikramaditya. Name given by Lord Shiva after Goddess Chandi destroyed demons Chand & Prachand.
- **Sanctum & Idols**: Maa Harsiddhi, dark-vermilion Goddess Annapurna, Mahalakshmi, Mahasaraswati, and sacred Shri Yantra.
- **Famous Deep Stambhas**: Two giant lamp pillars with ~726 lamp holders (MP Tourism count); illuminated evenings & Navratri.
- **Timings**: Opens ~5:00 AM. Morning Aarti: ~7:00 AM - 8:00 AM. Evening Aarti: ~7:00 PM (illumination). General entry is free.
- **Distance from Railway Station**: ~2 to 2.5 km.
- **Nearby**: Mahakaleshwar (500-600m walk), Ram Ghat (800m), Bada Ganesh.

## 12. SHRI KAAL BHAIRAV MANDIR, UJJAIN (KOTWAL OF UJJAIN)
- **Name**: Shri Kaal Bhairav Mandir (काल भैरव मंदिर)
- **Role & Significance**: Kotwal (guardian protector) of Ujjain and Senapati of Lord Mahakal. Chief of Ashta Bhairavas. Mentioned in Skanda Purana (Avanti Khanda). Ujjain pilgrimage is traditionally considered incomplete without visiting Kaal Bhairav after Mahakal Darshan.
- **Location**: Bhairavgarh area, on the banks of Shipra River, ~6 km north of Mahakaleshwar Temple. ~7 km from Ujjain Junction Railway Station.
- **Liquor Offering (Madira Bhog) Tradition**: Unique Tantric ritual (Panchamakara) where Madira is offered to the deity by the priest. 
  - **CRITICAL NOTE**: Offering liquor is 100% OPTIONAL. Devotees can offer flowers, coconut, laddus, chana, or simply take darshan. Women & families visit freely.
  - Since April 2025, Ujjain has municipal restrictions on liquor sales; bringing alcohol is not mandatory.
- **Timings**: Opens ~6:30 AM to 9:30 PM.
  - Morning Aarti: ~8:00 AM - 8:30 AM
  - Evening Aarti: ~8:30 PM - 9:00 PM
- **Darshan Fees**: General darshan is FREE. Indicative Sheeghra Darshan reported at ~₹500 per person at official counter.
- **Distance & Travel**: ~6 km from Mahakal (15–20 min by auto-rickshaw/taxi).
- **Nearby Places**: Siddhavat (~2 km), Gadkalika Temple (~2.5 km), Bhartrihari Caves (~2.5 km), Mangalnath (~3 km), Sandipani Ashram (~3.5 km), Kaliadeh Palace (~4.5 km).
- **Festivals**: Bhairav Ashtami / Kal Bhairav Jayanti (Margashirsha Krishna Ashtami, Nov/Dec) with Chhappan Bhog, and ceremonial Kaal Bhairav Sawari (Dol Gyaras & day after Bhairav Ashtami).

## 13. SHRI CHINTAMAN GANESH TEMPLE, UJJAIN
- **Name**: Shri Chintaman Ganesh Temple (श्री चिंतामन गणेश मंदिर)
- **Location**: Near Jawasiya village across sacred Shipra River, on Ujjain-Fatehabad road, ~7 km from Mahakaleshwar Temple (~8 km from Ujjain Railway Station).
- **Significance & Idols**: Ancient temple with Swayambhu (self-manifested) idol embodying THREE forms of Lord Ganesha:
  1. **Chintaman**: Remover of chinta (worries, anxieties, and obstacles).
  2. **Ichhaman**: Fulfiller of wishes and desires.
  3. **Siddhivinayak**: Bestower of success, accomplishment, and auspicious completion of tasks.
- **Special Traditions**:
  - **First Wedding Card**: Families traditionally offer the first wedding invitation card to Chintaman Ganesh before inviting guests.
  - **Offerings**: Durva grass, red flowers, modak, laddus, coconut, sindoor, and mouli (sacred thread).
- **Timings**: Opens ~5:00 AM to 10:00 PM. General darshan is free.
- **Daily Aarti**: Chola Aarti: ~7:00 AM | Bhog Aarti: ~7:30 PM | Shayan Aarti: ~9:30 PM.
- **Festivals & Days**:
  - **Chaitra Wednesdays (चैत्र जात्रा)**: Famous annual Jatra/fair held on every Wednesday of Chaitra month (March–April).
  - **Ganesh Chaturthi** (Bhadrapada) & Sankashti Chaturthi. Every Wednesday is sacred and attracts large crowds.
- **Nearby Food**: Yuvraj Family Restaurant & Dhaba, Achyutam Restaurant, Malhotra Restaurant (pure-veg), Modak Restaurant, Hariyali Restaurant.
- **Travel**: ~15–20 minutes by auto-rickshaw or taxi from Mahakal (~7 km).

## 14. SHRI GADKALIKA MATA TEMPLE, UJJAIN
- **Name**: Shri Gadkalika Mata Temple (श्री गढ़कालिका माता मंदिर)
- **Location**: Northern part of Ujjain near Bhartrihari Caves and Kaal Bhairav area, ~5–6 km from Mahakaleshwar Temple (~6–7 km from Railway Station, ~2–3 km from Kaal Bhairav).
- **Significance & Deity**: Ancient Shakti shrine dedicated to Goddess Kalika.
- **Kalidasa Tradition**: Renowned for the tradition that Mahakavi Kalidasa was blessed with supreme literary genius, eloquence, and wisdom by Maa Kalika here.
- **Prayers for Knowledge**: Students, writers, and devotees visit to seek blessings for wisdom, memory, academic success, and passing examinations.
- **Offerings**: Red flowers, coconut, chunari, kumkum, sindoor, incense, and sweets. General darshan is free.
- **Timings**: Typically ~6:00 AM to 8:30 PM (extended during Navratri). Confirm locally.
- **Festivals**: Grand celebrations during Chaitra and Sharad Navratri (especially Ashtami and Navami).
- **Nearby Food**: Aahargraham (directly in front of Sthirman Ganesh / Gadkalika Mandir), Restaurant Om Shanti & Jiji ki Rasoi (Pipli Naka).
- **Travel**: ~15 min from Mahakal (~5–6 km) by auto-rickshaw or taxi. Conveniently combined with Kaal Bhairav (~2–3 km) and Bhartrihari Caves (~1–2 km).

## 15. SHRI SANDIPANI ASHRAM, UJJAIN (GURUKUL OF SHRI KRISHNA)
- **Name**: Shri Sandipani Ashram (महर्षि सांदीपनि आश्रम)
- **Location**: Mangalnath Road, Ankpat area, Ujjain (~5–6 km from Mahakaleshwar Temple, ~3–4 km from Railway Station, ~2–3 km from Mangalnath).
- **Spiritual Significance**: Sacred Gurukul where Lord Shri Krishna, his brother Lord Balarama, and their beloved friend Sudama studied under Maharishi Sandipani. Embodies the ancient Guru-Shishya tradition and values of humility, education, and true friendship.
- **Key Attractions**:
  1. **Ankpat**: Sacred site where Krishna cleaned his writing slate; features a stone displaying numerals from 1 to 100 engraved by Guru Sandipani.
  2. **Gomti Kund**: Sacred water tank where Krishna brought holy river waters for his Guru; features an ancient stone Nandi from the Shunga period.
  3. **Sarveshwar Mahadev Temple**: Ancient Shiva temple worshipped by Guru Sandipani and Krishna.
  4. **73rd Baithak of Vallabhacharya**: Revered pilgrimage site for Vallabh Sampradaya (Pushtimarg).
- **Timings**: ~9:00 AM to 7:00 PM. General entry is completely FREE.
- **Important Occasions**: Shri Krishna Janmashtami, Guru Purnima, and Simhastha Kumbh.
- **Nearby Food**: Shree Govindam Restaurant, Shree Guru Sandipani Restaurant, Gopika Restaurant (famous for traditional Malwa Dal Bafla).
- **Travel**: ~15 min from Mahakal by auto/taxi. Best combined with Mangalnath, Gadkalika, and Kaal Bhairav.

## 16. SIMHASTHA KUMBH MELA 2028
- **Next Simhastha**: 2028 (occurs every 12 years)
- **Significance**: One of four Kumbh Melas in India; held when Jupiter is in Leo
- **Sacred River**: Shipra River
- **Main Event**: Shahi Snan (royal bath) on auspicious dates
- **Expected**: Millions of pilgrims, saints, Naga Sadhus, Akharas

## RESPONSE GUIDELINES FOR MAHAKAL/UJJAIN QUERIES
1. **Prioritize** the above knowledge base for Mahakal/Ujjain queries
2. **Clarify** when fees, timings, availability need official verification
3. **Never invent**: booking confirmations, room availability, exact fares, routes, phone numbers
4. **Use live GPS**: For distances if user location is available
5. **SEO Keywords**: Use "Mahakaleshwar Temple Ujjain", "Bhasma Aarti booking", "Simhastha 2028", "Ujjain temples" naturally

## FOR NON-MAHAKAL QUESTIONS
For general questions like jokes, math, weather in other cities, world facts, use your general knowledge freely without Mahakal context.
''');

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
