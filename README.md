# 🕉️ Simhastha AI Assistant - Phone Testing with ngrok

Complete setup for testing your Simhastha AI Assistant APK on physical phones using ngrok.

---

## 🎯 What's This?

This project now supports **testing on physical phones** by exposing your local backend to the internet via **ngrok**. This means you can:

- ✅ Build an APK and test on your real phone
- ✅ Test over cellular data (not just WiFi)
- ✅ Share the same backend with multiple test devices
- ✅ Test from anywhere, not just your local network

---

## 🚀 Quick Start (3 Steps)

### 1. Start Backend & ngrok (2 minutes)

```bash
cd "e:\AI app\backend"
start_ngrok.bat
```

**Output:** Two terminals will open:
- Terminal 1: Backend server running on port 3000
- Terminal 2: ngrok tunnel with public URL

**Copy the ngrok HTTPS URL** (looks like: `https://a1b2-c3d4.ngrok-free.app`)

---

### 2. Build APK (3 minutes)

```bash
cd "e:\AI app\ai_assistant"
build_for_phone.bat
```

**When prompted:**
- Override backend URL? → `y`
- Enter ngrok URL → Paste your ngrok URL

**Output:** APK file at `build\app\outputs\flutter-apk\app-release.apk`

---

### 3. Install & Test (2 minutes)

**Transfer APK to phone:**
- USB cable → Copy to Downloads
- Email → Send to yourself
- Cloud → Upload to Drive/Dropbox
- ADB → `adb install -r build\app\outputs\flutter-apk\app-release.apk`

**Launch app and test!**

---

## 📚 Documentation

We've created extensive documentation to help you:

### 📖 Start Here

**New to this?** → Read **[START_HERE.md](START_HERE.md)**

This is your navigation hub to all other documentation.

---

### 📘 Main Guides

1. **[README_PHONE_TESTING.md](README_PHONE_TESTING.md)** - Overview & 3 testing methods
2. **[QUICK_NGROK_REFERENCE.md](QUICK_NGROK_REFERENCE.md)** - Commands & quick reference
3. **[COMPLETE_TESTING_WORKFLOW.md](COMPLETE_TESTING_WORKFLOW.md)** - Detailed step-by-step
4. **[VISUAL_SETUP_GUIDE.md](VISUAL_SETUP_GUIDE.md)** - Visual diagrams & illustrations
5. **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Verification checklist

---

### 🛠️ Helper Scripts

Located in your project folders:

| Script | Location | Purpose |
|--------|----------|---------|
| `start_ngrok.bat` | `backend/` | Start backend + ngrok |
| `test_api.bat` | `backend/` | Test all API endpoints |
| `build_for_phone.bat` | `ai_assistant/` | Interactive APK builder |

**Usage:**
```bash
# Start everything
cd "e:\AI app\backend"
start_ngrok.bat

# Test APIs
test_api.bat https://your-ngrok-url.ngrok-free.app

# Build APK
cd "e:\AI app\ai_assistant"
build_for_phone.bat
```

---

### 🔧 Technical Details

**Backend:** `backend/README_NGROK.md` - Complete ngrok setup & configuration

---

## 🎯 Three Testing Methods

### Method 1: ngrok (Remote Testing) ⭐ Recommended

**Use when:** Testing from anywhere, sharing with others

```bash
# 1. Start services
start_ngrok.bat

# 2. Update app with ngrok URL
# Edit: lib/constants/app_constants.dart

# 3. Build & install
build_for_phone.bat
```

**Pros:** Works anywhere, shareable  
**Cons:** URL changes on restart

---

### Method 2: Local WiFi (Fastest)

**Use when:** Quick testing on same network

```bash
# 1. Find your IP
ipconfig  # Look for 192.168.x.x

# 2. Start backend
node server.js

# 3. Update app with: http://192.168.x.x:3000

# 4. Build & test
```

**Pros:** Faster, no ngrok  
**Cons:** Same WiFi only

---

### Method 3: Build-Time Override (No Editing)

**Use when:** Testing without editing files

```bash
flutter build apk --release \
  --dart-define=BACKEND_URL=https://your-ngrok-url.ngrok-free.app
```

**Pros:** No file changes  
**Cons:** Must specify each time

---

## 📁 Project Structure

```
e:\AI app\
│
├─ 📘 START_HERE.md                    → Start here!
├─ 📗 README_PHONE_TESTING.md          → Testing guide
├─ 📙 QUICK_NGROK_REFERENCE.md         → Quick commands
├─ 📕 COMPLETE_TESTING_WORKFLOW.md     → Detailed guide
├─ 📓 VISUAL_SETUP_GUIDE.md            → Visual diagrams
├─ 📋 TESTING_CHECKLIST.md             → Verification checklist
├─ 📄 IMPLEMENTATION_SUMMARY.md        → What changed
│
├─ backend/
│  ├─ 📄 README_NGROK.md               → ngrok details
│  ├─ 🚀 start_ngrok.bat               → Start script
│  ├─ 🧪 test_api.bat                  → Test script
│  ├─ 🖥️  server.js                     → Backend (Node.js)
│  ├─ 🐍 server.py                     → Backend (Python)
│  ├─ 🗄️  schema.sql                    → Database schema
│  └─ ⚙️  .env.example                  → Config template
│
└─ ai_assistant/
   ├─ 🔨 build_for_phone.bat           → APK builder
   ├─ lib/
   │  ├─ constants/
   │  │  └─ app_constants.dart         → Backend URL config
   │  └─ services/
   │     └─ simhastha_backend_service.dart
   └─ build/app/outputs/flutter-apk/
      └─ app-release.apk               → Your APK
```

---

## 🎓 Learning Path

### First Time (1 hour)

1. **Read:** [START_HERE.md](START_HERE.md) - Navigation guide
2. **Read:** [VISUAL_SETUP_GUIDE.md](VISUAL_SETUP_GUIDE.md) - See how it works
3. **Do:** Install ngrok
   ```bash
   choco install ngrok
   ngrok config add-authtoken YOUR_TOKEN
   ```
4. **Do:** First test
   ```bash
   cd "e:\AI app\backend"
   start_ngrok.bat
   # Then build APK and test!
   ```

---

### Daily Testing (10 minutes)

1. **Reference:** [QUICK_NGROK_REFERENCE.md](QUICK_NGROK_REFERENCE.md)
2. **Run:** `start_ngrok.bat`
3. **Build:** `build_for_phone.bat`
4. **Test:** Install and verify

---

## ✅ Verification

Your setup is working when:

✅ **Backend terminal shows:**
```
Server Running on Port: 3000
```

✅ **ngrok terminal shows:**
```
Session Status: online
Forwarding: https://xxxx.ngrok-free.app
```

✅ **Browser shows JSON:**
```
https://your-ngrok-url.ngrok-free.app/api/temples
```

✅ **App loads data:**
- Temple cards visible
- Events displayed
- Stays listed
- No connection errors

✅ **Logs confirm:**
```
[Backend] ✅ Got 3 temples from backend MySQL!
```

---

## 🐛 Troubleshooting

### Problem: "Failed to connect"

**Check:**
1. Backend running? (Terminal shows "Server Running")
2. ngrok running? (Terminal shows "Session Status: online")
3. URL correct in app_constants.dart?
4. APK rebuilt after URL change?

**Solution:**
```bash
# Test in browser first
https://your-ngrok-url.ngrok-free.app/api/temples

# Then rebuild
flutter clean
flutter build apk --release
```

---

### Problem: ngrok URL changed

**Why:** Free tier generates new URL each restart

**Solution:**
```bash
# Quick rebuild with new URL
flutter build apk --release \
  --dart-define=BACKEND_URL=https://new-url.ngrok-free.app
```

**Better:** Get ngrok Pro ($8/month) for permanent URL

---

### Problem: App is slow

**Why:** ngrok adds latency (~100-300ms)

**Normal!** This is expected for free tier.

**Alternatives:**
- Use local WiFi (faster)
- Deploy to cloud (Railway, Render)

---

## 📊 What Changed

### Files Modified (3)

1. **`backend/server.js`**
   - Added ngrok compatibility headers
   - Line 31: `ngrok-skip-browser-warning` header

2. **`lib/services/simhastha_backend_service.dart`**
   - Reads URL from AppConstants
   - Added ngrok headers to requests
   - Increased timeout to 10s

3. **`lib/constants/app_constants.dart`**
   - Added `backendBaseUrl` constant
   - Supports environment override

### Files Created (13)

- 📚 6 Documentation files
- 🛠️ 3 Helper scripts
- ⚙️ 2 Config files
- 📋 2 Summary files

---

## 🎯 Success Metrics

After setup, you'll have:

- ✅ Backend accessible over internet
- ✅ APK testable on any phone
- ✅ Automated scripts for common tasks
- ✅ Complete documentation
- ✅ Multiple testing workflows
- ✅ Troubleshooting guides

---

## 🚀 Next Steps

### Immediate
- [ ] Read [START_HERE.md](START_HERE.md)
- [ ] Install ngrok
- [ ] Run first test

### Short Term
- [ ] Test on multiple devices
- [ ] Share with team
- [ ] Gather feedback

### Long Term
- [ ] Deploy backend to cloud
- [ ] Get permanent URL
- [ ] Setup CI/CD

---

## 📞 Resources

### Documentation
- **Navigation:** [START_HERE.md](START_HERE.md)
- **Quick Reference:** [QUICK_NGROK_REFERENCE.md](QUICK_NGROK_REFERENCE.md)
- **Checklist:** [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)

### External Links
- **ngrok:** https://ngrok.com
- **Flutter:** https://flutter.dev
- **ADB Guide:** https://developer.android.com/studio/command-line/adb

---

## 💡 Pro Tips

1. **Keep terminals open** - Don't close backend/ngrok while testing
2. **Test in browser first** - Verify API before building APK
3. **Use scripts** - Save time with automated helpers
4. **Monitor logs** - Visit http://127.0.0.1:4040 for ngrok traffic
5. **Clean build** - Run `flutter clean` when changing URLs

---

## 🎊 Ready to Start?

```bash
# Quick test in 3 commands:

# 1. Start services
cd "e:\AI app\backend"
start_ngrok.bat

# 2. Build APK
cd "e:\AI app\ai_assistant"
build_for_phone.bat

# 3. Install on phone and test!
```

**Read [START_HERE.md](START_HERE.md) for detailed guidance!**

---

**Implementation Status:** ✅ Complete  
**Documentation:** 📚 Comprehensive  
**Ready to Use:** 🚀 Yes!

**Happy Testing! 📱✨**
