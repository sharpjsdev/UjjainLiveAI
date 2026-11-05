# Voice Pause Testing Guide

## Quick Test (1-2 minutes)

### Test 1: Simple Pause
1. Tap microphone button
2. Say: "How far" → pause 3 seconds → "is the temple"
3. Stop speaking
4. **Expected Result**: "How far is the temple" (full sentence)

### Test 2: Long Pause
1. Tap microphone button
2. Say: "Where is" → pause 5 seconds → "the Mahakal Temple"
3. Stop speaking
4. **Expected Result**: "Where is the Mahakal Temple" (full sentence)

### Test 3: Multiple Pauses
1. Tap microphone button
2. Say: "Tell me" → pause 2s → "about" → pause 3s → "temples in Ujjain"
3. Stop speaking
4. **Expected Result**: "Tell me about temples in Ujjain" (all words preserved)

---

## Comprehensive Test Suite (5-10 minutes)

### Test Group A: Natural Pauses

**Test A1: 1-Second Pause**
- Input: "What is" [1s pause] "Mahakal Temple"
- Expected: "What is Mahakal Temple"
- Result: ✓ / ✗

**Test A2: 3-Second Pause**
- Input: "Tell me" [3s pause] "about snan rituals"
- Expected: "Tell me about snan rituals"
- Result: ✓ / ✗

**Test A3: 5-Second Pause**
- Input: "How far is" [5s pause] "the nearest hotel"
- Expected: "How far is the nearest hotel"
- Result: ✓ / ✗

**Test A4: 8-Second Pause (Thinking Time)**
- Input: "What are" [8s pause] "the best restaurants"
- Expected: "What are the best restaurants"
- Result: ✓ / ✗

**Test A5: 10-Second Pause (Long Thinking)**
- Input: "Can you tell me" [10s pause] "about local temples"
- Expected: "Can you tell me about local temples"
- Result: ✓ / ✗

---

### Test Group B: Multiple Pauses

**Test B1: Two Pauses**
- Input: "Where can I" [2s] "find" [2s] "good food"
- Expected: "Where can I find good food"
- Result: ✓ / ✗

**Test B2: Three Pauses**
- Input: "Tell me" [2s] "about" [2s] "the" [2s] "weather"
- Expected: "Tell me about the weather"
- Result: ✓ / ✗

**Test B3: Mixed Pause Lengths**
- Input: "How far is" [1s] "the temple" [5s] "from my location"
- Expected: "How far is the temple from my location"
- Result: ✓ / ✗

---

### Test Group C: Edge Cases

**Test C1: No Pause (Fast Speaking)**
- Input: "What is the weather today?" (no pauses)
- Expected: "What is the weather today?"
- Result: ✓ / ✗

**Test C2: Very Long Sentence with Pause**
- Input: "Can you tell me" [3s] "where I can find" [2s] "the best accommodation" [2s] "near the temple"
- Expected: Full 20+ word sentence captured
- Result: ✓ / ✗

**Test C3: Pause After First Word**
- Input: "How" [4s pause] "far is the temple"
- Expected: "How far is the temple"
- Result: ✓ / ✗

**Test C4: Max Pause Duration (14 seconds)**
- Input: "Tell me" [14s pause] "about hotels"
- Expected: "Tell me about hotels"
- Result: ✓ / ✗

**Test C5: Exceeds Max Pause (16 seconds)**
- Input: "First part" [16s pause - exceeds pauseFor] "second part"
- Expected: "First part" (only, or timeout)
- Result: ✓ / ✗

---

### Test Group D: Real-World Scenarios

**Test D1: Asking About Temple**
- Input: "How far is" [pause 2s] "Mahakal Temple" [pause 1s] "from my current location"
- Expected: Full question captured with complete information
- Result: ✓ / ✗

**Test D2: Distance Inquiry**
- Input: "What's the distance" [pause 3s] "to Bade Ganesh Temple"
- Expected: Complete question for distance calculation
- Result: ✓ / ✗

**Test D3: Accommodation Search**
- Input: "Can you find me" [pause 2s] "a hotel" [pause 1s] "close to the temple"
- Expected: Complete search query
- Result: ✓ / ✗

**Test D4: Complex Query**
- Input: "Tell me about" [pause 2s] "temples and hotels" [pause 1s] "that are" [pause 2s] "within 2 kilometers"
- Expected: Full complex query captured
- Result: ✓ / ✗

---

## What to Check

### ✓ Positive Indicators (Fix is Working)

- Full sentences captured even with pauses
- No text loss between pauses
- Listening UI updates correctly during speech
- Partial results show accumulated text
- No premature sending of incomplete messages

### ✗ Negative Indicators (Fix Not Working)

- Text after pause is missing
- Only first part of sentence sent
- Listening stops too early
- Pause triggers message send
- "How far is the" sent without "temple"

---

## Debug Information

### Enable Logging

Check Android logcat or app logs for messages like:
```
[SpeechService] Intermediate final result received: How far is the temple
[SpeechService] notListening status received, words so far: "How far is the temple"
[SpeechService] Result: "from here" (final: true, confidence: 0.95)
[SpeechService] Speech status: done
[SpeechService] Completing listening due to done status with words: "How far is the temple from here"
```

### Key Log Messages to Look For

- ✅ "Intermediate final result received" → Listening continuing after pause
- ✅ "notListening status received, words so far:" → Preserving words
- ✅ "Completing listening due to done status" → Proper completion point
- ❌ "Final result: [partial text]" → Would indicate premature completion (old code)

---

## Testing Checklist

- [ ] Test A1: 1-second pause works
- [ ] Test A2: 3-second pause works
- [ ] Test A3: 5-second pause works
- [ ] Test A5: 10-second pause works
- [ ] Test B1: Two pauses work
- [ ] Test B3: Mixed pauses work
- [ ] Test C2: Long sentence works
- [ ] Test D1: Real-world temple query works
- [ ] Listening UI shows accumulated text
- [ ] No messages sent prematurely

---

## Expected Timeline

- **Pause 0-3s**: User continues speaking → Text accumulates ✓
- **Pause 3-8s**: User continues speaking → Text accumulates ✓
- **Pause 8-15s**: User continues speaking → Text accumulates ✓
- **Pause 15s+**: Listening timeout → Session ends
- **Total listening time**: 20 seconds maximum

---

## Results Summary

| Test | Status | Notes |
|------|--------|-------|
| A1 (1s pause) | ✓/✗ | |
| A2 (3s pause) | ✓/✗ | |
| A3 (5s pause) | ✓/✗ | |
| A5 (10s pause) | ✓/✗ | |
| B1 (Two pauses) | ✓/✗ | |
| B3 (Mixed pauses) | ✓/✗ | |
| C2 (Long sentence) | ✓/✗ | |
| D1 (Temple query) | ✓/✗ | |

---

**Date**: October 29, 2026
**Type**: Testing Guide
**Status**: Ready to Test
