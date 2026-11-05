# 📱 Complete Testing Workflow: Backend to Phone

This is your step-by-step checklist for testing the Simhastha APK on a physical phone with ngrok.

---

## 🎯 Goal
Run your backend locally, expose it via ngrok, build an APK, and test on your physical Android phone.

---

## ✅ Pre-Flight Checklist

Before starting, make sure you have:

- [ ] ngrok installed and authenticated
- [ ] Node.js installed (for backend)
- [ ] Flutter SDK installed
- [ ] Physical Android phone
- [ ] USB cable (optional, for ADB install)
- [ ] Backend database setup (MySQL or SQLite)

---

## 🚀 Complete Workflow (First Time)

### Phase 1: Setup ngrok (One-Time)

```bash
# 1. Install ngrok
choco install ngrok

# 2. Get authtoken from https://dashboard.ngrok.com/get-started/your-authtoken
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE

# 3. Verify installation
ngrok version
```

**Time:** 5 minutes

---

### Phase 2: Start Backend & ngrok

```bash
# Option A: Use automated script (recommended)
cd "e:\AI app\backend"
start_ngrok.bat

# Option B: Manual start
# Terminal 1: Start backend
node server.js

# Terminal 2: Start ngrok
ngrok http 3000
```

**Expected Output:**

Backend Terminal:
```
=======================================================
Simhastha Ujjain 2028 Node.js MySQL Server Running
Port: 3000
=======================================================
```

ngrok Terminal:
```
Forwarding    https://a1b2-c3d4-e5f6.ngrok-free.app -> http://localhost:3000
```

**Action:** Copy the ngrok HTTPS URL

**Time:** 2 minutes

---

### Phase 3: Test Backend Connection

```bash
# Test in browser
https://YOUR_NGROK_URL.ngrok-free.app/api/temples

# Or use test script
cd "e:\AI app\backend"
test_api.bat https://YOUR_NGROK_URL.ngrok-free.app
```

**Expected:** JSON data with temples

**If fails:** Check that both backend and ngrok are running

**Time:** 1 minute

---

### Phase 4: Update Flutter App

**Edit:** `e:\AI app\ai_assistant\lib\constants\app_constants.dart`

**Find this line (around line 10):**
```dart
defaultValue: 'http://localhost:3000',
```

**Change to:**
```dart
defaultValue: 'https://a1b2-c3d4-e5f6.ngrok-free.app',
```

**Replace** `a1b2-c3d4-e5f6.ngrok-free.app` with YOUR actual ngrok URL

**Save the file!**

**Time:** 1 minute

---

### Phase 5: Build APK

```bash
# Option A: Use build script (recommended)
cd "e:\AI app\ai_assistant"
build_for_phone.bat

# Option B: Manual build
cd "e:\AI app\ai_assistant"
flutter clean
flutter build apk --release
```

**Build Time:** 3-5 minutes

**Output Location:**
```
e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
```

**Expected Size:** ~40-60 MB

---

### Phase 6: Install on Phone

Choose your method:

#### Method A: USB Cable (Easiest)

1. Connect phone to computer
2. Enable "File Transfer" mode
3. Copy `app-release.apk` to phone's `Download` folder
4. On phone: Files → Downloads → Tap APK
5. Allow "Install from Unknown Sources"
6. Install!

#### Method B: ADB (Developer-Friendly)

```bash
# Check phone is connected
adb devices

# Install APK
adb install -r "build\app\outputs\flutter-apk\app-release.apk"
```

#### Method C: Cloud/Email

1. Upload APK to Google Drive/Dropbox
2. Download on phone
3. Install from Downloads

**Time:** 2-3 minutes

---

### Phase 7: Test the App

1. Open the Simhastha AI Assistant app on your phone

2. Try these actions:
   - Browse temple guide tab
   - Check calendar events tab
   - View stays & dharamshalas tab
   - Ask a question in chat

3. **Expected behavior:**
   - Data loads from backend
   - Real-time updates work
   - No "Failed to connect" errors

4. **Check logs (optional):**
   ```bash
   adb logcat | findstr Backend
   ```

   Look for:
   ```
   [Backend] ✅ Got X temples from backend MySQL!
   ```

**Time:** 5 minutes

---

## 🔄 Subsequent Testing (After First Time)

Once set up, testing is faster:

### Quick Workflow (Every Test Session)

1. **Start services** (2 min)
   ```bash
   cd "e:\AI app\backend"
   start_ngrok.bat
   ```

2. **Copy new ngrok URL** (1 min)
   - ngrok gives you a new URL each restart
   - Copy from terminal

3. **Update app** (1 min)
   ```bash
   # Edit app_constants.dart
   # Change defaultValue to new URL
   ```

4. **Rebuild** (3 min)
   ```bash
   cd "e:\AI app\ai_assistant"
   build_for_phone.bat
   ```

5. **Reinstall** (2 min)
   ```bash
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

**Total:** ~9 minutes per test cycle

---

## 🛠️ Optimization Tips

### Skip URL Updates

Use build-time override (no file editing):

```bash
flutter build apk --release --dart-define=BACKEND_URL=https://xxxx.ngrok-free.app
```

### Use Local WiFi Instead

If on same network (faster, no ngrok):

```bash
# Find your IP
ipconfig
# Look for: 192.168.x.x

# Build with local IP
flutter build apk --release --dart-define=BACKEND_URL=http://192.168.x.x:3000
```

### Get Permanent ngrok URL

ngrok Pro ($8/month) gives you:
- Custom subdomain: `https://simhastha.ngrok.app`
- No expiration
- No URL changes
- **No need to rebuild APK each time!**

---

## 🐛 Troubleshooting Decision Tree

### Problem: App shows "Failed to connect"

1. ✅ Is backend running?
   - Check terminal: Should show "Server Running"
   - Fix: Restart `node server.js`

2. ✅ Is ngrok running?
   - Check terminal: Should show "Session Status: online"
   - Fix: Restart `ngrok http 3000`

3. ✅ Did you update app_constants.dart?
   - Check the file: Should have ngrok URL
   - Fix: Update and rebuild

4. ✅ Did you rebuild APK after updating?
   - Check build time: Should be recent
   - Fix: Run `flutter build apk --release`

5. ✅ Is ngrok URL correct?
   - Test in browser: Should show JSON
   - Fix: Copy correct URL from ngrok terminal

### Problem: ngrok shows "502 Bad Gateway"

**Cause:** Backend crashed or not running

**Fix:**
```bash
cd "e:\AI app\backend"
node server.js
```

### Problem: Build fails

**Check:**
- Flutter SDK installed?
- In correct directory?
- Internet connection (downloads dependencies)?

**Fix:**
```bash
flutter doctor
flutter pub get
flutter clean
flutter build apk --release
```

### Problem: Can't install APK on phone

**Check:**
- "Install from Unknown Sources" enabled?
- Enough storage space?
- USB Debugging enabled (for ADB)?

**Fix:** Enable in Settings → Security

---

## 📊 Monitoring & Debugging

### Real-Time Monitoring

While testing, keep these open:

1. **Backend Terminal**
   - Shows API requests
   - Shows errors

2. **ngrok Terminal**
   - Shows tunnel status
   - Shows connection count

3. **ngrok Web Interface**
   ```
   http://127.0.0.1:4040
   ```
   - Detailed request/response logs
   - Can replay requests

4. **ADB Logcat**
   ```bash
   adb logcat | findstr Backend
   ```
   - Shows app logs
   - Shows connection attempts

### Useful Logs to Watch

**Successful connection:**
```
[Backend] 🔄 Fetching temples from https://xxxx.ngrok-free.app/api/temples...
[Backend] ✅ Got 3 temples from backend MySQL!
```

**Failed connection:**
```
[Backend] ❌ ERROR fetching temples: SocketException
[Backend] 🔙 Falling back to embedded offline data...
```

---

## 🎯 Success Criteria

Your setup is working correctly when:

- [ ] Backend server starts without errors
- [ ] ngrok tunnel shows "Session Status: online"
- [ ] Browser shows JSON when visiting ngrok URL
- [ ] APK builds successfully
- [ ] APK installs on phone
- [ ] App opens without crashing
- [ ] App loads data from backend (check logs)
- [ ] All tabs show dynamic data
- [ ] No "Failed to connect" errors

---

## 🚀 Advanced: CI/CD Pipeline

For frequent testing, automate everything:

### Master Script: `test_on_phone.bat`

```batch
@echo off
echo Full E2E Test Pipeline
echo.

REM 1. Start services
start cmd /k "cd e:\AI app\backend && node server.js"
timeout /t 2
start cmd /k "ngrok http 3000"
timeout /t 5

REM 2. Get ngrok URL (requires jq or manual)
curl -s http://127.0.0.1:4040/api/tunnels | jq -r .tunnels[0].public_url > ngrok_url.txt
set /p NGROK_URL=<ngrok_url.txt

REM 3. Build APK
cd "e:\AI app\ai_assistant"
flutter build apk --release --dart-define=BACKEND_URL=%NGROK_URL%

REM 4. Install
adb install -r build\app\outputs\flutter-apk\app-release.apk

echo Done! Test the app now.
pause
```

---

## 📈 Performance Tips

### Reduce Build Time

```bash
# Use debug build (faster, larger)
flutter build apk --debug

# Use split APKs (smaller, faster)
flutter build apk --split-per-abi

# Use app bundle (for Play Store)
flutter build appbundle
```

### Reduce Testing Latency

- Use local WiFi instead of ngrok
- Deploy backend to cloud (Railway, Render)
- Use ngrok Pro for better performance

---

## 🎓 Next Steps

Once comfortable with ngrok testing:

1. **Add Environment Switcher**
   - Create settings screen
   - Toggle between dev/staging/prod URLs
   - No rebuild needed

2. **Deploy Backend to Cloud**
   - Railway, Render, Heroku
   - Get permanent URL
   - Better performance

3. **Implement Proper Logging**
   - Firebase Crashlytics
   - Sentry
   - Custom analytics

4. **Setup CI/CD**
   - GitHub Actions
   - Automated builds
   - Automated testing

---

## 📚 Reference Links

- **ngrok Docs:** https://ngrok.com/docs
- **Flutter Build Docs:** https://docs.flutter.dev/deployment/android
- **ADB Commands:** https://developer.android.com/studio/command-line/adb

---

## ✅ Quick Checklist (Print & Keep)

```
[ ] ngrok installed & authenticated
[ ] Backend server started (port 3000)
[ ] ngrok tunnel started
[ ] ngrok URL copied
[ ] Browser test successful (JSON visible)
[ ] app_constants.dart updated
[ ] APK built successfully
[ ] APK transferred to phone
[ ] APK installed
[ ] App tested & working
[ ] Logs showing successful connection
```

---

**You're all set! Happy testing! 🎉📱**
