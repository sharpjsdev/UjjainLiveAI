// Query Agent Service
// Intelligent layer between user input and AI model
// Analyzes, understands, and reformulates queries for optimal AI responses

import '../models/query_analysis.dart';
import '../models/chat_session.dart';
import '../models/location_info.dart';
import '../utils/app_utils.dart';

class QueryAgentService {
  static final QueryAgentService _instance = QueryAgentService._internal();
  factory QueryAgentService() => _instance;
  QueryAgentService._internal();

  // Conversation memory for context tracking
  final List<String> _conversationHistory = [];
  final Map<String, dynamic> _sessionContext = {};
  String? _lastIntent;
  String? _lastTopic;

  /// Main entry point: Analyze and process user query
  Future<QueryAnalysis> analyzeQuery({
    required String userQuery,
    ChatSession? session,
    LocationInfo? locationInfo,
  }) async {
    debugLog('[QueryAgent] 🧠 Analyzing query: "$userQuery"');

    // Step 1: Normalize and clean the query
    final normalizedQuery = _normalizeQuery(userQuery);

    // Step 2: Detect language
    final language = _detectLanguage(normalizedQuery);

    // Step 3: Extract entities (temples, locations, dates, numbers, etc.)
    final entities = _extractEntities(normalizedQuery);

    // Step 4: Build context from session and history
    final context = _buildContext(
      session: session,
      locationInfo: locationInfo,
      query: normalizedQuery,
    );

    // Step 5: Identify intent
    final intent = _identifyIntent(
      query: normalizedQuery,
      entities: entities,
      context: context,
    );

    // Step 6: Determine complexity
    final complexity = _assessComplexity(
      intent: intent,
      entities: entities,
      context: context,
    );

    // Step 7: Check for location/real-time data requirements
    final requiresLocation = _requiresLocationData(intent, entities);
    final requiresRealTime = _requiresRealTimeData(intent);

    // Step 8: Reformulate query for AI model
    final reformulatedQuery = _reformulateQuery(
      originalQuery: userQuery,
      normalizedQuery: normalizedQuery,
      intent: intent,
      entities: entities,
      context: context,
      locationInfo: locationInfo,
      language: language,
    );

    // Step 9: Identify required capabilities
    final capabilities = _identifyRequiredCapabilities(intent, entities);

    // Step 10: Calculate confidence score
    final confidence = _calculateConfidence(intent, entities, context);

    // Update conversation memory
    _updateMemory(userQuery, intent.primaryIntent.toString());

    final analysis = QueryAnalysis(
      originalQuery: userQuery,
      intent: intent,
      context: context,
      extractedEntities: entities,
      reformulatedQuery: reformulatedQuery,
      confidenceScore: confidence,
      requiredCapabilities: capabilities,
      complexity: complexity,
      language: language,
      requiresLocation: requiresLocation,
      requiresRealTimeData: requiresRealTime,
    );

    debugLog('[QueryAgent] ✅ Analysis complete:');
    debugLog('  Intent: ${intent.primaryIntent}');
    debugLog('  Complexity: $complexity');
    debugLog('  Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    debugLog('  Reformulated: "$reformulatedQuery"');

    return analysis;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 1: QUERY NORMALIZATION
  // ═══════════════════════════════════════════════════════════════════

  String _normalizeQuery(String query) {
    String normalized = query.trim();

    // Remove excessive whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove special characters but keep Hindi/Devanagari
    // Keep: letters, numbers, spaces, Hindi characters, punctuation
    normalized = normalized.replaceAll(
      RegExp(r'[^\w\s\u0900-\u097F.,?!-]', unicode: true),
      '',
    );

    return normalized;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 2: LANGUAGE DETECTION
  // ═══════════════════════════════════════════════════════════════════

  String _detectLanguage(String query) {
    // Check for Hindi/Devanagari script
    final hasHindi = RegExp(r'[\u0900-\u097F]').hasMatch(query);
    final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(query);

    if (hasHindi && hasEnglish) return 'hi-en'; // Mixed
    if (hasHindi) return 'hi'; // Hindi
    if (hasEnglish) return 'en'; // English
    return 'unknown';
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 3: ENTITY EXTRACTION
  // ═══════════════════════════════════════════════════════════════════

  Map<String, dynamic> _extractEntities(String query) {
    final entities = <String, dynamic>{};
    final queryLower = query.toLowerCase();

    // Extract temples
    entities[EntityType.temple] = _extractTemples(queryLower);

    // Extract locations
    entities[EntityType.location] = _extractLocations(queryLower);

    // Extract dates and times
    entities[EntityType.date] = _extractDates(queryLower);
    entities[EntityType.time] = _extractTimes(queryLower);

    // Extract numbers and distances
    entities[EntityType.number] = _extractNumbers(queryLower);
    entities[EntityType.distance] = _extractDistances(queryLower);

    // Extract events
    entities[EntityType.event] = _extractEvents(queryLower);

    // Extract deities
    entities[EntityType.deity] = _extractDeities(queryLower);

    // Extract rituals
    entities[EntityType.ritual] = _extractRituals(queryLower);

    // Extract accommodation types
    entities[EntityType.accommodation] = _extractAccommodation(queryLower);

    // Extract transport types
    entities[EntityType.transport] = _extractTransport(queryLower);

    return entities;
  }

  List<String> _extractTemples(String query) {
    final temples = <String>[];
    final templePatterns = {
      'mahakaleshwar': [
        'mahakal',
        'महाकाल',
        'mahakaleshwar',
        'jyotirlinga',
        'ज्योतिर्लिंग'
      ],
      'kal_bhairav': ['bhairav', 'भैरव', 'kaal bhairav', 'काल भैरव'],
      'harsiddhi': ['harsiddhi', 'harsidhhi', 'हरसिद्धि', 'shakti peeth'],
      'chintaman': ['chintaman', 'ganesh', 'गणेश', 'chintamani'],
      'ram_ghat': ['ram ghat', 'राम घाट', 'ramghat'],
      'mangalnath': ['mangalnath', 'मंगलनाथ', 'mars temple'],
      'sandipani': ['sandipani', 'सांदीपनि', 'krishna ashram'],
    };

    for (final entry in templePatterns.entries) {
      for (final pattern in entry.value) {
        if (query.contains(pattern)) {
          temples.add(entry.key);
          break;
        }
      }
    }

    return temples;
  }

  List<String> _extractLocations(String query) {
    final locations = <String>[];
    final locationKeywords = [
      'ujjain',
      'उज्जैन',
      'indore',
      'इंदौर',
      'bhopal',
      'भोपाल',
      'delhi',
      'दिल्ली',
      'mumbai',
      'मुंबई',
      'railway station',
      'रेलवे स्टेशन',
      'bus stand',
      'बस स्टैंड',
    ];

    for (final keyword in locationKeywords) {
      if (query.contains(keyword)) {
        locations.add(keyword);
      }
    }

    return locations;
  }

  List<String> _extractDates(String query) {
    final dates = <String>[];

    // Date patterns: "april 9", "9 april", "9/4/2028"
    final dateRegex = RegExp(
      r'\b(\d{1,2})[\/\-\s]?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|oct|nov|dec)?\b',
      caseSensitive: false,
    );

    final matches = dateRegex.allMatches(query);
    for (final match in matches) {
      dates.add(match.group(0)!);
    }

    // Hindi months
    final hindiMonths = [
      'चैत्र',
      'वैशाख',
      'ज्येष्ठ',
      'आषाढ़',
      'श्रावण',
      'भाद्रपद',
      'आश्विन',
      'कार्तिक',
      'मार्गशीर्ष',
      'पौष',
      'माघ',
      'फाल्गुन'
    ];
    for (final month in hindiMonths) {
      if (query.contains(month)) dates.add(month);
    }

    return dates;
  }

  List<String> _extractTimes(String query) {
    final times = <String>[];

    // Time patterns: "4 am", "4:00", "morning", "evening"
    final timeRegex = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s?(am|pm|AM|PM)?\b',
    );

    final matches = timeRegex.allMatches(query);
    for (final match in matches) {
      times.add(match.group(0)!);
    }

    // Named times
    final namedTimes = [
      'morning',
      'afternoon',
      'evening',
      'night',
      'सुबह',
      'दोपहर',
      'शाम',
      'रात'
    ];
    for (final time in namedTimes) {
      if (query.contains(time)) times.add(time);
    }

    return times;
  }

  List<double> _extractNumbers(String query) {
    final numbers = <double>[];
    final numberRegex = RegExp(r'\b\d+(?:\.\d+)?\b');

    final matches = numberRegex.allMatches(query);
    for (final match in matches) {
      final num = double.tryParse(match.group(0)!);
      if (num != null) numbers.add(num);
    }

    return numbers;
  }

  Map<String, dynamic> _extractDistances(String query) {
    final distanceInfo = <String, dynamic>{};

    // Patterns: "5 km", "10 kilometers", "2 miles"
    final distanceRegex = RegExp(
      r'(\d+(?:\.\d+)?)\s?(km|kilometer|kilometers|mile|miles|meter|meters|किलोमीटर|मीटर)',
      caseSensitive: false,
    );

    final match = distanceRegex.firstMatch(query);
    if (match != null) {
      distanceInfo['value'] = double.tryParse(match.group(1)!);
      distanceInfo['unit'] = match.group(2);
    }

    return distanceInfo;
  }

  List<String> _extractEvents(String query) {
    final events = <String>[];
    final eventKeywords = [
      'simhastha',
      'सिंहस्थ',
      'kumbh',
      'कुंभ',
      'shahi snan',
      'शाही स्नान',
      'parva',
      'पर्व',
      'festival',
      'मेला',
      'panchkroshi',
      'पंचक्रोशी',
    ];

    for (final keyword in eventKeywords) {
      if (query.contains(keyword)) events.add(keyword);
    }

    return events;
  }

  List<String> _extractDeities(String query) {
    final deities = <String>[];
    final deityKeywords = [
      'shiva',
      'शिव',
      'mahadev',
      'महादेव',
      'ganesh',
      'गणेश',
      'durga',
      'दुर्गा',
      'kali',
      'काली',
      'krishna',
      'कृष्ण',
      'hanuman',
      'हनुमान',
    ];

    for (final keyword in deityKeywords) {
      if (query.contains(keyword)) deities.add(keyword);
    }

    return deities;
  }

  List<String> _extractRituals(String query) {
    final rituals = <String>[];
    final ritualKeywords = [
      'aarti',
      'आरती',
      'puja',
      'पूजा',
      'darshan',
      'दर्शन',
      'prasad',
      'प्रसाद',
      'abhishek',
      'अभिषेक',
      'bhasma',
      'भस्म',
      'snan',
      'स्नान',
    ];

    for (final keyword in ritualKeywords) {
      if (query.contains(keyword)) rituals.add(keyword);
    }

    return rituals;
  }

  List<String> _extractAccommodation(String query) {
    final accommodation = <String>[];
    final keywords = [
      'hotel',
      'होटल',
      'dharamshala',
      'धर्मशाला',
      'room',
      'कमरा',
      'stay',
      'ठहरना',
      'lodge',
      'guest house',
      'tent',
      'टेंट',
    ];

    for (final keyword in keywords) {
      if (query.contains(keyword)) accommodation.add(keyword);
    }

    return accommodation;
  }

  List<String> _extractTransport(String query) {
    final transport = <String>[];
    final keywords = [
      'train',
      'ट्रेन',
      'bus',
      'बस',
      'taxi',
      'टैक्सी',
      'auto',
      'ऑटो',
      'rickshaw',
      'रिक्शा',
      'car',
      'कार',
      'parking',
      'पार्किंग',
    ];

    for (final keyword in keywords) {
      if (query.contains(keyword)) transport.add(keyword);
    }

    return transport;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 4: CONTEXT BUILDING
  // ═══════════════════════════════════════════════════════════════════

  QueryContext _buildContext({
    ChatSession? session,
    LocationInfo? locationInfo,
    required String query,
  }) {
    final isFollowUp = _isFollowUpQuery(query);

    return QueryContext(
      conversationHistory: List.from(_conversationHistory),
      previousIntent: _lastIntent,
      sessionData: Map.from(_sessionContext),
      userLocation: locationInfo?.address,
      timeOfDay: _getTimeOfDay(),
      isFollowUp: isFollowUp,
      referencedTopic: _lastTopic,
    );
  }

  bool _isFollowUpQuery(String query) {
    final followUpPatterns = [
      'what about',
      'how about',
      'tell me more',
      'और बताइए',
      'इसके बारे में',
      'क्या',
      'कैसे',
      'there',
      'वहाँ',
      'it',
      'this',
      'that',
      'यह',
      'वह',
    ];

    final queryLower = query.toLowerCase();
    return followUpPatterns.any((pattern) => queryLower.contains(pattern));
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'early_morning';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 5: INTENT IDENTIFICATION
  // ═══════════════════════════════════════════════════════════════════

  QueryIntent _identifyIntent({
    required String query,
    required Map<String, dynamic> entities,
    required QueryContext context,
  }) {
    final queryLower = query.toLowerCase();
    IntentType primaryIntent = IntentType.unknown;
    final secondaryIntents = <IntentType>[];
    String description = '';
    final parameters = <String, dynamic>{};

    // Check for greeting
    if (_matchesPattern(queryLower, _greetingPatterns)) {
      primaryIntent = IntentType.greeting;
      description = 'User greeting';
    }
    // Check for farewell
    else if (_matchesPattern(queryLower, _farewellPatterns)) {
      primaryIntent = IntentType.farewell;
      description = 'User farewell';
    }
    // Check for gratitude
    else if (_matchesPattern(queryLower, _gratitudePatterns)) {
      primaryIntent = IntentType.gratitude;
      description = 'User expressing gratitude';
    }
    // Check for distance/location queries
    else if (_matchesPattern(queryLower, _distancePatterns)) {
      primaryIntent = IntentType.distanceQuery;
      description = 'User asking about distance or location';
      parameters['requiresGPS'] = true;
      if (entities[EntityType.temple]?.isNotEmpty ?? false) {
        parameters['target'] = entities[EntityType.temple];
      }
    }
    // Check for direction queries
    else if (_matchesPattern(queryLower, _directionPatterns)) {
      primaryIntent = IntentType.directionQuery;
      description = 'User asking for directions';
      parameters['requiresGPS'] = true;
    }
    // Check for temple-related queries
    else if (_matchesPattern(queryLower, _templePatterns) ||
        entities[EntityType.temple]?.isNotEmpty) {
      primaryIntent = IntentType.templeInquiry;
      description = 'User asking about temple information';
      parameters['temples'] = entities[EntityType.temple];
    }
    // Check for aarti/schedule queries
    else if (_matchesPattern(queryLower, _aartiPatterns)) {
      primaryIntent = IntentType.aartiSchedule;
      description = 'User asking about aarti timings';
      secondaryIntents.add(IntentType.templeInquiry);
    }
    // Check for darshan queries
    else if (_matchesPattern(queryLower, _darshanPatterns)) {
      primaryIntent = IntentType.darshanInquiry;
      description = 'User asking about darshan information';
      secondaryIntents.add(IntentType.templeInquiry);
    }
    // Check for event/simhastha queries
    else if (_matchesPattern(queryLower, _simhasthaPatterns) ||
        entities[EntityType.event]?.isNotEmpty) {
      primaryIntent = IntentType.simhasthaInquiry;
      description = 'User asking about Simhastha/Kumbh events';
    }
    // Check for accommodation queries
    else if (_matchesPattern(queryLower, _hotelPatterns) ||
        entities[EntityType.accommodation]?.isNotEmpty) {
      primaryIntent = IntentType.hotelInquiry;
      description = 'User asking about accommodation';
    }
    // Check for restaurant queries
    else if (_matchesPattern(queryLower, _restaurantPatterns)) {
      primaryIntent = IntentType.restaurantInquiry;
      description = 'User asking about food/restaurants';
    }
    // Check for transport queries
    else if (_matchesPattern(queryLower, _transportPatterns) ||
        entities[EntityType.transport]?.isNotEmpty) {
      primaryIntent = IntentType.transportInquiry;
      description = 'User asking about transportation';
    }
    // Check for calculation queries
    else if (_matchesPattern(queryLower, _calculationPatterns)) {
      primaryIntent = IntentType.calculation;
      description = 'User requesting calculation';
      parameters['numbers'] = entities[EntityType.number];
    }
    // Check for how-to queries
    else if (queryLower.startsWith('how') || queryLower.contains('कैसे')) {
      primaryIntent = IntentType.howToQuery;
      description = 'User asking how to do something';
    }
    // Check for what-is queries
    else if (queryLower.startsWith('what') || queryLower.contains('क्या')) {
      primaryIntent = IntentType.whatIsQuery;
      description = 'User asking for explanation';
    }
    // Check for when queries
    else if (queryLower.startsWith('when') || queryLower.contains('कब')) {
      primaryIntent = IntentType.whenQuery;
      description = 'User asking about time/date';
    }
    // Check for where queries
    else if (queryLower.startsWith('where') || queryLower.contains('कहाँ')) {
      primaryIntent = IntentType.whereQuery;
      description = 'User asking about location';
    }
    // Default to general information
    else {
      primaryIntent = IntentType.generalInformation;
      description = 'General information request';
    }

    return QueryIntent(
      primaryIntent: primaryIntent,
      secondaryIntents: secondaryIntents,
      description: description,
      parameters: parameters,
    );
  }

  bool _matchesPattern(String query, List<String> patterns) {
    return patterns.any((pattern) => query.contains(pattern));
  }

  // Intent Pattern Definitions
  final _greetingPatterns = [
    'hello',
    'hi',
    'hey',
    'namaste',
    'नमस्ते',
    'good morning',
    'good evening',
    'शुभ प्रभात'
  ];

  final _farewellPatterns = [
    'bye',
    'goodbye',
    'see you',
    'धन्यवाद',
    'alvida',
    'विदा'
  ];

  final _gratitudePatterns = [
    'thank',
    'thanks',
    'धन्यवाद',
    'शुक्रिया',
    'appreciate'
  ];

  final _distancePatterns = [
    'how far',
    'distance',
    'दूरी',
    'कितनी दूर',
    'kitna dur',
    'km away',
    'near',
    'nearby',
    'close',
    'नजदीक',
    'पास'
  ];

  final _directionPatterns = [
    'direction',
    'how to reach',
    'how to go',
    'way to',
    'रास्ता',
    'कैसे जाएं',
    'navigate',
    'route'
  ];

  final _templePatterns = [
    'temple',
    'मंदिर',
    'mandir',
    'shrine',
    'धाम',
    'dham',
    'deity',
    'देवता'
  ];

  final _aartiPatterns = [
    'aarti',
    'आरती',
    'arti',
    'timing',
    'समय',
    'schedule',
    'कब होती है'
  ];

  final _darshanPatterns = [
    'darshan',
    'दर्शन',
    'visit',
    'see',
    'दर्शन',
    'पूजा',
    'worship'
  ];

  final _simhasthaPatterns = [
    'simhastha',
    'सिंहस्थ',
    'kumbh',
    'कुंभ',
    'shahi snan',
    'शाही स्नान',
    'mela',
    'मेला',
    'event',
    'कार्यक्रम'
  ];

  final _hotelPatterns = [
    'hotel',
    'होटल',
    'accommodation',
    'stay',
    'ठहरना',
    'room',
    'कमरा',
    'lodge',
    'dharamshala',
    'धर्मशाला'
  ];

  final _restaurantPatterns = [
    'restaurant',
    'रेस्टोरेंट',
    'food',
    'खाना',
    'eat',
    'खाने',
    'meal',
    'भोजन',
    'dining'
  ];

  final _transportPatterns = [
    'train',
    'bus',
    'taxi',
    'auto',
    'transport',
    'यातायात',
    'ट्रेन',
    'बस',
    'how to reach'
  ];

  final _calculationPatterns = [
    'calculate',
    'add',
    'subtract',
    'multiply',
    'divide',
    '+',
    '-',
    '*',
    '/',
    'plus',
    'minus'
  ];

  // ═══════════════════════════════════════════════════════════════════
  // STEP 6: COMPLEXITY ASSESSMENT
  // ═══════════════════════════════════════════════════════════════════

  QueryComplexity _assessComplexity({
    required QueryIntent intent,
    required Map<String, dynamic> entities,
    required QueryContext context,
  }) {
    int complexityScore = 0;

    // Multiple intents increase complexity
    if (intent.secondaryIntents.isNotEmpty) complexityScore += 2;

    // Multiple entity types increase complexity
    int entityCount = 0;
    entities.forEach((key, value) {
      if (value != null && value is List && value.isNotEmpty) entityCount++;
    });
    complexityScore += entityCount;

    // Context-dependent queries are more complex
    if (context.isFollowUp) complexityScore += 1;

    // Certain intents are inherently complex
    if (intent.primaryIntent == IntentType.directionQuery ||
        intent.primaryIntent == IntentType.comparison) {
      complexityScore += 2;
    }

    // Ambiguous intents
    if (intent.primaryIntent == IntentType.unknown) {
      return QueryComplexity.ambiguous;
    }

    if (complexityScore == 0) return QueryComplexity.simple;
    if (complexityScore <= 3) return QueryComplexity.moderate;
    return QueryComplexity.complex;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 7: DATA REQUIREMENT CHECKS
  // ═══════════════════════════════════════════════════════════════════

  bool _requiresLocationData(QueryIntent intent, Map<String, dynamic> entities) {
    return intent.primaryIntent == IntentType.distanceQuery ||
        intent.primaryIntent == IntentType.directionQuery ||
        intent.primaryIntent == IntentType.nearbySearch ||
        intent.parameters['requiresGPS'] == true;
  }

  bool _requiresRealTimeData(QueryIntent intent) {
    return intent.primaryIntent == IntentType.eventInquiry ||
        intent.primaryIntent == IntentType.simhasthaInquiry ||
        intent.primaryIntent == IntentType.aartiSchedule;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 8: QUERY REFORMULATION
  // ═══════════════════════════════════════════════════════════════════

  String _reformulateQuery({
    required String originalQuery,
    required String normalizedQuery,
    required QueryIntent intent,
    required Map<String, dynamic> entities,
    required QueryContext context,
    LocationInfo? locationInfo,
    String? language,
  }) {
    final buffer = StringBuffer();

    // Add context prefix for AI model
    buffer.write('[CONTEXT] ');

    // Add intent information
    buffer.write('Intent: ${intent.primaryIntent.toString().split('.').last}. ');

    // Add location context if available
    if (locationInfo != null && _requiresLocationData(intent, entities)) {
      buffer.write(
        'User location: ${locationInfo.latitude}, ${locationInfo.longitude}. ',
      );
    }

    // Add conversational context for follow-up questions
    if (context.isFollowUp && context.referencedTopic != null) {
      buffer.write('Previous topic: ${context.referencedTopic}. ');
    }

    // Add entity context
    if (entities[EntityType.temple]?.isNotEmpty ?? false) {
      buffer.write('Temples mentioned: ${entities[EntityType.temple]}. ');
    }

    // Add time context for time-sensitive queries
    if (intent.primaryIntent == IntentType.aartiSchedule ||
        intent.primaryIntent == IntentType.eventInquiry) {
      buffer.write('Current time of day: ${context.timeOfDay}. ');
    }

    // Add main query with clarification
    buffer.write('\n[QUERY] ');
    buffer.write(originalQuery);

    // Add specific instructions based on intent
    buffer.write('\n[INSTRUCTIONS] ');
    buffer.write(_getInstructionsForIntent(intent, entities));

    return buffer.toString();
  }

  String _getInstructionsForIntent(
    QueryIntent intent,
    Map<String, dynamic> entities,
  ) {
    switch (intent.primaryIntent) {
      case IntentType.distanceQuery:
        return 'Provide direct, on-point distance with walking/driving time estimates. Keep it brief.';

      case IntentType.templeInquiry:
        return 'Answer ONLY the specific question asked about the temple. Be concise and strictly relevant. If asked about specialities or significance, provide only the key unique points in bullet points without unrequested timings, rules, or general overviews.';

      case IntentType.aartiSchedule:
        return 'Provide only the specific aarti timing asked for directly, accurately, and concisely.';

      case IntentType.simhasthaInquiry:
        return 'Provide concise, on-point Simhastha Kumbh Mela information answering directly what was asked.';

      case IntentType.hotelInquiry:
        return 'Suggest 2-3 relevant accommodations with approximate price ranges, and MANDATORILY provide the clickable Google Maps link for EACH hotel/dharamshala listed.';

      case IntentType.transportInquiry:
        return 'Provide direct transportation options with approximate cost and travel time concisely.';

      case IntentType.directionQuery:
        return 'Provide brief, clear directions with key landmarks.';

      case IntentType.greeting:
        return 'Respond warmly and briefly (1 sentence) asking how to help.';

      case IntentType.calculation:
        return 'Perform the calculation accurately and show the result directly.';

      default:
        return 'Be concise, direct, and strictly on-point. Answer only what was asked without unnecessary fluff or lengthy background.';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 9: CAPABILITY IDENTIFICATION
  // ═══════════════════════════════════════════════════════════════════

  List<String> _identifyRequiredCapabilities(
    QueryIntent intent,
    Map<String, dynamic> entities,
  ) {
    final capabilities = <String>[];

    // Location services
    if (_requiresLocationData(intent, entities)) {
      capabilities.add('gps');
      capabilities.add('geocoding');
    }

    // Database/API access
    if (intent.primaryIntent == IntentType.templeInquiry ||
        intent.primaryIntent == IntentType.eventInquiry ||
        intent.primaryIntent == IntentType.simhasthaInquiry) {
      capabilities.add('database');
    }

    // Speech synthesis
    if (intent.primaryIntent == IntentType.aartiSchedule ||
        intent.primaryIntent == IntentType.darshanInquiry) {
      capabilities.add('tts');
    }

    // Computation
    if (intent.primaryIntent == IntentType.calculation ||
        intent.primaryIntent == IntentType.conversion) {
      capabilities.add('computation');
    }

    // Always include base capability
    capabilities.add('nlp');

    return capabilities;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 10: CONFIDENCE CALCULATION
  // ═══════════════════════════════════════════════════════════════════

  double _calculateConfidence(
    QueryIntent intent,
    Map<String, dynamic> entities,
    QueryContext context,
  ) {
    double confidence = 0.5; // Base confidence

    // Known intent increases confidence
    if (intent.primaryIntent != IntentType.unknown) confidence += 0.2;

    // Extracted entities increase confidence
    int entityCount = 0;
    entities.forEach((key, value) {
      if (value != null && value is List && value.isNotEmpty) entityCount++;
    });
    confidence += (entityCount * 0.05).clamp(0.0, 0.2);

    // Context helps with confidence
    if (context.conversationHistory.isNotEmpty) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════
  // MEMORY MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  void _updateMemory(String query, String intent) {
    _conversationHistory.add(query);
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }

    _lastIntent = intent;

    // Extract topic for follow-up context
    if (query.length > 10) {
      _lastTopic = query.length > 50 ? query.substring(0, 50) : query;
    }
  }

  void clearMemory() {
    _conversationHistory.clear();
    _sessionContext.clear();
    _lastIntent = null;
    _lastTopic = null;
  }
}
