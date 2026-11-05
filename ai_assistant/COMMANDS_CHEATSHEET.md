# 💻 Commands Cheatsheet - Build & Test

## 🚀 Most Important Commands

### Build and Run on Device
```bash
flutter run
```
**What**: Builds debug app and installs on connected device
**Time**: 2-5 minutes first time, 30 seconds after changes

---

### Clean and Fresh Build
```bash
flutter clean
flutter pub get
flutter run
```
**What**: Remove old build artifacts and start fresh
**Use when**: App won't build or has strange errors

---

## 🔧 Setup & Preparation Commands

### Check Setup
```bash
flutter doctor
```
**Shows**: Flutter installation status, Android SDK, connected devices

### List Connected Devices
```bash
flutter devices
```
**Shows**: All devices that Flutter can detect

### Get Dependencies
```bash
flutter pub get
```
**What**: Downloads all packages from pubspec.yaml

---

## 📱 Build Commands

### Debug APK (For Testing)
```bash
flutter build apk --debug
```
**Output**: `build/app/outputs/flutter-apk/app-debug.apk`
**Size**: ~150 MB
**Use**: Development and testing

### Release APK (For Distribution)
```bash
flutter build apk --release
```
**Output**: `build/app/outputs/flutter-apk/app-release.apk`
**Size**: ~50-80 MB
**Use**: Sharing, deployment

### App Bundle (For Google Play)
```bash
flutter build appbundle --release
```
**Output**: `build/app/outputs/bundle/release/app-release.aab`
**Use**: Google Play Store distribution

### Web Version
```bash
flutter build web
```
**Output**: `build/web/`
**Use**: Deploy to web hosting

---

## 🧪 Testing & Debugging Commands

### Run with Verbose Logs
```bash
flutter run -v
```
**Shows**: Detailed build and runtime information

### Run on Specific Device
```bash
flutter run -d <device_id>
```
**Example**: `flutter run -d SM-G973F`

### Run Release Build
```bash
flutter run --release
```
**What**: Run optimized release build

### Run with Hot Reload Disabled
```bash
flutter run --no-hot
```
**Use**: When hot reload causes issues

---

## 📊 Project Information Commands

### Check Dependencies
```bash
flutter pub outdated
```
**Shows**: Which packages have newer versions

### Analyze Code
```bash
flutter analyze
```
**Shows**: Code quality and potential issues

### Format Code
```bash
flutter format lib/
```
**What**: Auto-formats code to Dart standards

---

## 🔌 Device Management Commands

### Connect via WiFi (After Initial USB)
```bash
adb tcpip 5555
adb connect <device_ip>:5555
```

### Disconnect WiFi Device
```bash
adb disconnect <device_ip>:5555
```

### Restart ADB
```bash
adb kill-server
adb start-server
```
**Use**: If device not recognized

### View Device Logs
```bash
adb logcat
```
**Shows**: Real-time device logs

---

## 🎮 Emulator Commands

### List Available Emulators
```bash
flutter emulators
```

### Create New Emulator
```bash
flutter emulators --create --name my_emulator
```

### Launch Emulator
```bash
flutter emulators --launch my_emulator
```

### Delete Emulator
```bash
flutter emulators --delete my_emulator
```

---

## 🔑 Interactive Commands (While Running)

**Press during `flutter run`**:

| Key | Action |
|-----|--------|
| `r` | Hot reload (rerun without rebuild) |
| `R` | Hot restart (full app restart) |
| `h` | Show help menu |
| `d` | Detach (stop following logs) |
| `q` | Quit |
| `p` | Toggle performance overlay |
| `i` | Toggle widget inspector |
| `w` | Show widget inspector info |
| `o` | Toggle iOS simulator orientation |
| `s` | Take screenshot |
| `M` | Toggle Material design grid |

---

## 🐛 Troubleshooting Commands

### If Build Fails
```bash
flutter clean
flutter pub get
flutter run -v
```

### If Device Not Found
```bash
adb kill-server
adb start-server
flutter devices
```

### If Permissions Issue
```bash
adb shell pm grant com.example.ai_assistant android.permission.RECORD_AUDIO
adb shell pm grant com.example.ai_assistant android.permission.ACCESS_FINE_LOCATION
```

### Check Gradle Build
```bash
cd android
./gradlew clean
./gradlew build
cd ..
```

---

## 📝 Install from APK

### Manual Installation
```bash
# Copy APK to device
adb push app-release.apk /sdcard/Download/

# Or install directly
adb install app-release.apk
```

---

## 🚀 Quick Reference Flow

### First Time Setup
```bash
flutter doctor                 # Check setup
flutter devices               # Verify device
flutter clean                 # Clean build
flutter pub get               # Get packages
flutter run                   # Build and run
```

### Regular Development
```bash
flutter run                   # Build and run
# Make changes
r                            # Hot reload (in terminal)
# Test changes
```

### Final Release Build
```bash
flutter clean                # Clean first
flutter build apk --release  # Build release
flutter build appbundle --release  # For Play Store
```

---

## 💾 File Locations

```
Project Structure:
ai_assistant/
├── build/
│   └── app/outputs/
│       ├── flutter-apk/
│       │   ├── app-debug.apk      (Debug)
│       │   └── app-release.apk    (Release)
│       └── bundle/release/
│           └── app-release.aab    (Play Store)
├── lib/
├── android/
├── ios/
├── pubspec.yaml
└── pubspec.lock
```

---

## 🎯 Most Used Commands

### For Development
```bash
flutter run          # Build and run
flutter run -v       # With logs
flutter format lib   # Format code
```

### For Testing
```bash
flutter test         # Run tests
flutter analyze      # Check code
```

### For Distribution
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## 🔗 Useful Shortcuts

### Create alias (Linux/Mac)
```bash
alias fr='flutter run'
alias frv='flutter run -v'
alias fc='flutter clean && flutter pub get'
```

### Windows batch file (optional)
Create `run.bat`:
```batch
@echo off
flutter run
```

Then double-click to run!

---

## 📚 Help Commands

### Flutter Help
```bash
flutter -h
flutter run -h
flutter build -h
```

### Dart Analysis
```bash
dart analyze
dart fix --dry-run
```

---

## 🌐 Advanced Commands

### Profile Build (Performance Testing)
```bash
flutter build apk --profile
```

### With Custom App Package Name
```bash
flutter run --release --package-name com.custom.appname
```

### Build for Specific Architecture
```bash
flutter build apk --target-platform android-arm64
```

---

## 📱 Device Info Commands

### Device Properties
```bash
adb shell getprop
```

### Android Version
```bash
adb shell getprop ro.build.version.release
```

### Device Model
```bash
adb shell getprop ro.product.model
```

---

## 🎓 Learn More

```bash
flutter help docs              # Documentation
flutter help upgrade          # Upgrade Flutter
flutter help create           # Create new project
flutter help analyze          # Code analysis
```

---

## ⚡ Quick Commands Summary

```bash
# Setup
flutter doctor
flutter pub get

# Develop
flutter run        # or: flutter run -v
r                 # Hot reload during run

# Test
flutter test
flutter analyze

# Build
flutter build apk --release
flutter build appbundle --release

# Deploy
adb install app-release.apk

# Troubleshoot
flutter clean && flutter pub get && flutter run
adb kill-server && adb start-server
```

---

## 🕉️ You're All Set!

Keep this handy while developing. Most common commands:

**Development**: `flutter run`
**Building**: `flutter build apk --release`
**Troubleshooting**: `flutter clean && flutter pub get && flutter run -v`

**Har Har Mahadev!** 🙏