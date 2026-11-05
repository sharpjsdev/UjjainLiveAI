# 🎤 Voice Not Working? - Debug Guide

## The Problem
Voice is not converting speech to text, and searches are not happening.

## Quick Fixes to Try

### Fix 1: Check Microphone Permission (CRITICAL!)

**On your Android device:**
```
Settings
  → Apps & Notifications
    → App permissions
      → Microphone
        → Find "Simhastha AI Assistant"
          → Set to "Allow"
```

If "Simhastha AI Assistant" doesn't show up, you need to allow it first:
```
Settings
  → Apps & Notifications
    → Permissions
      → Microphone
        → Toggle ON for this app
```

### Fix 2: Test Microphone First

Before testing the app:
1. Open Google Assistant or Voice Recorder
2. Try recording a message
3. If it doesn't work there, your phone's microphone is broken
4. If it works elsewhere, it's an app permissions issue

### Fix 3: Force Offline Mode (Already Done)

Check that API key is empty:
```dart
// File: lib/constants/app_constants.dart
// Line 9-10

static const String openAiApiKey = '';  // ← Should be EMPTY
static const String googleApiKey = '';  // ← Should be EMPTY
```

### Fix 4: Rebuild With Fresh Clean

```bash
flutter clean
flutter pub get
flutter run
```

Wait for full rebuild (first time takes 5-10 minutes)

### Fix 5: Enable Verbose Logs

Run with verbose output to see what's happening:
```bash
flutter run -v
```

Look for these lines while using voice:
```
[SpeechService] Starting voice listening...
[SpeechService] Result received: "your text here"
[ChatInput] Partial result: "your text here"
[ChatInput] Sending: "your text here"
```

---

## Testing Voice Step-by-Step

### Step 1: Launch App
```bash
flutter run
```

Wait for app to load completely (20-30 seconds first time)

### Step 2: Grant Permissions
When app asks for microphone permission, tap **"Allow"**

### Step 3: Test Voice Input

**In the app:**
```
1. Look for the microphone button (🎤) at bottom of chat
2. Tap the microphone button
3. Wait for "Listening..." indicator to appear
4. Speak clearly: "Hello"
5. Stop speaking or wait 10 seconds
6. Watch for text to appear
7. If text appears, wait for AI response
```

### Step 4: Check Response

**Expected flow:**
```
You tap 🎤
↓
App shows "Listening..."
↓
You speak "Hello"
↓
Text "Hello" appears in listening indicator
↓
App sends to AI
↓
AI response appears in chat: "Namaste! Welcome..."
↓
Total time: 3-5 seconds
```

---

## If Still Not Working

### Debugging Checklist

**1. Microphone Permission**
- [ ] Permission granted in device settings
- [ ] App is using microphone (test with other app)
- [ ] Microphone not blocked by case/screen protector

**2. App State**
- [ ] App fully loaded (wait 30 seconds)
- [ ] No error messages visible
- [ ] Connection icon shows offline mode (☁️❌)

**3. Voice Input**
- [ ] Microphone button is visible
- [ ] Tap activates it (button turns red)
- [ ] "Listening..." text appears
- [ ] You can speak

**4. Recognition**
- [ ] Text appears while speaking
- [ ] Text is correct (or close)
- [ ] Text shows in chat

**5. Response**
- [ ] AI processes the input
- [ ] Response appears in chat
- [ ] Response is relevant

---

## Common Issues & Solutions

### Issue: Microphone button doesn't activate
**Solution**: 
- Check permissions (see Fix 1 above)
- Restart app
- Restart phone
- Reinstall app

### Issue: "Listening..." appears but nothing happens
**Solution**:
- Speak louder/more clearly
- Wait full 10 seconds
- Check if microphone works in other apps
- Try restarting phone

### Issue: Text appears but no AI response
**Solution**:
- Check that you're in offline mode (☁️❌ icon)
- Wait 2-3 seconds for AI to process
- Check internet (disable for true offline)
- Check app logs: `flutter run -v`

### Issue: Wrong text recognized
**Solution**:
- Speak more clearly
- Reduce background noise
- Reduce speed of speech
- Try again

### Issue: "Listening..." never appears
**Solution**:
- Grant microphone permission
- Restart app
- Clear app cache: `flutter clean && flutter pub get`
- Restart phone

---

## Test Voice With This Simple Script

Try these exact phrases:

**Test 1: Simple**
```
Say: "Hotel"
Expected: Hotel list appears
```

**Test 2: Complete**
```
Say: "Best hotels in Ujjain"
Expected: Hotels with ratings
```

**Test 3: Question**
```
Say: "What are the temples?"
Expected: Temple information
```

**Test 4: Follow-up**
```
Say: "How much does it cost?"
Expected: Pricing information
```

---

## Logs to Check

When running `flutter run -v`, search for:

**Good signs:**
```
✅ [SpeechService] Starting voice listening...
✅ [SpeechService] Result received: "hotel"
✅ [ChatInput] Partial result: "hotel"
✅ [HybridAI] Using offline mode
✅ Response appears in chat
```

**Bad signs:**
```
❌ [SpeechService] Permission denied
❌ [SpeechService] Speech recognition not available
❌ [SpeechService] Initialization failed
❌ [HybridAI] Attempting online mode
```

If you see bad signs, search for the specific error message below.

---

## Error Message Solutions

### "Speech recognition not available"
- Your phone might not support voice recognition
- Try: Settings → Language & Input → Voice Input Settings
- Enable voice input if disabled

### "Microphone permission denied"
- Follow Fix 1 above
- Grant permission in device settings

### "No speech detected"
- Speak louder
- Speak more clearly
- Reduce background noise
- Move to quieter location

### "onError: 2"
- Device timeout
- Speak more quickly
- Try again

---

## Ultimate Test

If everything else fails, try this:

**1. Open Google Assistant**
- Use phone's voice search (usually hold home button)
- Test if voice works there
- If yes → app permission issue
- If no → phone microphone issue

**2. If phone microphone works:**
- Go to device Settings
- Find Simhastha AI Assistant
- Grant all permissions
- Restart app

**3. If phone microphone doesn't work:**
- Phone microphone is broken
- Use text input instead
- Contact device manufacturer

---

## Text Input (Fallback if Voice Doesn't Work)

If voice really isn't working, use text instead:

```
1. Type: "Best hotels"
2. Press send button
3. Response appears instantly
```

Text searching SHOULD work perfectly. If text also doesn't work:
- App itself has issues
- Run: flutter clean && flutter pub get && flutter run
- Rebuild completely

---

## Final Checklist Before Giving Up

- [ ] Microphone permission granted (in device settings)
- [ ] Microphone works in other apps
- [ ] App restarted
- [ ] Phone restarted
- [ ] App rebuilt (flutter clean && flutter pub get && flutter run)
- [ ] Offline mode enabled (API key empty)
- [ ] Microphone button is visible
- [ ] "Listening..." appears when tapping mic
- [ ] You waited at least 10 seconds

If ALL are checked and still doesn't work:
- Try text input instead
- Report microphone not working on your device
- Use phone's built-in assistant to verify

---

## Getting Help

When asking for help, provide:
1. Phone model
2. Android version
3. Error messages (from `flutter run -v`)
4. Whether microphone works in other apps
5. Screenshots of the issue

---

## 🕉️ Remember

- Voice processing takes 2-3 seconds
- Stay patient and wait for response
- Speak clearly and naturally
- Use microphone in quiet place
- Text input always works as fallback

**Har Har Mahadev!** 🙏

---

## One More Thing

If voice STILL doesn't work after all this, the issue might be:
1. **Rare device incompatibility** - Some rare phones don't support speech_to_text
2. **Android version issue** - Very old Android (< 5.0) might not work
3. **Missing language pack** - Device doesn't have English language pack

**Solution**: Use TEXT INPUT instead - it works perfectly and instantly!