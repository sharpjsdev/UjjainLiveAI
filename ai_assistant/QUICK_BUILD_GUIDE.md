# ⚡ Quick Build & Deploy Guide

## 🚀 Build in 3 Steps

### Step 1: Prepare
```bash
cd "e:\AI app\ai_assistant"
flutter clean
flutter pub get
```

### Step 2: Build
```bash
# For Android (APK - fastest for testing)
flutter build apk --release

# OR for Android (App Bundle - for Play Store)
flutter build appbundle --release

# OR for iOS
flutter build ios --release
```

### Step 3: Deploy

**For Testing:**
```bash
# Install directly on connected device
adb install build/app/outputs/apk/release/app-release.apk

# OR use Flutter
flutter run --release
```

**For Play Store:**
- Upload `build/app/outputs/bundle/release/app-release.aab`
- Fill in app details
- Set to publish

**For Distribution via Email/WhatsApp:**
- APK file: `build/app/outputs/apk/release/app-release.apk`
- Share directly

---

## 📱 Test on Device

### Real Device (Recommended)
```bash
# Connect device via USB
adb devices

# Run app
flutter run --release
```

### Android Emulator
```bash
flutter emulators --launch <emulator_name>
flutter run
```

---

## ✅ Verification Checklist

After building, verify:

```
Build Verification:
├── ✅ App starts with splash screen
├── ✅ Animations play smoothly
├── ✅ Can type in chat
├── ✅ Responses appear instantly
├── ✅ Ask for hotel/restaurant/temple
├── ✅ Turn off WiFi - still works
├── ✅ Ask follow-up questions
└── ✅ No crashes or errors
```

---

## 📊 Build Artifacts Locations

| File | Path | Use |
|------|------|-----|
| APK | `build/app/outputs/apk/release/app-release.apk` | Direct install, testing |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` | Play Store |
| iOS | `build/ios/iphoneos/Runner.app` | Device install |

---

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | `flutter clean` then retry |
| Slow build | First build is slow, subsequent are fast |
| Device not found | `adb devices` to check connection |
| App crashes on startup | Check device logs: `adb logcat` |
| Icon not showing | Reinstall APK, clear cache |

---

## 📈 File Size Expectations

| Build Type | Size |
|-----------|------|
| APK (Debug) | ~150-200 MB |
| APK (Release) | ~40-60 MB |
| App Bundle | ~30-50 MB |

---

## 🎯 Recommended Build Command

```bash
# All-in-one: clean, get, build, and show output
cd "e:\AI app\ai_assistant" && flutter clean && flutter pub get && flutter build apk --release && echo "✅ Build complete! File: build/app/outputs/apk/release/app-release.apk"
```

---

## 📝 App Information

- **App Name**: Simhastha AI Assistant
- **Package Name**: (check pubspec.yaml)
- **Version**: 1.0.0+1
- **Min SDK**: Android 5.0+ (API 21)
- **Target SDK**: Latest (API 33+)

---

## 🎨 Sign APK (Optional)

If you want to sign the APK for distribution:

```bash
# Create key (one-time)
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

# Build signed APK
flutter build apk --release
```

---

## ✨ You're Ready!

Run the quick build command above and your app will be ready in a few minutes.

**Questions?** Check `READY_TO_DEPLOY.md` for detailed info.

**Need help?** Read `BUILD_AND_DEPLOY_GUIDE.md` for step-by-step guide.
