# Mahakal Knowledge Base - Test Queries

## ✅ Testing the Smart Context-Aware AI

The system now intelligently routes queries:
- **Mahakal/Ujjain queries** → Use comprehensive Mahakal knowledge base
- **General queries** → Use LLM's general knowledge

---

## 🕉️ TEST QUERIES - MAHAKAL/UJJAIN (Uses Knowledge Base)

### Temple Information
1. **"What is Mahakaleshwar Temple?"**
   - Expected: Official info about Jyotirlinga, significance, GPS coordinates

2. **"Tell me about Mahakal temple"** (Hindi/English)
   - Expected: Temple overview, timing, significance

3. **"महाकालेश्वर मंदिर के बारे में बताओ"**
   - Expected: Hindi response with temple details

### Bhasma Aarti
4. **"What is Bhasma Aarti timing?"**
   - Expected: 4:00 AM - 6:00 AM, seasonal variations, booking info

5. **"How to book Bhasma Aarti?"**
   - Expected: Official booking URL, helpline numbers, requirements

6. **"भस्म आरती का समय क्या है?"**
   - Expected: Hindi response with timing and booking details

### Darshan & Entry
7. **"What is VIP darshan fee?"**
   - Expected: ₹250 (indicative), disclaimer to verify on official website

8. **"Temple entry timing"**
   - Expected: Regular darshan 6 AM - 11 PM, aarti schedules

9. **"How to reach Mahakal temple from railway station?"**
   - Expected: ~2 km, auto/e-rickshaw ₹50-₹100, transport options

### Nearby Places
10. **"Which temples to visit in Ujjain?"**
    - Expected: Harsiddhi, Kal Bhairav, Ram Ghat, Mangalnath, etc.

11. **"Places to visit near Mahakal"**
    - Expected: List of nearby temples with distances and descriptions

12. **"Tell me about Ram Ghat"**
    - Expected: Sacred bathing ghat, Shipra River, evening aarti

### Accommodation
13. **"Hotels near Mahakaleshwar temple"**
    - Expected: Anjushree, Rudraksh, MP Tourism properties, budget ₹3k-₹10k

14. **"Where to stay in Ujjain?"**
    - Expected: Hotel options with disclaimer about checking live rates

### Food
15. **"Where to eat near Mahakal temple?"**
    - Expected: Annakshetra, Balaji Bhojanalaya, local specialties

16. **"Best food in Ujjain"**
    - Expected: Ujjaini Poha, Dal Baafla, vegetarian options

### Distance Queries
17. **"How far is Mahakal from here?"** (requires GPS)
    - Expected: Calculate from user's GPS to 23.18312°N, 75.76819°E

18. **"Distance from Nanakheda bus stand to Mahakal"**
    - Expected: Fare estimate ₹100-₹180, disclaimer about confirming

### Events
19. **"When is Simhastha Kumbh Mela?"**
    - Expected: 2028, every 12 years, Shipra River, Shahi Snan

20. **"What is Mahakal Sawari?"**
    - Expected: Annual procession in Shravan month, Shahi Sawari

### Mahakal Lok
21. **"What is Mahakal Lok?"**
    - Expected: 900m corridor, 108 pillars, 192 statues, 53 murals, free entry

---

## 🌍 TEST QUERIES - GENERAL (Uses LLM Knowledge)

### Jokes & Entertainment
22. **"Tell me a joke"**
    - Expected: General joke (may include Ujjain context but not required)

23. **"Make me laugh"**
    - Expected: Funny content without using Mahakal knowledge base

### Mathematics
24. **"What is 25 × 34?"**
    - Expected: 850 (simple calculation, no Mahakal context)

25. **"Convert 10 km to miles"**
    - Expected: ~6.21 miles (unit conversion)

### Weather & Other Cities
26. **"Weather in Mumbai"**
    - Expected: General weather info (not Ujjain-specific)

27. **"How far is Delhi from Mumbai?"**
    - Expected: ~1400 km by road (no Mahakal context needed)

### General Knowledge
28. **"Who is the Prime Minister of India?"**
    - Expected: Current PM name (general knowledge)

29. **"What is Python programming?"**
    - Expected: Programming language explanation (tech knowledge)

30. **"Tell me about Taj Mahal"**
    - Expected: General Taj Mahal info (not Ujjain/Mahakal)

### Motivation & Greetings
31. **"Motivate me"**
    - Expected: Motivational message (may include spiritual context)

32. **"Good morning"**
    - Expected: Greeting response (may use "Har Har Mahadev" if appropriate)

---

## 🔀 TEST QUERIES - MIXED (Uses Both)

### Combined Context
33. **"Weather in Ujjain and best time to visit Mahakal"**
    - Expected: General weather + Mahakal visit timing from knowledge base

34. **"Tell me a joke about Ujjain temples"**
    - Expected: Creative blend of humor + temple context

35. **"How far is Ujjain from Indore and how to reach Mahakal from railway station?"**
    - Expected: City distance (general) + station to temple (knowledge base)

---

## 🧪 EDGE CASE TEST QUERIES

### Ambiguous Queries
36. **"Timing?"** (unclear what timing)
    - Expected: Ask for clarification or provide temple timings

37. **"How far?"** (unclear from where or to where)
    - Expected: Ask for clarification or use GPS if available

### Out of Scope
38. **"Book a flight to Ujjain"**
    - Expected: Can't book flights, suggest nearest airport (Indore)

39. **"Current Mahakal live darshan"**
    - Expected: Can't provide live video, suggest official website

### Multi-lingual
40. **"Mahakal ka address kya hai?"** (Hinglish)
    - Expected: Address in mixed Hindi/English

---

## ✅ SUCCESS CRITERIA

For each query type:

### Mahakal/Ujjain Queries Should:
✅ Use information from knowledge base  
✅ Include official URLs where applicable  
✅ Add disclaimers for fees, timings, availability  
✅ Use SEO keywords naturally  
✅ Provide GPS coordinates when relevant  
✅ Suggest verification from official sources  

### General Queries Should:
✅ Use LLM's general knowledge  
✅ Not force Mahakal context inappropriately  
✅ Provide accurate information  
✅ Be natural and conversational  

### Mixed Queries Should:
✅ Seamlessly blend both knowledge sources  
✅ Maintain context coherence  
✅ Answer all parts of the question  

---

## 📊 TESTING CHECKLIST

- [ ] Test 5+ Mahakal queries (verify knowledge base is used)
- [ ] Test 5+ general queries (verify LLM knowledge is used)
- [ ] Test 3+ mixed queries (verify smooth blending)
- [ ] Test Hindi responses (verify language switching)
- [ ] Test GPS-based distance queries (verify live location use)
- [ ] Test disclaimers (verify appropriate cautions)
- [ ] Test SEO keywords (verify natural usage)
- [ ] Test fallback to offline (verify when no internet)

---

## 🎯 EXPECTED BEHAVIOR SUMMARY

```
┌─────────────────────────────────────┐
│         User Query                  │
└─────────────┬───────────────────────┘
              │
              ▼
      ┌───────────────┐
      │ Is Internet?  │
      └───┬───────┬───┘
          │       │
     YES  │       │  NO
          │       │
          ▼       ▼
    ┌─────────┐ ┌──────────────┐
    │ Online  │ │   Offline    │
    │   AI    │ │      AI      │
    └────┬────┘ └──────┬───────┘
         │             │
         │             │
         ▼             ▼
    ┌─────────────────────────┐
    │ Mahakal/Ujjain Query?   │
    └──┬─────────────────┬────┘
       │                 │
      YES               NO
       │                 │
       ▼                 ▼
 ┌──────────┐    ┌──────────────┐
 │ Use      │    │ Use General  │
 │ Mahakal  │    │ LLM          │
 │ Knowledge│    │ Knowledge    │
 │ Base     │    │              │
 └──────────┘    └──────────────┘
```

---

## 🚀 HOW TO TEST

1. **Open Ujjain Live app**
2. **Ensure you're in Online Mode** (or toggle between modes)
3. **Ask test queries from the lists above**
4. **Verify responses match expected behavior**

### Quick Test Script:
```
1. "What is Bhasma Aarti timing?" → Should use knowledge base
2. "Tell me a joke" → Should use general knowledge
3. "Weather in Ujjain and temple timing" → Should use both
```

---

**Implementation Complete! ✅**  
Har Har Mahadev! 🕉️
