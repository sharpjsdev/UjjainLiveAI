# Voice Text Accumulation - Visual Flow Diagram

## How the Fix Works (Visual)

### BEFORE (BROKEN) ❌

```
User Input Timeline:
═════════════════════════════════════════════════════════════

Time 0s:  User says "Where is the temple"
          ↓
          Library: "Where is the temple" (partial)
          ↓
          _lastRecognizedWords = "Where is the temple"
          ↓
          Show in UI: "Where is the temple"

Time 2s:  [USER PAUSES - NATURAL SILENCE]
          ↓
          Library: "Where is the temple" (final)
          ↓
          _lastRecognizedWords = "Where is the temple"
          ↓
          Speech library RESETS internally

Time 4s:  User says "from here"
          ↓
          Library: "from here" (partial)
          ↓
          ❌ OLD CODE: _lastRecognizedWords = "from here" [OVERWRITES!]
          ↓
          Show in UI: "from here" [LOST FIRST PART!]

Time 5s:  User stops
          ↓
          Library: "Where is the temple from here" (final - corrected)
          ↓
          ❌ OLD CODE: _accumulatedText += "Where is the temple from here"
          ↓
          RESULT: ❌ DUPLICATION or LOSS
          ❌ Message sent: Only partial text ❌


═════════════════════════════════════════════════════════════
```

### AFTER (FIXED) ✅

```
User Input Timeline:
═════════════════════════════════════════════════════════════

Time 0s:  User says "Where is the temple"
          ↓
          Library: "Where is the temple" (partial)
          ↓
          _lastRecognizedWords = "Where is the temple"
          ↓
          Show in UI: "Where is the temple"

Time 2s:  [USER PAUSES - NATURAL SILENCE]
          ↓
          Library: "Where is the temple" (final)
          ↓
          ✅ NEW: Extract new words:
             Previous: "" (empty)
             Current: "Where is the temple"
             New words: "Where is the temple"
          ↓
          _accumulatedText = "Where is the temple" ✅ SAVED
          _lastFinalizedText = "Where is the temple" ✅ TRACKER SET
          ↓
          Speech library RESETS internally

Time 4s:  User says "from here"
          ↓
          Library: "from here" (partial - new session)
          ↓
          ✅ NEW: Show accumulated + partial:
             Accumulated: "Where is the temple"
             Partial: "from here"
             Combined: "Where is the temple from here" ✅
          ↓
          Show in UI: "Where is the temple from here" ✅

Time 5s:  User stops
          ↓
          Library: "Where is the temple from here" (final - corrected)
          ↓
          ✅ NEW: Smart extraction:
             Previous: "Where is the temple"
             Current: "Where is the temple from here"
             Does current START WITH previous? YES ✅
             Extract new: substring from position 24
             New words: "from here" ✅ ONLY NEW PART!
          ↓
          _accumulatedText += "from here" ✅ APPEND ONLY NEW
          _lastFinalizedText = "Where is the temple from here"
          ↓
          RESULT: ✅ "Where is the temple from here"
          ✅ Message sent: COMPLETE TEXT ✅


═════════════════════════════════════════════════════════════
```

---

## Algorithm Comparison

### OLD ALGORITHM (Broken)

```
┌─────────────────────┐
│   Result Received   │
└──────────┬──────────┘
           ↓
    ┌──────────────┐
    │ Is Final?    │
    └──┬────────┬──┘
       │        │
      YES      NO
       ↓        ↓
    ❌ End   Show
    Session   Text
       
Problem: Replaces text, doesn't accumulate
Result: Text lost on pause ❌
```

### NEW ALGORITHM (Fixed)

```
┌─────────────────────┐
│   Result Received   │
└──────────┬──────────┘
           ↓
    ┌──────────────┐
    │ Is Final?    │
    └──┬────────┬──┘
       │        │
      YES      NO
       ↓        ↓
    ┌─────────────────────────────┐    Show
    │ Smart Word Extraction        │    Accumulated
    │                             │    + Current
    │ 1. Get current words        │
    │ 2. Check if starts with     │
    │    previous final?          │
    │ 3. If YES:                  │
    │    Extract only NEW part    │
    │ 4. Append new words ONLY    │
    │                             │
    │ Result: ONLY NEW WORDS ✅   │
    └──────────┬──────────────────┘
               ↓
        Update Accumulated
        Save Final Text
        
Solution: Extracts only new words, properly accumulates
Result: Complete text preserved ✅
```

---

## Text Flow Diagram

### What the Speech Library Does

```
User Speech Stream:
┌──────────────────────────────────────────────────────────┐
│ "Where is the temple" [pause 2s] "from here"            │
└──────────────────────────────────────────────────────────┘
         ↓
    Speech Lib Events:
    
    Event 1: "Where" (partial)
    Event 2: "Where is" (partial)
    Event 3: "Where is the" (partial)
    Event 4: "Where is the temple" (PARTIAL)
    Event 5: "Where is the temple" (FINAL - pause detected)
    
    [LIB RESETS INTERNALLY]
    
    Event 6: "from" (partial - NEW SESSION)
    Event 7: "from here" (partial)
    Event 8: "Where is the temple from here" (FINAL - corrected)
                                             ↑ Includes previous!
```

### How Our Fix Handles It

```
Events 1-4:  Partial results
    ↓
    Show in UI: accumulated so far
    Continue listening

Event 5:  "Where is the temple" (FINAL)
    ↓
    Previous final: "" (empty)
    Current: "Where is the temple"
    New words: "Where is the temple"
    ↓
    _accumulatedText = "Where is the temple" ✅
    _lastFinalizedText = "Where is the temple" ✅

Event 6-7:  "from" and "from here" (partials)
    ↓
    Show: accumulated + partial
    = "Where is the temple" + "from here"
    = "Where is the temple from here" ✅

Event 8:  "Where is the temple from here" (FINAL)
    ↓
    Previous final: "Where is the temple"
    Current: "Where is the temple from here"
    
    Smart Check: Does current START WITH previous?
    "Where is the temple from here".startsWith("Where is the temple")
    Answer: YES ✅
    
    Extract only new:
    "Where is the temple from here".substring(24).trim()
    = "from here" ✅
    
    _accumulatedText += "from here"
    = "Where is the temple from here" ✅
```

---

## State Machine Diagram

```
                        ┌─────────────────────┐
                        │   Listening Start   │
                        │ _accumulated = ""   │
                        │ _lastFinalized = "" │
                        └──────────┬──────────┘
                                   ↓
                    ┌──────────────────────────────┐
                    │  User Speaks: "Where is"     │
                    │  finalResult = false         │
                    └──────────┬───────────────────┘
                               ↓
                    ┌──────────────────────────────┐
                    │  Show partial in UI          │
                    │  _lastRecognizedWords =      │
                    │    "Where is"                │
                    └──────────┬───────────────────┘
                               ↓
                    ┌──────────────────────────────┐
                    │  User Continues: "temple"    │
                    │  finalResult = false         │
                    └──────────┬───────────────────┘
                               ↓
                    ┌──────────────────────────────┐
                    │  Show accumulated + partial: │
                    │  "Where is temple"           │
                    └──────────┬───────────────────┘
                               ↓
                    ┌──────────────────────────────┐
                    │  User Pauses                 │
                    │  Library: (final)            │
                    │  "Where is temple"           │
                    └──────────┬───────────────────┘
                               ↓
        ┌──────────────────────────────────────────────────┐
        │  SMART EXTRACTION                                │
        │  Previous: "" → Extract all: "Where is temple"   │
        │  _accumulated = "Where is temple" ✅             │
        │  _lastFinalized = "Where is temple"              │
        └──────────┬───────────────────────────────────────┘
                   ↓
        ┌──────────────────────────────────────────────────┐
        │  [LIBRARY RESETS]                                │
        │  User continues: "from here"                     │
        │  (new recognition session)                       │
        └──────────┬───────────────────────────────────────┘
                   ↓
        ┌──────────────────────────────────────────────────┐
        │  Show: accumulated + partial                     │
        │  "Where is temple" + "from here"                 │
        │  = "Where is temple from here" ✅                │
        └──────────┬───────────────────────────────────────┘
                   ↓
        ┌──────────────────────────────────────────────────┐
        │  User Stops                                      │
        │  Library gives corrected final:                  │
        │  "Where is temple from here"                     │
        └──────────┬───────────────────────────────────────┘
                   ↓
        ┌──────────────────────────────────────────────────┐
        │  SMART EXTRACTION                                │
        │  Previous: "Where is temple"                     │
        │  Current: "Where is temple from here"            │
        │  Starts with prev? YES ✅                        │
        │  Extract new: "from here"                        │
        │  _accumulated += "from here"                     │
        │  = "Where is temple from here" ✅                │
        └──────────┬───────────────────────────────────────┘
                   ↓
        ┌──────────────────────────────────────────────────┐
        │  LISTENING COMPLETE                              │
        │  Send: "Where is temple from here" ✅            │
        │  Result: FULL SENTENCE PRESERVED ✅              │
        └──────────────────────────────────────────────────┘
```

---

## Comparison Table

| Stage | Event | Before | After |
|-------|-------|--------|-------|
| 1 | User: "Where is temple" | ✅ Show | ✅ Show |
| 2 | Pause → Final | ✅ Save | ✅ Save + Track |
| 3 | User: "from here" | ❌ Overwrite | ✅ Combine |
| 4 | Stop → Final | ❌ Lose/Duplicate | ✅ Extract new only |
| 5 | Result | ❌ Partial text | ✅ Complete text |

---

## Key Insight

The fix recognizes that speech libraries correct themselves by providing the FULL recognized text again after pauses. By checking if the new text STARTS WITH the previous text, we can detect this correction and extract ONLY the new part, avoiding duplication.

```
Before Fix:
  previous = "Where is the temple"
  current = "Where is the temple from here"
  ❌ We appended ALL of current
  ❌ Result: duplicate or lost text

After Fix:
  previous = "Where is the temple"
  current = "Where is the temple from here"
  ✅ We detect: current.startsWith(previous) = TRUE
  ✅ We extract: current.substring(previous.length)
  ✅ We get: " from here"
  ✅ We append ONLY: " from here"
  ✅ Result: complete accurate text!
```

---

**Visual Flow Complete**  
**Status**: ✅ READY FOR PRODUCTION  
