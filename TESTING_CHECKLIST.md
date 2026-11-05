# ✅ Complete Testing Checklist

Use this checklist to verify your ngrok setup is working correctly.

---

## 📋 Pre-Flight Checklist (One-Time Setup)

### 1. Software Installation

- [ ] **ngrok installed**
  ```bash
  ngrok version
  ```
  Expected: `ngrok version 3.x.x`

- [ ] **Node.js installed**
  ```bash
  node --version
  ```
  Expected: `v18.x.x` or higher

- [ ] **Flutter installed**
  ```bash
  flutter --version
  ```
  Expected: `Flutter 3.x.x`

- [ ] **MySQL running** (if using MySQL)
  ```bash
  mysql --version
  ```
  Or using Python with SQLite

---

### 2. ngrok Configuration

- [ ] **ngrok account created**
  - Visit: https://dashboard.ngrok.com/signup
  - Sign up with email

- [ ] **Authtoken configured**
  ```bash
  ngrok config add-authtoken YOUR_TOKEN_HERE
  ```
  Get token from: https://dashboard.ngrok.com/get-started/your-authtoken

- [ ] **Verify ngrok works**
  ```bash
  ngrok http 3000
  ```
  Expected: Shows "Session Status: online"

---

### 3. Backend Setup

- [ ] **Database configured**
  - MySQL: Check `.env` file has correct credentials
  - SQLite: Will be created automatically

- [ ] **Backend dependencies installed**
  ```bash
  cd "e:\AI app\backend"
  npm install
  ```

- [ ] **Backend starts successfully**
  ```bash
  node server.js
  ```
  Expected: "Server Running on Port: 3000"

---

### 4. Flutter Setup

- [ ] **Flutter dependencies installed**
  ```bash
  cd "e:\AI app\ai_assistant"
  flutter pub get
  ```

- [ ] **No errors in Flutter doctor**
  ```bash
  flutter doctor
  ```
  Expected: All checks pass (or only minor warnings)

---

## 🚀 Testing Session Checklist (Every Test)

### Phase 1: Start Services (2 minutes)

- [ ] **Start backend + ngrok**
  ```bash
  cd "e:\AI app\backend"
  start_ngrok.bat
  ```

- [ ] **Backend terminal shows:**
  ```
  Server Running on Port: 3000
  ```

- [ ] **ngrok terminal shows:**
  ```
  Session Status: online
  Forwarding: https://xxxx.ngrok-free.app -> http://localhost:3000
  ```

- [ ] **Copy ngrok URL**
  - Copy the HTTPS URL (e.g., `https://a1b2-c3d4.ngrok-free.app`)
  - Write it here: _________________________________

---

### Phase 2: Test Backend (1 minute)

- [ ] **Test in browser**
  - Open: `https://YOUR_NGROK_URL/api/temples`
  - Expected: JSON array with temple data
  - Screenshot if working ✅

- [ ] **Or use test script**
  ```bash
  cd "e:\AI app\backend"
  test_api.bat https://YOUR_NGROK_URL
  ```
  Expected:
  ```
  ✅ Temples API working!
  ✅ Events API working!
  ✅ Stays API working!
  ```

- [ ] **Check ngrok web interface**
  - Open: http://127.0.0.1:4040
  - See requests logged

---

### Phase 3: Configure App (1 minute)

Choose ONE method:

#### Option A: Edit Constants File

- [ ] **Open file**
  ```
  e:\AI app\ai_assistant\lib\constants\app_constants.dart
  ```

- [ ] **Find line ~10:**
  ```dart
  defaultValue: 'http://localhost:3000',
  ```

- [ ] **Change to:**
  ```dart
  defaultValue: 'https://YOUR_NGROK_URL',
  ```

- [ ] **Save file** (Ctrl+S)

#### Option B: Build-Time Override

- [ ] **Skip file editing, use build command instead:**
  ```bash
  flutter build apk --release --dart-define=BACKEND_URL=https://YOUR_NGROK_URL
  ```

---

### Phase 4: Build APK (3-5 minutes)

- [ ] **Navigate to project**
  ```bash
  cd "e:\AI app\ai_assistant"
  ```

- [ ] **Build APK**
  
  **Option A: Interactive script**
  ```bash
  build_for_phone.bat
  ```
  
  **Option B: Manual**
  ```bash
  flutter clean
  flutter build apk --release
  ```

- [ ] **Build completes successfully**
  Expected: "✓ Built build\app\outputs\flutter-apk\app-release.apk"

- [ ] **APK file exists**
  Location: `build\app\outputs\flutter-apk\app-release.apk`
  Size: ~40-60 MB

---

### Phase 5: Install on Phone (2 minutes)

Choose ONE method:

#### Method A: USB Cable

- [ ] Connect phone via USB
- [ ] Enable "File Transfer" mode
- [ ] Copy APK to phone's Download folder
- [ ] On phone: Tap APK file
- [ ] Allow "Unknown Sources" if prompted
- [ ] Tap "Install"
- [ ] Wait for installation
- [ ] Tap "Open" or launch from app drawer

#### Method B: ADB

- [ ] **Check device connected**
  ```bash
  adb devices
  ```
  Expected: Shows your device ID

- [ ] **Install APK**
  ```bash
  adb install -r "build\app\outputs\flutter-apk\app-release.apk"
  ```
  Expected: "Success"

#### Method C: Email/Cloud

- [ ] Upload APK to Google Drive/Dropbox
- [ ] Download on phone
- [ ] Install from Downloads

---

### Phase 6: Test App on Phone (5 minutes)

- [ ] **App installs successfully**
  - No errors during installation

- [ ] **App launches**
  - Opens without crashing
  - Shows splash screen
  - Loads home screen

- [ ] **Temple Guide Tab works**
  - Navigate to Temple Guide tab
  - See temple cards loading
  - Expected: Shows 3+ temples
  - Tap a temple to see details

- [ ] **Calendar Events Tab works**
  - Navigate to Calendar Events tab
  - See events loading
  - Expected: Shows 4+ events
  - Events show dates and details

- [ ] **Stays & Transit Tab works**
  - Navigate to Stays tab
  - See places loading
  - Expected: Shows 6+ places
  - Filter by category works

- [ ] **Chat works** (optional)
  - Navigate to Chat tab
  - Send a test message
  - Get response

---

### Phase 7: Verify Connection (2 minutes)

- [ ] **Check app logs** (if ADB connected)
  ```bash
  adb logcat | findstr Backend
  ```
  Expected to see:
  ```
  [Backend] 🔄 Fetching temples from https://xxxx.ngrok-free.app...
  [Backend] ✅ Got 3 temples from backend MySQL!
  [Backend] ✅ Got 4 events from backend MySQL!
  [Backend] ✅ Got 6 places from backend MySQL!
  ```

- [ ] **Check backend terminal**
  Expected to see:
  ```
  GET /api/temples 200 25ms
  GET /api/events 200 18ms
  GET /api/stays 200 32ms
  ```

- [ ] **Check ngrok terminal**
  Expected to see:
  ```
  HTTP Requests
  GET /api/temples    200 OK
  GET /api/events     200 OK
  GET /api/stays      200 OK
  ```

- [ ] **Check ngrok web interface**
  - Open: http://127.0.0.1:4040
  - See requests from your phone
  - Click request to inspect details

---

## 🎯 Success Criteria

Mark each ✅ when achieved:

### Backend
- [ ] Backend server starts without errors
- [ ] ngrok tunnel connects successfully
- [ ] Browser shows JSON data from ngrok URL
- [ ] All 3 API endpoints return 200 OK
- [ ] test_api.bat shows all ✅

### App
- [ ] APK builds without errors
- [ ] APK installs on phone
- [ ] App launches successfully
- [ ] All 3 tabs load data from backend
- [ ] No "Failed to connect" errors
- [ ] App logs show successful backend connection

### Monitoring
- [ ] Backend terminal shows API requests
- [ ] ngrok terminal shows forwarded requests
- [ ] ngrok web interface shows traffic
- [ ] ADB logcat shows successful data fetch

---

## 🐛 Troubleshooting Checklist

If something doesn't work, check these:

### Backend Issues

- [ ] **Backend won't start**
  - Check port 3000 is not already in use
  - Check MySQL credentials (if using MySQL)
  - Check Node.js is installed
  - Try: `npm install` first

- [ ] **ngrok won't connect**
  - Check authtoken is configured
  - Check internet connection
  - Try: `ngrok config check`
  - Try different region: `ngrok http 3000 --region us`

- [ ] **Browser shows error**
  - 502 Bad Gateway → Backend not running
  - 404 Not Found → Wrong URL or endpoint
  - ERR_NAME_NOT_RESOLVED → ngrok not running

### App Issues

- [ ] **Build fails**
  - Run: `flutter clean`
  - Run: `flutter pub get`
  - Check Flutter doctor: `flutter doctor`
  - Check internet connection (downloads dependencies)

- [ ] **App won't install**
  - Enable "Unknown Sources" in phone settings
  - Check storage space on phone
  - Try uninstalling previous version first

- [ ] **App crashes on launch**
  - Check ADB logcat for errors
  - Rebuild with: `flutter build apk --release`
  - Try debug build: `flutter build apk --debug`

- [ ] **App shows no data**
  - Check if backend URL is correct in app_constants.dart
  - Rebuild APK after changing URL
  - Test ngrok URL in browser first
  - Check app logs with ADB logcat

---

## 📊 Test Results Log

### Session Date: _______________

### ngrok URL: _______________

### Test Results:

| Component | Status | Notes |
|-----------|--------|-------|
| Backend Start | ⬜ Pass ⬜ Fail | |
| ngrok Tunnel | ⬜ Pass ⬜ Fail | |
| Browser Test | ⬜ Pass ⬜ Fail | |
| API Test Script | ⬜ Pass ⬜ Fail | |
| APK Build | ⬜ Pass ⬜ Fail | |
| APK Install | ⬜ Pass ⬜ Fail | |
| App Launch | ⬜ Pass ⬜ Fail | |
| Temple Tab | ⬜ Pass ⬜ Fail | |
| Events Tab | ⬜ Pass ⬜ Fail | |
| Stays Tab | ⬜ Pass ⬜ Fail | |
| Backend Logs | ⬜ Pass ⬜ Fail | |

### Issues Encountered:
_____________________________________________
_____________________________________________
_____________________________________________

### Solutions Applied:
_____________________________________________
_____________________________________________
_____________________________________________

### Total Time: __________ minutes

---

## 🎓 Quick Reference

### Most Common Commands

```bash
# Start everything
cd "e:\AI app\backend" && start_ngrok.bat

# Test API
cd "e:\AI app\backend" && test_api.bat https://YOUR_URL

# Build APK
cd "e:\AI app\ai_assistant" && build_for_phone.bat

# Install APK
adb install -r build\app\outputs\flutter-apk\app-release.apk

# Watch logs
adb logcat | findstr Backend
```

### Files to Update

```
Backend URL:
e:\AI app\ai_assistant\lib\constants\app_constants.dart
Line 10: defaultValue: 'https://YOUR_NGROK_URL'
```

### Important URLs

```
ngrok Web Interface: http://127.0.0.1:4040
Backend (local): http://localhost:3000
Backend (ngrok): https://YOUR_NGROK_URL.ngrok-free.app
Test Endpoint: https://YOUR_NGROK_URL/api/temples
```

---

## ✅ Final Verification

All items checked = Perfect setup! 🎉

- [ ] I can start backend + ngrok with one command
- [ ] I can test APIs in browser
- [ ] I can build APK successfully
- [ ] I can install APK on my phone
- [ ] App loads data from my backend
- [ ] I understand how to troubleshoot issues
- [ ] I know where to find documentation

---

## 📚 Next Actions

After completing this checklist:

1. **Keep for reference**
   - Use this checklist for every test session
   - Mark your results in the log section

2. **Share with team**
   - Others can follow the same checklist
   - Same ngrok URL works for everyone

3. **Automate more**
   - Consider scripting repetitive tasks
   - Set up aliases for common commands

---

**Print this checklist and keep it at your desk!** 📄✅
