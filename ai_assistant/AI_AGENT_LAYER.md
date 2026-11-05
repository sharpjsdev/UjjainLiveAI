# 🧠 AI Agent Layer - Intelligent Query Processing

## Overview

The **AI Agent Layer** is an intelligent intermediary system that sits between user queries and the AI model. It analyzes, understands, and reformulates queries to ensure the AI model receives optimally structured input for generating accurate, relevant, and context-aware responses.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER QUERY                               │
│                    "mahakal kitni dur hai?"                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   🧠 QUERY AGENT LAYER                           │
│                   (query_agent_service.dart)                     │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 1: Normalization                                    │   │
│  │ • Clean whitespace, special chars                        │   │
│  │ • Preserve Hindi/Devanagari script                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 2: Language Detection                               │   │
│  │ • Detect: Hindi, English, or Mixed                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 3: Entity Extraction                                │   │
│  │ • Temples: Mahakaleshwar, Kal Bhairav, etc.             │   │
│  │ • Locations: Ujjain, Railway Station, etc.              │   │
│  │ • Dates/Times: "april 9", "4 am", "morning"             │   │
│  │ • Numbers: Distances, prices, quantities                 │   │
│  │ • Events: Simhastha, Shahi Snan, festivals              │   │
│  │ • Deities: Shiva, Ganesh, Durga, Krishna                │   │
│  │ • Rituals: Aarti, Darshan, Puja, Prasad                 │   │
│  │ • Services: Hotels, restaurants, transport              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 4: Context Building                                 │   │
│  │ • Conversation history (last 10 messages)                │   │
│  │ • Previous intent tracking                               │   │
│  │ • User location (if available)                           │   │
│  │ • Time of day context                                    │   │
│  │ • Follow-up detection                                    │   │
│  │ • Session data preservation                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 5: Intent Identification                            │   │
│  │ • Primary Intent: distanceQuery                          │   │
│  │ • Secondary Intents: templeInquiry                       │   │
│  │ • Confidence Score: 85%                                  │   │
│  │ • Parameters: {requiresGPS: true, target: [mahakal]}    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 6: Complexity Assessment                            │   │
│  │ • Simple: Single intent, no context                      │   │
│  │ • Moderate: Multiple intents or context needed           │   │
│  │ • Complex: Multi-step reasoning required                 │   │
│  │ • Ambiguous: Needs clarification                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 7: Data Requirements                                │   │
│  │ • Requires Location: ✅ Yes                              │   │
│  │ • Requires Real-time Data: ❌ No                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 8: Query Reformulation                              │   │
│  │ • Add context prefix                                     │   │
│  │ • Include intent information                             │   │
│  │ • Add location data                                      │   │
│  │ • Append conversation context                            │   │
│  │ • Add specific instructions                              │   │
│  │                                                           │   │
│  │ OUTPUT:                                                   │   │
│  │ "[CONTEXT] Intent: distanceQuery. User location:         │   │
│  │  23.1827, 75.7682.                                       │   │
│  │  [QUERY] mahakal kitni dur hai?                          │   │
│  │  [INSTRUCTIONS] Provide accurate distance information    │   │
│  │  with walking/driving time. Include Google Maps link."   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 9: Capability Identification                        │   │
│  │ Required: [gps, geocoding, nlp]                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         │                                        │
│  ┌──────────────────────▼──────────────────────────────────┐   │
│  │ STEP 10: Confidence Score                                │   │
│  │ Overall Confidence: 0.85 (85%)                           │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│               HYBRID AI SERVICE (Routing)                        │
│                                                                   │
│  IF (online AND apiConfigured):                                  │
│     → Send reformulated query to Online AI (OpenAI/OpenRouter)  │
│  ELSE:                                                            │
│     → Send to Offline AI with query analysis context            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AI MODEL RESPONSE                           │
│                                                                   │
│  "Shri Mahakaleshwar Jyotirlinga is 2.3 km from your current    │
│   location. It will take approximately 5 minutes by car or       │
│   30 minutes walking. [Open in Google Maps]"                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Intent Classification System

### **Location & Navigation**
- `locationQuery` - "where is temple?"
- `directionQuery` - "how to reach mahakal?"
- `distanceQuery` - "kitni dur hai?"
- `nearbySearch` - "temples near me"

### **Temple & Religious**
- `templeInquiry` - "tell me about mahakaleshwar"
- `aartiSchedule` - "bhasma aarti time?"
- `darshanInquiry` - "darshan timings?"
- `religiousInformation` - "significance of ujjain"
- `ritualInquiry` - "how to do puja?"

### **Events & Calendar**
- `eventInquiry` - "what events today?"
- `simhasthaInquiry` - "when is simhastha?"
- `festivalInquiry` - "upcoming festivals"
- `dateQuery` - "shahi snan date?"

### **Accommodation & Services**
- `hotelInquiry` - "hotels near mahakal"
- `restaurantInquiry` - "best food places"
- `transportInquiry` - "how to reach ujjain"
- `bookingInquiry` - "can i book?"

### **Information Seeking**
- `generalInformation` - General queries
- `howToQuery` - "how to..."
- `whatIsQuery` - "what is..."
- `whenQuery` - "when does..."
- `whereQuery` - "where is..."

### **Computational**
- `calculation` - "2 + 2 = ?"
- `conversion` - "km to miles"
- `comparison` - "A vs B"

### **Conversational**
- `greeting` - "hello", "namaste"
- `farewell` - "bye", "thank you"
- `gratitude` - "thanks", "dhanyavaad"
- `followUp` - "tell me more", "what about..."

---

## Entity Extraction Examples

### **Temple Entities**
```dart
Input: "mahakal ka rasta batao"
Extracted: {
  'temple': ['mahakaleshwar'],
  'location': [],
  'intent': 'directionQuery'
}
```

### **Time Entities**
```dart
Input: "aarti timing 4 am se 6 am tak"
Extracted: {
  'time': ['4 am', '6 am'],
  'ritual': ['aarti'],
  'intent': 'aartiSchedule'
}
```

### **Distance Entities**
```dart
Input: "5 km radius me hotels"
Extracted: {
  'distance': {'value': 5.0, 'unit': 'km'},
  'accommodation': ['hotels'],
  'intent': 'hotelInquiry'
}
```

### **Event Entities**
```dart
Input: "simhastha 2028 shahi snan dates"
Extracted: {
  'event': ['simhastha', 'shahi snan'],
  'date': ['2028'],
  'intent': 'simhasthaInquiry'
}
```

---

## Query Reformulation Examples

### Example 1: Distance Query
**Original:** "mahakal kitni dur hai?"

**Reformulated:**
```
[CONTEXT] Intent: distanceQuery. User location: 23.1827, 75.7682. 
[QUERY] mahakal kitni dur hai?
[INSTRUCTIONS] Provide accurate distance information with walking/driving time estimates. Include Google Maps link if relevant.
```

### Example 2: Temple Inquiry
**Original:** "tell me about kal bhairav"

**Reformulated:**
```
[CONTEXT] Intent: templeInquiry. Temples mentioned: [kal_bhairav]. Current time of day: morning. 
[QUERY] tell me about kal bhairav
[INSTRUCTIONS] Provide comprehensive temple information including darshan timings, aarti schedules, significance, and visitor guidelines.
```

### Example 3: Follow-up Question
**Original:** "how to reach there?"

**Reformulated:**
```
[CONTEXT] Intent: directionQuery. Previous topic: mahakaleshwar temple. User location: 23.1827, 75.7682. 
[QUERY] how to reach there?
[INSTRUCTIONS] Provide clear step-by-step directions. Mention landmarks along the route. Suggest best mode of transport.
```

### Example 4: Event Query
**Original:** "shahi snan kab hai?"

**Reformulated:**
```
[CONTEXT] Intent: simhasthaInquiry. Current time of day: afternoon. 
[QUERY] shahi snan kab hai?
[INSTRUCTIONS] Provide Simhastha Kumbh Mela information focusing on 2028 dates, Shahi Snan timings, and pilgrim guidelines.
```

---

## Complexity Assessment

### **Simple Query**
- Single intent
- No context needed
- Direct answer possible
- Example: "hello", "2+2", "ujjain weather"

### **Moderate Query**
- Multiple intents OR context required
- Some entity extraction needed
- Example: "hotels near mahakal", "aarti timing today"

### **Complex Query**
- Multiple steps required
- Heavy context dependency
- Multiple entity types
- Example: "compare hotels near mahakal and kal bhairav with prices below 2000"

### **Ambiguous Query**
- Intent unclear
- Needs clarification
- Example: "it", "there", "that one"

---

## Confidence Scoring

The Query Agent calculates a confidence score (0.0 to 1.0) based on:

1. **Intent Clarity** (+0.2) - Is the intent identifiable?
2. **Entity Extraction** (+0.05 per entity type) - How many entities extracted?
3. **Context Availability** (+0.1) - Is conversation history available?

**Example Calculation:**
```
Query: "mahakal kitni dur hai?"
- Known intent (distanceQuery): +0.2
- Extracted temple entity: +0.05
- Extracted location entity: +0.05
- Conversation history available: +0.1
- Base confidence: +0.5

Total: 0.9 (90% confidence)
```

---

## Integration Flow

### In `hybrid_ai_service.dart`:
```dart
// BEFORE (Direct query to AI)
final response = await _onlineAIService.generateResponse(
  userMessage: userMessage, // Raw user input
  session: session,
);

// AFTER (With Query Agent)
// Step 1: Analyze query
final analysis = await _queryAgent.analyzeQuery(
  userQuery: userMessage,
  session: session,
  locationInfo: locationInfo,
);

// Step 2: Use reformulated query
final response = await _onlineAIService.generateResponse(
  userMessage: analysis.reformulatedQuery, // Enhanced query
  session: session,
  locationInfo: locationInfo,
  responseLanguage: analysis.language,
);
```

### In `offline_ai_service.dart`:
```dart
Future<String> generateOfflineResponse({
  required String userMessage,
  required ChatSession session,
  LocationInfo? locationInfo,
  String responseLanguage = 'hi',
  QueryAnalysis? queryAnalysis, // NEW: Optional enhanced context
}) async {
  // Use query analysis if available
  if (queryAnalysis != null) {
    final entities = queryAnalysis.extractedEntities;
    final intent = queryAnalysis.intent.primaryIntent;
    // Enhanced processing with extracted entities
  }
  
  // Continue with existing offline logic
  ...
}
```

---

## Benefits of Query Agent Layer

### 1. **Better Context Understanding**
- Tracks conversation history
- Understands follow-up questions
- Maintains session context

### 2. **Enhanced Intent Detection**
- 20+ intent types
- Multi-language support (Hindi/English)
- Fuzzy matching for voice recognition errors

### 3. **Smart Entity Extraction**
- Temples, locations, dates, times
- Deities, rituals, events
- Numbers, distances, transport types

### 4. **Optimized AI Queries**
- Reformulated queries with context
- Specific instructions for each intent
- Location data integration

### 5. **Improved Accuracy**
- Confidence scoring
- Complexity assessment
- Capability identification

### 6. **Seamless Fallback**
- Works with both online and offline AI
- Graceful degradation
- Context preservation

---

## Usage Examples

### Query Agent in Action

**Input:** "मंदिर कहाँ है?"

**Agent Analysis:**
```dart
QueryAnalysis {
  originalQuery: "मंदिर कहाँ है?",
  intent: QueryIntent {
    primaryIntent: IntentType.whereQuery,
    secondaryIntents: [IntentType.templeInquiry],
    description: "User asking about location",
  },
  extractedEntities: {
    'temple': [],  // Generic temple query
    'location': [],
  },
  reformulatedQuery: "[CONTEXT] Intent: whereQuery... [QUERY] मंदिर कहाँ है? ...",
  confidenceScore: 0.75,
  complexity: QueryComplexity.moderate,
  language: "hi",
  requiresLocation: true,
}
```

---

## File Structure

```
lib/
├── models/
│   └── query_analysis.dart          # Query analysis data models
│       ├── QueryAnalysis
│       ├── QueryIntent
│       ├── QueryContext
│       ├── IntentType (enum)
│       ├── QueryComplexity (enum)
│       └── EntityType (constants)
│
├── services/
│   ├── query_agent_service.dart     # Main Query Agent logic
│   ├── hybrid_ai_service.dart       # Updated with Query Agent
│   └── offline_ai_service.dart      # Updated with Query Agent
```

---

## Key Features

✅ **Multi-language Support** - Hindi, English, and mixed  
✅ **Intent Classification** - 20+ intent types  
✅ **Entity Extraction** - Temples, locations, dates, numbers  
✅ **Context Tracking** - Conversation history and follow-ups  
✅ **Query Reformulation** - Enhanced queries for better AI responses  
✅ **Confidence Scoring** - Quality assessment of analysis  
✅ **Complexity Assessment** - Simple to complex query handling  
✅ **Capability Identification** - Required services (GPS, DB, etc.)  
✅ **Memory Management** - Session context preservation  

---

## Debugging & Monitoring

The Query Agent provides detailed logging:

```
[QueryAgent] 🧠 Analyzing query: "mahakal kitni dur hai?"
[QueryAgent] ✅ Analysis complete:
  Intent: distanceQuery
  Complexity: moderate
  Confidence: 85.0%
  Reformulated: "[CONTEXT] Intent: distanceQuery..."
```

Monitor these logs to understand how queries are being processed and improve the system over time.

---

## Future Enhancements

- **Machine Learning Intent Classification** - Train model on user queries
- **Personalization** - Learn user preferences over time
- **Multi-turn Dialogues** - Better context chaining
- **Sentiment Analysis** - Detect user mood/urgency
- **Query Suggestions** - Autocomplete based on intent
- **Analytics Dashboard** - Query patterns and insights

---

**The Query Agent Layer transforms raw user input into AI-optimized queries, ensuring more accurate, relevant, and contextually appropriate responses across both online and offline modes.**
