# 🎯 AI Agent Layer - Real-World Examples

## Complete Query Processing Examples

### Example 1: Distance Query (Hindi)

**User Input:** "mahakal kitni dur hai?"

#### Step-by-Step Processing:

**1. Normalization:**
```
Input:  "mahakal kitni dur hai?"
Output: "mahakal kitni dur hai"
```

**2. Language Detection:**
```
Result: "hi-en" (Hindi-English mixed)
```

**3. Entity Extraction:**
```dart
{
  'temple': ['mahakaleshwar'],
  'location': [],
  'number': [],
  'distance': {},
}
```

**4. Context Building:**
```dart
QueryContext {
  conversationHistory: [],
  previousIntent: null,
  userLocation: "23.1827, 75.7682",
  timeOfDay: "morning",
  isFollowUp: false,
}
```

**5. Intent Identification:**
```dart
QueryIntent {
  primaryIntent: IntentType.distanceQuery,
  secondaryIntents: [IntentType.templeInquiry],
  description: "User asking about distance",
  parameters: {
    'requiresGPS': true,
    'target': ['mahakaleshwar']
  },
}
```

**6. Complexity Assessment:**
```
Result: QueryComplexity.moderate
Reason: Requires GPS + temple database
```

**7. Requirements:**
```
requiresLocation: true
requiresRealTimeData: false
```

**8. Query Reformulation:**
```
[CONTEXT] Intent: distanceQuery. User location: 23.1827, 75.7682. 
Temples mentioned: [mahakaleshwar]. 
[QUERY] mahakal kitni dur hai?
[INSTRUCTIONS] Provide accurate distance information with walking/driving 
time estimates. Include Google Maps link if relevant.
```

**9. Capabilities:**
```
['gps', 'geocoding', 'nlp']
```

**10. Confidence Score:**
```
0.85 (85%)
- Intent clear: +0.2
- Temple entity: +0.05
- Location available: +0.1
- Base: +0.5
```

**AI Response:**
```
श्री महाकालेश्वर ज्योतिर्लिंग आपकी वर्तमान स्थिति से 2.3 किलोमीटर दूर है। 
कार से लगभग 5 मिनट या पैदल 30 मिनट का समय लगेगा।

[Google Maps पर खोलें](https://google.com/maps/dir/23.1827,75.7682/23.18312,75.76819)
```

---

### Example 2: Aarti Timing Query

**User Input:** "bhasma aarti kitne baje hoti hai?"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "bhasma aarti kitne baje hoti hai?",
  
  intent: QueryIntent {
    primaryIntent: IntentType.aartiSchedule,
    secondaryIntents: [IntentType.templeInquiry],
    description: "User asking about aarti timings",
    parameters: {},
  },
  
  extractedEntities: {
    'ritual': ['bhasma', 'aarti'],
    'time': [],
    'temple': ['mahakaleshwar'], // Inferred from 'bhasma'
  },
  
  context: QueryContext {
    timeOfDay: "evening",
    isFollowUp: false,
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: aartiSchedule. Current time of day: evening. 
    Temples mentioned: [mahakaleshwar]. 
    [QUERY] bhasma aarti kitne baje hoti hai?
    [INSTRUCTIONS] Provide detailed aarti timings (both summer and winter 
    schedules if applicable). Mention special requirements or dress codes.
  """,
  
  confidenceScore: 0.9,
  complexity: QueryComplexity.simple,
  language: "hi-en",
  requiresLocation: false,
  requiresRealTimeData: true,
}
```

**AI Response:**
```
भस्म आरती प्रतिदिन प्रातः 4:00 बजे से 6:00 बजे तक होती है (गर्मी और सर्दी दोनों में)।

विशेष निर्देश:
🕉️ भस्म आरती के लिए ऑनलाइन पास की आवश्यकता होती है
👔 पुरुष: धोती/कुर्ता अनिवार्य
👗 महिला: साड़ी अनिवार्य
🚪 प्रवेश: गेट नं. 1 (नंदी द्वार)
💰 शीघ्र दर्शन पास: ₹250 (गेट 4 पर उपलब्ध)

बुकिंग: https://shrimahakaleshwar.mp.gov.in
```

---

### Example 3: Follow-up Question

**Previous Query:** "tell me about mahakaleshwar temple"  
**Previous Response:** [Temple information provided]

**User Input:** "how to reach there?"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "how to reach there?",
  
  intent: QueryIntent {
    primaryIntent: IntentType.directionQuery,
    secondaryIntents: [],
    description: "User asking for directions",
    parameters: {'requiresGPS': true},
  },
  
  extractedEntities: {
    'location': [],
    'transport': [],
  },
  
  context: QueryContext {
    conversationHistory: [
      "tell me about mahakaleshwar temple",
    ],
    previousIntent: "templeInquiry",
    referencedTopic: "mahakaleshwar temple",
    userLocation: "23.1827, 75.7682",
    isFollowUp: true, // 🔑 Detected as follow-up
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: directionQuery. Previous topic: mahakaleshwar temple. 
    User location: 23.1827, 75.7682. 
    [QUERY] how to reach there?
    [INSTRUCTIONS] Provide clear step-by-step directions. Mention landmarks 
    along the route. Suggest best mode of transport.
  """,
  
  confidenceScore: 0.8,
  complexity: QueryComplexity.moderate,
  language: "en",
  requiresLocation: true,
}
```

**AI Response:**
```
From your current location to Shri Mahakaleshwar Temple:

🚗 By Auto/Taxi (Recommended):
- Head south on Main Road
- Turn right at Vikramaditya Clock Tower
- Continue straight for 1.5 km
- Temple will be on your left
- Estimated time: 5-8 minutes
- Approximate cost: ₹80-100

🚶 Walking Route:
- Distance: 2.3 km
- Time: 25-30 minutes
- Route: Main Road → Clock Tower → Temple Path

🅿️ Parking: Available near Gate 4 (₹20/hour)

[Open in Google Maps](https://google.com/maps/dir/...)
```

---

### Example 4: Complex Multi-Intent Query

**User Input:** "simhastha 2028 me kitne hotels hai aur prices kya hain?"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "simhastha 2028 me kitne hotels hai aur prices kya hain?",
  
  intent: QueryIntent {
    primaryIntent: IntentType.hotelInquiry,
    secondaryIntents: [
      IntentType.simhasthaInquiry,
      IntentType.comparison,
    ],
    description: "User asking about accommodation with pricing during event",
    parameters: {
      'event': 'simhastha',
      'year': '2028',
      'requiresPricing': true,
    },
  },
  
  extractedEntities: {
    'event': ['simhastha'],
    'date': ['2028'],
    'accommodation': ['hotels'],
    'number': [],
  },
  
  context: QueryContext {
    conversationHistory: [],
    isFollowUp: false,
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: hotelInquiry. Secondary intents: simhasthaInquiry, 
    comparison. Event mentioned: Simhastha 2028. 
    [QUERY] simhastha 2028 me kitne hotels hai aur prices kya hain?
    [INSTRUCTIONS] Suggest accommodations with approximate prices, locations, 
    and contact information. Consider pilgrim budget options. Mention that 
    prices increase during Simhastha period.
  """,
  
  confidenceScore: 0.9,
  complexity: QueryComplexity.complex, // 🔑 Multiple intents + pricing
  language: "hi-en",
  requiresLocation: false,
  requiresRealTimeData: true,
}
```

**AI Response:**
```
सिंहस्थ 2028 के दौरान उज्जैन में विभिन्न प्रकार के आवास उपलब्ध होंगे:

🏨 होटल (Hotels):
1. होटल शिवा पैलेस - ₹2,000-3,500/रात
   📍 महाकाल मार्ग (मंदिर से 1 किमी)
   ☎️ +91-734-2551234

2. गंगा व्यू होटल - ₹1,500-2,500/रात
   📍 राम घाट के पास
   ☎️ +91-734-2552345

🕉️ धर्मशाला (Dharamshalas):
- पंजाब धर्मशाला - ₹200-500/रात
- गुजरात धर्मशाला - ₹300-600/रात
- राजस्थान धर्मशाला - ₹250-550/रात

⛺ अस्थायी शिविर (Temporary Tents):
- सरकारी शिविर - ₹100-300/रात
- निजी शिविर - ₹500-1,000/रात

⚠️ महत्वपूर्ण नोट:
• सिंहस्थ के दौरान दरें 2-3 गुना बढ़ सकती हैं
• पहले से बुकिंग अनिवार्य
• शाही स्नान के दिन और भी अधिक दरें

📝 बुकिंग: 6 महीने पहले से शुरू कर दें
```

---

### Example 5: Calculation Query

**User Input:** "45 km ko miles me convert karo"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "45 km ko miles me convert karo",
  
  intent: QueryIntent {
    primaryIntent: IntentType.conversion,
    secondaryIntents: [],
    description: "User requesting calculation",
    parameters: {
      'operation': 'conversion',
      'from': 'km',
      'to': 'miles',
      'value': 45,
    },
  },
  
  extractedEntities: {
    'number': [45.0],
    'distance': {'value': 45.0, 'unit': 'km'},
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: conversion. 
    [QUERY] 45 km ko miles me convert karo
    [INSTRUCTIONS] Perform the calculation accurately and show the result clearly.
  """,
  
  confidenceScore: 1.0, // 🔑 Perfect confidence for calculations
  complexity: QueryComplexity.simple,
  language: "hi-en",
  requiresLocation: false,
}
```

**AI Response:**
```
45 किलोमीटर = 27.96 मील (miles)

📐 फॉर्मूला: 1 km = 0.621371 miles
🔢 गणना: 45 × 0.621371 = 27.96 miles
```

---

### Example 6: Greeting with Context

**User Input:** "namaste! main first time ujjain aa raha hu"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "namaste! main first time ujjain aa raha hu",
  
  intent: QueryIntent {
    primaryIntent: IntentType.greeting,
    secondaryIntents: [IntentType.generalInformation],
    description: "User greeting with first-time visitor context",
    parameters: {
      'firstTimeVisitor': true,
      'location': 'ujjain',
    },
  },
  
  extractedEntities: {
    'location': ['ujjain'],
  },
  
  context: QueryContext {
    conversationHistory: [],
    sessionData: {
      'userProfile': 'firstTimeVisitor',
    },
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: greeting. User is first-time visitor to Ujjain. 
    [QUERY] namaste! main first time ujjain aa raha hu
    [INSTRUCTIONS] Respond warmly and ask how you can assist with their 
    Ujjain pilgrimage. Provide helpful first-time visitor tips.
  """,
  
  confidenceScore: 0.85,
  complexity: QueryComplexity.simple,
  language: "hi",
}
```

**AI Response:**
```
🙏 नमस्ते! उज्जैन में आपका स्वागत है!

मैं आपकी सिंहस्थ नगरी उज्जैन की यात्रा में मदद के लिए यहाँ हूँ। 
पहली बार आ रहे हैं तो यह जानकारी आपके लिए उपयोगी होगी:

🕉️ प्रमुख दर्शनीय स्थल:
1. श्री महाकालेश्वर ज्योतिर्लिंग (भस्म आरती अवश्य देखें)
2. श्री काल भैरव मंदिर
3. माँ हरसिद्धि शक्तिपीठ
4. राम घाट (संध्या आरती)

📋 यात्रा सुझाव:
✅ भस्म आरती के लिए ऑनलाइन पास बुक करें
✅ मंदिर में उचित पोशाक (धोती/साड़ी) पहनें
✅ सुबह जल्दी दर्शन के लिए निकलें
✅ स्थानीय मिठाइयाँ अवश्य खाएं

क्या आप किसी विशेष मंदिर, आवास, या यात्रा मार्ग के बारे में जानना चाहेंगे?
```

---

### Example 7: Ambiguous Query

**User Input:** "वहाँ कैसे जाएं?"

#### Analysis Output:

```dart
QueryAnalysis {
  originalQuery: "वहाँ कैसे जाएं?",
  
  intent: QueryIntent {
    primaryIntent: IntentType.unknown,
    secondaryIntents: [],
    description: "Ambiguous query - unclear reference",
    parameters: {},
  },
  
  extractedEntities: {},
  
  context: QueryContext {
    conversationHistory: [], // No previous context!
    previousIntent: null,
    isFollowUp: true, // Detected as follow-up but no context
  },
  
  reformulatedQuery: """
    [CONTEXT] Intent: unknown. Query is ambiguous - needs clarification. 
    [QUERY] वहाँ कैसे जाएं?
    [INSTRUCTIONS] Ask user to clarify which location they're referring to.
  """,
  
  confidenceScore: 0.3, // 🔑 Low confidence
  complexity: QueryComplexity.ambiguous, // 🔑 Needs clarification
  language: "hi",
}
```

**AI Response:**
```
मैं मदद करना चाहता हूँ! कृपया बताएं आप किस स्थान पर जाना चाहते हैं?

उदाहरण के लिए:
🕉️ महाकालेश्वर मंदिर
🔱 काल भैरव मंदिर
🏨 होटल/धर्मशाला
🚂 रेलवे स्टेशन
🚌 बस स्टैंड

कृपया स्थान का नाम बताएं।
```

---

## Pattern Recognition Examples

### Temple Name Variations

The Query Agent recognizes multiple variations:

```dart
"mahakal" → mahakaleshwar ✅
"महाकाल" → mahakaleshwar ✅
"mahakaleshwar" → mahakaleshwar ✅
"jyotirlinga" → mahakaleshwar ✅
"महाकालेश्वर" → mahakaleshwar ✅

"bhairav" → kal_bhairav ✅
"भैरव" → kal_bhairav ✅
"kaal bhairav" → kal_bhairav ✅
"kaala bhairava" → kal_bhairav ✅
```

### Distance Keywords

```dart
"kitni dur" → distanceQuery ✅
"how far" → distanceQuery ✅
"दूरी" → distanceQuery ✅
"distance" → distanceQuery ✅
"km away" → distanceQuery ✅
"पास" → nearbySearch ✅
"नजदीक" → nearbySearch ✅
"nearby" → nearbySearch ✅
```

### Time Expressions

```dart
"4 am" → ['4 am'] ✅
"4:00 AM" → ['4:00 AM'] ✅
"सुबह" → ['morning'] ✅
"morning" → ['morning'] ✅
"प्रातः काल" → ['morning'] ✅
```

---

## Benefits Demonstrated

### ✅ Context Preservation
Follow-up questions work seamlessly because the agent remembers previous topics.

### ✅ Multi-language Support
Hindi, English, and mixed queries all processed correctly.

### ✅ Entity Recognition
Automatically extracts temples, locations, times, numbers without manual parsing.

### ✅ Intent Classification
Identifies what the user wants to accomplish, not just keywords.

### ✅ Query Enhancement
Reformulated queries provide AI models with rich context for better responses.

### ✅ Confidence Scoring
System knows when it's unsure and can ask for clarification.

### ✅ Complexity Awareness
Simple queries get fast responses; complex queries get detailed processing.

---

## Testing the Query Agent

You can test with various inputs:

**Simple:**
- "hello"
- "2+2"
- "ujjain weather"

**Moderate:**
- "mahakal timing"
- "hotels near temple"
- "shahi snan date"

**Complex:**
- "compare hotels near mahakal and bhairav under 2000 rupees"
- "ujjain se indore bus timing aur price"
- "simhastha 2028 first shahi snan ke din accommodation"

**Ambiguous:**
- "वहाँ"
- "this"
- "how much?"

---

**The Query Agent Layer ensures every user query is understood, contextualized, and optimally formatted for the AI model, resulting in significantly better responses!**
