# 🎨 Visual Setup Guide - Phone Testing with ngrok

A visual, step-by-step guide with ASCII diagrams for testing your app on a physical phone.

---

## 📊 Overview Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     TESTING WORKFLOW                          │
└──────────────────────────────────────────────────────────────┘

    ┌─────────┐         ┌─────────┐         ┌──────────┐
    │ Step 1  │────────▶│ Step 2  │────────▶│  Step 3  │
    │ Setup   │         │ Start   │         │ Configure│
    └─────────┘         └─────────┘         └──────────┘
        │                    │                     │
        │                    │                     │
        ▼                    ▼                     ▼
   Install              Backend +              Update
   ngrok                ngrok                  Flutter
   authtoken            running                app
        │                    │                     │
        └────────────────────┴─────────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │   Step 4     │
                    │   Build APK  │
                    └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │   Step 5     │
                    │ Install & Test│
                    └──────────────┘
```

---

## 🎯 Step 1: Initial Setup (One-Time)

```
┌─────────────────────────────────────────────────────────────┐
│  INITIAL SETUP (Do this once)                               │
└─────────────────────────────────────────────────────────────┘

[1] Install ngrok
    ┌─────────────────────────────────────────┐
    │ Windows Command Prompt or PowerShell    │
    │                                         │
    │ > choco install ngrok                   │
    │   or                                    │
    │ > npm install -g ngrok                  │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ ngrok installed


[2] Sign up for ngrok
    ┌─────────────────────────────────────────┐
    │ Browser                                 │
    │                                         │
    │ https://dashboard.ngrok.com/signup      │
    │                                         │
    │ 📧 Email: _________________             │
    │ 🔒 Password: _____________              │
    │                                         │
    │         [ Sign Up ]                     │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ Account created


[3] Get authtoken
    ┌─────────────────────────────────────────┐
    │ ngrok Dashboard                         │
    │                                         │
    │ Your Authtoken:                         │
    │ ┌─────────────────────────────────────┐ │
    │ │ 2abc...xyz                          │ │
    │ └─────────────────────────────────────┘ │
    │         [ Copy ]                        │
    └─────────────────────────────────────────┘
           │
           ▼
    ┌─────────────────────────────────────────┐
    │ > ngrok config add-authtoken 2abc...xyz │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ ngrok configured

┌─────────────────────────────────────────────────────────────┐
│ ✅ SETUP COMPLETE - You won't need to do this again!       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Step 2: Start Backend & ngrok

```
┌─────────────────────────────────────────────────────────────┐
│  START SERVICES                                             │
└─────────────────────────────────────────────────────────────┘

Option A: Automatic (Recommended)
    ┌─────────────────────────────────────────┐
    │ > cd "e:\AI app\backend"                │
    │ > start_ngrok.bat                       │
    └─────────────────────────────────────────┘
           │
           ├──────────────────┬────────────────┐
           ▼                  ▼                ▼
    Terminal 1          Terminal 2         Displays
    (Backend)           (ngrok)            Instructions


Option B: Manual
    Terminal 1                     Terminal 2
    ┌───────────────────┐         ┌────────────────────┐
    │ > node server.js  │         │ > ngrok http 3000  │
    │                   │         │                    │
    │ Server Running    │         │ Session: online    │
    │ Port: 3000        │         │ Forwarding:        │
    │                   │         │ https://xyz.ngrok  │
    └───────────────────┘         └────────────────────┘
           ✅                            ✅
      Backend Ready                 Tunnel Ready

┌─────────────────────────────────────────────────────────────┐
│ RESULT: Two terminal windows running                        │
│ ⚠️  DO NOT CLOSE THESE WINDOWS!                            │
└─────────────────────────────────────────────────────────────┘


What you'll see in ngrok terminal:
┌─────────────────────────────────────────────────────────────┐
│ ngrok                                                        │
│                                                              │
│ Session Status    online                                     │
│ Account           your-email@example.com                     │
│ Version           3.x.x                                      │
│ Region            United States (us)                         │
│ Latency           45ms                                       │
│ Web Interface     http://127.0.0.1:4040                     │
│ Forwarding        https://a1b2-c3d4.ngrok-free.app ->       │
│                   http://localhost:3000                      │
│                   ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲                 │
│                   COPY THIS URL!                             │
│                                                              │
│ Connections       ttl     opn     rt1     rt5               │
│                   0       0       0.00    0.00              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Step 3: Test Connection

```
┌─────────────────────────────────────────────────────────────┐
│  VERIFY BACKEND IS ACCESSIBLE                               │
└─────────────────────────────────────────────────────────────┘

[1] Copy your ngrok URL
    Example: https://a1b2-c3d4.ngrok-free.app


[2] Test in Browser
    ┌─────────────────────────────────────────────────────────┐
    │  🌐 Browser                                             │
    │                                                          │
    │  https://a1b2-c3d4.ngrok-free.app/api/temples          │
    │  ─────────────────────────────────────────              │
    │                                                          │
    │  Response:                                               │
    │  [                                                       │
    │    {                                                     │
    │      "templeId": "mahakaleshwar",                       │
    │      "templeName": "Shri Mahakaleshwar Jyotirlinga",    │
    │      "deity": "Lord Shiva",                             │
    │      ...                                                 │
    │    }                                                     │
    │  ]                                                       │
    └─────────────────────────────────────────────────────────┘
           │
           ▼
    ✅ Backend accessible!


[3] Or use test script
    ┌─────────────────────────────────────────┐
    │ > cd "e:\AI app\backend"                │
    │ > test_api.bat https://a1b2...ngrok.app │
    │                                         │
    │ [1/3] Testing Temples API...            │
    │ ✅ Temples API working!                 │
    │                                         │
    │ [2/3] Testing Events API...             │
    │ ✅ Events API working!                  │
    │                                         │
    │ [3/3] Testing Stays API...              │
    │ ✅ Stays API working!                   │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ All APIs working!

┌─────────────────────────────────────────────────────────────┐
│ ✅ BACKEND VERIFIED - Ready to build app!                   │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Step 4: Configure Flutter App

```
┌─────────────────────────────────────────────────────────────┐
│  UPDATE BACKEND URL IN APP                                  │
└─────────────────────────────────────────────────────────────┘

Method A: Edit Constants File
    [1] Open file
        📁 e:\AI app\ai_assistant\lib\constants\app_constants.dart

    [2] Find this line (around line 10):
        ┌───────────────────────────────────────────────────┐
        │ static const String backendBaseUrl =              │
        │   String.fromEnvironment(                         │
        │     'BACKEND_URL',                                │
        │     defaultValue: 'http://localhost:3000', ❌     │
        │                   ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲      │
        │                   CHANGE THIS                     │
        │   );                                              │
        └───────────────────────────────────────────────────┘

    [3] Change to:
        ┌───────────────────────────────────────────────────┐
        │ static const String backendBaseUrl =              │
        │   String.fromEnvironment(                         │
        │     'BACKEND_URL',                                │
        │     defaultValue:                                 │
        │       'https://a1b2-c3d4.ngrok-free.app', ✅     │
        │   );                                              │
        └───────────────────────────────────────────────────┘

    [4] Save file (Ctrl+S)


Method B: Build-Time Override (No file editing!)
    Skip editing and use this build command instead:
    ┌───────────────────────────────────────────────────────┐
    │ > flutter build apk --release                         │
    │     --dart-define=BACKEND_URL=https://...ngrok.app    │
    └───────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ✅ APP CONFIGURED - Ready to build APK!                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔨 Step 5: Build APK

```
┌─────────────────────────────────────────────────────────────┐
│  BUILD RELEASE APK                                          │
└─────────────────────────────────────────────────────────────┘

Option A: Using Build Script (Interactive)
    ┌─────────────────────────────────────────┐
    │ > cd "e:\AI app\ai_assistant"           │
    │ > build_for_phone.bat                   │
    └─────────────────────────────────────────┘
           │
           ▼
    ┌─────────────────────────────────────────┐
    │ Override backend URL? (y/n): y          │
    │ Enter ngrok URL: https://...            │
    │                                         │
    │ [1/3] Cleaning...                       │
    │ [2/3] Building...                       │
    │   (2-5 minutes)                         │
    │ [3/3] Complete!                         │
    │                                         │
    │ Install via ADB? (y/n): y               │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ APK Built & Installed!


Option B: Manual Build
    ┌─────────────────────────────────────────┐
    │ > cd "e:\AI app\ai_assistant"           │
    │ > flutter clean                         │
    │ > flutter build apk --release           │
    └─────────────────────────────────────────┘
           │
           ▼
    Building Process:
    [        ] 0%  Initializing...
    [■■      ] 25% Compiling Dart...
    [■■■■    ] 50% Building Android...
    [■■■■■■  ] 75% Signing APK...
    [■■■■■■■■] 100% Complete!
           │
           ▼
    ✅ APK Built!

    APK Location:
    📁 e:\AI app\ai_assistant\
       └─ build\
          └─ app\
             └─ outputs\
                └─ flutter-apk\
                   └─ app-release.apk ⭐

┌─────────────────────────────────────────────────────────────┐
│ ✅ APK READY - Size: ~40-60 MB                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📱 Step 6: Install on Phone

```
┌─────────────────────────────────────────────────────────────┐
│  TRANSFER & INSTALL APK                                     │
└─────────────────────────────────────────────────────────────┘

Method 1: USB Cable
    Computer                         Phone
    ┌──────────────┐                ┌──────────────┐
    │              │   USB Cable    │              │
    │  💻 PC       │ ──────────────▶│  📱 Phone    │
    │              │                │              │
    │ app-release  │                │ Download/    │
    │ .apk         │                │ app-release  │
    │              │                │ .apk         │
    └──────────────┘                └──────────────┘
           │                               │
           │                               ▼
           │                        Tap APK file
           │                               │
           │                               ▼
           │                        ┌──────────────┐
           │                        │ Install App? │
           │                        │              │
           │                        │ [Install]    │
           │                        └──────────────┘
           │                               │
           │                               ▼
           └───────────────────────▶ ✅ Installed!


Method 2: ADB (Developer)
    ┌─────────────────────────────────────────┐
    │ > adb devices                           │
    │ List of devices attached                │
    │ ABC123456789    device                  │
    │                                         │
    │ > adb install -r build\...\app-release │
    │   .apk                                  │
    │                                         │
    │ Performing Streamed Install             │
    │ Success                                 │
    └─────────────────────────────────────────┘
           │
           ▼
    ✅ Installed via ADB!


Method 3: Email/Cloud
    Computer                    Email/Cloud              Phone
    ┌──────────┐               ┌──────────┐            ┌──────────┐
    │          │               │          │            │          │
    │ Upload   │──────────────▶│  ☁️      │───────────▶│ Download │
    │ APK      │               │  Cloud   │            │ & Install│
    │          │               │          │            │          │
    └──────────┘               └──────────┘            └──────────┘
                                                              │
                                                              ▼
                                                       ✅ Installed!

┌─────────────────────────────────────────────────────────────┐
│ ⚠️  Enable "Unknown Sources" if prompted                    │
│     Settings → Security → Unknown Sources → Enable          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 Step 7: Test the App

```
┌─────────────────────────────────────────────────────────────┐
│  VERIFY APP WORKS WITH BACKEND                              │
└─────────────────────────────────────────────────────────────┘

[1] Launch App
    Phone Screen
    ┌─────────────────────────────────────┐
    │  📱                                  │
    │  ┌───────────────────────────────┐  │
    │  │                               │  │
    │  │    🕉️ Simhastha              │  │
    │  │    AI Assistant               │  │
    │  │                               │  │
    │  └───────────────────────────────┘  │
    │                                      │
    │  [ Tap to Open ]                     │
    └─────────────────────────────────────┘


[2] Check Tabs
    ┌─────────────────────────────────────────────────────────┐
    │  Simhastha AI Assistant                              ⚙️ │
    ├─────────────────────────────────────────────────────────┤
    │                                                          │
    │  🕉️ Temple Guide Tab                                    │
    │  ├─ Mahakaleshwar Temple ✅                             │
    │  ├─ Kal Bhairav Temple ✅                               │
    │  └─ Harsiddhi Temple ✅                                 │
    │                                                          │
    │  📅 Calendar Events Tab                                 │
    │  ├─ First Shahi Snan ✅                                 │
    │  ├─ Second Shahi Snan ✅                                │
    │  └─ Maha Shahi Snan ✅                                  │
    │                                                          │
    │  🏨 Stays & Transit Tab                                 │
    │  ├─ Hotels ✅                                           │
    │  ├─ Dharamshalas ✅                                     │
    │  └─ Transport ✅                                        │
    │                                                          │
    ├─────────────────────────────────────────────────────────┤
    │  [ 🏛️ Guide ]  [ 📅 Events ]  [ 🏨 Stay ]  [ 💬 Chat ] │
    └─────────────────────────────────────────────────────────┘


[3] Monitor Logs (Optional)
    Computer Terminal
    ┌─────────────────────────────────────────┐
    │ > adb logcat | findstr Backend          │
    │                                         │
    │ [Backend] 🔄 Fetching temples...        │
    │ [Backend] ✅ Got 3 temples!             │
    │ [Backend] 🔄 Fetching events...         │
    │ [Backend] ✅ Got 4 events!              │
    │ [Backend] 🔄 Fetching stays...          │
    │ [Backend] ✅ Got 6 stays!               │
    └─────────────────────────────────────────┘

    ngrok Terminal
    ┌─────────────────────────────────────────┐
    │ HTTP Requests                           │
    │ ─────────────                           │
    │ GET /api/temples    200 OK   45ms       │
    │ GET /api/events     200 OK   38ms       │
    │ GET /api/stays      200 OK   52ms       │
    │                                         │
    │ Connections: 3 requests                 │
    └─────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ✅ SUCCESS! App is connected to backend via ngrok!          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Monitoring Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  REAL-TIME MONITORING                                       │
└─────────────────────────────────────────────────────────────┘

ngrok Web Interface: http://127.0.0.1:4040

┌─────────────────────────────────────────────────────────────┐
│  ngrok Inspector                                         ✖️ │
├─────────────────────────────────────────────────────────────┤
│  Status: 🟢 online     Requests: 15     Region: US          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Recent Requests:                                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ 200 GET /api/temples               45ms    2:35 PM    │ │
│  │ 200 GET /api/events                38ms    2:35 PM    │ │
│  │ 200 GET /api/stays                 52ms    2:35 PM    │ │
│  │ 200 GET /api/temples/mahakaleshwar 28ms    2:36 PM    │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Click any request to see details:                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Request Headers                                        │ │
│  │ ├─ Accept: application/json                           │ │
│  │ └─ ngrok-skip-browser-warning: true                   │ │
│  │                                                        │ │
│  │ Response Body (200 OK)                                │ │
│  │ [                                                      │ │
│  │   {                                                    │ │
│  │     "templeId": "mahakaleshwar",                      │ │
│  │     "templeName": "Shri Mahakaleshwar...",            │ │
│  │     ...                                                │ │
│  │   }                                                    │ │
│  │ ]                                                      │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│               END-TO-END DATA FLOW                          │
└─────────────────────────────────────────────────────────────┘

  📱 Phone App
      │
      │ 1. User opens app
      │
      ▼
  ┌──────────────────────┐
  │ Flutter App          │
  │ (app-release.apk)    │
  └──────────────────────┘
      │
      │ 2. Request data
      │ GET https://xxxx.ngrok-free.app/api/temples
      │
      ▼
  ┌──────────────────────┐
  │ Internet             │
  │ (Cellular/WiFi)      │
  └──────────────────────┘
      │
      │ 3. Route through ngrok
      │
      ▼
  ┌──────────────────────┐
  │ ngrok Cloud          │
  │ (US Server)          │
  └──────────────────────┘
      │
      │ 4. Tunnel to local
      │ http://localhost:3000/api/temples
      │
      ▼
  ┌──────────────────────┐
  │ Your PC              │
  │ Backend Server       │
  │ (Node.js)            │
  └──────────────────────┘
      │
      │ 5. Query database
      │ SELECT * FROM temples
      │
      ▼
  ┌──────────────────────┐
  │ MySQL Database       │
  │ (simhastha_db)       │
  └──────────────────────┘
      │
      │ 6. Return data
      │ [{templeId: "mahakaleshwar", ...}]
      │
      ▼
  ┌──────────────────────┐
  │ Backend Server       │
  │ (Format as JSON)     │
  └──────────────────────┘
      │
      │ 7. Send response
      │
      ▼
  ┌──────────────────────┐
  │ ngrok Cloud          │
  │ (Forward response)   │
  └──────────────────────┘
      │
      │ 8. Return to app
      │
      ▼
  ┌──────────────────────┐
  │ Phone App            │
  │ (Display temples)    │
  └──────────────────────┘
      │
      │ 9. User sees data
      │
      ▼
  📱 Happy User!

Total Time: ~100-300ms
```

---

## ✅ Final Checklist

```
┌─────────────────────────────────────────────────────────────┐
│  SETUP VERIFICATION CHECKLIST                               │
└─────────────────────────────────────────────────────────────┘

Pre-Testing
  [ ] ngrok installed
  [ ] ngrok authenticated
  [ ] Backend database setup
  [ ] Flutter SDK installed

Starting Services
  [ ] Backend server started (Terminal 1 shows "Server Running")
  [ ] ngrok tunnel started (Terminal 2 shows "Session Status: online")
  [ ] ngrok URL copied

Testing Backend
  [ ] Browser test successful (JSON data visible)
  [ ] test_api.bat passed (all 3 endpoints ✅)
  [ ] ngrok web interface accessible (localhost:4040)

Configuring App
  [ ] app_constants.dart updated with ngrok URL
  [ ] File saved

Building APK
  [ ] Build completed successfully
  [ ] No errors in build output
  [ ] APK found at: build\app\outputs\flutter-apk\app-release.apk
  [ ] APK size reasonable (~40-60 MB)

Installing on Phone
  [ ] APK transferred to phone
  [ ] Unknown Sources enabled
  [ ] APK installed successfully
  [ ] App icon visible on phone

Testing App
  [ ] App opens without crashing
  [ ] Temple Guide tab shows data
  [ ] Calendar Events tab shows data
  [ ] Stays & Transit tab shows data
  [ ] Chat works
  [ ] No "Failed to connect" errors

Verification
  [ ] App logs show: "[Backend] ✅ Got X temples..."
  [ ] Backend logs show: "GET /api/temples 200"
  [ ] ngrok shows requests in terminal
  [ ] ngrok web interface shows traffic

┌─────────────────────────────────────────────────────────────┐
│  ALL CHECKS PASSED ✅                                       │
│  You're successfully running backend + ngrok + phone app!   │
└─────────────────────────────────────────────────────────────┘
```

---

**Keep this guide handy for visual reference! 🎨**
