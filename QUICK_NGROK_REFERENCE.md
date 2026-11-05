# 🚀 Quick ngrok Reference Card

## One-Time Setup (First Time Only)

```bash
# Install ngrok
choco install ngrok

# Get authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken
ngrok config add-authtoken YOUR_TOKEN_HERE
```

---

## Every Time You Test (3 Steps)

### 1️⃣ Start Backend + ngrok
```bash
cd "e:\AI app\backend"
start_ngrok.bat
```

### 2️⃣ Copy ngrok URL & Update App
```
Look at ngrok terminal, copy the HTTPS URL like:
https://a1b2-c3d4.ngrok-free.app

Edit: lib\constants\app_constants.dart
Change: defaultValue: 'https://a1b2-c3d4.ngrok-free.app',
```

### 3️⃣ Build & Install APK
```bash
cd "e:\AI app\ai_assistant"
flutter build apk --release
```

APK location: `build\app\outputs\flutter-apk\app-release.apk`

---

## Test Before Building

```bash
# Open in browser:
https://YOUR_NGROK_URL.ngrok-free.app/api/temples

# Should see JSON data
```

---

## Useful Commands

```bash
# Start backend only
node server.js

# Start ngrok only
ngrok http 3000

# Test API
test_api.bat https://YOUR_NGROK_URL.ngrok-free.app

# View ngrok traffic
http://127.0.0.1:4040

# Check if ngrok is running
curl https://YOUR_NGROK_URL.ngrok-free.app/api/temples
```

---

## Common URLs to Update

When using ngrok, change these:

| File | Line | Change To |
|------|------|-----------|
| `app_constants.dart` | `defaultValue:` | `'https://xxxx.ngrok-free.app'` |

---

## Build Variations

```bash
# Standard build (uses app_constants.dart)
flutter build apk --release

# Override URL at build time (no file edit needed)
flutter build apk --release --dart-define=BACKEND_URL=https://xxxx.ngrok-free.app

# Debug build (faster, larger file)
flutter build apk --debug
```

---

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| "Failed to connect" | 1. Check ngrok is running<br>2. Test URL in browser<br>3. Rebuild APK |
| "502 Bad Gateway" | Restart backend: `node server.js` |
| "ngrok URL changed" | Normal! Update app & rebuild |
| App is slow | Expected with ngrok (adds latency) |

---

## Alternative: Local WiFi (No ngrok)

**Faster for same network:**

```bash
# Find your IP
ipconfig
# Look for: IPv4 Address like 192.168.1.100

# Update app_constants.dart
defaultValue: 'http://192.168.1.100:3000'

# Allow firewall
netsh advfirewall firewall add rule name="Simhastha" dir=in action=allow protocol=TCP localport=3000
```

**Pro:** Fast, free
**Con:** Same WiFi only

---

## File Locations Quick Reference

```
Backend Server:
  e:\AI app\backend\server.js
  
Flutter Constants:
  e:\AI app\ai_assistant\lib\constants\app_constants.dart
  
Built APK:
  e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
  
Helper Scripts:
  e:\AI app\backend\start_ngrok.bat
  e:\AI app\backend\test_api.bat
```

---

## ngrok Web Interface

While ngrok is running, visit:
**http://127.0.0.1:4040**

Shows:
- ✅ All HTTP requests in real-time
- ✅ Request/response details
- ✅ Replay requests
- ✅ Connection status

---

## Important Notes

⚠️ **Free Tier Limits:**
- New URL every restart (can't persist)
- 2-hour session timeout
- Some latency added

✅ **Good for:**
- Testing on physical devices
- Sharing with others temporarily
- Demo purposes

❌ **Not for:**
- Production use
- Long-term testing (use cloud deployment)

---

## When ngrok URL Changes

If you restart ngrok and get a new URL:

```bash
# 1. Copy new URL from ngrok terminal

# 2. Quick update
# Edit: lib\constants\app_constants.dart
# Change defaultValue to new URL

# 3. Quick rebuild
flutter clean && flutter build apk --release

# 4. Reinstall APK
```

Takes ~3-5 minutes total.

---

## Get Permanent URL

**ngrok Pro Plan:** $8/month
- Custom subdomain: `https://simhastha.ngrok.app`
- No timeout
- Better performance

**Or deploy to cloud (free options):**
- Railway.app
- Render.com
- Fly.io

---

**Print this and keep it handy! 📄**
