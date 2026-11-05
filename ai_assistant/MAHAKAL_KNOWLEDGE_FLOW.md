# 🕉️ Mahakal Knowledge Base - Query Flow Diagram

## Visual Flow Chart

```
┌────────────────────────────────────────────────────────────────┐
│                        USER QUERY                              │
│  Example: "What is Bhasma Aarti timing?" or "Tell me a joke"  │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │     Is Internet Available?             │
        └───────────┬───────────────┬────────────┘
                    │               │
                   YES             NO
                    │               │
                    ▼               ▼
        ┌─────────────────┐  ┌──────────────────┐
        │   ONLINE MODE   │  │   OFFLINE MODE   │
        │                 │  │                  │
        │  ai_service.    │  │  offline_ai_     │
        │  dart           │  │  service.dart    │
        │                 │  │                  │
        │  System Prompt  │  │  Embedded 5000+  │
        │  with Mahakal   │  │  lines knowledge │
        │  Knowledge Base │  │                  │
        └────────┬────────┘  └────────┬─────────┘
                 │                    │
                 │                    │
                 ▼                    ▼
        ┌─────────────────────────────────────┐
        │   QUERY CLASSIFICATION               │
        │   Is this about Mahakal/Ujjain?     │
        └──────────┬──────────────────┬────────┘
                   │                  │
           ┌───────┴───────┐         │
           │               │         │
          YES             NO         │
           │               │         │
           ▼               ▼         ▼
┌────────────────┐  ┌───────────────────┐
│  MAHAKAL QUERY │  │  GENERAL QUERY    │
│                │  │                   │
│  Examples:     │  │  Examples:        │
│  • Temple      │  │  • Jokes          │
│    timings     │  │  • Math           │
│  • Bhasma      │  │  • Weather        │
│    Aarti       │  │  • Other cities   │
│  • VIP darshan │  │  • World facts    │
│  • Hotels in   │  │  • Motivation     │
│    Ujjain      │  │                   │
│  • Distance to │  │                   │
│    Mahakal     │  │                   │
│  • Nearby      │  │                   │
│    temples     │  │                   │
└────────┬───────┘  └─────────┬─────────┘
         │                    │
         ▼                    ▼
┌─────────────────┐  ┌────────────────────┐
│ USE MAHAKAL     │  │ USE LLM GENERAL    │
│ KNOWLEDGE BASE  │  │ KNOWLEDGE          │
│                 │  │                    │
│ • Official info │  │ • GPT-4 training   │
│ • Temple coords │  │ • World knowledge  │
│ • Aarti times   │  │ • Calculations     │
│ • Booking URLs  │  │ • Humor            │
│ • Fares         │  │ • Facts            │
│ • Hotels        │  │                    │
│ • Disclaimers   │  │                    │
│ • SEO keywords  │  │                    │
└────────┬────────┘  └─────────┬──────────┘
         │                     │
         └──────────┬──────────┘
                    │
                    ▼
        ┌────────────────────────────┐
        │   ENHANCED RESPONSE        │
        │                            │
        │   • Accurate information   │
        │   • Proper disclaimers     │
        │   • Official URLs          │
        │   • GPS-based distances    │
        │   • SEO-optimized          │
        │   • Natural language       │
        │   • Hindi/English/Hinglish │
        └────────────┬───────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │     DISPLAY TO USER        │
        │                            │
        │  • In chat screen          │
        │  • With voice output       │
        │  • Formatted nicely        │
        └────────────────────────────┘
```

---

## 🔍 Query Classification Examples

### Mahakal/Ujjain Queries (Use Knowledge Base):

| Query | Knowledge Source | Response Includes |
|-------|-----------------|-------------------|
| "Bhasma Aarti timing?" | Mahakal KB | Official timing + booking URL |
| "Hotels in Ujjain?" | Mahakal KB | Hotel list + budget + disclaimer |
| "How far is Mahakal?" | Mahakal KB + GPS | Calculated distance + travel time |
| "VIP darshan fee?" | Mahakal KB | ₹250 (indicative) + verify disclaimer |
| "Temples near Mahakal?" | Mahakal KB | List with distances + descriptions |
| "Mahakal Lok timings?" | Mahakal KB | 6 AM - 10 PM + free entry |

### General Queries (Use LLM Knowledge):

| Query | Knowledge Source | Response Type |
|-------|-----------------|---------------|
| "Tell me a joke" | LLM General | Humor/Entertainment |
| "What is 25 × 34?" | LLM General | Math calculation |
| "Weather in Mumbai?" | LLM General | Weather info |
| "Who is PM of India?" | LLM General | Current affairs |
| "Convert km to miles" | LLM General | Unit conversion |
| "Motivate me" | LLM General | Motivational content |

### Mixed Queries (Use Both):

| Query | Knowledge Sources | Response Combines |
|-------|------------------|-------------------|
| "Weather in Ujjain + temple timing?" | LLM + Mahakal KB | Weather + aarti schedule |
| "Joke about Ujjain temples?" | LLM + Mahakal KB | Humor with temple context |
| "Distance Ujjain-Indore + how to reach Mahakal?" | LLM + Mahakal KB | City distance + station to temple |

---

## 🎯 Decision Tree

```
Is query about:
├─ Mahakaleshwar Temple?        → Use Mahakal KB
├─ Ujjain temples?              → Use Mahakal KB
├─ Ujjain accommodation?        → Use Mahakal KB
├─ Ujjain transport?            → Use Mahakal KB
├─ Bhasma Aarti?                → Use Mahakal KB
├─ Simhastha Kumbh?             → Use Mahakal KB
├─ Distance to Ujjain places?   → Use Mahakal KB + GPS
├─ Mahakal Lok?                 → Use Mahakal KB
├─ Mahakal Sawari?              → Use Mahakal KB
├─ Food in Ujjain?              → Use Mahakal KB
└─ Other topics?                → Use LLM General Knowledge
```

---

## 📊 Priority Matrix

| Query Type | Priority 1 | Priority 2 | Priority 3 |
|-----------|-----------|-----------|-----------|
| **Temple Info** | Mahakal KB | — | — |
| **Aarti/Darshan** | Mahakal KB | — | — |
| **Ujjain Hotels** | Mahakal KB | — | — |
| **Distance Queries** | User GPS | Mahakal KB | — |
| **General Math** | LLM | — | — |
| **Jokes** | LLM | Ujjain context (optional) | — |
| **Other Cities** | LLM | — | — |
| **Mixed Queries** | Relevant KB | LLM supplement | GPS data |

---

## 🔄 Offline vs Online Behavior

### **Online Mode (ai_service.dart):**
```
User Query
    ↓
System Prompt includes:
  • Language preference (Hindi/English)
  • Complete Mahakal knowledge base
  • User's live GPS coordinates
  • Response guidelines
    ↓
Sent to OpenAI/OpenRouter API
    ↓
LLM processes with context
    ↓
Returns SEO-optimized response
```

### **Offline Mode (offline_ai_service.dart):**
```
User Query
    ↓
Query Agent analyzes:
  • Intent classification
  • Entity extraction
  • Context building
    ↓
Pattern matching with:
  • 5000+ lines embedded knowledge
  • Temple database
  • Hotel database
  • Distance calculations
    ↓
Returns offline response
```

---

## 🎨 Response Enhancement Pipeline

```
Query → Classification → Knowledge Selection → Enhancement → Output

Example Flow:
"Bhasma Aarti timing?"
    ↓
[Temple/Aarti Intent]
    ↓
[Mahakal KB Selected]
    ↓
[Add: timing + booking URL + helpline + disclaimer]
    ↓
[SEO keywords: "Bhasma Aarti Mahakaleshwar Ujjain"]
    ↓
"Bhasma Aarti at Mahakaleshwar Temple is held from 
4:00 AM to 6:00 AM. Book here: https://...
Helpline: 1800-233-1008..."
```

---

## 🌐 SEO Optimization Flow

```
User Query: "temple timing ujjain"
    ↓
AI recognizes: Mahakal query
    ↓
Response includes keywords:
  • "Mahakaleshwar Temple Ujjain"
  • "Bhasma Aarti timing"
  • "darshan schedule"
  • "Ujjain Jyotirlinga"
    ↓
When shared online/searched:
  ✅ Better search engine ranking
  ✅ More discoverable content
  ✅ Professional presentation
```

---

## 🎯 Success Metrics

**What makes a good response:**

✅ **Accuracy**: Uses verified official information  
✅ **Completeness**: Answers all parts of question  
✅ **Disclaimers**: Appropriate cautions included  
✅ **Resources**: Official URLs and contacts provided  
✅ **SEO**: Keywords used naturally  
✅ **Clarity**: Easy to understand  
✅ **Context**: Relevant to user's needs  

---

**Implementation Status:** ✅ **LIVE & WORKING**  
Har Har Mahadev! 🕉️
