# 📡 Flutter App - Backend Connectivity Report

## Answer: YES ✅

**Your Flutter app IS connected to the backend**, but it has **intelligent fallback logic**:

```
┌─────────────────────────────────────────┐
│  Flutter App (Offline-First)            │
├─────────────────────────────────────────┤
│                                          │
│  Try → Backend API (http://localhost:3000)
│          ├─ GET /api/temples             │
│          ├─ GET /api/events              │
│          └─ GET /api/stays               │
│            ↓ (fail/timeout)              │
│  Fallback → Embedded Data (Offline)      │
│                                          │
└─────────────────────────────────────────┘
```

---

## Architecture: Hybrid Data Layer

### Backend Services in Flutter

There are **3 backend services** integrated:

#### 1. **SimhasthaBackendService** (Main Backend Connector)
```dart
// File: lib/services/simhastha_backend_service.dart

class SimhasthaBackendService {
  String _baseUrl = 'http://localhost:3000';  // Default for local dev
  
  // 3-second timeout for each call
  Future<List<TempleDarshanInfo>> fetchTemples() { ... }
  Future<List<SnanEvent>> fetchEvents() { ... }
  Future<List<SimhasthaPlace>> fetchStaysAndTransit() { ... }
}
```

**Configuration Comments**:
```dart
// When running on an Android Emulator use 'http://10.0.2.2:3000'
// When running on physical device on local WiFi use your machine's local IP (e.g., 'http://192.168.1.X:3000')
// When running web or desktop use 'http://localhost:3000'
```

#### 2. **BackendService** (Data Models)
```dart
// File: lib/services/backend_service.dart

class Temple {
  final String id;
  final String templeName;
  final String hindiName;
  final List<Map<String, dynamic>>? aartis;
  final List<String>? entryGates;
  // ... parses JSON from backend
}

class SnanEvent {
  final String title;
  final bool isShahiSnan;
  final String? location;
  // ... parses backend events
}
```

#### 3. **DataIntegrationService** (Parallel Loading)
```dart
// File: lib/services/data_integration_service.dart

class DataIntegrationService {
  final BackendService _backendService = BackendService();
  
  // Fetches all 3 resources in parallel
  final templesFuture = _backendService.fetchTemples();
  final eventsFuture = _backendService.fetchEvents();
  final staysFuture = _backendService.fetchStays();
}
```

---

## Integration Points: Where Backend is Used

### 1. **Temple Guide Tab**
```dart
// File: lib/screens/tabs/temple_guide_tab.dart

Future<void> _loadTemplesFromBackend() async {
  setState(() => _isLoading = true);
  final data = await SimhasthaBackendService().fetchTemples();
  
  if (mounted) {
    setState(() {
      _temples = data;
      _isLoading = false;
    });
  }
}
```

**Flow**:
- User opens "Temple Guide" tab
- App calls `SimhasthaBackendService().fetchTemples()`
- If backend responds: Shows dynamic data from MySQL
- If backend timeout/offline: Shows embedded data

### 2. **Calendar Events Tab**
```dart
// File: lib/screens/tabs/calendar_events_tab.dart

Future<void> _loadEventsFromBackend() async {
  setState(() => _isLoading = true);
  final data = await SimhasthaBackendService().fetchEvents();
  
  if (mounted) {
    setState(() {
      _events = data;
      _isLoading = false;
    });
  }
}
```

**Shows**:
- Shahi Snan dates (April 9, 24, May 8, 2028)
- Panchkroshi Yatra pilgrimage
- Dynamic event updates from backend

### 3. **Accommodation & Transport Tab**
```dart
// File: lib/screens/tabs/accommodation_transport_tab.dart

Future<void> _loadPlacesFromBackend() async {
  setState(() => _isLoading = true);
  final data = await SimhasthaBackendService().fetchStaysAndTransit();
  
  if (mounted) {
    setState(() {
      _places = data;
      _isLoading = false;
    });
  }
}
```

**Shows**:
- Hotels (MPT Shipra Residency)
- Dharamshalas (Mahakaleshwar Bhakt Niwas)
- Tent City
- Transport (Railway, buses)
- Parking facilities

---

## Connection Details

### Backend URL Configuration
```dart
// lib/services/simhastha_backend_service.dart

String _baseUrl = 'http://localhost:3000';  // Default for local development

// For other platforms:
// Android Emulator: 'http://10.0.2.2:3000'
// Physical device: 'http://192.168.1.X:3000' (replace X with your machine IP)
// Web/Desktop: 'http://localhost:3000'
```

### API Endpoints Called
```http
GET http://localhost:3000/api/temples       → Fetch all temples
GET http://localhost:3000/api/events        → Fetch all Simhastha events
GET http://localhost:3000/api/stays         → Fetch hotels, dharamshalas, transport
```

### Timeout Behavior
```dart
// 3-second timeout for each API call
final res = await http.get(Uri.parse('$_baseUrl/api/temples'))
  .timeout(const Duration(seconds: 3));

// If timeout → Exception caught → Falls back to embedded data
```

---

## Fallback Logic: Offline-First

### What Happens When Backend is Unavailable

```dart
Future<List<TempleDarshanInfo>> fetchTemples() async {
  try {
    // Try to fetch from backend
    final res = await http.get(Uri.parse('$_baseUrl/api/temples'))
      .timeout(const Duration(seconds: 3));
    
    if (res.statusCode == 200) {
      // Success: Parse JSON from MySQL
      return list.map((json) => TempleDarshanInfo.fromJson(json)).toList();
    }
  } catch (_) {
    // Timeout, network error, or 500 error
  }
  
  // Fallback: Return baked-in data
  return TempleGuideData.temples;  // Embedded offline data
}
```

### Embedded Fallback Data
Located in:
- `lib/constants/temple_guide_data.dart` → 3+ temples
- `lib/constants/simhastha_calendar_data.dart` → Events
- `lib/constants/simhastha_places_data.dart` → Hotels, stays, transport

These are hardcoded so the app **always** works offline.

---

## Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Backend Service Code** | ✅ Implemented | Ready to fetch from backend |
| **API Endpoints** | ✅ Coded | 3 endpoints: temples, events, stays |
| **Fallback Logic** | ✅ Implemented | Offline data available |
| **Integration Points** | ✅ Hooked | 3 tabs use backend service |
| **Backend Server** | ⚠️ Needs Setup | MySQL + Node.js not running yet |
| **API Key** | ✅ Configured | OpenRouter key set for AI |
| **Database** | ⚠️ Pending | Tables created, needs seeding |

---

## How to Enable Backend Sync

### Step 1: Start MySQL
```bash
# Windows with XAMPP/WAMP
mysqld --console

# Or verify it's running
mysql -u root -e "SELECT VERSION();"
```

### Step 2: Create Database & Tables
```bash
cd backend
mysql -u root -p < schema.sql
```

### Step 3: Start Backend Server
```bash
cd backend
npm install
npm start
```

**Output**:
```
=======================================================
Simhastha Ujjain 2028 Node.js MySQL Server Running
Port: 3000
MySQL Host: localhost:3306
MySQL Database: simhastha_db
Admin Portal: http://localhost:3000/admin
REST APIs: /api/temples, /api/events, /api/stays
=======================================================
```

### Step 4: Run Flutter App
```bash
flutter run

# For Android Emulator, you may need to change:
# 'http://localhost:3000' → 'http://10.0.2.2:3000'
```

### Step 5: Test Connection
1. Open "Temple Guide" tab
2. If backend is running: Sees data from MySQL
3. If backend is offline: Falls back to embedded data
4. Check console logs for: `[BackendService] Fetching temples from http://localhost:3000/api/temples`

---

## Testing Connectivity

### Check Backend is Running
```bash
curl http://localhost:3000/api/temples

# Should return JSON:
[
  {
    "id": "mahakaleshwar",
    "templeName": "Shri Mahakaleshwar Jyotirlinga",
    ...
  }
]
```

### Check MySQL Database
```bash
mysql -u root simhastha_db -e "SELECT * FROM temples LIMIT 1;"

# Should return:
+---------------+-------+
| id            | templeName |
+---------------+-------+
| mahakaleshwar | Shri Mahakaleshwar Jyotirlinga |
+---------------+-------+
```

### Enable Debug Logging in Flutter
```dart
// In SimhasthaBackendService
print('[Backend] Fetching from $_baseUrl/api/temples');
print('[Backend] Success: ${res.statusCode}');
print('[Backend] Fallback: Using embedded data');
```

Check logcat/Xcode output to see which path is taken.

---

## Deployment Scenarios

### Scenario 1: Development (Local)
```
Flutter App → Backend on localhost:3000
├─ MySQL running: Shows dynamic data
└─ MySQL offline: Uses embedded data
```

### Scenario 2: Physical Device on WiFi
```
Change URL from 'http://localhost:3000' to 'http://192.168.1.100:3000'
(Replace 100 with your machine's IP)

simhastha_backend_service.dart:
String _baseUrl = 'http://192.168.1.100:3000';
```

### Scenario 3: Android Emulator
```
Change URL from 'http://localhost:3000' to 'http://10.0.2.2:3000'

simhastha_backend_service.dart:
String _baseUrl = 'http://10.0.2.2:3000';
```

### Scenario 4: Production Deployment
```
Change URL to: 'https://api.simhastha-ujjain.com'

simhastha_backend_service.dart:
String _baseUrl = 'https://api.simhastha-ujjain.com';
```

---

## Architecture Diagram

```
┌────────────────────────────────────┐
│        FLUTTER APP                 │
├────────────────────────────────────┤
│                                    │
│  UI Tabs:                          │
│  ├─ Temple Guide                   │
│  ├─ Calendar Events                │
│  └─ Accommodation & Transport      │
│                                    │
└────────────────┬───────────────────┘
                 │
         ┌───────┴────────┐
         │                │
         ▼                ▼
    ┌─────────────┐  ┌──────────────┐
    │  Backend    │  │  Embedded    │
    │  Service    │  │  Data        │
    │ (Try First) │  │ (Fallback)   │
    └──────┬──────┘  └──────────────┘
           │
           ▼
    ┌────────────────┐
    │  Backend API   │
    │ localhost:3000 │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  Express.js    │
    │  Server        │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  MySQL DB      │
    │ simhastha_db   │
    │                │
    │ Tables:        │
    │ ├─ temples     │
    │ ├─ events      │
    │ └─ stays       │
    └────────────────┘
```

---

## Summary

✅ **YES, Flutter is connected to backend**

- 3 backend services are coded and integrated
- Temple Guide, Events, and Accommodation tabs all try to fetch from backend
- Smart fallback to embedded offline data if backend unavailable
- Works both online AND offline
- Ready for immediate use once MySQL + backend server are running

**Next Steps**:
1. Start MySQL database
2. Run `npm start` in `/backend` folder
3. Flutter app will automatically fetch from backend
4. If backend down, app seamlessly falls back to embedded data

