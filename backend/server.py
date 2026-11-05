"""
Simhastha Ujjain 2028 Backend & Admin Server (Pure Python 3 - Zero external dependencies)
Provides identical endpoints and data structures compatible with Node.js/Express.
Run with: python server.py
Simhastha Ujjain 2028 SQLite SQL Backend & Admin Server
Provides full REST APIs backed directly by SQLite3 database (simhastha.db).
"""
import os
import json
import sqlite3
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 3000
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
PUBLIC_DIR = os.path.join(os.path.dirname(__file__), 'public')
DB_PATH = os.path.join(DATA_DIR, 'simhastha.db')

os.makedirs(DATA_DIR, exist_ok=True)

FILES = {
    'temples': os.path.join(DATA_DIR, 'temples.json'),
    'events': os.path.join(DATA_DIR, 'events.json'),
    'stays': os.path.join(DATA_DIR, 'stays.json'),
    'context': os.path.join(DATA_DIR, 'knowledge_context.json'),
}
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def read_data(key):
    path = FILES.get(key)
    if path and os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error reading {key}: {e}")
    return []
def init_sql_database():
    conn = get_db()
    cursor = conn.cursor()

def write_data(key, data):
    path = FILES.get(key)
    if path:
        try:
            with open(path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"Error writing {key}: {e}")
    return False
    # 1. Temples Table
    cursor.execute("""
      CREATE TABLE IF NOT EXISTS temples (
        id TEXT PRIMARY KEY,
        templeId TEXT,
        templeName TEXT NOT NULL,
        hindiName TEXT,
        deity TEXT,
        significance TEXT,
        timing TEXT,
        aartis TEXT,
        entryGates TEXT,
        darshanRoutes TEXT,
        vipFastTrackRules TEXT,
        bookingWebsite TEXT,
        dressCode TEXT,
        prasadDetails TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    """)

def init_seed_data():
    if not os.path.exists(FILES['temples']):
        default_temples = [
            {
                "id": "mahakaleshwar",
                "templeId": "mahakaleshwar",
                "templeName": "Shri Mahakaleshwar Jyotirlinga",
                "hindiName": "श्री महाकालेश्वर ज्योतिर्लिंग",
                "deity": "Lord Shiva (Mahakal - Lord of Eternity & Time)",
                "significance": "The only Dakshinmukhi (south-facing) Jyotirlinga in the world. Enshrines the continuous Cosmic Lingam and is world-renowned for the daily sacred Bhasma Aarti with fresh sacred ashes.",
                "timing": "4:00 AM – 11:00 PM (Temple doors open at 4:00 AM for Bhasma Aarti)",
                "aartis": [
                    {
                        "name": "Bhasma Aarti",
                        "hindiName": "दिव्य भस्म आरती",
                        "timingSummer": "4:00 AM – 6:00 AM",
                        "timingWinter": "4:00 AM – 6:00 AM",
                        "description": "Sacred ash ritual performed before dawn."
                    },
                    {
                        "name": "Sandhya Aarti (Evening)",
                        "hindiName": "संध्या आरती (सायंकालीन)",
                        "timingSummer": "7:00 PM – 7:45 PM",
                        "timingWinter": "6:30 PM – 7:15 PM",
                        "description": "Grand evening shringar aarti."
                    }
                ],
                "entryGates": [
                    "Gate No. 1 (Nandi Dwar): Bhasma Aarti pilgrims",
                    "Gate No. 4: Sheegra Darshan & VIP pass entry"
                ],
                "darshanRoutes": [
                    "Mahakal Lok Corridor -> Sabhamandap -> Nandi Hall View -> Sanctum Jaladhari Exit."
                ],
                "vipFastTrackRules": "Sheegra Darshan passes available for ₹250 online or at Gate 4 kiosks.",
                "bookingWebsite": "https://shrimahakaleshwar.mp.gov.in",
                "dressCode": "Sanctum: Men in Dhoti/Kurta; Women in Saree.",
                "prasadDetails": "Certified Besan Laddu Mahaprasad available at temple counters from ₹70."
            },
            {
                "id": "kal_bhairav",
                "templeId": "kal_bhairav",
                "templeName": "Shri Kal Bhairav Temple",
                "hindiName": "श्री काल भैरव मंदिर",
                "deity": "Lord Kal Bhairav (Tantric & City Guardian)",
                "significance": "Regarded as the Senapati and celestial administrator of Ujjain.",
                "timing": "5:00 AM – 10:00 PM",
                "aartis": [
                    {
                        "name": "Pratah Aarti",
                        "hindiName": "प्रातः आरती",
                        "timingSummer": "6:00 AM",
                        "timingWinter": "6:30 AM",
                        "description": "Morning awakening ritual."
                    }
                ],
                "entryGates": [
                    "Main Toran Gate: Entrance from Bhairavgarh parking"
                ],
                "darshanRoutes": [
                    "Courtyard -> Sanctum Rail -> Blessing -> Exit"
                ],
                "vipFastTrackRules": "Special queue for ₹100 on festival days.",
                "bookingWebsite": "https://ujjain.nic.in/en/tourist-places/",
                "dressCode": "Modest casual or traditional attire.",
                "prasadDetails": "Prasad baskets with coconuts and flowers outside."
            },
            {
                "id": "harsiddhi",
                "templeId": "harsiddhi",
                "templeName": "Maa Harsiddhi Shaktipeeth",
                "hindiName": "माँ हरसिद्धि शक्तिपीठ",
                "deity": "Goddess Harsiddhi (Durga / Mangala)",
                "significance": "13th of 51 Shaktipeeths where Devi Sati's elbow fell.",
                "timing": "5:00 AM – 11:00 PM",
                "aartis": [
                    {
                        "name": "Deepstambh Deepotsav Aarti",
                        "hindiName": "दीपस्तंभ प्रज्वलन एवं महाआरती",
                        "timingSummer": "7:00 PM – 8:00 PM",
                        "timingWinter": "6:30 PM – 7:30 PM",
                        "description": "Lighting of 1008 oil lamps on towering stone pillars."
                    }
                ],
                "entryGates": [
                    "Main East Gate (Facing Rudrasagar pathway)"
                ],
                "darshanRoutes": [
                    "Courtyard -> Deepstambh -> Inner Sanctum -> Exit"
                ],
                "vipFastTrackRules": "Deepstambh sponsorship available via trust desk.",
                "bookingWebsite": "https://ujjain.nic.in/en/places-of-interest/",
                "dressCode": "Traditional Indian attire preferred.",
                "prasadDetails": "Chunari, dried coconuts, and peda prasad."
            }
    # 2. Events / Snan Calendar Table
    cursor.execute("""
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        hindiTitle TEXT,
        date TEXT NOT NULL,
        tithi TEXT,
        significance TEXT,
        hindiSignificance TEXT,
        location TEXT,
        isShahiSnan INTEGER DEFAULT 0,
        type TEXT DEFAULT 'parva_snan',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    """)

    # 3. Stays, Dharamshalas & Transit Table
    cursor.execute("""
      CREATE TABLE IF NOT EXISTS stays (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        hindiName TEXT,
        category TEXT NOT NULL,
        lat REAL,
        lon REAL,
        icon TEXT,
        area TEXT,
        description TEXT,
        hindiDescription TEXT,
        contact TEXT,
        timing TEXT,
        gates TEXT,
        pricing TEXT,
        rating REAL DEFAULT 4.5,
        tags TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    """)
    conn.commit()

    # Seed data if tables are empty
    cursor.execute("SELECT COUNT(*) as count FROM temples")
    if cursor.fetchone()['count'] == 0:
        seed_temples = [
            (
                "mahakaleshwar", "mahakaleshwar", "Shri Mahakaleshwar Jyotirlinga",
                "श्री महाकालेश्वर ज्योतिर्लिंग", "Lord Shiva (Mahakal - Lord of Eternity & Time)",
                "The only Dakshinmukhi (south-facing) Jyotirlinga in the world. Enshrines the continuous Cosmic Lingam and is world-renowned for the daily sacred Bhasma Aarti with fresh sacred ashes.",
                "4:00 AM – 11:00 PM (Temple doors open at 4:00 AM for Bhasma Aarti)",
                json.dumps([
                    {"name": "Bhasma Aarti", "hindiName": "दिव्य भस्म आरती", "timingSummer": "4:00 AM – 6:00 AM", "timingWinter": "4:00 AM – 6:00 AM", "description": "Sacred ash ritual performed before dawn."},
                    {"name": "Sandhya Aarti", "hindiName": "संध्या आरती (सायंकालीन)", "timingSummer": "7:00 PM – 7:45 PM", "timingWinter": "6:30 PM – 7:15 PM", "description": "Grand evening shringar aarti."}
                ], ensure_ascii=False),
                json.dumps(["Gate No. 1: Bhasma Aarti entry", "Gate No. 4: Sheegra Darshan pass entry"], ensure_ascii=False),
                json.dumps(["Mahakal Lok Corridor -> Sabhamandap -> Nandi Hall View -> Sanctum Jaladhari Exit."], ensure_ascii=False),
                "Sheegra Darshan passes available for ₹250 online or at Gate 4 kiosks.",
                "https://shrimahakaleshwar.mp.gov.in",
                "Sanctum: Men in Dhoti/Kurta; Women in Saree.",
                "Certified Besan Laddu Mahaprasad available at temple counters from ₹70."
            ),
            (
                "kal_bhairav", "kal_bhairav", "Shri Kal Bhairav Temple",
                "श्री काल भैरव मंदिर", "Lord Kal Bhairav (Tantric & City Guardian)",
                "Regarded as the Senapati and celestial administrator of Ujjain.",
                "5:00 AM – 10:00 PM",
                json.dumps([{"name": "Pratah Aarti", "hindiName": "प्रातः आरती", "timingSummer": "6:00 AM", "timingWinter": "6:30 AM", "description": "Morning awakening ritual."}], ensure_ascii=False),
                json.dumps(["Main Toran Gate: Entrance from Bhairavgarh parking"], ensure_ascii=False),
                json.dumps(["Courtyard -> Sanctum Rail -> Blessing -> Exit"], ensure_ascii=False),
                "Special queue for ₹100 on festival days.",
                "https://ujjain.nic.in/en/tourist-places/",
                "Modest casual or traditional attire.",
                "Prasad baskets with coconuts and flowers outside."
            ),
            (
                "harsiddhi", "harsiddhi", "Maa Harsiddhi Shaktipeeth",
                "माँ हरसिद्धि शक्तिपीठ", "Goddess Harsiddhi (Durga / Mangala)",
                "13th of 51 Shaktipeeths where Devi Sati's elbow fell.",
                "5:00 AM – 11:00 PM",
                json.dumps([{"name": "Deepstambh Deepotsav Aarti", "hindiName": "दीपस्तंभ प्रज्वलन एवं महाआरती", "timingSummer": "7:00 PM – 8:00 PM", "timingWinter": "6:30 PM – 7:30 PM", "description": "Lighting of 1008 oil lamps on towering stone pillars."}], ensure_ascii=False),
                json.dumps(["Main East Gate (Facing Rudrasagar pathway)"], ensure_ascii=False),
                json.dumps(["Courtyard -> Deepstambh -> Inner Sanctum -> Exit"], ensure_ascii=False),
                "Deepstambh sponsorship available via trust desk.",
                "https://ujjain.nic.in/en/places-of-interest/",
                "Traditional Indian attire preferred.",
                "Chunari, dried coconuts, and peda prasad."
            )
        ]
        write_data('temples', default_temples)
        cursor.executemany("""
          INSERT INTO temples (id, templeId, templeName, hindiName, deity, significance, timing, aartis, entryGates, darshanRoutes, vipFastTrackRules, bookingWebsite, dressCode, prasadDetails)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, seed_temples)
        conn.commit()

    if not os.path.exists(FILES['events']):
        default_events = [
            {
                "id": "event_1",
                "title": "First Shahi Snan (Royal Bath)",
                "hindiTitle": "प्रथम शाही स्नान (महाप्रारंभ)",
                "date": "April 9, 2028 (Sunday)",
                "tithi": "Chaitra Shukla Purnima (चैत्र पूर्णिमा)",
                "significance": "Grand Opening of Simhastha Kumbh Mela 2028. Sacred royal dip led by Akhara Saints and Naga Babas.",
                "hindiSignificance": "सिंहस्थ 2028 का प्रथम शाही स्नान। 13 अखाड़ों के नागा साधुओं एवं संतों द्वारा सूर्योदय पर सर्वप्रथम अमृत डुबकी।",
                "location": "Ram Ghat & Dutt Akhara Ghat, Shipra River",
                "isShahiSnan": True,
                "type": "shahi_snan"
            },
            {
                "id": "event_2",
                "title": "Second Shahi Snan (Vaishakh Amavasya)",
                "hindiTitle": "द्वितीय शाही स्नान (वैशाख अमावस्या)",
                "date": "April 24, 2028 (Monday)",
                "tithi": "Vaishakh Krishna Amavasya (वैशाखी अमावस्या)",
                "significance": "The massive second Royal Bath. High planetary alignment for pitru tarpan and liberation.",
                "hindiSignificance": "द्वितीय महा शाही स्नान। पितृ तर्पण एवं आत्मिक शुद्धि का महापुण्य पर्व।",
                "location": "Ram Ghat, Dutt Akhara & Siddhwat Ghat",
                "isShahiSnan": True,
                "type": "shahi_snan"
            },
            {
                "id": "event_3",
                "title": "Maha Shahi Snan (The Grand Royal Bath)",
                "hindiTitle": "महा शाही स्नान (सिंहस्थ का सर्वोच्च पर्व)",
                "date": "May 8, 2028 (Monday)",
                "tithi": "Vaishakh Shukla Purnima (बुद्ध पूर्णिमा)",
                "significance": "The supreme zenith of Simhastha Ujjain 2028! The largest cosmic congregation of humanity.",
                "hindiSignificance": "सिंहस्थ 2028 का सबसे बड़ा एवं अंतिम महा शाही स्नान। करोड़ों संतों व भक्तों का एक साथ अमृत स्नान।",
                "location": "All Ghats: Ram Ghat, Dutt Akhara, Mangalnath, Narsingha Ghat",
                "isShahiSnan": True,
                "type": "shahi_snan"
            },
            {
                "id": "event_4",
                "title": "Panchkroshi Yatra Pilgrimage",
                "hindiTitle": "पावन 118 किमी पंचक्रोशी यात्रा",
                "date": "April 25 – April 30, 2028",
                "tithi": "Vaishakh Krishna Dashami to Amavasya",
                "significance": "Ancient 118-km barefoot pilgrimage encircling Ujjain across 4 directional Mahadev temples.",
                "hindiSignificance": "उज्जैन के चारों दिशाओं के रक्षक महादेवों की 118 किमी पैदल परिक्रमा।",
                "location": "Starts & ends at Nagchandreshwar (Patni Bazaar)",
                "isShahiSnan": False,
                "type": "program"
            }
    cursor.execute("SELECT COUNT(*) as count FROM events")
    if cursor.fetchone()['count'] == 0:
        seed_events = [
            ("event_1", "First Shahi Snan (Royal Bath)", "प्रथम शाही स्नान (महाप्रारंभ)", "April 9, 2028 (Sunday)", "Chaitra Shukla Purnima (चैत्र पूर्णिमा)", "Grand Opening of Simhastha Kumbh Mela 2028. Sacred royal dip led by Akhara Saints and Naga Babas.", "सिंहस्थ 2028 का प्रथम शाही स्नान। 13 अखाड़ों के नागा साधुओं एवं संतों द्वारा सूर्योदय पर सर्वप्रथम अमृत डुबकी।", "Ram Ghat & Dutt Akhara Ghat, Shipra River", 1, "shahi_snan"),
            ("event_2", "Second Shahi Snan (Vaishakh Amavasya)", "द्वितीय शाही स्नान (वैशाख अमावस्या)", "April 24, 2028 (Monday)", "Vaishakh Krishna Amavasya (वैशाखी अमावस्या)", "The massive second Royal Bath. High planetary alignment for pitru tarpan and liberation.", "द्वितीय महा शाही स्नान। पितृ तर्पण एवं आत्मिक शुद्धि का महापुण्य पर्व।", "Ram Ghat, Dutt Akhara & Siddhwat Ghat", 1, "shahi_snan"),
            ("event_3", "Maha Shahi Snan (The Grand Royal Bath)", "महा शाही स्नान (सिंहस्थ का सर्वोच्च पर्व)", "May 8, 2028 (Monday)", "Vaishakh Shukla Purnima (बुद्ध पूर्णिमा)", "The supreme zenith of Simhastha Ujjain 2028! The largest cosmic congregation of humanity.", "सिंहस्थ 2028 का सबसे बड़ा एवं अंतिम महा शाही स्नान। करोड़ों संतों व भक्तों का एक साथ अमृत स्नान।", "All Ghats: Ram Ghat, Dutt Akhara, Mangalnath, Narsingha Ghat", 1, "shahi_snan"),
            ("event_4", "Panchkroshi Yatra Pilgrimage", "पावन 118 किमी पंचक्रोशी यात्रा", "April 25 – April 30, 2028", "Vaishakh Krishna Dashami to Amavasya", "Ancient 118-km barefoot pilgrimage encircling Ujjain across 4 directional Mahadev temples.", "उज्जैन के चारों दिशाओं के रक्षक महादेवों की 118 किमी पैदल परिक्रमा।", "Starts & ends at Nagchandreshwar (Patni Bazaar)", 0, "program")
        ]
        write_data('events', default_events)
        cursor.executemany("""
          INSERT INTO events (id, title, hindiTitle, date, tithi, significance, hindiSignificance, location, isShahiSnan, type)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, seed_events)
        conn.commit()

    if not os.path.exists(FILES['stays']):
        default_stays = [
            {
                "id": "hotel_shipra_residency",
                "name": "MPT Shipra Residency (MP Tourism)",
                "hindiName": "एमपीटी शिप्रा रेजीडेंसी (म.प्र. पर्यटन)",
                "category": "hotel",
                "lat": 23.1785,
                "lon": 75.7830,
                "icon": "🏨",
                "area": "University Road, Freeganj",
                "timing": "Check-in 12:00 PM • Check-out 11:00 AM",
                "contact": "0734-2551495",
                "pricing": "₹3,000 – ₹7,500 / night",
                "rating": 4.7,
                "description": "Official Madhya Pradesh Tourism luxury hotel with garden, swimming pool, and secure parking.",
                "hindiDescription": "मध्य प्रदेश पर्यटन निगम का प्रतिष्ठित शासकीय हेरिटेज होटल। परिवार हेतु श्रेष्ठ।"
            },
            {
                "id": "mahakal_vishram_dharamshala",
                "name": "Shri Mahakaleshwar Bhakt Niwas",
                "hindiName": "श्री महाकालेश्वर भक्त निवास (मंदिर ट्रस्ट)",
                "category": "dharamshala",
                "lat": 23.1845,
                "lon": 75.7695,
                "icon": "🏢",
                "area": "Near Mahakal Mandir Gate 1",
                "timing": "24 Hours Check-in",
                "contact": "1800-233-1008",
                "pricing": "₹400 – ₹1,200 / night (AC & Non-AC Rooms)",
                "rating": 4.8,
                "description": "Official Temple Trust pilgrim accommodation within 200m walking distance to sanctum.",
                "hindiDescription": "मंदिर समिति द्वारा संचालित सबसे निकटतम एवं स्वच्छ भक्त निवास।"
            },
            {
                "id": "simhastha_tent_city",
                "name": "Simhastha Luxury Tent City & Swiss Cottages",
                "hindiName": "सिंहस्थ लक्जरी टेंट सिटी (म.प्र. पर्यटन)",
                "category": "tent",
                "lat": 23.1950,
                "lon": 75.7600,
                "icon": "⛺",
                "area": "Kshipra Vihar Mela Zone Sector 4",
                "timing": "Simhastha 2028 Season • 24/7 Concierge",
                "contact": "1800-233-7777",
                "pricing": "₹2,500 – ₹8,000 / night",
                "rating": 4.8,
                "description": "Eco-friendly Swiss luxury air-conditioned tents with attached plush washrooms.",
                "hindiDescription": "सिंहस्थ 2028 का विशेष आकर्षण। शिप्रा किनारे वातानुकूलित स्विस टेंट।"
            },
            {
                "id": "ujjain_junction",
                "name": "Ujjain Junction Railway Station (UJN)",
                "hindiName": "उज्जैन जंक्शन रेलवे स्टेशन (UJN)",
                "category": "transport",
                "lat": 23.17954,
                "lon": 75.78195,
                "icon": "🚆",
                "area": "Station Road",
                "timing": "Open 24/7",
                "contact": "139",
                "pricing": "Platform Ticket: ₹10",
                "rating": 4.7,
                "description": "Premier railway hub connecting Ujjain to Mumbai, Delhi, Varanasi, and all corners.",
                "hindiDescription": "उज्जैन का मुख्य रेलवे स्टेशन। 24 घंटे ट्रेन आवागमन।"
            },
            {
                "id": "dewas_gate_bus",
                "name": "Dewas Gate Inter-City Bus Stand",
                "hindiName": "देवास गेट अंतरराज्यीय बस स्टैंड",
                "category": "transport",
                "lat": 23.18093,
                "lon": 75.78238,
                "icon": "🚌",
                "area": "Opposite Railway Station",
                "timing": "Open 24/7",
                "contact": "0734-2550500",
                "pricing": "Indore ₹80, Omkareshwar ₹200",
                "rating": 4.4,
                "description": "Direct air-conditioned electric buses departing every 10 minutes to Indore, Omkareshwar, and Bhopal.",
                "hindiDescription": "इंदौर, ओंकारेश्वर और भोपाल हेतु हर 10 मिनट में बसें उपलब्ध।"
            },
            {
                "id": "parking_karkraj",
                "name": "Karkraj Multi-Level & Ground Parking",
                "hindiName": "कर्कराज विशाल वाहन पार्किंग (महाकाल लोक)",
                "category": "parking",
                "lat": 23.1788,
                "lon": 75.7645,
                "icon": "🅿️",
                "area": "Near Karkraj Temple & Mahakal Lok Gate 4",
                "timing": "Open 24/7 with Free E-Cart Shuttle to Temple",
                "pricing": "Two-Wheeler: ₹20 • Car/SUV: ₹50 for 8 hrs",
                "rating": 4.7,
                "description": "Flagship smart parking facility accommodating 3,000+ four-wheelers with EV charging points.",
                "hindiDescription": "3000+ कारों की क्षमता वाली विशाल पार्किंग। महाकाल मंदिर तक निःशुल्क ई-रिक्शा।"
            }
    cursor.execute("SELECT COUNT(*) as count FROM stays")
    if cursor.fetchone()['count'] == 0:
        seed_stays = [
            ("hotel_shipra_residency", "MPT Shipra Residency (MP Tourism)", "एमपीटी शिप्रा रेजीडेंसी (म.प्र. पर्यटन)", "hotel", 23.1785, 75.7830, "🏨", "University Road, Freeganj", "Official Madhya Pradesh Tourism luxury hotel with garden, swimming pool, and secure parking.", "मध्य प्रदेश पर्यटन निगम का प्रतिष्ठित शासकीय हेरिटेज होटल। परिवार हेतु श्रेष्ठ।", "0734-2551495", "Check-in 12:00 PM • Check-out 11:00 AM", "Main Porch", "₹3,000 – ₹7,500 / night", 4.7, "[]"),
            ("mahakal_vishram_dharamshala", "Shri Mahakaleshwar Bhakt Niwas", "श्री महाकालेश्वर भक्त निवास (मंदिर ट्रस्ट)", "dharamshala", 23.1845, 75.7695, "🏢", "Near Mahakal Mandir Gate 1", "Official Temple Trust pilgrim accommodation within 200m walking distance to sanctum.", "मंदिर समिति द्वारा संचालित सबसे निकटतम एवं स्वच्छ भक्त निवास।", "1800-233-1008", "24 Hours Check-in", "Reception Gate", "₹400 – ₹1,200 / night (AC & Non-AC Rooms)", 4.8, "[]"),
            ("simhastha_tent_city", "Simhastha Luxury Tent City & Swiss Cottages", "सिंहस्थ लक्जरी टेंट सिटी (म.प्र. पर्यटन)", "tent", 23.1950, 75.7600, "⛺", "Kshipra Vihar Mela Zone Sector 4", "Eco-friendly Swiss luxury air-conditioned tents with attached plush washrooms.", "सिंहस्थ 2028 का विशेष आकर्षण। शिप्रा किनारे वातानुकूलित स्विस टेंट।", "1800-233-7777", "Simhastha 2028 Season • 24/7 Concierge", "Main Archway", "₹2,500 – ₹8,000 / night", 4.8, "[]"),
            ("ujjain_junction", "Ujjain Junction Railway Station (UJN)", "उज्जैन जंक्शन रेलवे स्टेशन (UJN)", "transport", 23.17954, 75.78195, "🚆", "Station Road", "Premier railway hub connecting Ujjain to Mumbai, Delhi, Varanasi, and all corners.", "उज्जैन का मुख्य रेलवे स्टेशन। 24 घंटे ट्रेन आवागमन।", "139", "Open 24/7", "Platform 1 & 4", "Platform Ticket: ₹10", 4.7, "[]"),
            ("dewas_gate_bus", "Dewas Gate Inter-City Bus Stand", "देवास गेट अंतरराज्यीय बस स्टैंड", "transport", 23.18093, 75.78238, "🚌", "Opposite Railway Station", "Direct air-conditioned electric buses departing every 10 minutes to Indore, Omkareshwar, and Bhopal.", "इंदौर, ओंकारेश्वर और भोपाल हेतु हर 10 मिनट में बसें उपलब्ध।", "0734-2550500", "Open 24/7", "Bays 1-12", "Indore ₹80, Omkareshwar ₹200", 4.4, "[]"),
            ("parking_karkraj", "Karkraj Multi-Level & Ground Parking", "कर्कराज विशाल वाहन पार्किंग (महाकाल लोक)", "parking", 23.1788, 75.7645, "🅿️", "Near Karkraj Temple & Mahakal Lok Gate 4", "Flagship smart parking facility accommodating 3,000+ four-wheelers with EV charging points.", "3000+ कारों की क्षमता वाली विशाल पार्किंग। महाकाल मंदिर तक निःशुल्क ई-रिक्शा।", "", "Open 24/7 with Free E-Cart Shuttle to Temple", "Entry 1 & 2", "Two-Wheeler: ₹20 • Car/SUV: ₹50 for 8 hrs", 4.7, "[]")
        ]
        write_data('stays', default_stays)
        cursor.executemany("""
          INSERT INTO stays (id, name, hindiName, category, lat, lon, icon, area, description, hindiDescription, contact, timing, gates, pricing, rating, tags)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, seed_stays)
        conn.commit()

init_seed_data()
    conn.close()

class SimhasthaHandler(BaseHTTPRequestHandler):
init_sql_database()

def row_to_dict(table, row):
    d = dict(row)
    if table == 'temples':
        for key in ('aartis', 'entryGates', 'darshanRoutes'):
            if key in d and isinstance(d[key], str):
                try: d[key] = json.loads(d[key])
                except: d[key] = []
    elif table == 'events':
        d['isShahiSnan'] = bool(d.get('isShahiSnan'))
    elif table == 'stays':
        if 'tags' in d and isinstance(d['tags'], str):
            try: d['tags'] = json.loads(d['tags'])
            except: d['tags'] = []
    return d

class SqlApiHandler(BaseHTTPRequestHandler):
    def _set_cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')

    def do_OPTIONS(self):
        self.send_response(204)
        self._set_cors()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path in ('/', '/admin', '/index.html'):
            index_file = os.path.join(PUBLIC_DIR, 'index.html')
            if os.path.exists(index_file):
                self.send_response(200)
                self._set_cors()
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()
                with open(index_file, 'rb') as f:
                    self.wfile.write(f.read())
                return

        # Check API
        parts = [p for p in path.split('/') if p]
        if len(parts) >= 2 and parts[0] == 'api' and parts[1] in FILES:
            resource = parts[1]
        if len(parts) >= 2 and parts[0] == 'api' and parts[1] in ('temples', 'events', 'stays', 'context'):
            table = 'knowledge_context' if parts[1] == 'context' else parts[1]
            item_id = parts[2] if len(parts) > 2 else None
            items = read_data(resource)
            conn = get_db()
            cursor = conn.cursor()

            if item_id:
                found = next((x for x in items if x.get('id') == item_id or x.get('templeId') == item_id), None)
                if found:
                if table == 'temples':
                    cursor.execute("SELECT * FROM temples WHERE id = ? OR templeId = ?", (item_id, item_id))
                else:
                    cursor.execute(f"SELECT * FROM {table} WHERE id = ?", (item_id,))
                row = cursor.fetchone()
                conn.close()
                if row:
                    self.send_response(200)
                    self._set_cors()
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps(found, ensure_ascii=False).encode('utf-8'))
                    self.wfile.write(json.dumps(row_to_dict(table, row), ensure_ascii=False).encode('utf-8'))
                else:
                    self.send_response(404)
                    self._set_cors()
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps({'error': 'Item not found'}).encode('utf-8'))
            else:
                cursor.execute(f"SELECT * FROM {table} ORDER BY created_at DESC")
                rows = cursor.fetchall()
                conn.close()
                results = [row_to_dict(table, r) for r in rows]
                self.send_response(200)
                self._set_cors()
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(items, ensure_ascii=False).encode('utf-8'))
                self.wfile.write(json.dumps(results, ensure_ascii=False).encode('utf-8'))
            return

        self.send_response(404)
        self._set_cors()
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'error': 'Not found'}).encode('utf-8'))

    def do_POST(self):
        parts = [p for p in self.path.split('/') if p]
        if len(parts) == 2 and parts[0] == 'api' and parts[1] in FILES:
            resource = parts[1]
        if len(parts) == 2 and parts[0] == 'api' and parts[1] in ('temples', 'events', 'stays'):
            table = parts[1]
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length).decode('utf-8')
            payload = json.loads(body) if body else {}

            if not payload.get('id'):
                payload['id'] = f"{resource[:3]}_{int(os.times().elapsed * 1000)}"
            if resource == 'temples' and not payload.get('templeId'):
                payload['templeId'] = payload['id']
            item_id = payload.get('id') or f"{table[:3]}_{int(os.times().elapsed * 1000)}"
            payload['id'] = item_id

            items = read_data(resource)
            items.insert(0, payload)
            write_data(resource, items)
            conn = get_db()
            cursor = conn.cursor()

            if table == 'temples':
                sql = """
                  INSERT INTO temples (id, templeId, templeName, hindiName, deity, significance, timing, aartis, entryGates, darshanRoutes, vipFastTrackRules, bookingWebsite, dressCode, prasadDetails)
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(sql, (
                    item_id, payload.get('templeId') or item_id, payload.get('templeName', ''),
                    payload.get('hindiName', ''), payload.get('deity', ''), payload.get('significance', ''),
                    payload.get('timing', ''), json.dumps(payload.get('aartis', []), ensure_ascii=False),
                    json.dumps(payload.get('entryGates', []), ensure_ascii=False),
                    json.dumps(payload.get('darshanRoutes', []), ensure_ascii=False),
                    payload.get('vipFastTrackRules', ''), payload.get('bookingWebsite', ''),
                    payload.get('dressCode', ''), payload.get('prasadDetails', '')
                ))
            elif table == 'events':
                sql = """
                  INSERT INTO events (id, title, hindiTitle, date, tithi, significance, hindiSignificance, location, isShahiSnan, type)
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(sql, (
                    item_id, payload.get('title', ''), payload.get('hindiTitle', ''),
                    payload.get('date', ''), payload.get('tithi', ''), payload.get('significance', ''),
                    payload.get('hindiSignificance', ''), payload.get('location', ''),
                    1 if payload.get('isShahiSnan') else 0, payload.get('type', 'parva_snan')
                ))
            elif table == 'stays':
                sql = """
                  INSERT INTO stays (id, name, hindiName, category, lat, lon, icon, area, description, hindiDescription, contact, timing, gates, pricing, rating, tags)
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(sql, (
                    item_id, payload.get('name', ''), payload.get('hindiName', ''),
                    payload.get('category', 'hotel'), float(payload.get('lat', 23.18)), float(payload.get('lon', 75.77)),
                    payload.get('icon', '🏨'), payload.get('area', ''), payload.get('description', ''),
                    payload.get('hindiDescription', ''), payload.get('contact', ''), payload.get('timing', ''),
                    payload.get('gates', ''), payload.get('pricing', ''), float(payload.get('rating', 4.5)),
                    json.dumps(payload.get('tags', []), ensure_ascii=False)
                ))

            conn.commit()
            conn.close()

            self.send_response(201)
            self._set_cors()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'success': True, 'item': payload}, ensure_ascii=False).encode('utf-8'))
            return

        self.send_response(400)
        self._set_cors()
        self.end_headers()

    def do_PUT(self):
        parts = [p for p in self.path.split('/') if p]
        if len(parts) == 3 and parts[0] == 'api' and parts[1] in FILES:
            resource = parts[1]
        if len(parts) == 3 and parts[0] == 'api' and parts[1] in ('temples', 'events', 'stays'):
            table = parts[1]
            item_id = parts[2]
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length).decode('utf-8')
            payload = json.loads(body) if body else {}

            items = read_data(resource)
            idx = next((i for i, x in enumerate(items) if x.get('id') == item_id or x.get('templeId') == item_id), -1)
            if idx == -1:
                self.send_response(404)
                self._set_cors()
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Item not found'}).encode('utf-8'))
                return
            conn = get_db()
            cursor = conn.cursor()

            items[idx].update(payload)
            items[idx]['id'] = item_id
            write_data(resource, items)
            if table == 'temples':
                sql = """
                  UPDATE temples SET templeName = ?, hindiName = ?, deity = ?, significance = ?, timing = ?,
                  vipFastTrackRules = ?, bookingWebsite = ?, dressCode = ?, prasadDetails = ?
                  WHERE id = ? OR templeId = ?
                """
                cursor.execute(sql, (
                    payload.get('templeName', ''), payload.get('hindiName', ''), payload.get('deity', ''),
                    payload.get('significance', ''), payload.get('timing', ''), payload.get('vipFastTrackRules', ''),
                    payload.get('bookingWebsite', ''), payload.get('dressCode', ''), payload.get('prasadDetails', ''),
                    item_id, item_id
                ))
            elif table == 'events':
                sql = """
                  UPDATE events SET title = ?, hindiTitle = ?, date = ?, tithi = ?, significance = ?,
                  hindiSignificance = ?, location = ?, isShahiSnan = ?
                  WHERE id = ?
                """
                cursor.execute(sql, (
                    payload.get('title', ''), payload.get('hindiTitle', ''), payload.get('date', ''),
                    payload.get('tithi', ''), payload.get('significance', ''), payload.get('hindiSignificance', ''),
                    payload.get('location', ''), 1 if payload.get('isShahiSnan') else 0, item_id
                ))
            elif table == 'stays':
                sql = """
                  UPDATE stays SET name = ?, hindiName = ?, category = ?, icon = ?, area = ?, description = ?,
                  contact = ?, pricing = ?
                  WHERE id = ?
                """
                cursor.execute(sql, (
                    payload.get('name', ''), payload.get('hindiName', ''), payload.get('category', 'hotel'),
                    payload.get('icon', '🏨'), payload.get('area', ''), payload.get('description', ''),
                    payload.get('contact', ''), payload.get('pricing', ''), item_id
                ))

            conn.commit()
            conn.close()

            self.send_response(200)
            self._set_cors()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'success': True, 'item': items[idx]}, ensure_ascii=False).encode('utf-8'))
            self.wfile.write(json.dumps({'success': True, 'item': {**payload, 'id': item_id}}, ensure_ascii=False).encode('utf-8'))
            return

        self.send_response(400)
        self._set_cors()
        self.end_headers()

    def do_DELETE(self):
        parts = [p for p in self.path.split('/') if p]
        if len(parts) == 3 and parts[0] == 'api' and parts[1] in FILES:
            resource = parts[1]
        if len(parts) == 3 and parts[0] == 'api' and parts[1] in ('temples', 'events', 'stays'):
            table = parts[1]
            item_id = parts[2]
            items = read_data(resource)
            filtered = [x for x in items if x.get('id') != item_id and x.get('templeId') != item_id]
            conn = get_db()
            cursor = conn.cursor()
            if table == 'temples':
                cursor.execute("DELETE FROM temples WHERE id = ? OR templeId = ?", (item_id, item_id))
            else:
                cursor.execute(f"DELETE FROM {table} WHERE id = ?", (item_id,))
            conn.commit()
            conn.close()

            if len(filtered) == len(items):
                self.send_response(404)
                self._set_cors()
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Item not found'}).encode('utf-8'))
                return

            write_data(resource, filtered)
            self.send_response(200)
            self._set_cors()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'success': True, 'message': 'Deleted successfully'}).encode('utf-8'))
            self.wfile.write(json.dumps({'success': True, 'message': 'Deleted from SQL database'}).encode('utf-8'))
            return

        self.send_response(400)
        self._set_cors()
        self.end_headers()

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), SimhasthaHandler)
    server = HTTPServer(('0.0.0.0', PORT), SqlApiHandler)
    print("=======================================================")
    print("Simhastha Ujjain 2028 Backend and Admin Portal Live")
    print("Simhastha Ujjain 2028 SQLite SQL Backend Running")
    print(f"Port: {PORT}")
    print(f"Admin Dashboard: http://localhost:{PORT}/admin")
    print("REST APIs: /api/temples, /api/events, /api/stays")
    print(f"Admin Portal: http://localhost:{PORT}/admin")
    print(f"Database File: {DB_PATH}")
    print("=======================================================")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
