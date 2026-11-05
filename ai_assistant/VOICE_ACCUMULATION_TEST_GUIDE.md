# Voice Text Accumulation - Testing Guide

## Quick Verification (2 minutes)

### Test: Simple Pause and Continue
1. Tap microphone button
2. Say: "Where is the Mahakal Temple" → **Pause for 3 seconds** → "from here"
3. Stop speaking / Wait for completion
4. **Expected in chat**: "Where is the Mahakal Temple from here"
5. **Result**: ✅ / ❌

If ✅, the fix is working!

---

## Comprehensive Test Suite

### Test Group A: Basic Accumulation

#### Test A1: Two-Part Query with Pause
```
Instructions:
  1. Tap microphone
  2. Say: "How far is"
  3. Pause for 2 seconds
  4. Say: "the temple"
  5. Stop speaking

Expected in UI (listening indicator):
  - During first part: "How far is"
  - During pause: "How far is"
  - During second part: "How far is the temple"
  - After stop: Message sent with "How far is the temple"

Result: ✅ / ❌
Notes: ___________________________
```

#### Test A2: Three-Part Query with Multiple Pauses
```
Instructions:
  1. Tap microphone
  2. Say: "Tell me"
  3. Pause for 2 seconds
  4. Say: "about"
  5. Pause for 1 second
  6. Say: "temples"
  7. Stop speaking

Expected Message: "Tell me about temples"
Result: ✅ / ❌
Notes: ___________________________
```

#### Test A3: Long Query with Natural Pauses
```
Instructions:
  1. Tap microphone
  2. Say: "Can you find"
  3. Pause for 3 seconds
  4. Say: "a nice hotel"
  5. Pause for 2 seconds
  6. Say: "near the temple"
  7. Stop speaking

Expected Message: "Can you find a nice hotel near the temple"
Result: ✅ / ❌
Notes: ___________________________
```

---

### Test Group B: Edge Cases

#### Test B1: Very Short Pause (0.5 seconds)
```
Instructions:
  1. Tap microphone
  2. Say: "Where" → Quick 0.5s pause → "is" → 0.5s pause → "temple"
  3. Stop speaking

Expected Message: "Where is temple"
Result: ✅ / ❌
Notes: ___________________________
```

#### Test B2: Long Pause (8 seconds - Testing pauseFor limit)
```
Instructions:
  1. Tap microphone
  2. Say: "First sentence"
  3. Pause for 8 seconds (thinking time)
  4. Say: "Second sentence"
  5. Stop speaking

Expected Message: "First sentence Second sentence"
Result: ✅ / ❌
Notes: ___________________________
```

#### Test B3: Pause at Beginning (Before First Word)
```
Instructions:
  1. Tap microphone
  2. Pause for 2 seconds
  3. Say: "How far is the temple"
  4. Stop speaking

Expected Message: "How far is the temple"
Result: ✅ / ❌
Notes: ___________________________
```

#### Test B4: No Pause (Continuous Speech)
```
Instructions:
  1. Tap microphone
  2. Say: "Where is the Mahakal Temple from here" (without pausing)
  3. Stop speaking

Expected Message: "Where is the Mahakal Temple from here"
Result: ✅ / ❌ (Should still work as before)
Notes: ___________________________
```

---

### Test Group C: Real-World Scenarios

#### Test C1: Distance Query with Pause
```
Instructions:
  1. Tap microphone
  2. Say: "How far is" → Pause 2s → "the Bade Ganesh Temple" → Pause 1s → "from my location"
  3. Stop speaking

Expected Message: "How far is the Bade Ganesh Temple from my location"
Verify AI receives complete query: ✅ / ❌
AI Response includes distance: ✅ / ❌
Notes: ___________________________
```

#### Test C2: Hotel Search with Pauses
```
Instructions:
  1. Tap microphone
  2. Say: "Find me" → Pause 2s → "a good hotel" → Pause 1s → "near temples" → Pause 2s → "in Ujjain"
  3. Stop speaking

Expected Message: "Find me a good hotel near temples in Ujjain"
Verify: Full query understood: ✅ / ❌
Notes: ___________________________
```

#### Test C3: Complex Multi-Clause Query
```
Instructions:
  1. Tap microphone
  2. Say: "I want to know" → Pause 2s → "the distance" → Pause 1s → "to Mahakal Temple" → Pause 1s → "and opening hours"
  3. Stop speaking

Expected Message: "I want to know the distance to Mahakal Temple and opening hours"
Result: ✅ / ❌
Notes: ___________________________
```

---

### Test Group D: UI/UX Verification

#### Test D1: Listening Indicator Updates Correctly
```
Instructions:
  1. Tap microphone
  2. Observe listening indicator in chat input area
  3. Say: "First part" → Pause 2s → "Second part"
  4. Observe indicator text changes

Expected Behavior:
  - Initially shows "🎤 Listening... speak now"
  - Updates to show: "First part"
  - During pause: Still shows "First part"
  - Updates to show: "First part Second part"
  - After completion: Disappears

Result: ✅ / ❌
Notes: ___________________________
```

#### Test D2: Text in Indicator Shows Accumulated Text
```
Instructions:
  1. Tap microphone
  2. Carefully observe the listening indicator text
  3. Say: "Where is" → Pause 2s → "the temple"
  4. Watch if text accumulates correctly

Expected:
  - Shows "Where is"
  - After pause, still shows "Where is"
  - After "the temple", shows "Where is the temple"

Result: ✅ / ❌
Notes: ___________________________
```

#### Test D3: Message Sent Only After Session Ends
```
Instructions:
  1. Tap microphone
  2. Say: "First part" → Pause 2s → "Second part"
  3. Observe when message appears in chat

Expected:
  - Message appears ONLY after 15 seconds of silence OR user taps stop
  - Complete text: "First part Second part"
  - NOT sent after first pause

Result: ✅ / ❌
Notes: ___________________________
```

---

### Test Group E: Negative Tests (Verify No Regressions)

#### Test E1: Existing Single-Sentence Queries
```
Instructions:
  1. Tap microphone
  2. Say: "How far is Mahakal Temple" (in one breath, no pauses)
  3. Stop speaking

Expected Message: "How far is Mahakal Temple"
Result: ✅ / ❌ (Should still work exactly as before)
Notes: ___________________________
```

#### Test E2: Short Quick Queries
```
Instructions:
  1. Tap microphone
  2. Say: "Distance to temple"
  3. Immediately stop

Expected Message: "Distance to temple"
Result: ✅ / ❌
Notes: ___________________________
```

#### Test E3: Cancel During Speaking
```
Instructions:
  1. Tap microphone
  2. Say: "How far" → Click X button to cancel
  3. Observe result

Expected: Session cancels, no message sent
Result: ✅ / ❌
Notes: ___________________________
```

---

## Observation Checklist

### During Test Execution

- [ ] Listening indicator appears when mic tapped
- [ ] Listening indicator shows partial results
- [ ] Text in indicator accumulates (doesn't replace)
- [ ] Pause doesn't trigger message send
- [ ] Continuing after pause adds to text (not replaces)
- [ ] Final message contains complete accumulated text
- [ ] No duplicate words in final message
- [ ] UI is responsive during listening
- [ ] Stop button works correctly
- [ ] Timeout dialog appears after 20 seconds if needed

### After Test Execution

- [ ] Message appears in chat correctly
- [ ] Message text matches expected output
- [ ] AI can understand complete query
- [ ] AI response is contextually correct
- [ ] No error messages appear
- [ ] App doesn't crash or freeze

---

## Debug Log Checking

### Expected Log Sequence for "Where is" [Pause] "the temple"

```
[SpeechService] Result: "Where is" (final: false, confidence: 0.92)
[SpeechService] Partial result. Current display: "Where is"

[SpeechService] Result: "Where is" (final: true, confidence: 0.91)  ← PAUSE DETECTED
[SpeechService] Final result accumulated. Current accumulated: "Where is"
[SpeechService] Intermediate final result received: Where is (will continue listening)

[SpeechService] Result: "the temple" (final: false, confidence: 0.88)
[SpeechService] Partial result. Current display: "Where is the temple"  ← ACCUMULATED!

[SpeechService] Result: "the temple" (final: true, confidence: 0.90)
[SpeechService] Final result accumulated. Current accumulated: "Where is the temple"

[SpeechService] Speech status: done  ← LISTENING ENDS
[SpeechService] Completing listening due to done status with words: "Where is the temple"
```

**If you see different logs**, the fix may not be working correctly.

---

## Pass/Fail Criteria

### ✅ Test PASSES if:
1. Complete sentence captured with all pauses
2. No text loss between pauses
3. Words in correct order
4. No duplication
5. AI receives complete query
6. Matches expected output exactly

### ❌ Test FAILS if:
1. Only final segment sent ("the temple" without "Where is")
2. Text is duplicated ("Where is the temple the temple")
3. Words in wrong order
4. Message sent prematurely during pause
5. Only first part sent (incomplete query)
6. Partial results don't update correctly

---

## Test Results Summary

| Test # | Scenario | Expected | Actual | Pass |
|--------|----------|----------|--------|------|
| A1 | Simple pause | Full sentence | | ✅/❌ |
| A2 | Multiple pauses | All parts | | ✅/❌ |
| A3 | Long with pauses | Complete | | ✅/❌ |
| B1 | Short pause | Works | | ✅/❌ |
| B2 | Long pause (8s) | Works | | ✅/❌ |
| C1 | Distance query | Full question | | ✅/❌ |
| C2 | Hotel search | Complete search | | ✅/❌ |
| D1 | UI indicator | Updates correctly | | ✅/❌ |
| E1 | Single sentence | Still works | | ✅/❌ |
| E2 | Quick query | Still works | | ✅/❌ |

**Overall Result**: ✅ PASS / ❌ FAIL

---

## Common Issues & Solutions

### Issue: Only Second Part Sent

**Problem**: "the temple" sent instead of "Where is the temple"

**Cause**: Accumulation not working

**Fix Check**:
- Verify `_accumulatedText` is initialized as empty
- Verify final results append to accumulated
- Check onResult callback logic

---

### Issue: Text Duplicated

**Problem**: "Where is Where is the temple"

**Cause**: Text added twice to accumulated

**Fix Check**:
- Verify accumulated text set to final result (not appended initially)
- Check if partial results are being counted as finals

---

### Issue: Pause Triggers Message Send

**Problem**: Message sent after pause (before user finishes)

**Cause**: Status handler completing on wrong signal

**Fix Check**:
- Verify 'done' status is waited for
- Check 'notListening' doesn't trigger completion
- Verify pauseFor: 15 seconds

---

### Issue: UI Not Updating

**Problem**: Listening indicator shows old text

**Cause**: onPartialResult callback not being called

**Fix Check**:
- Verify onPartialResult called for partial results
- Check partial results include accumulated text
- Verify chat_input.dart processes updates

---

## Notes

- Test on different devices/OS if possible (Android, iOS)
- Test with different languages (Hindi, English)
- Test in different network conditions
- Test with background noise
- Document any unexpected behavior

---

**Date**: October 29, 2026  
**Version**: 1.0.0 (Accumulation Testing Guide)  
**Status**: Ready for Testing
