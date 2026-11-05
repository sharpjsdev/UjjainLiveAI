# 📱 Phone Testing Setup - Complete Guide

Your backend is now configured for testing on physical phones using ngrok! This document provides everything you need.

---

## 🎯 What Was Implemented

### ✅ Backend Changes

1. **Updated Node.js Server** (`backend/server.js`)
   - Added ngrok-friendly headers
   - Configured for external access
   - CORS enabled for all origins

2. **Updated Flutter Service** (`lib/services/simhastha_backend_service.dart`)
   - Reads backend URL from AppConstants
   - Added ngrok-skip-browser-warning header
   - Increased timeout to 10 seconds for ngrok latency
   - Graceful fallback to offline data

3. **Updated App Constants** (`lib/constants/app_constants.dart`)
   - Added `backendBaseUrl` configuration
   - Supports environment variable override
   - Easy to update for different environments

---

## 📁 New Files Created

### Documentation Files

| File | Purpose | Use When |
|------|---------|----------|
| `backend/README_NGROK.md` | Detailed ngrok setup guide | First-time setup |
| `QUICK_NGROK_REFERENCE.md` | Quick reference card | Daily testing |
| `COMPLETE_TESTING_WORKFLOW.md` | Step-by-step workflow | Complete guidance |
| `README_PHONE_TESTING.md` | This file - overview | Getting started |

### Helper Scripts

| File | Purpose | Command |
|------|---------|---------|
| `backend/start_ngrok.bat` | Auto-start backend + ngrok | `start_ngrok.bat` |
| `backend/test_api.bat` | Test backend APIs | `test_api.bat URL` |
| `ai_assistant/build_for_phone.bat` | Build APK with options | `build_for_phone.bat` |

### Configuration Files

| File | Purpose |
|------|---------|
| `backend/.env.example` | Environment variables template |

---

## 🚀 Quick Start (3 Methods)

### Method 1: Using ngrok (Recommended for Remote Testing)

**Best for:** Testing on any phone, anywhere

```bash
# 1. Start backend and ngrok
cd "e:\AI app\backend"
start_ngrok.bat

# 2. Copy the ngrok HTTPS URL from terminal
# Example: https://a1b2-c3d4.ngrok-free.app

# 3. Update Flutter app
# Edit: lib\constants\app_constants.dart
# Change: defaultValue: 'https://your-ngrok-url.ngrok-free.app'

# 4. Build APK
cd "e:\AI app\ai_assistant"
build_for_phone.bat

# 5. Install on phone and test!
```

**Time:** ~10 minutes first time, ~5 minutes after

---

### Method 2: Local WiFi (Fastest, Same Network Only)

**Best for:** Quick testing when on same WiFi

```bash
# 1. Find your computer's IP
ipconfig
# Look for: IPv4 Address like 192.168.1.100

# 2. Allow firewall
netsh advfirewall firewall add rule name="Simhastha" dir=in action=allow protocol=TCP localport=3000

# 3. Start backend
cd "e:\AI app\backend"
node server.js

# 4. Update Flutter app
# Edit: lib\constants\app_constants.dart
# Change: defaultValue: 'http://192.168.1.100:3000'

# 5. Build and install
cd "e:\AI app\ai_assistant"
build_for_phone.bat
```

**Pros:** Fast, no ngrok needed
**Cons:** Must be on same WiFi

---

### Method 3: Build-Time URL Override (No File Editing)

**Best for:** Quick tests without editing files

```bash
# 1. Start backend + ngrok
cd "e:\AI app\backend"
start_ngrok.bat

# 2. Build with custom URL
cd "e:\AI app\ai_assistant"
flutter build apk --release --dart-define=BACKEND_URL=https://your-ngrok-url.ngrok-free.app

# 3. Install and test
adb install build\app\outputs\flutter-apk\app-release.apk
```

**Pros:** No file editing
**Cons:** Must specify URL each time

---

## 📖 Documentation Guide

### For First-Time Setup
1. Read: `backend/README_NGROK.md`
   - Complete ngrok installation guide
   - Detailed setup instructions
   - Troubleshooting section

### For Daily Use
1. Keep handy: `QUICK_NGROK_REFERENCE.md`
   - Quick commands
   - Common fixes
   - File locations

### For Complete Workflow
1. Follow: `COMPLETE_TESTING_WORKFLOW.md`
   - Full step-by-step process
   - Decision trees
   - Optimization tips

---

## 🛠️ Helper Scripts Reference

### start_ngrok.bat

**Location:** `backend/start_ngrok.bat`

**What it does:**
- Starts backend server (Node.js)
- Starts ngrok tunnel on port 3000
- Shows next steps

**Usage:**
```bash
cd "e:\AI app\backend"
start_ngrok.bat
```

**Output:** 
- Two terminal windows (backend + ngrok)
- Instructions for next steps

---

### test_api.bat

**Location:** `backend/test_api.bat`

**What it does:**
- Tests all 3 API endpoints
- Works with localhost or ngrok
- Shows pass/fail for each endpoint

**Usage:**
```bash
# Test localhost
cd "e:\AI app\backend"
test_api.bat

# Test ngrok URL
test_api.bat https://your-ngrok-url.ngrok-free.app
```

**Output:**
```
✅ Temples API working!
✅ Events API working!
✅ Stays API working!
```

---

### build_for_phone.bat

**Location:** `ai_assistant/build_for_phone.bat`

**What it does:**
- Shows current backend URL
- Offers to override URL
- Cleans previous build
- Builds release APK
- Shows APK location
- Optionally installs via ADB
- Opens APK folder

**Usage:**
```bash
cd "e:\AI app\ai_assistant"
build_for_phone.bat
```

**Features:**
- Interactive prompts
- URL override option
- ADB installation option
- Explorer integration

---

## 🔍 How It Works

### Architecture Overview

```
┌─────────────────┐
│  Physical Phone │
│   (Your APK)    │
└────────┬────────┘
         │
         │ HTTPS
         │
┌────────▼────────┐
│  ngrok Tunnel   │ (Public: https://xxxx.ngrok-free.app)
│  (Cloud)        │
└────────┬────────┘
         │
         │ HTTP
         │
┌────────▼────────┐
│ Local Backend   │ (Localhost:3000)
│  (Your PC)      │
└────────┬────────┘
         │
┌────────▼────────┐
│ MySQL Database  │
│  (Local DB)     │
└─────────────────┘
```

### Request Flow

1. **App sends request:** `https://xxxx.ngrok-free.app/api/temples`
2. **ngrok forwards to:** `http://localhost:3000/api/temples`
3. **Backend queries:** MySQL database
4. **Backend responds:** JSON data
5. **ngrok forwards:** Response back to phone
6. **App displays:** Data to user

---

## 🎯 Testing Checklist

### Pre-Testing
- [ ] ngrok installed and authenticated
- [ ] Backend database populated
- [ ] Node.js and Flutter installed

### Every Test Session
- [ ] Backend server running
- [ ] ngrok tunnel active (showing "online")
- [ ] ngrok URL copied
- [ ] Browser test passed (JSON visible)
- [ ] app_constants.dart updated OR build-time override used
- [ ] APK built successfully
- [ ] APK transferred to phone
- [ ] App installed

### Verification
- [ ] App opens without crash
- [ ] Temple Guide tab shows data
- [ ] Calendar Events tab shows data
- [ ] Stays & Transit tab shows data
- [ ] No "Failed to connect" errors
- [ ] Logs show successful backend connection

---

## 🐛 Common Issues & Solutions

### Issue: "Failed to connect to backend"

**Possible Causes:**
1. Backend not running
2. ngrok not running
3. Wrong URL in app
4. Didn't rebuild after URL change
5. Firewall blocking

**Solution:**
```bash
# 1. Check backend is running
# Terminal should show: "Server Running on Port: 3000"

# 2. Check ngrok is running
# Terminal should show: "Session Status: online"

# 3. Test URL in browser
https://your-ngrok-url.ngrok-free.app/api/temples

# 4. Verify app_constants.dart has correct URL

# 5. Rebuild APK
flutter clean && flutter build apk --release
```

---

### Issue: ngrok URL changes every restart

**Why:** Free tier gives random URLs

**Solutions:**

**Quick Fix:** Rebuild APK with new URL each time
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://new-url.ngrok-free.app
```

**Better Fix:** ngrok Pro ($8/month)
- Get permanent custom subdomain
- No URL changes
- No rebuilding needed

**Best Fix:** Deploy to cloud
- Railway, Render, Fly.io (free tiers available)
- Permanent URL
- Better performance

---

### Issue: App is slow

**Why:** ngrok adds latency (routes through their servers)

**Expected Latency:**
- Local: ~10ms
- ngrok: ~100-300ms
- Acceptable for testing!

**Solutions:**
- Use local WiFi for faster testing
- Get ngrok Pro for better performance
- Deploy to cloud for production

---

### Issue: Can't install APK

**Check:**
- "Unknown Sources" enabled in phone settings?
- Enough storage space?
- USB Debugging enabled (for ADB)?
- Previous version uninstalled?

**Fix:**
```
Phone Settings → Security → Unknown Sources → Enable
```

---

## 📊 Monitoring Your Testing

### Terminal Monitoring

**Backend Terminal:**
```
GET /api/temples 200 15ms
GET /api/events 200 8ms
GET /api/stays 200 12ms
```

**ngrok Terminal:**
```
HTTP Requests
-------------
GET /api/temples     200 OK
GET /api/events      200 OK
```

---

### ngrok Web Interface

Visit: **http://127.0.0.1:4040**

**Features:**
- Real-time request logs
- Request/response inspection
- Request replay
- Performance metrics

---

### App Logs (ADB)

```bash
adb logcat | findstr Backend
```

**Successful:**
```
[Backend] 🔄 Fetching temples from https://xxxx.ngrok-free.app/api/temples...
[Backend] ✅ Got 3 temples from backend MySQL!
```

**Failed:**
```
[Backend] ❌ ERROR fetching temples: SocketException
[Backend] 🔙 Falling back to embedded offline data...
```

---

## 🎓 Best Practices

### 1. Always Test API First

Before building APK, test in browser:
```
https://your-ngrok-url.ngrok-free.app/api/temples
```

Should see JSON data. If not, fix backend first.

---

### 2. Keep ngrok & Backend Running

Don't close those terminals while testing!
- Backend terminal: Shows API requests
- ngrok terminal: Shows tunnel status

---

### 3. Use Scripts

Automated scripts save time:
- `start_ngrok.bat` - One command to start everything
- `build_for_phone.bat` - Interactive APK builder
- `test_api.bat` - Quick API verification

---

### 4. Document Your ngrok URL

Keep track of current URL:
```
Current Session: https://a1b2-c3d4.ngrok-free.app
Started: 2:30 PM
Expires: 4:30 PM (2 hours)
```

---

### 5. Clean Build When Changing URLs

```bash
flutter clean
flutter build apk --release
```

Ensures new URL is baked in.

---

## 🚀 Next Steps

### Short Term (Testing Phase)

1. **Use ngrok for testing**
   - Fine for development
   - URL changes are okay
   - Just rebuild as needed

2. **Test on multiple devices**
   - Same ngrok URL works for all
   - Test different Android versions
   - Test different screen sizes

---

### Medium Term (Staging)

1. **Deploy backend to cloud**
   - Railway.app (free tier)
   - Render.com (free tier)
   - Get permanent URL

2. **Use staging URL in app**
   ```dart
   defaultValue: 'https://simhastha-api.railway.app'
   ```

3. **No more rebuilding!**
   - URL never changes
   - Better performance
   - Team can use same backend

---

### Long Term (Production)

1. **Professional hosting**
   - AWS, GCP, Azure
   - Load balancing
   - Auto-scaling

2. **Environment switching**
   - Dev, staging, production URLs
   - Config in app settings
   - No rebuild needed

3. **CI/CD pipeline**
   - GitHub Actions
   - Automated builds
   - Automated deployment

---

## 📚 Additional Resources

### ngrok
- Website: https://ngrok.com
- Docs: https://ngrok.com/docs
- Dashboard: https://dashboard.ngrok.com

### Flutter
- Docs: https://docs.flutter.dev
- Build Guide: https://docs.flutter.dev/deployment/android

### ADB
- Docs: https://developer.android.com/studio/command-line/adb

---

## 💡 Tips & Tricks

### Tip 1: Keep Multiple URLs

Track URLs for different purposes:
```
Development: http://localhost:3000
Testing (ngrok): https://xxxx.ngrok-free.app
Staging: https://api-staging.yourapp.com
Production: https://api.yourapp.com
```

### Tip 2: Use ADB for Faster Install

```bash
# Build and install in one command
flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Tip 3: Test Multiple Scenarios

- ✅ Backend running (should load data)
- ❌ Backend stopped (should show offline data)
- ❌ Wrong URL (should show offline data)
- ⚠️ Slow network (should show loading)

### Tip 4: Share with Team

Same ngrok URL works for everyone:
1. You start ngrok
2. Share URL with team
3. They test on their phones
4. No setup needed for them!

---

## ✅ Success Indicators

You'll know everything is working when:

1. **Backend logs show requests:**
   ```
   GET /api/temples 200 15ms
   ```

2. **ngrok shows traffic:**
   ```
   HTTP Requests: 15
   Connections: 1
   ```

3. **App logs show success:**
   ```
   [Backend] ✅ Got 3 temples from backend MySQL!
   ```

4. **App displays data:**
   - Temple cards appear
   - Events listed
   - Stays visible

---

## 🎉 You're Ready!

Everything is set up for phone testing. Choose your workflow:

- **Quick Testing:** Use Method 2 (Local WiFi)
- **Remote Testing:** Use Method 1 (ngrok)
- **No File Editing:** Use Method 3 (Build-time override)

**Start with:** `QUICK_NGROK_REFERENCE.md` for commands you'll use daily.

**Need help?** Check `COMPLETE_TESTING_WORKFLOW.md` for detailed steps.

---

**Happy Testing! 🚀📱**
