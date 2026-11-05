-- ===============================================================
-- Simhastha Ujjain 2028 - MySQL Database Schema & Initial Seeds
-- ===============================================================

CREATE DATABASE IF NOT EXISTS `simhastha_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `simhastha_db`;

-- 1. Temples Table
CREATE TABLE IF NOT EXISTS `temples` (
  `id` VARCHAR(100) PRIMARY KEY,
  `templeId` VARCHAR(100) NOT NULL,
  `templeName` VARCHAR(255) NOT NULL,
  `hindiName` VARCHAR(255) NOT NULL,
  `deity` VARCHAR(255),
  `significance` TEXT,
  `timing` VARCHAR(255),
  `imageUrl` TEXT,
  `aartis` JSON,
  `entryGates` JSON,
  `darshanRoutes` JSON,
  `vipFastTrackRules` TEXT,
  `bookingWebsite` VARCHAR(255),
  `dressCode` TEXT,
  `prasadDetails` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Events & Snan Calendar Table
CREATE TABLE IF NOT EXISTS `events` (
  `id` VARCHAR(100) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `hindiTitle` VARCHAR(255) NOT NULL,
  `date` VARCHAR(100) NOT NULL,
  `tithi` VARCHAR(150),
  `significance` TEXT,
  `hindiSignificance` TEXT,
  `location` VARCHAR(255),
  `isShahiSnan` TINYINT(1) DEFAULT 0,
  `type` VARCHAR(50) DEFAULT 'parva_snan',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Stays, Dharamshalas & Transit Table
CREATE TABLE IF NOT EXISTS `stays` (
  `id` VARCHAR(100) PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `hindiName` VARCHAR(255) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `lat` DECIMAL(10, 6),
  `lon` DECIMAL(10, 6),
  `icon` VARCHAR(20),
  `area` VARCHAR(255),
  `description` TEXT,
  `hindiDescription` TEXT,
  `contact` VARCHAR(100),
  `timing` VARCHAR(255),
  `gates` VARCHAR(255),
  `pricing` VARCHAR(255),
  `rating` DECIMAL(3, 1) DEFAULT 4.5,
  `tags` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================================================
-- Initial Seed Data
-- ===============================================================

INSERT IGNORE INTO `temples` (`id`, `templeId`, `templeName`, `hindiName`, `deity`, `significance`, `timing`, `aartis`, `entryGates`, `darshanRoutes`, `vipFastTrackRules`, `bookingWebsite`, `dressCode`, `prasadDetails`)
INSERT IGNORE INTO `temples` (`id`, `templeId`, `templeName`, `hindiName`, `deity`, `significance`, `timing`, `imageUrl`, `aartis`, `entryGates`, `darshanRoutes`, `vipFastTrackRules`, `bookingWebsite`, `dressCode`, `prasadDetails`)
VALUES 
(
  'mahakaleshwar', 'mahakaleshwar', 'Shri Mahakaleshwar Jyotirlinga', 'श्री महाकालेश्वर ज्योतिर्लिंग',
  'Lord Shiva (Mahakal - Lord of Eternity & Time)',
  'The only Dakshinmukhi (south-facing) Jyotirlinga in the world. Enshrines the continuous Cosmic Lingam and is world-renowned for the daily sacred Bhasma Aarti with fresh sacred ashes.',
  '4:00 AM – 11:00 PM (Temple doors open at 4:00 AM for Bhasma Aarti)',
  'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop',
  '[{"name": "Bhasma Aarti", "hindiName": "दिव्य भस्म आरती", "timingSummer": "4:00 AM – 6:00 AM", "timingWinter": "4:00 AM – 6:00 AM", "description": "Sacred ash ritual performed before dawn."}, {"name": "Sandhya Aarti", "hindiName": "संध्या आरती (सायंकालीन)", "timingSummer": "7:00 PM – 7:45 PM", "timingWinter": "6:30 PM – 7:15 PM", "description": "Grand evening shringar aarti."}]',
  '["Gate No. 1 (Nandi Dwar): Bhasma Aarti pilgrims", "Gate No. 4: Sheegra Darshan & VIP pass entry"]',
  '["Mahakal Lok Corridor -> Sabhamandap -> Nandi Hall View -> Sanctum Jaladhari Exit."]',
  'Sheegra Darshan passes available for ₹250 online or at Gate 4 kiosks.',
  'https://shrimahakaleshwar.mp.gov.in',
  'Sanctum: Men in Dhoti/Kurta; Women in Saree.',
  'Certified Besan Laddu Mahaprasad available at temple counters from ₹70.'
),
(
  'kal_bhairav', 'kal_bhairav', 'Shri Kal Bhairav Temple', 'श्री काल भैरव मंदिर',
  'Lord Kal Bhairav (Tantric & City Guardian)',
  'Regarded as the Senapati and celestial administrator of Ujjain.',
  '5:00 AM – 10:00 PM',
  'https://images.unsplash.com/photo-1626014303757-6564477318f7?q=80&w=1200&auto=format&fit=crop',
  '[{"name": "Pratah Aarti", "hindiName": "प्रातः आरती", "timingSummer": "6:00 AM", "timingWinter": "6:30 AM", "description": "Morning awakening ritual."}]',
  '["Main Toran Gate: Entrance from Bhairavgarh parking"]',
  '["Courtyard -> Sanctum Rail -> Blessing -> Exit"]',
  'Special queue for ₹100 on festival days.',
  'https://ujjain.nic.in/en/tourist-places/',
  'Modest casual or traditional attire.',
  'Prasad baskets with coconuts and flowers outside.'
),
(
  'harsiddhi', 'harsiddhi', 'Maa Harsiddhi Shaktipeeth', 'माँ हरसिद्धि शक्तिपीठ',
  'Goddess Harsiddhi (Durga / Mangala)',
  '13th of 51 Shaktipeeths where Devi Sati\'s elbow fell.',
  '5:00 AM – 11:00 PM',
  'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=1200&auto=format&fit=crop',
  '[{"name": "Deepstambh Deepotsav Aarti", "hindiName": "दीपस्तंभ प्रज्वलन एवं महाआरती", "timingSummer": "7:00 PM – 8:00 PM", "timingWinter": "6:30 PM – 7:30 PM", "description": "Lighting of 1008 oil lamps on towering stone pillars."}]',
  '["Main East Gate (Facing Rudrasagar pathway)"]',
  '["Courtyard -> Deepstambh -> Inner Sanctum -> Exit"]',
  'Deepstambh sponsorship available via trust desk.',
  'https://ujjain.nic.in/en/places-of-interest/',
  'Traditional Indian attire preferred.',
  'Chunari, dried coconuts, and peda prasad.'
);

INSERT IGNORE INTO `events` (`id`, `title`, `hindiTitle`, `date`, `tithi`, `significance`, `hindiSignificance`, `location`, `isShahiSnan`, `type`)
VALUES
('event_1', 'First Shahi Snan (Royal Bath)', 'प्रथम शाही स्नान (महाप्रारंभ)', 'April 9, 2028 (Sunday)', 'Chaitra Shukla Purnima (चैत्र पूर्णिमा)', 'Grand Opening of Simhastha Kumbh Mela 2028. Sacred royal dip led by Akhara Saints and Naga Babas.', 'सिंहस्थ 2028 का प्रथम शाही स्नान। 13 अखाड़ों के नागा साधुओं एवं संतों द्वारा सूर्योदय पर सर्वप्रथम अमृत डुबकी।', 'Ram Ghat & Dutt Akhara Ghat, Shipra River', 1, 'shahi_snan'),
('event_2', 'Second Shahi Snan (Vaishakh Amavasya)', 'द्वितीय शाही स्नान (वैशाख अमावस्या)', 'April 24, 2028 (Monday)', 'Vaishakh Krishna Amavasya (वैशाखी अमावस्या)', 'The massive second Royal Bath. High planetary alignment for pitru tarpan and liberation.', 'द्वितीय महा शाही स्नान। पितृ तर्पण एवं आत्मिक शुद्धि का महापुण्य पर्व।', 'Ram Ghat, Dutt Akhara & Siddhwat Ghat', 1, 'shahi_snan'),
('event_3', 'Maha Shahi Snan (The Grand Royal Bath)', 'महा शाही स्नान (सिंहस्थ का सर्वोच्च पर्व)', 'May 8, 2028 (Monday)', 'Vaishakh Shukla Purnima (बुद्ध पूर्णिमा)', 'The supreme zenith of Simhastha Ujjain 2028! The largest cosmic congregation of humanity.', 'सिंहस्थ 2028 का सबसे बड़ा एवं अंतिम महा शाही स्नान। करोड़ों संतों व भक्तों का एक साथ अमृत स्नान।', 'All Ghats: Ram Ghat, Dutt Akhara, Mangalnath, Narsingha Ghat', 1, 'shahi_snan'),
('event_4', 'Panchkroshi Yatra Pilgrimage', 'पावन 118 किमी पंचक्रोशी यात्रा', 'April 25 – April 30, 2028', 'Vaishakh Krishna Dashami to Amavasya', 'Ancient 118-km barefoot pilgrimage encircling Ujjain across 4 directional Mahadev temples.', 'उज्जैन के चारों दिशाओं के रक्षक महादेवों की 118 किमी पैदल परिक्रमा।', 'Starts & ends at Nagchandreshwar (Patni Bazaar)', 0, 'program');

INSERT IGNORE INTO `stays` (`id`, `name`, `hindiName`, `category`, `lat`, `lon`, `icon`, `area`, `description`, `hindiDescription`, `contact`, `timing`, `pricing`, `rating`, `tags`)
VALUES
('hotel_shipra_residency', 'MPT Shipra Residency (MP Tourism)', 'एमपीटी शिप्रा रेजीडेंसी (म.प्र. पर्यटन)', 'hotel', 23.178500, 75.783000, '🏨', 'University Road, Freeganj', 'Official Madhya Pradesh Tourism luxury hotel with garden, swimming pool, and secure parking.', 'मध्य प्रदेश पर्यटन निगम का प्रतिष्ठित शासकीय हेरिटेज होटल। परिवार हेतु श्रेष्ठ।', '0734-2551495', 'Check-in 12:00 PM • Check-out 11:00 AM', '₹3,000 – ₹7,500 / night', 4.7, '[]'),
('mahakal_vishram_dharamshala', 'Shri Mahakaleshwar Bhakt Niwas', 'श्री महाकालेश्वर भक्त निवास (मंदिर ट्रस्ट)', 'dharamshala', 23.184500, 75.769500, '🏢', 'Near Mahakal Mandir Gate 1', 'Official Temple Trust pilgrim accommodation within 200m walking distance to sanctum.', 'मंदिर समिति द्वारा संचालित सबसे निकटतम एवं स्वच्छ भक्त निवास।', '1800-233-1008', '24 Hours Check-in', '₹400 – ₹1,200 / night (AC & Non-AC Rooms)', 4.8, '[]'),
('simhastha_tent_city', 'Simhastha Luxury Tent City & Swiss Cottages', 'सिंहस्थ लक्जरी टेंट सिटी (म.प्र. पर्यटन)', 'tent', 23.195000, 75.760000, '⛺', 'Kshipra Vihar Mela Zone Sector 4', 'Eco-friendly Swiss luxury air-conditioned tents with attached plush washrooms.', 'सिंहस्थ 2028 का विशेष आकर्षण। शिप्रा किनारे वातानुकूलित स्विस टेंट।', '1800-233-7777', 'Simhastha 2028 Season • 24/7 Concierge', '₹2,500 – ₹8,000 / night', 4.8, '[]'),
('ujjain_junction', 'Ujjain Junction Railway Station (UJN)', 'उज्जैन जंक्शन रेलवे स्टेशन (UJN)', 'transport', 23.179540, 75.781950, '🚆', 'Station Road', 'Premier railway hub connecting Ujjain to Mumbai, Delhi, Varanasi, and all corners.', 'उज्जैन का मुख्य रेलवे स्टेशन। 24 घंटे ट्रेन आवागमन।', '139', 'Open 24/7', 'Platform Ticket: ₹10', 4.7, '[]'),
('dewas_gate_bus', 'Dewas Gate Inter-City Bus Stand', 'देवास गेट अंतरराज्यीय बस स्टैंड', 'transport', 23.180930, 75.782380, '🚌', 'Opposite Railway Station', 'Direct air-conditioned electric buses departing every 10 minutes to Indore, Omkareshwar, and Bhopal.', 'इंदौर, ओंकारेश्वर और भोपाल हेतु हर 10 मिनट में बसें उपलब्ध।', '0734-2550500', 'Open 24/7', 'Indore ₹80, Omkareshwar ₹200', 4.4, '[]'),
('parking_karkraj', 'Karkraj Multi-Level & Ground Parking', 'कर्कराज विशाल वाहन पार्किंग (महाकाल लोक)', 'parking', 23.178800, 75.764500, '🅿️', 'Near Karkraj Temple & Mahakal Lok Gate 4', 'Flagship smart parking facility accommodating 3,000+ four-wheelers with EV charging points.', '3000+ कारों की क्षमता वाली विशाल पार्किंग। महाकाल मंदिर तक निःशुल्क ई-रिक्शा।', '', 'Open 24/7 with Free E-Cart Shuttle to Temple', 'Two-Wheeler: ₹20 • Car/SUV: ₹50 for 8 hrs', 4.7, '[]');



-- 4. AI Knowledge Context Table
CREATE TABLE IF NOT EXISTS `knowledge_context` (
  `id` VARCHAR(100) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `category` VARCHAR(100) NOT NULL,
  `content` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `knowledge_context` (`id`, `title`, `category`, `content`)
VALUES ('mahakaleshwar_temple', 'Mahakaleshwar Temple, Ujjain – AI Tourist Assistant Knowledge Context', 'temple_guide', '# Mahakaleshwar Temple, Ujjain – AI Tourist Assistant Knowledge Context

## 1. About Mahakaleshwar Temple
Shri Mahakaleshwar Jyotirlinga Temple is one of the twelve sacred Jyotirlingas of Lord Shiva and is located in Ujjain, Madhya Pradesh. It is one of the most important pilgrimage destinations in India. The temple is especially famous for its Bhasma Aarti, which takes place early in the morning. The deity is worshipped as Mahakal, the Lord of Time. The temple attracts devotees throughout the year, particularly during Mahashivratri, the holy month of Shravan, and the annual Mahakal Sawari.
The temple is situated in the old city area of Ujjain. Visitors can reach it by auto-rickshaw, e-rickshaw, taxi, or local transport. The temple''s official website is https://www.shrimahakaleshwar.mp.gov.in/.

## 2. Darshan and VIP Darshan
Devotees can visit Mahakaleshwar Temple for regular darshan. VIP or Sheeghra Darshan may be available through arrangements announced by the temple administration. The indicative VIP Darshan charge supplied for this knowledge base is ₹250 per person. This amount is user-provided and must be verified against the latest official temple notification before informing visitors that it is the current fee. Do not guarantee VIP access or a particular waiting time.
Visitors should check the official temple website for current darshan arrangements, entry gates, restrictions, and special-day arrangements.

## 3. Daily Aarti Schedule
Mahakaleshwar Temple traditionally conducts five main Aartis during the day. The published timings vary according to the Hindu calendar season.
Chaitra Krishna Pratipada to Ashwin Purnima:
- Bhasma Aarti: 4:00 AM to 6:00 AM
- Dadyodak / Bal Bhog Aarti: 7:00 AM to 7:45 AM
- Bhog Aarti: 10:00 AM to 10:45 AM
- Sandhya Aarti: 7:00 PM to 7:45 PM
- Shayan Aarti: 10:30 PM to 11:00 PM

Kartik Krishna Pratipada to Phalgun Purnima:
- Bhasma Aarti: 4:00 AM to 6:00 AM
- Dadyodak Aarti: 7:30 AM to 8:15 AM
- Bhog Aarti: 10:30 AM to 11:15 AM
- Sandhya Aarti: 6:30 PM to 7:15 PM
- Shayan Aarti: 10:30 PM to 11:00 PM
These are published seasonal timings, not a guarantee of the schedule on every date. Aarti timings and entry arrangements can change during festivals, special occasions, and administrative updates. Always check the latest official schedule before advising a visitor.

## 4. Bhasma Aarti Booking
Bhasma Aarti is one of the most distinctive religious ceremonies at Mahakaleshwar Temple. It takes place early in the morning and attracts devotees from across India. Visitors generally need to follow the temple''s booking and entry process.
The official Bhasma Aarti booking page is:
https://www.shrimahakaleshwar.mp.gov.in/services/bhasmaarti
Visitors should check the official portal for available dates, booking windows, identity document requirements, reporting time, dress code, and entry instructions. Booking availability and rules can change. Never promise a confirmed booking or suggest that a visitor can enter without following the current rules.
For assistance, visitors can contact the temple helpdesk using the published contact details: 1800-233-1008, 0734-2550563, or 0734-2559277. The published email address is office@mahakaleshwar.nic.in. Visitors should verify that these contact details are still active.

## 5. Mahakal Lok
Mahakal Lok is a major religious and tourism development surrounding the Mahakaleshwar Temple. It provides a large landscaped corridor with sculptures, murals, pillars, and representations of stories associated with Lord Shiva. The development includes 108 decorative pillars, 192 statues, and 53 murals, with the main corridor extending for more than 900 metres.
Mahakal Lok is an important place for visitors to explore before or after temple darshan. Published visitor-hour information has listed timings of approximately 6:00 AM to 10:00 PM and free entry, but visitors should confirm current access arrangements, timings, and any special restrictions locally.

## 6. How to Reach Mahakal Temple from Transport Hubs
Ujjain Railway Station is approximately 2 km from Mahakaleshwar Temple. Visitors can use an auto-rickshaw, e-rickshaw, taxi, or other local transport.
Indicative auto-rickshaw and e-rickshaw fares supplied for this knowledge base:
- Ujjain Railway Station to Mahakal Temple: approximately ₹50 minimum to ₹100 maximum.
- Nanakheda Bus Stand to Mahakal Temple: approximately ₹100 minimum to ₹180 maximum.
These are approximate local fare estimates, not fixed or government-notified fares. The actual fare may depend on the vehicle, time, traffic, luggage, passenger count, demand, and whether the ride is shared or private. Visitors should confirm the fare with the driver before starting the journey.
Dewas Gate Bus Stand is another important bus terminal in Ujjain. Visitors arriving there can use an auto-rickshaw or e-rickshaw to reach Mahakal Temple. Confirm the fare locally rather than assuming a fixed rate.
For reference, published city transport information has listed Ujjain Railway Station to Dewas Gate Bus Stand at approximately 0.6 km and Ujjain Railway Station to Nanakheda Bus Stand at approximately 5 km. These are distances from the railway station to the bus stands, not from Mahakal Temple. Use a live map or local route information for accurate journey distances and travel times.

## 7. Major Temples and Tourist Attractions Near Mahakal
Ujjain has several important religious and historical places. Visitors can combine these attractions into a one-day or two-day sightseeing plan.
- Harsiddhi Mata Temple: A famous Shakti temple located close to Mahakaleshwar Temple. It is known for its distinctive lamp pillars and is frequently visited by Mahakal devotees.
- Ram Ghat: A sacred bathing ghat on the Shipra River. Visitors come here for religious rituals and to experience the evening Shipra Aarti. It is an important stop during a Ujjain pilgrimage.
- Kal Bhairav Temple: A famous temple dedicated to Kal Bhairav, an important form of Lord Shiva. It is approximately 4 km from the central city area. Visitors can reach it by auto-rickshaw, e-rickshaw, taxi, or local transport.
- Mangalnath Temple: A well-known temple associated with Lord Mangal and religious traditions related to astrology. It is approximately 5 km from the central city area. Visitors can use local autos or taxis.
- Chintaman Ganesh Temple: An important temple dedicated to Lord Ganesha, approximately 7 km from the central city area. It can be reached by auto-rickshaw, taxi, or other local transport.
- Sandipani Ashram: A religious and historical site associated with the traditional account of Lord Krishna, Balram, and Sudama studying under Guru Sandipani. Visitors can include it in a local sightseeing route.
- Bhartrihari Caves: A historical and religious attraction associated with the saint Bhartrihari. It is a popular sightseeing stop near the Shipra River area.
- Siddhavat: A sacred religious site known for its ancient banyan tree and associated rituals. It is located outside the immediate Mahakal Temple area.
- Vedh Shala (Ujjain Observatory): A historical astronomical observatory associated with Ujjain''s contribution to Indian astronomy. It is approximately 1 km from the central city area.
- Kaliadeh Palace: A historical site situated near the Shipra River, known for its architecture and surroundings. It is farther from the main temple area and is better visited by taxi or private vehicle.
Distances mentioned above are approximate city-level references, not exact gate-to-gate distances from Mahakaleshwar Temple. An AI assistant should use a live map or routing service to provide current distances, travel times, and the best route.

## 8. Local Transport Options for Sightseeing
Auto-rickshaws and e-rickshaws are common options for short-distance travel in Ujjain. Visitors can also hire a taxi or use a private vehicle to visit multiple temples in one trip.
For nearby places such as Harsiddhi Temple and Ram Ghat, visitors may be able to walk depending on their starting point, mobility, crowd conditions, and weather. For Kal Bhairav, Mangalnath, Chintaman Ganesh, Sandipani Ashram, Bhartrihari Caves, and Siddhavat, local autos and taxis are practical options.
Do not invent fixed public transport routes, bus numbers, service frequencies, or fares. If a visitor asks for a specific route, provide current information from a live map or verified local transport source. For a multi-stop temple tour, explain that the visitor can negotiate a package with an auto or taxi driver, but do not invent a package price.

## 9. Annual Mahakal Sawari
The Mahakal Sawari is a major annual religious procession in Ujjain. During the holy month of Shravan and the associated festival period, the ceremonial procession of Lord Mahakal travels through designated city routes. Devotees gather along the procession route to receive darshan.
The final or special Sawari is popularly known as Shahi Sawari. The procession route, date, departure time, security arrangements, traffic restrictions, and viewing arrangements are announced by the district administration and temple authorities.
Dates from a previous year must never be presented as upcoming dates. Visitors should check current-year announcements from the Mahakaleshwar Temple administration and Ujjain district administration.

## 10. Food and Bhojnalaya Information
Visitors can find vegetarian food, restaurants, and bhojanalayas around the Mahakaleshwar Temple area.
- Mahakaleshwar Annakshetra: The Annakshetra is associated with the temple''s food service facilities. Published tourism information has described it as a free food facility and listed approximate operating hours of 11:00 AM to 9:00 PM. Actual meal service, availability, timings, coupons, and entry rules should be confirmed on the day of the visit.
- Balaji Bhojanalaya: A local vegetarian dining option that visitors may consider when looking for a meal near the temple area. Confirm current opening hours, menu, and prices directly.
- Shree Atithi Veg Restaurant NX: Another vegetarian dining option in the city. Confirm its current location, operating hours, and prices before directing visitors there.
Do not invent food prices or guarantee free meals. If a visitor asks for current meal prices or whether food is available at a particular time, advise them to contact the facility or check current local listings.

## 11. Major Hotels and Accommodation Near Ujjain
Ujjain offers accommodation ranging from premium hotels and MP Tourism properties to mid-range and budget hotels. Visitors should select a hotel according to their budget, preferred location, family requirements, and distance from Mahakaleshwar Temple.
The following indicative hotel information has been supplied for this knowledge base. The ₹3,000–₹10,000 per day range is an approximate budget range, not a live room quotation. Actual prices can vary significantly depending on travel dates, occupancy, room type, availability, and booking platform. Confirm the latest rates and availability before recommending a booking.
- Anjushree Hotel: A major hotel option in Ujjain. It is listed in this knowledge base as a 3-star hotel, with an indicative budget of approximately ₹3,000 to ₹10,000 per day.
- Rudraksh Club & Resort / Rudraksh Hotel: A hotel and accommodation option in Ujjain. It is listed in this knowledge base as a 3-star property, with an indicative budget of approximately ₹3,000 to ₹10,000 per day. Confirm the exact property name and current classification before booking.
- Ujjaini by Madhya Pradesh Tourism: An MP Tourism accommodation option for visitors to Ujjain. Indicative budget: approximately ₹3,000 to ₹10,000 per day.
- Kshipra Hotel by Madhya Pradesh Tourism: An MP Tourism accommodation option in Ujjain. Indicative budget: approximately ₹3,000 to ₹10,000 per day.
Other hotel options that visitors may explore include Hotel Sharda Inn, Hotel Ganraj, Hotel Narmada Palace, and Hotel Prabhu Palace. Their current room rates, facilities, exact location, and availability must be checked before recommending them.
Do not assign a star classification to a property unless it is confirmed by a reliable current source. Do not claim that a hotel has rooms available without checking live availability. When asked for a hotel recommendation, consider the visitor''s budget, family size, preferred facilities, and desired distance from Mahakal Temple.

## 12. Frequently Asked Questions for the AI Tourist Assistant
Q: How far is Mahakal Temple from Ujjain Railway Station?
A: Mahakal Temple is approximately 2 km from Ujjain Railway Station. You can take an auto-rickshaw or e-rickshaw. The indicative fare supplied for this knowledge base is ₹50–₹100. Confirm the fare with the driver before travelling.

Q: How much does an auto or e-rickshaw cost from Nanakheda Bus Stand to Mahakal?
A: The indicative fare supplied is approximately ₹100–₹180. The actual fare may vary, so confirm it before starting.

Q: What is the VIP Darshan fee?
A: The indicative amount supplied for this knowledge base is ₹250 per person. Please confirm the latest fee and availability on the official Mahakaleshwar Temple website.

Q: What time is Bhasma Aarti?
A: Bhasma Aarti is traditionally held early in the morning, with published seasonal timing of approximately 4:00 AM to 6:00 AM. Check the official schedule and booking requirements for your visit date.

Q: Where can I book Bhasma Aarti?
A: Use the official booking page: https://www.shrimahakaleshwar.mp.gov.in/services/bhasmaarti.

Q: Which temples can I visit after Mahakal?
A: Popular options include Harsiddhi Mata Temple, Ram Ghat, Kal Bhairav Temple, Mangalnath Temple, Chintaman Ganesh Temple, Sandipani Ashram, Bhartrihari Caves, and Siddhavat.

Q: Where can I get food near Mahakal Temple?
A: You can check the Mahakaleshwar Annakshetra and nearby vegetarian bhojanalayas and restaurants. Confirm current service timings and meal availability before visiting.

Q: Which are the major hotels in Ujjain?
A: Options include Anjushree, Rudraksh, Ujjaini by MP Tourism, and Kshipra Hotel by MP Tourism. The indicative budget supplied for these properties is ₹3,000–₹10,000 per day. Check live room rates and availability before booking.

## 13. Instructions for the AI Assistant
You are a helpful local tourist guide for Ujjain, Madhya Pradesh. Answer questions in natural Hindi, English, or Hinglish according to the visitor''s language. Be polite, practical, and concise.
Use the information in this document as a knowledge source. Clearly distinguish between official information, approximate estimates, and user-provided local information. In particular, the VIP Darshan fee, local auto/e-rickshaw fares, hotel classifications, and hotel budget ranges are supplied estimates and must not be presented as verified official rates.
For questions about current Aarti timings, Bhasma Aarti booking, VIP Darshan, hotel availability, food service, festival schedules, and traffic, recommend checking the latest official or live source. Never invent a booking confirmation, current room availability, exact fare, route, phone number, or festival schedule.
For distance and travel-time questions, use a live maps or routing service whenever available. Do not confuse railway-station-to-bus-stand distances with Mahakal Temple-to-bus-stand distances. Ask for the visitor''s starting point only when it is necessary to calculate a route.
When explaining a journey, give practical options such as walking, auto-rickshaw, e-rickshaw, or taxi. Mention approximate fares only with the appropriate caveat. When suggesting a hotel, explain the indicative budget and remind the visitor to check the rate for their dates.
The main objective is to help pilgrims and tourists plan a safe, convenient, and memorable visit to Mahakaleshwar Temple and other attractions in Ujjain.')
ON DUPLICATE KEY UPDATE `content` = VALUES(`content`), `title` = VALUES(`title`), `updated_at` = CURRENT_TIMESTAMP;
