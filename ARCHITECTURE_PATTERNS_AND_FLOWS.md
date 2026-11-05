# 🏗️ Architecture Patterns & Data Flows

**Ujjain Live Codebase - Advanced Architecture Patterns**

---

## TABLE OF CONTENTS

1. [Design Patterns Used](#1-design-patterns-used)
2. [Singleton Pattern](#2-singleton-pattern)
3. [Provider Pattern](#3-provider-pattern)
4. [Factory Pattern](#4-factory-pattern)
5. [Strategy Pattern](#5-strategy-pattern)
6. [Observer Pattern](#7-observer-pattern)
7. [Dependency Injection](#8-dependency-injection)
8. [State Management Flow](#9-state-management-flow)
9. [API Response Handling](#10-api-response-handling)
10. [Error Recovery Patterns](#11-error-recovery-patterns)
11. [Caching Strategies](#12-caching-strategies)
12. [Real-World Usage Examples](#13-real-world-usage-examples)

---

## 1. DESIGN PATTERNS USED

This codebase implements industry-standard design patterns:

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Singleton** | All Services (AIService, OfflineAIService, etc) | Single instance per app lifetime |
| **Provider** | ChatProvider | Reactive state management |
| **Factory** | HybridAIService | Create appropriate AI service instance |
| **Strategy** | Online vs Offline AI | Switch algorithms at runtime |
| **Observer** | NetworkService listeners | React to connectivity changes |
| **Repository** | StorageService | Abstract data layer |
| **Adapter** | LocationService | Wrap platform-specific code |
| **Template Method** | AI response generation | Standardize processing steps |
| **Decorator** | Message metadata | Add metadata to core objects |
| **Chain of Responsibility** | Error handling | Try multiple fallbacks |

---

## 2. SINGLETON PATTERN

**Purpose:** Ensure only one instance of a service exists throughout app lifetime

**Examples in Codebase:**

### AIService Singleton
```dart
class AIService {
  static final AIService _instance = AIService._internal();
  
  factory AIService() => _instance;  // Return same instance
  
  AIService._internal();  // Private constructor prevents new instances
  
  // Service implementation
  Future<String> generateResponse({ ... }) async { ... }
}

// Usage
final aiService1 = AIService();
final aiService2 = AIService();
assert(aiService1 == aiService2); // True - same instance
```

### OfflineAIService Singleton
```dart
class OfflineAIService {
  static final OfflineAIService _instance = OfflineAIService._internal();
  
  factory OfflineAIService() => _instance;
  
  OfflineAIService._internal() {
    // Initialize embedded knowledge base once
    _landmarks = {...};
    _cities = {...};
    _hotels = {...};
  }
}
```

### LocationService Singleton
```dart
class LocationService {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() => _instance;
  
  LocationService._internal() {
    _lastKnownLocation = null;
  }
  
  // Cached location persists for app lifetime
  LocationInfo? _lastKnownLocation;
}
```

**Benefits:**
- ✅ Shared state across entire app
- ✅ No duplicate network requests
- ✅ Efficient memory usage
- ✅ Thread-safe (Dart is single-threaded)
- ✅ Easy testing with mock factories

---

## 3. PROVIDER PATTERN

**Purpose:** Separate business logic from UI, enable reactive updates

**ChatProvider Implementation:**

```dart
import 'package:flutter/foundation.dart';

class ChatProvider with ChangeNotifier {
  // Business logic (not tied to UI)
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isGeneratingResponse = false;
  LocationInfo? _currentLocation;
  
  // Services (injected)
  final HybridAIService _aiService = HybridAIService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();
  
  // Getters (expose state to UI)
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  bool get isGeneratingResponse => _isGeneratingResponse;
  LocationInfo? get currentLocation => _currentLocation;
  
  // Methods (business logic)
  Future<void> sendMessage(String userMessage) async {
    _isGeneratingResponse = true;
    notifyListeners();  // Trigger UI rebuild
    
    try {
      // Call service
      final response = await _aiService.generateResponse(...);
      
      // Update state
      _currentSession?.messages.add(Message(...));
      
      // Notify UI of changes
      notifyListeners();
    } catch (e) {
      print('Error: $e');
    } finally {
      _isGeneratingResponse = false;
      notifyListeners();
    }
  }
}

// Usage in UI (automatic rebuild on change)
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    return Column(
      children: [
        if (chatProvider.isGeneratingResponse)
          CircularProgressIndicator(),
        ...chatProvider.chatSessions.map((session) => 
          Text(session.title)
        ),
      ],
    );
  },
)
```

**UI Rebuild Mechanism:**
```
User Action (e.g., tap send button)
    ↓
chatProvider.sendMessage("Hello")
    ↓
Business logic processes (AI call, DB save, etc)
    ↓
State changes (isGeneratingResponse, messages, etc)
    ↓
notifyListeners() called
    ↓
All Consumer<ChatProvider> widgets rebuild
    ↓
UI displays new state
```

---

## 4. FACTORY PATTERN

**Purpose:** Create appropriate object based on conditions

### HybridAIService Factory Decision
```dart
class HybridAIService {
  Future<String> generateResponse({
    required String userMessage,
    required ChatSession session,
    LocationInfo? locationInfo,
  }) async {
    // Step 1: Analyze query
    final analysis = await _queryAgent.analyzeQuery(
      userQuery: userMessage,
      session: session,
      locationInfo: locationInfo,
    );
    
    // Step 2: Decide which service to use (Factory logic)
    final hasConnection = _networkService.hasInternetAccess;
    final isApiKeyConfigured = _isApiKeyConfigured();
    
    // Factory: Create/select appropriate service
    if (hasConnection && isApiKeyConfigured) {
      print('[HybridAI] 🌐 Routing to Online AI Service');
      return _onlineAIService.generateResponse(
        userMessage: analysis.reformulatedQuery,  // Use reformulated
        session: session,
        locationInfo: locationInfo,
      );
    } else {
      print('[HybridAI] 📱 Routing to Offline AI Service');
      return _offlineAIService.generateResponse(
        userMessage: analysis.reformulatedQuery,
        session: session,
        locationInfo: locationInfo,
      );
    }
  }
}
```

**Decision Tree:**
```
                    ┌─────────────────────────┐
                    │   Analyze Query         │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │ Check Connectivity      │
                    ├───────────┬──────────────┤
        Online (YES) │         │ Offline (NO)
        ──────────────┘         └──────────────┐
                    ┌────────────────────────┐ │
                    │ Check API Key Configured
                    ├───────────┬────────────┤ │
        Configured   │         │ Not Config │ │
        ──────────────┘         └──────────┬─┘─┤
                    ┌────────────────────────│──┴─┐
                    │ SELECT SERVICE          │    │
            ┌───────▼────────┐         ┌────▼─────▼──┐
            │ Online AI      │         │ Offline AI  │
            │ (GPT, OpenRoute│         │ (Embedded)  │
            │  Gemini)       │         │             │
            └────────────────┘         └─────────────┘
```

---

## 5. STRATEGY PATTERN

**Purpose:** Define multiple algorithms and switch between them at runtime

### AI Response Generation Strategies

```dart
// Strategy 1: Online AI Strategy
Future<String> _generateOnlineResponse({
  required String reformulatedQuery,
  required ChatSession session,
}) async {
  // Use OpenAI/OpenRouter/Gemini
  // Quality: 95% (state-of-art models)
  // Speed: 1-3 seconds
  // Cost: $$ per token
  // Requires: Internet + API key
  
  final messages = _buildConversationHistory(session);
  final response = await _dio.post(
    apiUrl,
    data: jsonEncode({
      'model': 'openai/gpt-4o-mini',
      'messages': [...systemPrompt, ...messages],
      'max_tokens': 1500,
      'temperature': 0.7,
    }),
  );
  
  return response.data['choices'][0]['message']['content'];
}

// Strategy 2: Offline AI Strategy
Future<String> _generateOfflineResponse({
  required String reformulatedQuery,
  required ChatSession session,
}) async {
  // Use embedded knowledge + pattern matching
  // Quality: 85% (for common queries)
  // Speed: <100ms
  // Cost: Free
  // Requires: None (fully offline)
  
  // Step 1: Detect intent
  final intent = _identifyIntent(reformulatedQuery);
  
  // Step 2: Extract entities
  final entities = _extractEntities(reformulatedQuery);
  
  // Step 3: Generate response from templates
  return _generateResponseFromTemplate(intent, entities);
}

// Usage: Switch strategies based on conditions
Future<String> generateResponse({...}) async {
  if (_shouldUseOnlineStrategy()) {
    return _generateOnlineResponse(...);
  } else {
    return _generateOfflineResponse(...);
  }
}

bool _shouldUseOnlineStrategy() {
  return _networkService.hasInternetAccess &&
         _isApiKeyConfigured() &&
         !_forceOfflineMode;
}
```

**Strategy Comparison Matrix:**

| Aspect | Online Strategy | Offline Strategy |
|--------|-----------------|-----------------|
| **Quality** | 95% (GPT-4o) | 85% (pattern-based) |
| **Speed** | 1-3 sec | <100ms |
| **Cost** | $$ per request | Free |
| **Requires** | Internet + API | None |
| **Coverage** | All queries | Common only |
| **Use Case** | Best quality needed | Fallback/Reliability |

---

## 6. OBSERVER PATTERN

**Purpose:** Notify multiple observers when state changes

### Connectivity Observer Example

```dart
class NetworkService {
  late StreamController<ConnectivityResult> _connectivityStream;
  
  Stream<ConnectivityResult> get onConnectivityChanged =>
    _connectivityStream.stream;
  
  Future<void> initialize() async {
    _connectivityStream = StreamController.broadcast();
    
    // Listen for system connectivity changes
    Connectivity().onConnectivityChanged.listen(
      (result) {
        _hasInternetAccess = _isReallyConnected(result);
        print('[NetworkService] Connectivity changed: $_hasInternetAccess');
        
        // Notify all observers (broadcast)
        _connectivityStream.add(result);
      },
    );
  }
}

// Observer 1: ChatProvider listens
class ChatProvider with ChangeNotifier {
  Future<void> initialize() async {
    await _aiService.initialize();
    
    // Subscribe to connectivity changes
    _aiService.onConnectivityChanged.listen((_) {
      _isOnline = _aiService.isOnline;
      notifyListeners();  // Rebuild UI
    });
  }
}

// Observer 2: UI directly listens
class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    
    // Subscribe to connectivity stream
    context.read<ChatProvider>().onConnectivityChanged.listen((_) {
      setState(() {}); // Rebuild with new status
    });
  }
}
```

**Observer Flow:**
```
NetworkService (Observable)
    │
    ├─ Detects connectivity change
    ├─ Updates _hasInternetAccess
    ├─ Broadcasts via StreamController
    │
    ├─ Observer 1: ChatProvider
    │  ├─ Updates _isOnline
    │  ├─ Calls notifyListeners()
    │  └─ Triggers UI rebuild
    │
    └─ Observer 2: ChatScreen
       ├─ Receives event
       ├─ Updates UI directly
       └─ Shows online/offline indicator
```

---

## 7. REPOSITORY PATTERN

**Purpose:** Abstract data access, provide single interface to data

```dart
class StorageService implements StorageRepository {
  late Database _database;
  
  Future<void> initialize() async {
    final dbPath = await getDatabasePath();
    _database = await openDatabase(dbPath);
    await _createTables();
  }
  
  // Repository interface
  Future<void> saveChatSession(ChatSession session) async {
    await _database.insert(
      'chat_sessions',
      session.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<ChatSession>> getAllChatSessions() async {
    final maps = await _database.query('chat_sessions');
    return maps.map((map) => ChatSession.fromJson(map)).toList();
  }
  
  Future<void> addMessageToSession(
    String sessionId,
    Message message,
  ) async {
    await _database.insert('messages', {
      'id': message.id,
      'session_id': sessionId,
      'content': message.content,
      'sender': message.sender.toString(),
      'timestamp': message.timestamp.toIso8601String(),
    });
  }
}

// Usage (UI code doesn't know about SQLite)
class ChatProvider {
  final StorageService _storage = StorageService();
  
  Future<void> _loadChatSessions() async {
    _chatSessions = await _storage.getAllChatSessions();
    notifyListeners();
  }
  
  Future<void> sendMessage(String text) async {
    // ... generate response ...
    
    // Save via repository (abstracted)
    await _storage.addMessageToSession(
      _currentSession!.id,
      userMessage,
    );
  }
}
```

**Benefits:**
- ✅ UI code doesn't know about SQLite
- ✅ Can swap SQLite for Hive without changing UI
- ✅ Easier testing (mock repository)
- ✅ Single responsibility

---

## 8. DEPENDENCY INJECTION

**Purpose:** Inject dependencies rather than creating them internally

```dart
// Without DI (tightly coupled)
class ChatProvider {
  // Creates instances internally
  final HybridAIService _aiService = HybridAIService();
  final StorageService _storage = StorageService();
  
  // Hard to test - can't use mock services
}

// With DI (loosely coupled)
class ChatProvider {
  final HybridAIService _aiService;
  final StorageService _storage;
  final LocationService _location;
  
  // Dependencies injected via constructor
  ChatProvider({
    required HybridAIService aiService,
    required StorageService storage,
    required LocationService location,
  })
    : _aiService = aiService,
      _storage = storage,
      _location = location;
}

// Usage with real services
final provider = ChatProvider(
  aiService: HybridAIService(),
  storage: StorageService(),
  location: LocationService(),
);

// Usage with mocks (for testing)
final mockProvider = ChatProvider(
  aiService: MockAIService(),
  storage: MockStorageService(),
  location: MockLocationService(),
);

// Provided via Provider widget
ChangeNotifierProvider(
  create: (_) => ChatProvider(
    aiService: HybridAIService(),
    storage: StorageService(),
    location: LocationService(),
  ),
  child: MyApp(),
)
```

---

## 9. STATE MANAGEMENT FLOW

**Complete State Management Cycle:**

```
┌──────────────────────────────────────────────────────────────┐
│           COMPLETE STATE MANAGEMENT CYCLE                     │
└──────────────────────────────────────────────────────────────┘

1️⃣ INITIAL STATE
   ├─ _chatSessions = []
   ├─ _currentSession = null
   ├─ _isGeneratingResponse = false
   └─ _currentLocation = null

2️⃣ INITIALIZE PROVIDER
   await provider.initialize()
   ├─ Load chat sessions from SQLite
   ├─ Initialize AI service
   ├─ Get current location
   └─ Listen for connectivity changes

3️⃣ USER SENDS MESSAGE
   Provider.sendMessage("Hello")
   │
   ├─ Create user Message object
   ├─ Add to currentSession.messages
   ├─ Call notifyListeners() → UI updates
   │
   └─ Set _isGeneratingResponse = true
      ├─ Show loading spinner
      └─ Disable input field

4️⃣ AI GENERATES RESPONSE
   await _aiService.generateResponse()
   │
   ├─ Query Agent analyzes
   ├─ Routes to online/offline AI
   ├─ AI generates response
   │
   └─ Return response string

5️⃣ UPDATE STATE WITH RESPONSE
   ├─ Create AI Message object
   ├─ Add to currentSession.messages
   ├─ Save to SQLite
   │
   ├─ Set _isGeneratingResponse = false
   └─ Call notifyListeners() → UI rebuilds
      ├─ Hide loading spinner
      ├─ Display AI message
      └─ Enable input field

6️⃣ CONNECTIVITY CHANGE DETECTED
   _aiService.onConnectivityChanged fires
   │
   ├─ Update _isOnline flag
   ├─ Call notifyListeners()
   │
   └─ UI updates with online/offline indicator

7️⃣ FOLLOW-UP MESSAGE
   Provider.sendMessage("Tell me more")
   │
   ├─ Query includes full conversation history
   ├─ Context-aware response generated
   ├─ Add both messages to session
   │
   └─ Cycle repeats from step 3
```

**State Variables Hierarchy:**
```
ChatProvider (root state)
├─ _isInitialized: bool
│  └─ Indicates if setup complete
│
├─ _chatSessions: List<ChatSession>
│  └─ All conversations
│     └─ ChatSession
│        └─ messages: List<Message>
│           └─ Message
│              ├─ content: String
│              ├─ sender: Enum (user/ai)
│              └─ metadata: Map
│
├─ _currentSession: ChatSession?
│  └─ Active conversation
│
├─ _isLoading: bool
│  └─ Initial app load
│
├─ _isGeneratingResponse: bool
│  └─ AI thinking indicator
│
├─ _isOnline: bool
│  └─ Network status
│
├─ _currentLocation: LocationInfo?
│  └─ GPS coordinates
│
└─ _error: String?
   └─ Error message to display
```

---

## 10. API RESPONSE HANDLING

**Complete API Call Lifecycle:**

```dart
// Scenario: Fetch temples from backend

Future<List<Temple>> fetchTemples() async {
  // STEP 1: Check cache
  if (_isCacheFresh('temples', 15.minutes)) {
    print('📦 Using cached temples');
    return _cache['temples'] as List<Temple>;
  }
  
  print('🌐 Fetching temples from backend...');
  
  try {
    // STEP 2: Make request
    final response = await _dio.get(
      '${AppConstants.backendBaseUrl}/api/temples',
      options: Options(
        receiveTimeout: Duration(seconds: 10),
        connectTimeout: Duration(seconds: 5),
      ),
    );
    
    // STEP 3: Validate status code
    if (response.statusCode != 200) {
      throw HttpException(
        'Server error: ${response.statusCode}',
      );
    }
    
    // STEP 4: Parse JSON
    final data = response.data;
    if (data is! List) {
      throw FormatException('Expected list of temples');
    }
    
    // STEP 5: Map to objects
    final temples = data
      .map((json) {
        try {
          return Temple.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Error parsing temple: $e');
          return null;
        }
      })
      .whereType<Temple>()
      .toList();
    
    // STEP 6: Cache result
    _cache['temples'] = temples;
    _cacheTimestamp['temples'] = DateTime.now();
    print('✅ Temples cached (${temples.length} items)');
    
    // STEP 7: Return result
    return temples;
    
  } on DioException catch (e) {
    // STEP 8: Handle Dio errors
    print('❌ Dio error: ${e.type}');
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('⏱️ Connection timeout');
        return _getOfflineTemples();
        
      case DioExceptionType.receiveTimeout:
        print('⏱️ Receive timeout');
        return _getOfflineTemples();
        
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          print('🌐 No internet');
          return _getOfflineTemples();
        }
        rethrow;
        
      default:
        rethrow;
    }
    
  } on FormatException catch (e) {
    // STEP 9: Handle parsing errors
    print('📄 JSON parsing error: $e');
    return _getOfflineTemples();
    
  } catch (e) {
    // STEP 10: Handle unexpected errors
    print('⚠️ Unexpected error: $e');
    return _getOfflineTemples();
  }
}
```

**API Error Handling Flow:**

```
API Request
    ↓
┌─ Timeout? → Use offline data
├─ Network error? → Use offline data
├─ 404 Not found? → Use offline data
├─ 401 Unauthorized? → Show login
├─ 429 Rate limit? → Try fallback model
├─ 500 Server error? → Retry after 5s
├─ JSON parse error? → Use default data
└─ Success (200) → Parse & cache
```

---

## 11. ERROR RECOVERY PATTERNS

### Pattern 1: Fallback Chain

```dart
Future<String> getAIResponse(String query) async {
  try {
    // Attempt 1: Online AI
    return await _onlineAIService.generateResponse(query);
  } catch (e1) {
    print('⚠️ Online AI failed: $e1');
    
    try {
      // Attempt 2: Offline AI
      return await _offlineAIService.generateResponse(query);
    } catch (e2) {
      print('⚠️ Offline AI failed: $e2');
      
      // Attempt 3: Template response
      return 'मुझे समझ नहीं आया। कृपया फिर से पूछें। '
             '(I didn\'t understand. Please ask again.)';
    }
  }
}
```

**Fallback Flow:**
```
Online AI (best quality)
    ↓ (fails)
Offline AI (good quality)
    ↓ (fails)
Generic template (minimum)
```

### Pattern 2: Retry with Exponential Backoff

```dart
Future<T> retryWithBackoff<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  int attempt = 0;
  Duration delay = initialDelay;
  
  while (attempt < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      
      if (attempt >= maxAttempts) {
        print('❌ All $maxAttempts attempts failed');
        rethrow;
      }
      
      print('⚠️ Attempt $attempt failed, retrying in ${delay.inMilliseconds}ms');
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff: 100ms → 200ms → 400ms
    }
  }
}

// Usage
final response = await retryWithBackoff(
  operation: () => _dio.get(apiUrl),
  maxAttempts: 3,
);
```

### Pattern 3: Circuit Breaker

```dart
class CircuitBreaker {
  bool _isBroken = false;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  
  static const int FAILURE_THRESHOLD = 5;
  static const Duration RESET_TIMEOUT = Duration(seconds: 60);
  
  bool get isOpen => _isBroken;
  
  Future<T> execute<T>(
    Future<T> Function() operation,
  ) async {
    // Check if circuit should reset
    if (_isBroken) {
      if (DateTime.now().difference(_lastFailureTime ?? DateTime.now())
          .compareTo(RESET_TIMEOUT) > 0) {
        print('🔄 Circuit Breaker: Attempting reset');
        _isBroken = false;
        _failureCount = 0;
      } else {
        throw Exception('Circuit breaker is OPEN');
      }
    }
    
    try {
      final result = await operation();
      
      // Success - reset failures
      if (_failureCount > 0) {
        print('✅ Circuit Breaker: Operation succeeded');
        _failureCount = 0;
      }
      
      return result;
    } catch (e) {
      _failureCount++;
      _lastFailureTime = DateTime.now();
      
      if (_failureCount >= FAILURE_THRESHOLD) {
        print('🚨 Circuit Breaker: OPENING after $_failureCount failures');
        _isBroken = true;
      }
      
      rethrow;
    }
  }
}

// Usage
final breaker = CircuitBreaker();

try {
  final temples = await breaker.execute(
    () => backendService.fetchTemples(),
  );
} catch (e) {
  print('Service unavailable: $e');
}
```

---

## 12. CACHING STRATEGIES

### Cache with TTL (Time-To-Live)

```dart
class CacheManager<T> {
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _timestamps = {};
  final Duration _ttl;
  
  CacheManager({required this.ttl});
  
  // Get from cache if fresh
  T? get(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _timestamps[key]!;
    if (DateTime.now().difference(timestamp) > _ttl) {
      // Expired - remove
      _cache.remove(key);
      _timestamps.remove(key);
      return null;
    }
    
    return _cache[key];
  }
  
  // Set in cache
  void set(String key, T value) {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }
  
  // Clear all
  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
  
  // Clear expired
  void clearExpired() {
    final now = DateTime.now();
    final expiredKeys = _timestamps.entries
      .where((e) => now.difference(e.value) > _ttl)
      .map((e) => e.key)
      .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _timestamps.remove(key);
    }
  }
}

// Usage
final templeCache = CacheManager<List<Temple>>(
  ttl: Duration(minutes: 15),
);

Future<List<Temple>> getTemples() async {
  // Check cache first
  final cached = templeCache.get('temples');
  if (cached != null) {
    print('📦 Using cached temples');
    return cached;
  }
  
  // Fetch and cache
  final temples = await backendService.fetchTemples();
  templeCache.set('temples', temples);
  return temples;
}
```

### LRU Cache (Least Recently Used)

```dart
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _data = {};
  final List<K> _accessOrder = [];
  
  LRUCache({required this.maxSize});
  
  V? get(K key) {
    if (!_data.containsKey(key)) return null;
    
    // Move to end (most recently used)
    _accessOrder.remove(key);
    _accessOrder.add(key);
    
    return _data[key];
  }
  
  void put(K key, V value) {
    if (_data.containsKey(key)) {
      _accessOrder.remove(key);
    }
    
    _data[key] = value;
    _accessOrder.add(key);
    
    // Remove oldest if size exceeded
    if (_data.length > maxSize) {
      final lruKey = _accessOrder.removeAt(0);
      _data.remove(lruKey);
    }
  }
}

// Usage: Keep 50 most recently accessed landmarks
final landmarkCache = LRUCache<String, Landmark>(maxSize: 50);

Landmark getLandmark(String id) {
  final cached = landmarkCache.get(id);
  if (cached != null) return cached;
  
  final landmark = _landmarks[id];
  landmarkCache.put(id, landmark);
  return landmark;
}
```

---

## 13. REAL-WORLD USAGE EXAMPLES

### Example 1: User Asks About Nearby Hotels

```
┌─────────────────────────────────────────────────────────┐
│   USER: "मेरे पास होटल कहाँ मिलेगा?"                  │
│   (Where will I find hotels near me?)                  │
└─────────────────────────────────────────────────────────┘
    ↓
┌─ CHATPROVIDER.SENDMESSAGE                              ┐
│                                                        │
│  1️⃣ Create user message                               │
│  2️⃣ Show in UI                                        │
│  3️⃣ Set isGeneratingResponse = true                   │
└────────────────────────────────────────────────────────┘
    ↓
┌─ HYBRIDAISERVICE.GENERATERESPONSE                      ┐
│                                                        │
│  1️⃣ QueryAgent.analyzeQuery()                        │
│     ├─ Language: "hi" (Hindi)                         │
│     ├─ Intent: "accommodation_inquiry"                │
│     ├─ Entities: 
│     │  ├─ location: ["near me", "nearby"]             │
│     │  └─ accommodation_type: ["hotel"]               │
│     ├─ Requires location: YES                         │
│     ├─ Requires real-time data: YES                   │
│     └─ Reformulated:                                  │
│        "I'm looking for hotels near my current        │
│         location in Ujjain. My coordinates are        │
│         23.1827, 75.7682. Show me 3-5 star hotels   │
│         with price range and contact info. In Hindi." │
│                                                        │
│  2️⃣ Check connectivity: ONLINE                        │
│  3️⃣ Route to OnlineAIService                         │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ AISERVICE.GENERATERESPONSE (Online)                   ┐
│                                                        │
│  1️⃣ Build system prompt (Simhastha context)          │
│  2️⃣ Include conversation history (3 previous msgs)   │
│  3️⃣ Prepare payload:                                 │
│     {                                                 │
│       "model": "openai/gpt-4o-mini",                 │
│       "messages": [                                   │
│         { "role": "system",                           │
│           "content": "You are helpful Ujjain guide..."│
│         },                                            │
│         { "role": "user",                             │
│           "content": "Reformulated query..."          │
│         }                                             │
│       ],                                              │
│       "max_tokens": 1500,                             │
│       "temperature": 0.7                              │
│     }                                                 │
│                                                        │
│  4️⃣ POST to OpenRouter API                           │
│     Timeout: 30 seconds                              │
│                                                        │
│  5️⃣ Handle response:                                 │
│     Response (200 OK):                               │
│     {                                                 │
│       "choices": [{                                   │
│         "message": {                                  │
│           "content":                                  │
│           "होटल विकल्प:..."                          │
│         }                                             │
│       }]                                              │
│     }                                                 │
│                                                        │
│  6️⃣ Extract: "होटल विकल्प:..."                       │
│  7️⃣ Return response string                           │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ CHATPROVIDER (Update State)                           ┐
│                                                        │
│  1️⃣ Create AI message with response                  │
│  2️⃣ Add metadata:                                    │
│     {                                                 │
│       "ai_model": "gpt-4o-mini",                     │
│       "response_time_ms": 2100,                       │
│       "language": "hi",                               │
│       "reformulated_query": "I'm looking for..."      │
│     }                                                 │
│  3️⃣ Add to currentSession.messages                   │
│  4️⃣ Save user message to SQLite                      │
│  5️⃣ Save AI message to SQLite                        │
│  6️⃣ Set isGeneratingResponse = false                 │
│  7️⃣ Call notifyListeners()                           │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ UI REBUILDS                                            ┐
│                                                        │
│  1️⃣ User message bubble (right side)                 │
│     "मेरे पास होटल कहाँ मिलेगा?"                      │
│                                                        │
│  2️⃣ AI message bubble (left side)                    │
│     "होटल विकल्प:                                     │
│      1. Hotel ABC - ₹3,500/रात - ...                │
│      2. Hotel XYZ - ₹4,200/रात - ..."                │
│                                                        │
│  3️⃣ Hide loading spinner                             │
│  4️⃣ Enable input field                               │
│  5️⃣ Scroll to bottom                                 │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
CONVERSATION CONTINUES (Follow-up Questions)
  User can ask:
  - "First wali kitne star ki hai?" (How many stars?)
  - "Booking ke liye link do" (Booking link)
  - "Dharamshala kahan hai?" (Where's dharamshala)
  - Context is preserved across all messages
```

### Example 2: User is Offline, Asks About Distance

```
┌─────────────────────────────────────────────────────────┐
│   USER: "महाकाल मंदिर कितना दूर है?"                   │
│   (How far is Mahakaleshwar temple?)                   │
│   [DEVICE IS OFFLINE]                                  │
└─────────────────────────────────────────────────────────┘
    ↓
┌─ CHATPROVIDER.SENDMESSAGE                              ┐
└────────────────────────────────────────────────────────┘
    ↓
┌─ HYBRIDAISERVICE.GENERATERESPONSE                      ┐
│                                                        │
│  1️⃣ Query Agent analyzes                              │
│     ├─ Intent: "distance_query"                       │
│     ├─ Temple: "mahakal" → "mahakaleshwar"           │
│     └─ Reformulated: "Distance to Mahakaleshwar..."  │
│                                                        │
│  2️⃣ Check connectivity: OFFLINE ❌                    │
│  3️⃣ Route to OfflineAIService                         │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ OFFLINEAISERVICE.GENERATERESPONSE                     ┐
│                                                        │
│  1️⃣ Intent: distance_query                            │
│  2️⃣ Extract temple: mahakaleshwar                     │
│  3️⃣ Lookup embedded database:                         │
│     mahakaleshwar = {                                 │
│       lat: 23.18312,                                  │
│       lon: 75.76819,                                  │
│       name: "Mahakaleshwar Jyotirlinga"               │
│     }                                                 │
│                                                        │
│  4️⃣ Get user location (from cache):                  │
│     {                                                 │
│       lat: 23.1827,                                   │
│       lon: 75.7682,                                   │
│       city: "Ujjain"                                  │
│     }                                                 │
│                                                        │
│  5️⃣ Calculate distance (Haversine):                  │
│     ├─ dLat = 23.18312 - 23.1827 = -0.0004          │
│     ├─ dLon = 75.76819 - 75.7682 = 0.00009          │
│     ├─ Distance ≈ 0.18 km ≈ 180 meters             │
│                                                        │
│  6️⃣ Generate response:                                │
│     "महाकालेश्वर ज्योतिर्लिंग आपसे केवल 180 मीटर  │
│      दूर है। यह चलकर 3 मिनट में पहुंचा जा सकता है।│
│      [Google Maps Link]"                             │
│                                                        │
│  7️⃣ Response time: < 50ms                            │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ CHATPROVIDER (Update State)                           ┐
│                                                        │
│  1️⃣ Add AI message to session                        │
│  2️⃣ Mark as offline response                         │
│  3️⃣ Save to SQLite                                   │
│  4️⃣ Notify listeners                                 │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
┌─ UI SHOWS RESPONSE                                      ┐
│                                                        │
│  ✅ "महाकालेश्वर ज्योतिर्लिंग आपसे केवल 180 मीटर │
│      दूर है। यह चलकर 3 मिनट में पहुंचा जा सकता है। │
│      [Tap for Google Maps]"                           │
│                                                        │
│  Icon: "📍 OFFLINE RESPONSE" (show it was generated  │
│         from embedded data while offline)             │
│                                                        │
└────────────────────────────────────────────────────────┘
    ↓
LATER: INTERNET RESTORED
  ├─ NetworkService detects connectivity
  ├─ HybridAIService._forceOfflineMode = false
  ├─ Auto-switches back to online mode
  └─ Next message uses GPT-4o
```

### Example 3: Network Error → Fallback → Recovery

```
┌──────────────────────────────────────────────────┐
│  USER QUERY: "Simhastha kab hai?" (When's it?)   │
│  [POOR NETWORK: 4G timeout prone]                 │
└──────────────────────────────────────────────────┘
    ↓
┌─ ATTEMPT 1: OPENAI/GPT-4O-MINI                  ┐
│                                                  │
│  POST to openrouter.ai/api/v1/chat/completions  │
│  Timeout: 30 seconds                             │
│                                                  │
│  ❌ Timeout after 28 seconds                    │
│  Error: DioExceptionType.receiveTimeout         │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
┌─ ATTEMPT 2: FALLBACK MODEL (NVIDIA)             ┐
│                                                  │
│  POST same query to nvidia/nemotron (free)      │
│  Timeout: 30 seconds                             │
│                                                  │
│  ❌ Also times out (network poor)               │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
┌─ ATTEMPT 3: OPENROUTER/FREE                     ┐
│                                                  │
│  POST same query                                 │
│  Timeout: 30 seconds                             │
│                                                  │
│  ❌ Still times out                             │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
┌─ ALL ONLINE ATTEMPTS FAILED                     ┐
│                                                  │
│  Exception caught in AIService                  │
│  Falls back to OfflineAIService                 │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
┌─ OFFLINE FALLBACK                               ┐
│                                                  │
│  Query: "Simhastha kab hai?"                    │
│  Intent: "event_query"                          │
│                                                  │
│  Lookup embedded calendar:                      │
│  Simhastha 2028: January 14 - February 21       │
│  Parva Snan: Jan 14-15, Jan 29-30, Feb 5-6     │
│  Shahi Snan: Jan 22, Feb 12, Feb 21            │
│                                                  │
│  Response generated in <50ms                    │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
┌─ UI SHOWS OFFLINE RESPONSE                      ┐
│                                                  │
│  "🕉️ सिंहस्थ 2028: 14 जनवरी - 21 फरवरी        │
│   मुख्य तारीखें:                                │
│   - पूरा स्नान: 22 जनवरी, 12 फरवरी, 21 फरवरी│
│   [📍 OFFLINE MODE - कम्युनिकेशन के बिना]    │
│   (Full response with offline indicator)"        │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓
WHEN NETWORK IMPROVES
  └─ Next query automatically uses online AI
     (auto-switching enabled when connectivity
      improves)
```

---

## SUMMARY: Architecture Highlights

| Pattern | Purpose | Location |
|---------|---------|----------|
| **Singleton** | Global service instance | AIService, OfflineAIService, LocationService |
| **Provider** | Reactive state management | ChatProvider |
| **Factory** | Choose AI service | HybridAIService |
| **Strategy** | Online vs offline AI | generateResponse() |
| **Observer** | Connectivity tracking | NetworkService streams |
| **Repository** | Abstract data access | StorageService |
| **Adapter** | Platform-specific code | LocationService (geolocator wrapper) |
| **Template Method** | Standardize AI flow | Query analysis pipeline |
| **Decorator** | Add metadata | Message objects |
| **Chain of Responsibility** | Error handling | Fallback chains |
| **Retry** | Resilience | Exponential backoff |
| **Circuit Breaker** | Protect service | Backend calls |
| **Caching** | Performance | TTL + LRU cache |

This architecture makes the codebase:
- ✅ Testable (all components have clear responsibilities)
- ✅ Maintainable (patterns are recognizable)
- ✅ Scalable (easy to add features)
- ✅ Resilient (multiple fallback layers)
- ✅ Performant (caching and offline support)
