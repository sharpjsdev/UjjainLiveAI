// Query Analysis Model
// Represents the structured analysis of a user query by the AI Agent

class QueryAnalysis {
  final String originalQuery;
  final QueryIntent intent;
  final QueryContext context;
  final Map<String, dynamic> extractedEntities;
  final String reformulatedQuery;
  final double confidenceScore;
  final List<String> requiredCapabilities;
  final QueryComplexity complexity;
  final String? language;
  final bool requiresLocation;
  final bool requiresRealTimeData;

  QueryAnalysis({
    required this.originalQuery,
    required this.intent,
    required this.context,
    required this.extractedEntities,
    required this.reformulatedQuery,
    required this.confidenceScore,
    required this.requiredCapabilities,
    required this.complexity,
    this.language,
    this.requiresLocation = false,
    this.requiresRealTimeData = false,
  });

  Map<String, dynamic> toJson() => {
        'originalQuery': originalQuery,
        'intent': intent.toJson(),
        'context': context.toJson(),
        'extractedEntities': extractedEntities,
        'reformulatedQuery': reformulatedQuery,
        'confidenceScore': confidenceScore,
        'requiredCapabilities': requiredCapabilities,
        'complexity': complexity.toString(),
        'language': language,
        'requiresLocation': requiresLocation,
        'requiresRealTimeData': requiresRealTimeData,
      };
}

// Query Intent Classification
class QueryIntent {
  final IntentType primaryIntent;
  final List<IntentType> secondaryIntents;
  final String description;
  final Map<String, dynamic> parameters;

  QueryIntent({
    required this.primaryIntent,
    this.secondaryIntents = const [],
    required this.description,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() => {
        'primaryIntent': primaryIntent.toString(),
        'secondaryIntents': secondaryIntents.map((i) => i.toString()).toList(),
        'description': description,
        'parameters': parameters,
      };
}

// Intent Types
enum IntentType {
  // Location & Navigation
  locationQuery,
  directionQuery,
  distanceQuery,
  nearbySearch,

  // Temple & Religious
  templeInquiry,
  aartiSchedule,
  darshanInquiry,
  religiousInformation,
  ritualInquiry,

  // Events & Calendar
  eventInquiry,
  simhasthaInquiry,
  festivalInquiry,
  dateQuery,

  // Accommodation & Services
  hotelInquiry,
  restaurantInquiry,
  transportInquiry,
  bookingInquiry,

  // Information Seeking
  generalInformation,
  howToQuery,
  whatIsQuery,
  whenQuery,
  whereQuery,
  whyQuery,

  // Computational
  calculation,
  conversion,
  comparison,

  // Conversational
  greeting,
  farewell,
  gratitude,
  clarification,
  followUp,
  smallTalk,

  // Unknown
  unknown,
}

// Query Context
class QueryContext {
  final List<String> conversationHistory;
  final String? previousIntent;
  final Map<String, dynamic> sessionData;
  final String? userLocation;
  final String? timeOfDay;
  final bool isFollowUp;
  final String? referencedTopic;

  QueryContext({
    this.conversationHistory = const [],
    this.previousIntent,
    this.sessionData = const {},
    this.userLocation,
    this.timeOfDay,
    this.isFollowUp = false,
    this.referencedTopic,
  });

  Map<String, dynamic> toJson() => {
        'conversationHistory': conversationHistory,
        'previousIntent': previousIntent,
        'sessionData': sessionData,
        'userLocation': userLocation,
        'timeOfDay': timeOfDay,
        'isFollowUp': isFollowUp,
        'referencedTopic': referencedTopic,
      };
}

// Query Complexity
enum QueryComplexity {
  simple, // Single intent, no context needed
  moderate, // Multiple intents or context required
  complex, // Multiple steps, chaining required
  ambiguous, // Needs clarification
}

// Entity Types
class EntityType {
  static const String temple = 'temple';
  static const String location = 'location';
  static const String date = 'date';
  static const String time = 'time';
  static const String number = 'number';
  static const String distance = 'distance';
  static const String person = 'person';
  static const String event = 'event';
  static const String deity = 'deity';
  static const String ritual = 'ritual';
  static const String accommodation = 'accommodation';
  static const String transport = 'transport';
  static const String food = 'food';
}
