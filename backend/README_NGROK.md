# Using ngrok to Test APK on Physical Phone

## 🎯 What is ngrok?

ngrok creates a secure tunnel from a public URL to your local backend server, allowing your phone to access your development backend over the internet.

## 📋 Prerequisites

1. **Install ngrok**
   - Download from: https://ngrok.com/download
   - Or use: `choco install ngrok` (Windows with Chocolatey)
   - Or use: `npm install -g ngrok` (if you have Node.js)

2. **Sign up for ngrok account** (Free tier is sufficient)
   - Visit: https://dashboard.ngrok.com/signup
   - Get your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken

## 🚀 Setup Steps

### Step 1: Configure ngrok authtoken (One-time setup)

```bash
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
```

Replace `YOUR_AUTHTOKEN_HERE` with your actual token from ngrok dashboard.

### Step 2: Start Your Backend Server

#### Option A: Using Node.js (with MySQL)
```bash
cd "e:\AI app\backend"
node server.js
```

#### Option B: Using Python (with SQLite)
```bash
cd "e:\AI app\backend"
python server.py
```

**Note:** The server should start on port 3000 by default.

### Step 3: Start ngrok Tunnel

Open a **NEW terminal window** and run:

```bash
ngrok http 3000
```

You'll see output like this:
```
ngrok                                                                                                                                                                                     
                                                                                                                                                                                           
Session Status                online                                                                                                                                                       
Account                       your-email@example.com (Plan: Free)                                                                                                                         
Version                       3.x.x                                                                                                                                                        
Region                        United States (us)                                                                                                                                           
Latency                       -                                                                                                                                                            
Web Interface                 http://127.0.0.1:4040                                                                                                                                        
Forwarding                    https://abcd-1234-xyz.ngrok-free.app -> http://localhost:3000                                                                                               
                                                                                                                                                                                           
Connections                   ttl     opn     rt1     rt5     p50     p90                                                                                                                  
                              0       0       0.00    0.00    0.00    0.00
```

**IMPORTANT:** Copy the `Forwarding` URL (e.g., `https://abcd-1234-xyz.ngrok-free.app`)

### Step 4: Update Flutter App Configuration

There are **3 ways** to set the backend URL in your Flutter app:

#### Method 1: Edit app_constants.dart (Recommended for development)

Open `lib\constants\app_constants.dart` and update:

```dart
static const String backendBaseUrl = 'https://your-ngrok-url.ngrok-free.app';
```

Then rebuild your APK:
```bash
flutter build apk --release
```

#### Method 2: Use Environment Variable (Build-time)

```bash
flutter build apk --release --dart-define=BACKEND_URL=https://your-ngrok-url.ngrok-free.app
```

#### Method 3: Runtime Configuration (Settings Screen)

If your app has a settings screen, you can enter the ngrok URL directly in the app without rebuilding.

### Step 5: Install APK on Phone

1. Locate the APK file:
   ```
   e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
   ```

2. Transfer to your phone via:
   - USB cable → Copy to phone storage
   - Email attachment
   - Cloud storage (Google Drive, Dropbox, etc.)
   - ADB: `adb install app-release.apk`

3. Enable "Install from Unknown Sources" on your phone if prompted

4. Install and launch the app!

## 🧪 Testing the Connection

### 1. Test ngrok tunnel in browser

Open your ngrok URL in a browser:
```
https://your-ngrok-url.ngrok-free.app/api/temples
```

You should see JSON data with temples information.

### 2. Monitor ngrok traffic

Visit the ngrok web interface:
```
http://127.0.0.1:4040
```

This shows all HTTP requests hitting your tunnel in real-time.

### 3. Check app logs

When the app starts, look for these logs:
```
[Backend] 🔄 Fetching temples from https://your-ngrok-url.ngrok-free.app/api/temples...
[Backend] ✅ Got X temples from backend MySQL!
```

## ⚠️ Important Notes

### Free Tier Limitations
- **URL changes on restart**: Each time you restart ngrok, you get a new random URL
- **Solution**: Get a paid plan for a permanent custom domain, or rebuild your APK with the new URL each time

### HTTPS Only
- ngrok provides HTTPS by default (secure)
- Your app should use `https://` not `http://`

### Session Timeout
- Free ngrok sessions expire after 2 hours
- Just restart ngrok to get a new session

### Performance
- Expect slight latency since traffic routes through ngrok's servers
- Good enough for testing, but not for production

## 🔧 Troubleshooting

### Problem: "Failed to connect to backend"

**Check:**
1. Is your backend server running? (Check terminal for "Server Running" message)
2. Is ngrok running and showing "Session Status: online"?
3. Did you copy the correct ngrok URL (the HTTPS one)?
4. Did you rebuild the APK after updating the URL?

### Problem: ngrok shows 502 Bad Gateway

**Solution:** Your backend server stopped. Restart it:
```bash
node server.js
# or
python server.py
```

### Problem: App crashes or shows no data

**Check:**
1. Test the API in browser first: `https://your-ngrok-url.ngrok-free.app/api/temples`
2. Check ngrok web interface (localhost:4040) for errors
3. Enable USB debugging and check Android logs: `adb logcat | findstr Backend`

### Problem: ngrok command not found

**Solution:** 
- Make sure ngrok is installed and added to PATH
- On Windows, restart terminal after installation
- Try full path: `C:\path\to\ngrok.exe http 3000`

## 🎬 Quick Start Script

Save this as `start_ngrok.bat`:

```batch
@echo off
echo Starting Backend Server and ngrok...
echo.

start "Backend Server" cmd /k "cd /d e:\AI app\backend && node server.js"
timeout /t 3

start "ngrok Tunnel" cmd /k "ngrok http 3000"

echo.
echo ========================================
echo Both servers started!
echo ========================================
echo.
echo 1. Copy the ngrok URL from the ngrok window
echo 2. Update app_constants.dart with the URL
echo 3. Rebuild APK: flutter build apk --release
echo 4. Install APK on your phone
echo.
pause
```

Run it by double-clicking `start_ngrok.bat`

## 📱 Alternative: Local Network Testing (No ngrok needed)

If your phone and computer are on the same WiFi:

1. Find your computer's local IP:
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

2. Update Flutter app to use:
   ```dart
   static const String backendBaseUrl = 'http://192.168.1.100:3000';
   ```

3. Make sure Windows Firewall allows port 3000

**Pros:** No ngrok needed, faster
**Cons:** Only works on same WiFi network

## 🌐 Production Deployment (Later)

For production, deploy your backend to:
- **Railway**: https://railway.app
- **Render**: https://render.com
- **Heroku**: https://heroku.com
- **AWS/GCP/Azure**

Then update your app with the permanent production URL.
