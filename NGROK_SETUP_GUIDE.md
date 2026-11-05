# 📱 Complete Guide: Testing APK on Phone with ngrok

This guide walks you through setting up ngrok to test your Simhastha AI Assistant APK on a physical phone.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (5 minutes)](#quick-setup)
3. [Detailed Step-by-Step](#detailed-steps)
4. [Troubleshooting](#troubleshooting)
5. [Alternative Methods](#alternatives)

---

## Prerequisites

### ✅ What You Need:

1. **ngrok installed** - [Download here](https://ngrok.com/download)
2. **ngrok account** - [Sign up free](https://dashboard.ngrok.com/signup)
3. **Backend server ready** - Node.js or Python
4. **Flutter SDK** - For building APK
5. **Physical Android phone** - With USB debugging or file transfer

---

## Quick Setup

### For the Impatient (5-Minute Version):

```bash
# 1. Install ngrok (choose one)
choco install ngrok          # Windows with Chocolatey
npm install -g ngrok         # Or via npm

# 2. Set your authtoken (get from https://dashboard.ngrok.com/get-started/your-authtoken)
ngrok config add-authtoken YOUR_TOKEN_HERE

# 3. Start everything (use provided script)
cd "e:\AI app\backend"
start_ngrok.bat

# 4. Copy the ngrok HTTPS URL from the terminal

# 5. Update Flutter app
# Edit: e:\AI app\ai_assistant\lib\constants\app_constants.dart
# Change: defaultValue: 'https://YOUR_NGROK_URL.ngrok-free.app'

# 6. Build APK
cd "e:\AI app\ai_assistant"
flutter build apk --release

# 7. Install on phone
# File location: e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
```

Done! 🎉

---

## Detailed Steps

### Step 1: Install ngrok

#### Option A: Using Chocolatey (Recommended for Windows)
```bash
choco install ngrok
```

#### Option B: Using npm
```bash
npm install -g ngrok
```

#### Option C: Manual Installation
1. Download from https://ngrok.com/download
2. Extract `ngrok.exe`
3. Add to PATH or move to a folder in PATH

Verify installation:
```bash
ngrok version
```

### Step 2: Configure ngrok

1. Sign up at https://dashboard.ngrok.com/signup (Free tier is fine)

2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken

3. Configure it:
```bash
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
```

This is a **one-time setup** - you won't need to do this again.

### Step 3: Start Backend Server

Choose your backend:

#### Using Node.js + MySQL:
```bash
cd "e:\AI app\backend"
node server.js
```

#### Using Python + SQLite:
```bash
cd "e:\AI app\backend"
python server.py
```

You should see:
```
=======================================================
Simhastha Ujjain 2028 Node.js MySQL Server Running
Port: 3000
=======================================================
```

**Keep this terminal window open!**

### Step 4: Start ngrok Tunnel

Open a **NEW terminal window**:

```bash
ngrok http 3000
```

You'll see:
```
ngrok

Session Status                online
Account                       your-email@example.com (Plan: Free)
Version                       3.x.x
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://a1b2-c3d4-e5f6.ngrok-free.app -> http://localhost:3000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**IMPORTANT:** Copy the **Forwarding** URL (the HTTPS one):
```
https://a1b2-c3d4-e5f6.ngrok-free.app
```

**Keep this terminal window open too!**

### Step 5: Test the Connection

Open your browser and visit:
```
https://YOUR_NGROK_URL.ngrok-free.app/api/temples
```

You should see JSON data with temple information. If you see data, the tunnel is working! ✅

**Bonus:** Visit `http://127.0.0.1:4040` to see the ngrok web interface with real-time request logs.

### Step 6: Update Flutter App

You have **3 options** to set the backend URL:

#### Option A: Edit Constants (Recommended)

1. Open: `e:\AI app\ai_assistant\lib\constants\app_constants.dart`

2. Find this line:
```dart
static const String backendBaseUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://localhost:3000', // ⚠️ UPDATE THIS
);
```

3. Change to:
```dart
defaultValue: 'https://a1b2-c3d4-e5f6.ngrok-free.app',
```

4. Save the file.

#### Option B: Use Build Argument (Advanced)

Skip editing files and pass URL during build:
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://your-ngrok-url.ngrok-free.app
```

#### Option C: Runtime Configuration (If Implemented)

If your app has a settings screen with a backend URL field, you can enter it there after installing.

### Step 7: Build APK

```bash
cd "e:\AI app\ai_assistant"
flutter clean
flutter build apk --release
```

Build takes 2-5 minutes. Wait for:
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (XX.X MB).
```

APK location:
```
e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
```

### Step 8: Install on Phone

#### Method A: USB Cable
1. Connect phone to computer via USB
2. Enable "File Transfer" mode on phone
3. Copy `app-release.apk` to phone's Download folder
4. On phone, open Files app → Downloads → Tap `app-release.apk`
5. Allow "Install from Unknown Sources" if prompted
6. Install!

#### Method B: ADB (Developer-Friendly)
```bash
adb devices
adb install "e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk"
```

#### Method C: Cloud/Email
1. Upload APK to Google Drive / Dropbox / OneDrive
2. Download on phone
3. Install from Downloads

### Step 9: Test the App

1. Launch the app on your phone
2. Try asking a question or browsing temples
3. The app should fetch data from your backend through ngrok!

Check logs (if USB debugging enabled):
```bash
adb logcat | findstr Backend
```

Look for:
```
[Backend] ✅ Got X temples from backend MySQL!
```

---

## Troubleshooting

### ❌ Problem: "ngrok: command not found"

**Solutions:**
1. Restart terminal after installation
2. Check if ngrok is in PATH: `where ngrok`
3. Use full path: `C:\path\to\ngrok.exe http 3000`
4. Reinstall using a different method

### ❌ Problem: ngrok shows "Session Status: offline"

**Solutions:**
1. Check your internet connection
2. Make sure you configured the authtoken: `ngrok config add-authtoken YOUR_TOKEN`
3. Try a different region: `ngrok http 3000 --region us`

### ❌ Problem: Browser shows 502 Bad Gateway

**Solution:** Your backend server isn't running or crashed.
- Restart it: `node server.js` or `python server.py`
- Check the backend terminal for errors

### ❌ Problem: App shows "Failed to connect"

**Check:**
1. ✅ Did you update `app_constants.dart` with the ngrok URL?
2. ✅ Did you rebuild the APK after updating?
3. ✅ Is the ngrok URL still valid? (Check ngrok terminal)
4. ✅ Can you access the API in a browser? Test: `https://YOUR_URL.ngrok-free.app/api/temples`

**Fix:** Rebuild with correct URL:
```bash
flutter clean
flutter build apk --release
```

### ❌ Problem: ngrok URL changes every time

**Why:** Free tier gives you a random URL each session.

**Solutions:**
1. **Quick fix:** Just rebuild APK with new URL each time you restart ngrok
2. **Better fix:** Get ngrok Pro ($8/month) for a permanent custom domain
3. **Best fix for development:** Use local WiFi instead (see below)

### ❌ Problem: App is slow

**Why:** ngrok routes traffic through their servers (adds latency).

**Solutions:**
- Expected behavior for free tier
- Acceptable for testing
- For production, deploy backend to a real server

---

## Alternatives

### Option 1: Local WiFi (No ngrok needed!)

If your phone and computer are on the **same WiFi network**:

1. Find your computer's local IP:
```bash
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter (e.g., `192.168.1.100`)

2. Make sure Windows Firewall allows port 3000:
```bash
netsh advfirewall firewall add rule name="Simhastha Backend" dir=in action=allow protocol=TCP localport=3000
```

3. Update Flutter app:
```dart
defaultValue: 'http://192.168.1.100:3000',
```

4. Rebuild APK and install

**Pros:** Faster, no ngrok needed
**Cons:** Only works on same WiFi, IP might change

### Option 2: Deploy to Cloud

For longer-term testing, deploy backend to:

- **Railway** - https://railway.app (Free tier available)
- **Render** - https://render.com (Free tier available)
- **Heroku** - https://heroku.com (Paid)
- **Vercel** - https://vercel.com (Free for API routes)

Then use the permanent URL in your app.

---

## Automated Scripts

### start_ngrok.bat

We've created a convenient script for you:

```bash
cd "e:\AI app\backend"
start_ngrok.bat
```

This automatically:
1. Starts the backend server
2. Starts ngrok tunnel
3. Shows you next steps

### test_api.bat

Test your API (works with both localhost and ngrok):

```bash
# Test localhost
cd "e:\AI app\backend"
test_api.bat

# Test ngrok URL
test_api.bat https://your-ngrok-url.ngrok-free.app
```

---

## FAQ

**Q: How long does an ngrok session last?**
A: 2 hours on free tier, then you need to restart.

**Q: Can I use HTTP instead of HTTPS?**
A: ngrok provides both, but use HTTPS for security. Android prefers HTTPS.

**Q: Do I need to rebuild APK every time I restart ngrok?**
A: Yes, if the URL changes. Or use paid ngrok for a permanent URL.

**Q: Can I test on iOS?**
A: Yes! Same ngrok URL works for iOS builds too.

**Q: Is this safe for production?**
A: No. ngrok is for development/testing only. Deploy to a real server for production.

**Q: Can multiple people test the same APK?**
A: Yes! Same ngrok URL works for all users until you restart ngrok.

**Q: How do I stop ngrok?**
A: Press `Ctrl+C` in the ngrok terminal window.

---

## Summary Checklist

- [ ] ngrok installed and authtoken configured
- [ ] Backend server running on port 3000
- [ ] ngrok tunnel running and showing "online"
- [ ] ngrok HTTPS URL copied
- [ ] Browser test successful (can see JSON data)
- [ ] `app_constants.dart` updated with ngrok URL
- [ ] APK built with `flutter build apk --release`
- [ ] APK installed on phone
- [ ] App works and fetches data from backend

---

## Need Help?

1. **Check ngrok web interface:** http://127.0.0.1:4040
2. **Check backend logs:** Look at the terminal running `server.js`
3. **Check app logs:** `adb logcat | findstr Backend`
4. **Test API in browser first** before testing in app
5. **Read error messages carefully** - they usually tell you what's wrong

---

**Happy Testing! 🚀📱**
