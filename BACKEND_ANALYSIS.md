# 🔧 Backend System - Complete Analysis

## Overview

The project has a **separate Node.js/Express backend** (`/backend` folder) that serves as:
1. **MySQL Database Server** - Persistent storage for temples, events, and stays
2. **REST API Server** - HTTP endpoints for CRUD operations
3. **Admin Portal** - Web UI for managing content
4. **Data Synchronization Hub** - Feeds data to the Flutter app

The **Flutter frontend** is configured to work either **completely offline** (embedded knowledge) OR **sync with this backend** (for updates).

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  SIMHASTHA ECOSYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Flutter Mobile App (Offline-First)                         │
│  ├─ Embedded Knowledge Base (offline mode)                  │
│  ├─ Optional Cloud Sync (online mode)                       │
│  └─ UI/UX for pilgrims                                      │
│         ↓ (REST API calls if online)                        │
│                                                               │
│  Node.js/Express Backend Server (http://localhost:3000)    │
│  ├─ Port: 3000                                              │
│  ├─ REST API Routes:                                        │
│  │  ├─ GET/POST/PUT/DELETE /api/temples                    │
│  │  ├─ GET/POST/PUT/DELETE /api/events                     │
│  │  └─ GET/POST/PUT/DELETE /api/stays                      │
│  ├─ Admin Dashboard (http://localhost:3000/admin)          │
│  └─ MySQL Connection Pool                                   │
│         ↓                                                     │
│                                                               │
│  MySQL Database (localhost:3306)                            │
│  ├─ Database: simhastha_db                                  │
│  ├─ Tables:                                                  │
│  │  ├─ temples (temple info + aartis + gates + routes)      │
│  │  ├─ events (Simhastha royal baths + programs)            │
│  │  └─ stays (hotels + dharamshalas + transport + parking)  │
│  └─ UTF-8mb4 encoding (supports Hindi/Devanagari)          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

### Dependencies
```json
{
  "express": "^4.19.2",           // Web framework
  "mysql2": "^3.9.7",             // MySQL driver with promise support
  "cors": "^2.8.5",               // Cross-origin resource sharing
  "dotenv": "^16.4.5"             // Environment variables
}
```

### Server Setup
- **Framework**: Express.js (HTTP server)
- **Runtime**: Node.js
- **Database**: MySQL 5.7+ or MariaDB
- **Connection Pool**: mysql2 with 15 concurrent connections
- **CORS**: Enabled for all origins (`*`)
- **Charset**: UTF-8mb4 (full Unicode support)

---

## Database Schema

### 1. TEMPLES Table
```sql
CREATE TABLE `temples` (
  `id` VARCHAR(100) PRIMARY KEY,
  `templeId` VARCHAR(100) NOT NULL,
  `templeName` VARCHAR(255) NOT NULL,
  `hindiName` VARCHAR(255) NOT NULL,
  `deity` VARCHAR(255),
  `significance` TEXT,
  `timing` VARCHAR(255),
  `aartis` JSON,                    -- Array of aarti timings & descriptions
  `entryGates` JSON,                -- Array of entry gates
  `darshanRoutes` JSON,             -- Array of darshan flow routes
  `vipFastTrackRules` TEXT,         -- VIP pass information
  `bookingWebsite` VARCHAR(255),    -- Official booking portal
  `dressCode` TEXT,                 -- Dress code guidelines
  `prasadDetails` TEXT,             -- Prasad availability & pricing
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
)
```

**Sample Data**:
- Mahakaleshwar Jyotirlinga (दक्षिणमुखी ज्योतिर्लिंग - only south-facing)
- Kal Bhairav Temple (Ujjain's city guardian)
- Harsiddhi Mata Shaktipeeth (13th of 51 Shaktipeeths)

---

### 2. EVENTS Table
```sql
CREATE TABLE `events` (
  `id` VARCHAR(100) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `hindiTitle` VARCHAR(255) NOT NULL,
  `date` VARCHAR(100) NOT NULL,
  `tithi` VARCHAR(150),             -- Lunar calendar date
  `significance` TEXT,
  `hindiSignificance` TEXT,
  `location` VARCHAR(255),
  `isShahiSnan` TINYINT(1),         -- Royal bath flag
  `type` VARCHAR(50),               -- 'shahi_snan' or 'program'
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
)
```

**Sample Events**:
- **April 9, 2028**: First Shahi Snan (Grand Opening)
- **April 24, 2028**: Second Shahi Snan (Vaishakh Amavasya)
- **May 8, 2028**: Maha Shahi Snan (The Supreme Royal Bath - 10-15 million pilgrims)
- **April 25-30, 2028**: Panchkroshi Yatra (118-km pilgrimage)

---

### 3. STAYS Table
```sql
CREATE TABLE `stays` (
  `id` VARCHAR(100) PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `hindiName` VARCHAR(255) NOT NULL,
  `category` VARCHAR(50),           -- 'hotel', 'dharamshala', 'tent', 'transport', 'parking'
  `lat` DECIMAL(10, 6),             -- GPS latitude
  `lon` DECIMAL(10, 6),             -- GPS longitude
  `icon` VARCHAR(20),               -- Emoji icon
  `area` VARCHAR(255),              -- Location area name
  `description` TEXT,
  `hindiDescription` TEXT,
  `contact` VARCHAR(100),           -- Phone/helpline
  `timing` VARCHAR(255),            -- Operating hours
  `gates` VARCHAR(255),             -- Entry/exit information
  `pricing` VARCHAR(255),           -- Price range
  `rating` DECIMAL(3, 1),           -- Rating (1-5 stars)
  `tags` JSON,                      -- Features/facilities
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
)
```

**Sample Stays by Category**:

| Category | Examples | Purpose |
|----------|----------|---------|
| **Hotels** | MPT Shipra Residency | Luxury accommodation near temple |
| **Dharamshala** | Mahakaleshwar Bhakt Niwas | Budget pilgrim stays (temple-managed) |
| **Tent City** | Simhastha Luxury Tent City | 2028 event accommodation |
| **Transport** | Ujjain Junction, Dewas Gate Bus | Rail & bus connectivity |
| **Parking** | Karkraj Parking | Smart parking with EV charging |

---

## REST API Endpoints

### 1. TEMPLES API

#### Get All Temples
```http
GET /api/temples
Content-Type: application/json

Response:
[
  {
    "id": "mahakaleshwar",
    "templeName": "Shri Mahakaleshwar Jyotirlinga",
    "hindiName": "श्री महाकालेश्वर ज्योतिर्लिंग",
    "deity": "Lord Shiva",
    "timing": "4:00 AM – 11:00 PM",
    "aartis": [
      {
        "name": "Bhasma Aarti",
        "timingSummer": "4:00 AM – 6:00 AM",
        "description": "Sacred ash ritual performed before dawn."
      }
    ],
    "bookingWebsite": "https://shrimahakaleshwar.mp.gov.in"
  },
  ...
]
```

#### Get Single Temple
```http
GET /api/temples/mahakaleshwar

Response:
{
  "id": "mahakaleshwar",
  ...full temple object...
}
```

#### Create Temple
```http
POST /api/temples
Content-Type: application/json

{
  "templeName": "New Temple",
  "hindiName": "नया मंदिर",
  "deity": "Deity Name",
  "significance": "Temple significance",
  "timing": "Opening hours",
  "aartis": [...]
}

Response: 201 Created
{
  "success": true,
  "item": {...inserted object...}
}
```

#### Update Temple
```http
PUT /api/temples/mahakaleshwar
Content-Type: application/json

{
  "timing": "Updated timing",
  "vipFastTrackRules": "Updated rules"
}

Response: 200 OK
{
  "success": true
}
```

#### Delete Temple
```http
DELETE /api/temples/mahakaleshwar

Response: 200 OK
{
  "success": true,
  "message": "Deleted from MySQL database"
}
```

---

### 2. EVENTS API

#### Get All Events
```http
GET /api/events

Response:
[
  {
    "id": "event_1",
    "title": "First Shahi Snan (Royal Bath)",
    "hindiTitle": "प्रथम शाही स्नान",
    "date": "April 9, 2028 (Sunday)",
    "tithi": "Chaitra Shukla Purnima",
    "significance": "Grand Opening of Simhastha Kumbh Mela 2028",
    "location": "Ram Ghat & Dutt Akhara Ghat, Shipra River",
    "isShahiSnan": true,
    "type": "shahi_snan"
  },
  ...
]
```

#### Create Event
```http
POST /api/events
{
  "title": "Panchkroshi Yatra",
  "hindiTitle": "पंचक्रोशी यात्रा",
  "date": "April 25-30, 2028",
  "tithi": "Vaishakh Krishna",
  "significance": "118-km pilgrimage",
  "isShahiSnan": false
}
```

---

### 3. STAYS API

#### Get All Stays (Hotels, Temples, Transport, Parking)
```http
GET /api/stays

Response:
[
  {
    "id": "hotel_shipra_residency",
    "name": "MPT Shipra Residency",
    "category": "hotel",
    "lat": 23.1785,
    "lon": 75.783,
    "pricing": "₹3,000 – ₹7,500 / night",
    "rating": 4.7,
    "contact": "0734-2551495"
  },
  {
    "id": "parking_karkraj",
    "name": "Karkraj Multi-Level Parking",
    "category": "parking",
    "lat": 23.1788,
    "lon": 75.7645,
    "pricing": "₹50 for 8 hrs",
    "rating": 4.7
  }
]
```

#### Get Stays by Category (Filter)
**Note**: Backend doesn't support query filters yet. Frontend must filter client-side or add backend support:
```http
GET /api/stays?category=hotel
GET /api/stays?category=dharamshala
GET /api/stays?category=transport
```

---

## Configuration

### `.env` File
```env
# MySQL Server Connection
PORT=3000                    # Express server port
DB_HOST=localhost           # MySQL host
DB_USER=root                # MySQL user
DB_PASSWORD=                # MySQL password (empty = no password)
DB_NAME=simhastha_db        # Database name
DB_PORT=3306                # MySQL port
```

### Startup

#### Option 1: Development (with auto-reload)
```bash
npm install
npm run dev          # Uses nodemon
```

#### Option 2: Production
```bash
npm install
npm start            # node server.js
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

---

## Database Initialization

### Automatic Setup
When the backend starts (`node server.js`):

1. **Checks** if MySQL is running at `localhost:3306`
2. **Creates** `simhastha_db` database if it doesn't exist
3. **Initializes** three tables with proper schema
4. **Seeds** initial data from `schema.sql`

### Manual Setup (If automatic fails)

```bash
# 1. Connect to MySQL
mysql -u root -p

# 2. Create database
CREATE DATABASE simhastha_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE simhastha_db;

# 3. Run schema
SOURCE backend/schema.sql;

# 4. Start backend
cd backend
npm start
```

### Verify Connection
```bash
# Check if MySQL is running
mysql -u root -h localhost -e "SELECT VERSION();"

# Check if database exists
mysql -u root -h localhost -e "SHOW DATABASES LIKE 'simhastha%';"

# Check tables
mysql -u root -h localhost simhastha_db -e "SHOW TABLES;"
```

---

## Data Flow

### Offline Mode (App Only)
```
User Input (Voice/Text)
    ↓
ChatProvider (Flutter)
    ↓
OfflineAIService (Embedded Knowledge)
    ↓ (No network call)
Response Generated
    ↓
TTS + Display
```

### Online Mode (App + Backend)
```
User Input (Voice/Text)
    ↓
ChatProvider checks: isOnline && hasApiKey?
    ↓ YES
HybridAIService.generateResponse()
    ↓
Optional: Fetch /api/temples, /api/events, /api/stays
    ↓
OpenAI/Gemini/OpenRouter API
    ↓
Response with dynamic data
    ↓
TTS + Display
```

### Admin Portal Usage
```
Browser → http://localhost:3000/admin
    ↓
Admin Dashboard (HTML/JS frontend)
    ↓
Create/Edit/Delete temples, events, stays
    ↓
REST API calls → Backend
    ↓
MySQL database updated
    ↓
Changes sync to Flutter app (if configured)
```

---

## Integration with Flutter App

### Current Configuration
The Flutter app is set to **OFFLINE-FIRST** with an optional online fallback:

```dart
// From app_constants.dart
static const String openAiApiKey = 'sk-or-v1-...';  // OpenRouter key placeholder
static bool get useOnlineMode => openAiApiKey.isNotEmpty;

// Backend base URL (not currently used)
static const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
```

### To Enable Backend Sync

**Option 1: Use Backend for Temple/Event Data**
```dart
// In hybrid_ai_service.dart, add:
Future<List<Temple>> fetchTemples() async {
  if (!_networkService.hasInternetAccess) return [];
  try {
    final response = await _dio.get('http://YOUR_SERVER:3000/api/temples');
    return (response.data as List).map((t) => Temple.fromJson(t)).toList();
  } catch (e) {
    return [];  // Fallback to embedded data
  }
}
```

**Option 2: Sync Events for Simhastha Calendar**
```dart
Future<List<Event>> fetchUpcomingEvents() async {
  if (!_networkService.hasInternetAccess) return [];
  try {
    final response = await _dio.get('http://YOUR_SERVER:3000/api/events?type=shahi_snan');
    return (response.data as List).map((e) => Event.fromJson(e)).toList();
  } catch (e) {
    return [];
  }
}
```

---

## Data Files

### JSON Seeds (for manual import)
Located in `/backend/data/`:

| File | Purpose | Records |
|------|---------|---------|
| `temples.json` | Temple information | 3 temples |
| `events.json` | Simhastha 2028 events | 4 royal baths + programs |
| `stays.json` | Hotels, stays, transport | 6 properties |

### Database State
```
backend/data/simhastha.db       (SQLite backup - reference only)
backend/data/temples.json       (JSON export of temples table)
backend/data/events.json        (JSON export of events table)
backend/data/stays.json         (JSON export of stays table)
```

---

## Admin Portal Features

The admin dashboard at `http://localhost:3000/admin` allows:

### 1. Temple Management
- ✅ Add new temples
- ✅ Edit temple info (timing, aartis, VIP rules, etc.)
- ✅ Manage entry gates and darshan routes
- ✅ Update booking websites
- ✅ Delete temples

### 2. Event Management
- ✅ Add Simhastha events
- ✅ Edit dates and significance
- ✅ Mark as Shahi Snan (royal bath)
- ✅ Set lunar tithi dates
- ✅ Update event locations

### 3. Stays Management
- ✅ Add hotels, dharamshalas, tents
- ✅ Manage transport (buses, trains)
- ✅ Configure parking facilities
- ✅ Update pricing and contact info
- ✅ Edit GPS coordinates
- ✅ Set ratings and availability

### 4. Data Import/Export
- ✅ Export to JSON
- ✅ Bulk edit via JSON upload
- ✅ Clear and reset database

---

## Performance Considerations

### Connection Pool
```javascript
connectionLimit: 15              // Max 15 concurrent MySQL connections
queueLimit: 0                    // Unlimited queue
waitForConnections: true         // Wait if pool exhausted
```

### For 10,000+ concurrent users during Simhastha 2028:
1. **Scale horizontally**: Run multiple Express instances
2. **Use load balancer**: Nginx/HAProxy to distribute traffic
3. **Increase pool**: Change `connectionLimit` to 50-100
4. **Cache layer**: Add Redis for frequently accessed data
5. **Database optimization**: Index on `id`, `category`, `date`

---

## Security Notes

### Current Gaps
⚠️ **No Authentication**: All API endpoints are publicly accessible  
⚠️ **No Rate Limiting**: Can be abused by bots  
⚠️ **No Input Validation**: SQL injection risk (though mysql2 uses parameterized queries)  
⚠️ **No CORS Restrictions**: All origins allowed (`*`)  

### Recommended Fixes for Production
```javascript
// 1. Add API key authentication
if (req.headers['x-api-key'] !== process.env.API_KEY) {
  return res.status(401).json({ error: 'Unauthorized' });
}

// 2. Add rate limiting
const rateLimit = require('express-rate-limit');
const limiter = rateLimit({ windowMs: 15*60*1000, max: 100 });
app.use('/api/', limiter);

// 3. Restrict CORS
res.setHeader('Access-Control-Allow-Origin', 'https://yourdomain.com');

// 4. Input validation
const { body, validationResult } = require('express-validator');
app.post('/api/temples', body('templeName').trim().isLength({ min: 1 }), ...);
```

---

## Troubleshooting

### Backend Won't Start
```
Error: connect ECONNREFUSED 127.0.0.1:3306
→ MySQL is not running
→ Start MySQL: mysql.server start (Mac) or mysqld (Windows)
```

### Tables Not Created
```
Error: ER_NO_DB_SELECTED
→ Database doesn't exist
→ Run: mysql -u root -e "CREATE DATABASE simhastha_db CHARACTER SET utf8mb4;"
```

### CORS Errors in Flutter
```
Access to XMLHttpRequest blocked by CORS policy
→ Already handled: CORS enabled for all origins
→ Check: Is backend running on correct port?
→ Verify: URL matches http://localhost:3000
```

### Data Not Syncing
```
→ Check if app is configured to use online mode
→ Verify: useOnlineMode is true
→ Check: Backend /api/ endpoints return data
→ Test: curl http://localhost:3000/api/temples
```

---

## Deployment

### Deployment Checklist
- [ ] MySQL running on production server
- [ ] Node.js installed (v16+)
- [ ] Environment variables set (`.env`)
- [ ] Database seeded with initial data
- [ ] HTTPS enabled (not HTTP)
- [ ] Firewall allows port 3000
- [ ] Rate limiting enabled
- [ ] API key authentication enabled
- [ ] CORS restricted to frontend domain
- [ ] Regular backups scheduled

### Deployment Platforms
- **Heroku**: `npm start` on port `process.env.PORT`
- **AWS EC2**: Install MySQL + Node.js manually
- **Docker**: Create Dockerfile with Node + MySQL image
- **DigitalOcean**: Similar to EC2

---

## Summary

| Aspect | Details |
|--------|---------|
| **Technology** | Node.js + Express + MySQL + CORS |
| **Purpose** | Backend API for temple/event/stay data |
| **Data Storage** | MySQL database with UTF-8mb4 (full Unicode) |
| **API Style** | RESTful with JSON requests/responses |
| **Endpoints** | 3 main resources: `/api/temples`, `/api/events`, `/api/stays` |
| **Operations** | CRUD (Create, Read, Update, Delete) |
| **Admin Portal** | Web UI at `http://localhost:3000/admin` |
| **Security** | ⚠️ MINIMAL - needs auth + rate limiting for production |
| **Scalability** | Supports 15 concurrent DB connections (configurable) |
| **Offline Support** | Flutter app works 100% without this backend |

---

## Key Integration Points

1. **Flutter App** ← → **Backend (Optional)**
   - App works offline with embedded data
   - Can optionally fetch from `/api/temples` for updates
   
2. **Admin Portal** → **Backend API** → **MySQL**
   - Admins manage content via web UI
   - Changes stored in database
   - No direct sync to Flutter (manual refresh needed)

3. **Simhastha 2028 Timeline**
   - Events can be managed via admin portal
   - Updated dates reflected if app syncs

---

**Status**: Backend is functional, not integrated with Flutter yet. Flutter currently uses only offline embedded data.
