# Voice Accumulation - Troubleshooting Guide

## Quick Diagnosis

### Test 1: Is It Working?

**Do this now**:
```
1. Open app
2. Tap microphone 🎤
3. Say: "Where is"
4. Pause 2-3 seconds (DON'T stop)
5. Say: "the temple"
6. Stop speaking
7. Check message in chat
```

**Expected**: "Where is the temple"

- ✅ **PASS**: Working correctly! Proceed to deployment
- ❌ **FAIL**: Still not working? Use this guide

---

## If Text Is Still Lost

### Issue 1: Still Replacing Text

**Symptoms**:
- Only second part sent ("the temple" without "Where is")
- OR: Duplicated text ("Where is Where is the temple")
- OR: Mixed up text

**Cause**: Word extraction not working properly

**Check These**:

1. **Verify `_lastFinalizedText` is set**
   ```dart
   // In speech_service.dart, check line ~294
   _lastFinalizedText = currentWords;  // ← Must be here
   ```

2. **Verify prefix detection logic**
   ```dart
   // Check line ~272
   if (_lastFinalizedText.isNotEmpty && 
       currentWords.startsWith(_lastFinalizedText)) {
     // ← This is critical - checks if new text contains old
   ```

3. **Check substring extraction**
   ```dart
   // Check line ~274
   newWords = currentWords
       .substring(_lastFinalizedText.length)  // ← Gets new part
       .trim();
   ```

**Fix If Needed**:
- Verify all three checks are in place
- Verify variable names match exactly
- Verify no typos in `_lastFinalizedText`

---

### Issue 2: Duplicated Text

**Symptoms**:
- "Where is Where is the temple"
- Multiple copies of words
- Text appears twice

**Cause**: Appending entire result instead of just new words

**Check These**:

1. **Verify extraction happens BEFORE append**
   ```dart
   // Lines 272-276: MUST extract first
   if (_lastFinalizedText.isNotEmpty && 
       currentWords.startsWith(_lastFinalizedText)) {
     newWords = currentWords.substring(_lastFinalizedText.length).trim();
   }
   
   // Line 279-284: THEN append only newWords
   if (newWords.isNotEmpty) {
     _accumulatedText += ' $newWords';
   }
   ```

2. **Verify NOT appending currentWords**
   ```dart
   // ❌ WRONG:
   _accumulatedText += ' $currentWords';  // Would duplicate!
   
   // ✅ RIGHT:
   _accumulatedText += ' $newWords';      // Append only new
   ```

**Fix If Needed**:
- Replace `currentWords` with `newWords` in append line
- Verify extraction logic above append

---

### Issue 3: Text Disappears

**Symptoms**:
- Typing in listening indicator, but message is empty
- Or: "Where is" shows, but "temple" doesn't appear
- Or: Works first time, fails second time

**Cause**: Accumulated text not being updated or reset incorrectly

**Check These**:

1. **Verify `_accumulatedText` starts empty**
   ```dart
   // Check line ~231 in startListening()
   _accumulatedText = '';              // ← Must reset here
   _lastFinalizedText = '';            // ← And here
   ```

2. **Verify accumulated is NOT cleared mid-session**
   ```dart
   // Should NEVER have: _accumulatedText = ''
   // Anywhere in onResult callback
   // (Only in startListening)
   ```

3. **Verify UI is receiving updates**
   ```dart
   // Check line ~298
   if (onPartialResult != null) {
     onPartialResult(_lastRecognizedWords);  // ← Must call
   }
   ```

**Fix If Needed**:
- Make sure `_accumulatedText` only resets in `startListening()`
- Make sure `onPartialResult` is called for partial results
- Make sure `_lastRecognizedWords` is always set correctly

---

## Debug by Looking at Logs

### What to Look For

When testing, check console logs for:

✅ **GOOD LOG SEQUENCE**:
```
[SpeechService] Result: "Where is" (final: false)
[SpeechService] Partial result. Current display: "Where is"

[SpeechService] Result: "Where is" (final: true)
[SpeechService] Final result: NEW words="Where is", Accumulated: "Where is"

[SpeechService] Result: "the temple" (final: false)
[SpeechService] Partial result. Current display: "Where is the temple"

[SpeechService] Result: "Where is the temple" (final: true)
[SpeechService] Final result: NEW words="the temple", Accumulated: "Where is the temple"
```

Key indicators:
- ✅ `NEW words=` shows extracted part
- ✅ `Accumulated:` shows complete text
- ✅ New words section NOT empty

❌ **BAD LOG SEQUENCE** (signs of bug):
```
[SpeechService] Final result: NEW words="", Accumulated: ""
→ Empty words! ❌

[SpeechService] Final result: NEW words="Where is the temple", Accumulated: "Where is the temple"
[SpeechService] Final result: NEW words="Where is the temple", Accumulated: "Where is the temple Where is the temple"
→ Duplication! ❌

[SpeechService] Final result: NEW words="the", Accumulated: "Where is the"
(Missing "temple") 
→ Incomplete extraction! ❌
```

### How to Enable Debug Logging

Check `lib/services/speech_service.dart`:
- Look for `debugLog('...')` calls
- These should print to console automatically
- If not, check app console output

---

## Step-by-Step Verification

### Step 1: Code Structure Check

Open `lib/services/speech_service.dart`:

**Line ~26**: Check variables declared
```dart
String _accumulatedText = '';
String _lastRecognizedWords = '';
String _lastFinalizedText = '';  // ← Must have this
```
- ✅ If all three exist → Continue to Step 2
- ❌ If missing `_lastFinalizedText` → Add it

**Line ~231**: Check reset in `startListening()`
```dart
_accumulatedText = '';
_lastRecognizedWords = '';
_lastFinalizedText = '';  // ← Must reset here
```
- ✅ If all three reset → Continue to Step 2
- ❌ If missing reset → Add it

### Step 2: Logic Check

**Lines ~272-276**: Check extraction logic
```dart
if (_lastFinalizedText.isNotEmpty && 
    currentWords.startsWith(_lastFinalizedText)) {
  newWords = currentWords.substring(_lastFinalizedText.length).trim();
}
```
- ✅ If logic exists → Continue to Step 3
- ❌ If missing or wrong → Fix it

**Line ~294**: Check finalized text update
```dart
_lastFinalizedText = currentWords;
```
- ✅ If present → Continue to Step 3
- ❌ If missing → Add it

### Step 3: Manual Test

1. Stop app completely (restart)
2. Open app fresh
3. Run quick test above
4. Check logs
5. Verify message is correct

---

## Common Mistakes

### ❌ Mistake 1: Forgetting to Reset
```dart
// WRONG: Never reset _lastFinalizedText
// Only reset _accumulatedText

// RIGHT: Reset both
_accumulatedText = '';
_lastFinalizedText = '';
```

### ❌ Mistake 2: Wrong Variable Name
```dart
// WRONG: Using wrong variable name
if (currentWords.startsWith(_lastRecognizedWords)) {  // ← Wrong!

// RIGHT: Use the right one
if (currentWords.startsWith(_lastFinalizedText)) {   // ← Correct
```

### ❌ Mistake 3: Appending Full Instead of New
```dart
// WRONG: Appending entire current result
_accumulatedText += ' $currentWords';  // ← Duplicates!

// RIGHT: Append only extracted new words
_accumulatedText += ' $newWords';      // ← Correct
```

### ❌ Mistake 4: Not Checking if Empty
```dart
// WRONG: Always appending
_accumulatedText += ' $newWords';  // Even if empty!

// RIGHT: Only append if has content
if (newWords.isNotEmpty) {
  _accumulatedText += ' $newWords';
}
```

---

## Testing Verification Matrix

| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| No pause | Full sentence | | ✅/❌ |
| Short pause (1s) | Full sentence | | ✅/❌ |
| Medium pause (3s) | Full sentence | | ✅/❌ |
| Long pause (8s) | Full sentence | | ✅/❌ |
| Two pauses | All words | | ✅/❌ |
| Logs show extraction | NEW words="..." | | ✅/❌ |
| No duplication | Each word once | | ✅/❌ |
| Correct order | Words in order | | ✅/❌ |

---

## If Everything Else Fails

### Nuclear Option: Print Debugging

Add temporary print statements:

```dart
if (result.finalResult) {
  print('=== FINAL RESULT ===');
  print('Previous: $_lastFinalizedText');
  print('Current: $currentWords');
  print('Starts with check: ${currentWords.startsWith(_lastFinalizedText)}');
  print('Extracted new: $newWords');
  print('Accumulated now: $_accumulatedText');
  print('=== END ===');
}
```

Run and look for:
- ✅ Previous has old text
- ✅ Current has new words included
- ✅ Starts with check is TRUE
- ✅ Extracted new shows just new words
- ✅ Accumulated shows full text

---

## Fast Rollback

If fix doesn't work and you need to quickly rollback:

```bash
# Get previous version
git checkout HEAD~1 lib/services/speech_service.dart

# Or manually:
# 1. Delete _lastFinalizedText variable
# 2. Remove the if (startsWith) block
# 3. Change _accumulatedText += ' $currentWords'
# 4. Redeploy
```

Time: 5 minutes

---

## Need More Help?

1. Check VOICE_ACCUMULATION_FINAL_FIX.md for detailed explanation
2. Review logs following "Debug by Looking at Logs" section
3. Verify code structure using "Step-by-Step Verification"
4. Test using matrices above
5. Contact development team if still issues

---

**Status**: Troubleshooting Guide Ready  
**Date**: October 29, 2026  

