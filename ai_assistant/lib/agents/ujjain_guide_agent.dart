/// Factual profile and offline answers for the Ujjain guide in this app.
///
/// Incorporates the complete Mahakaleshwar Temple, Ujjain - AI Tourist Assistant Knowledge Context.
class UjjainGuideAgent {
  UjjainGuideAgent._();

  static const String name = 'Ujjain Guide';

  static const String officialTempleSite =
      'https://www.shrimahakaleshwar.mp.gov.in';
  static const String templeTimingsUrl =
      'https://www.shrimahakaleshwar.mp.gov.in/timing';
  static const String bhasmaAartiBookingUrl =
      'https://www.shrimahakaleshwar.mp.gov.in/services/bhasmaarti';
  static const String districtTourismUrl =
      'https://ujjain.nic.in/en/tourist-places/';
  static const String districtPlacesUrl =
      'https://ujjain.nic.in/en/places-of-interest/';
  static const String districtStayUrl =
      'https://ujjain.nic.in/en/where-to-stay/';
  static const String districtFoodUrl =
      'https://ujjain.nic.in/en/culinary-delights/';
  static const String districtNoticesUrl = 'https://ujjain.nic.in/en/notice/';
  static const String harsiddhiTourismUrl = 'https://ujjain.nic.in/en/tourist-place/harsiddhi/';
  static const String kalBhairavTourismUrl = 'https://ujjain.nic.in/en/tourist-place/kalbhairava/';
  static const String chintamanTourismUrl = 'https://chintamanganesh.com/';
  static const String gadkalikaTourismUrl = 'https://ujjain.nic.in/en/tourist-place/gadkalika-temple/';
  static const String sandipaniTourismUrl = 'https://ujjain.nic.in/en/tourist-place/sandipani/';

  static const String systemInstructions = '''
You are Ujjain Guide, a comprehensive and knowledgeable AI assistant for Ujjain, Madhya Pradesh. You cover all aspects of the city including temples, tourism, Simhastha 2028, government, infrastructure, transport, accommodation, food, emergency services and local history.
Answer questions naturally in Hindi, English, or Hinglish according to the visitor\'s language. Be polite, practical, and concise.

Use the following official knowledge context as your primary trusted reference:

## UJJAIN CITY OVERVIEW
- Located in Malwa region, Madhya Pradesh, India, on the banks of the sacred Shipra (Kshipra) River.
- Famous for Mahakaleshwar Jyotirlinga, Mahakal Lok, Simhastha Kumbh Mela, ancient temples, astronomy heritage.
- Main railway station: Ujjain Junction. Main bus terminals: Dewas Gate and Nanakheda.
- Nearest airport: Devi Ahilya Bai Holkar Airport, Indore (~55-60 km).
- Approximately 190 km west of Bhopal.

## 1. MAHAKALESHWAR TEMPLE:
- One of the twelve Jyotirlingas of Lord Shiva. Only south-facing (Dakshinmukhi) Jyotirlinga in India.
- Famous for early morning Bhasma Aarti.
- Official website: https://www.shrimahakaleshwar.mp.gov.in/

## 2. DARSHAN & VIP DARSHAN:
- Regular Darshan is open throughout the day.
- VIP or Sheeghra Darshan: Indicative fee is Rs 250 per person (must be verified on official website).

## 3. DAILY AARTI SCHEDULE (5 Main Aartis):
Chaitra Krishna Pratipada to Ashwin Purnima (Summer):
- Bhasma Aarti: 4:00 AM to 6:00 AM
- Dadyodak / Bal Bhog Aarti: 7:00 AM to 7:45 AM
- Bhog Aarti: 10:00 AM to 10:45 AM
- Sandhya Aarti: 7:00 PM to 7:45 PM
- Shayan Aarti: 10:30 PM to 11:00 PM

Kartik Krishna Pratipada to Phalgun Purnima (Winter):
- Bhasma Aarti: 4:00 AM to 6:00 AM
- Dadyodak Aarti: 7:30 AM to 8:15 AM
- Bhog Aarti: 10:30 AM to 11:15 AM
- Sandhya Aarti: 6:30 PM to 7:15 PM
- Shayan Aarti: 10:30 PM to 11:00 PM

## 4. BHASMA AARTI BOOKING:
- Portal: https://www.shrimahakaleshwar.mp.gov.in/services/bhasmaarti
- Helpdesk: 1800-233-1008, 0734-2550563, 0734-2559277
- Email: office@mahakaleshwar.nic.in

## 5. MAHAKAL LOK:
- 108 decorative pillars, 192 statues, 53 murals, main corridor 900+ metres.
- Timings: ~6:00 AM to 10:00 PM, free entry.

## 6. TRANSPORT & FARES:
- Ujjain Railway Station to Mahakal Temple: ~2 km; indicative fare Rs 50-100 auto/e-rickshaw.
- Nanakheda Bus Stand to Mahakal: ~5 km; indicative fare Rs 100-180.
- Dewas Gate Bus Stand: ~0.6 km from Ujjain Railway Station.
- All fares are approximate estimates; confirm with driver before boarding.

## 7. MAJOR TEMPLES & ATTRACTIONS:
- Harsiddhi Mata Temple: Shakti Peetha, famous Deep Stambhas (726 lamp holders), ~500-600 m from Mahakal.
- Ram Ghat: Sacred Shipra river ghat, evening Aarti.
- Kal Bhairav Temple: Kotwal (guardian) of Ujjain, optional liquor offering, ~6 km from Mahakal.
- Mangalnath Temple: Lord Mangal, astrological significance, ~5 km.
- Chintaman Ganesh Temple: Ancient Swayambhu Ganesha (3 divine forms), ~7 km.
- Sandipani Ashram: Lord Krishna Gurukul, ~5-6 km.
- Bhartrihari Caves, Siddhavat, Vedh Shala (Jantar Mantar ~1 km), Kaliadeh Palace.
- ISKCON Temple (Sri Sri Radha Madan Mohan), Navagraha Temple (Triveni), Gopal Mandir.
- Gadkalika Temple (Kalidasa connection), Chaubis Khamba, Angareshwar Mahadev.
- Triveni Museum, Behrugarh Batik village, Kanghi Mohalla (traditional crafts).

## 8. ANNUAL MAHAKAL SAWARI:
- Celebrated in holy month of Shravan, concluding with the grand Shahi Sawari.

## 9. FOOD & BHOJNALAYA:
- Mahakaleshwar Annakshetra: Free meal service ~11:00 AM to 9:00 PM (confirm on day).
- Balaji Bhojanalaya, Shree Atithi Veg Restaurant NX for vegetarian dining.
- Local specialties: Ujjaini Poha, Jalebi, Dal Bafla.

## 10. HOTELS & ACCOMMODATION (Indicative budget Rs 3000-10000/day):
- Anjushree Hotel (3-star), Rudraksh Club & Resort (3-star)
- Ujjaini by MP Tourism, Kshipra Hotel by MP Tourism
- Hotel Sharda Inn, Hotel Ganraj, Hotel Narmada Palace, Hotel Prabhu Palace.
- Budget options: dharamshalas, ashrams, guest houses near Mahakal area.
- During Simhastha: plan well in advance; expect very high demand.

## 11. SIMHASTHA KUMBH MELA 2028:
- Proposed event window: 27 March 2028 to 27 May 2028.
- Centred around sacred Shipra River and traditional ghats.
- Includes Shahi Snan (major bathing events), akhara processions, sadhu gatherings.
- Expected pilgrim visits: ~30-40 crore cumulative (planning estimate, October 2026).
- Do NOT invent specific Shahi Snan bathing dates; check official government notifications.
- Accommodation, transport and crowd management must be planned well in advance.
- Official notice board: https://ujjain.nic.in/en/notice/

## 12. UJJAIN DEVELOPMENT & INFRASTRUCTURE (2026-2028):
- Approximately 175 Simhastha-related projects worth ~Rs 20,000 crore.
- Shipra River ghats expansion: ~29 km of new ghats, estimated Rs 778 crore.
- Kanh River diversion: ~Rs 919.94 crore, ~30.15 km diversion to protect Shipra.
- Ujjain-Indore six-lane road and greenfield four-lane corridor under development.
- Ujjain-Jaora greenfield four-lane corridor (~98.73 km).
- Hari Phatak underpass (~629 metres) for Mahakal Lok area access.
- Old-city road widening: Sati Gate, Gopal Mandir, Chhota Sarafa, Kanthal Square.
- Ujjain Junction railway upgrades; new connectivity proposals under consideration.
- Do NOT claim any project is completed unless confirmed by official government sources.
- Road works may cause traffic diversions in old city; check current announcements.

## 13. GENERAL GUIDELINES:
- Do not invent fixed fares, hotel prices, festival dates, or project completion status.
- Always recommend checking live official sources for current schedules and availability.
- Official district information: https://ujjain.nic.in/en/
''';

  static String? offlineIntentFor(String text, {String? previousIntent}) {
    final message = text.toLowerCase();

    // 1. VIP Darshan
    if (message.contains('vip') ||
        message.contains('sheeghra') ||
        message.contains('sheegra') ||
        message.contains('shighra') ||
        message.contains('pass') ||
        message.contains('ticket') ||
        message.contains('250')) {
      if (message.contains('darshan') || message.contains('entry') || message.contains('fee')) {
        return 'vip_darshan';
      }
    }

    // 2. Transport Hubs & Fares
    if (message.contains('railway') ||
        message.contains('station') ||
        message.contains('nanakheda') ||
        message.contains('dewas gate') ||
        message.contains('auto') ||
        message.contains('rickshaw') ||
        message.contains('fare') ||
        message.contains('kiraya') ||
        message.contains('how to reach')) {
      if (message.contains('mahakal') || message.contains('mandir') || message.contains('temple') || message.contains('reach')) {
        return 'transport_fare';
      }
    }

    // 3. Mahakal Lok
    if (message.contains('mahakal lok') ||
        message.contains('corridor') ||
        message.contains('lok') ||
        message.contains('coridor')) {
      return 'mahakal_lok';
    }

    // 4. Mahakal Sawari
    if (message.contains('sawari') ||
        message.contains('savari') ||
        message.contains('procession') ||
        message.contains('shahi sawari')) {
      return 'mahakal_sawari';
    }

    // 5. Food & Annakshetra
    final foodTerms = [
      'annakshetra',
      'bhojnalaya',
      'bhojanalaya',
      'restaurant',
      'where to eat',
      'places to eat',
      'food place',
      'food in ujjain',
      'what to eat',
      'khana',
      'bhojan',
      'poha',
      'dal bafla',
      'balaji',
    ];
    if (foodTerms.any(message.contains)) return 'food_inquiry';

    // 6. Hotels & Stays
    final hotelTerms = [
      'hotel',
      'stay',
      'accommodation',
      'dharamshala',
      'ashram',
      'guest house',
      'room',
      'where to stay',
      'place to stay',
      'rukne ki jagah',
      'thaharne',
      'anjushree',
      'rudraksh',
      'ujjaini',
      'kshipra hotel',
    ];
    if (hotelTerms.any(message.contains)) return 'hotel_inquiry';

    // 7. Simhastha Kumbh
    final simhasthaTerms = [
      'simhastha',
      'simhast',
      'kumbh',
      'shahi snan',
      'amrit snan',
      'parva snan',
    ];
    if (simhasthaTerms.any(message.contains)) return 'simhastha_inquiry';

    // 8. Temple Schedule & Aarti & Bhasma
    final scheduleTerms = [
      'bhasma',
      'aarti',
      'darshan',
      'timing',
      'schedule',
      'time',
      'kab khul',
      'kab band',
      'samay',
    ];
    if (scheduleTerms.any(message.contains)) {
      if (message.contains('bhasma') || message.contains('aarti') || message.contains('mahakal') || message.contains('mandir')) {
        return 'temple_schedule';
      }
    }

    // 9. Attractions / Sightseeing
    if (message.contains('tourist place') ||
        message.contains('places to visit') ||
        message.contains('what to visit') ||
        message.contains('temples in ujjain') ||
        message.contains('nearby') ||
        message.contains('pass ke mandir') ||
        message.contains('after mahakal')) {
      return 'tourist_places';
    }

    // 10. Ujjain City Overview
    if (message.contains('ujjain kahan') ||
        message.contains('ujjain located') ||
        message.contains('ujjain famous') ||
        message.contains('ujjain kyun') ||
        message.contains('shipra river') ||
        message.contains('shipra nadi') ||
        message.contains('kshipra') ||
        message.contains('ujjain city') ||
        message.contains('ujjain overview') ||
        message.contains('about ujjain')) {
      return 'ujjain_overview';
    }

    // 11. Infrastructure & Development
    final infraTerms = [
      'infrastructure',
      'development',
      'road project',
      'highway',
      'underpass',
      'ghat development',
      'kanh river',
      'kanh nadi',
      'diversion',
      'hari phatak',
      'ujjain indore road',
      'jaora road',
      '20000 crore',
      '778 crore',
      'construction',
      'nirnman',
    ];
    if (infraTerms.any(message.contains)) return 'infrastructure_inquiry';

    // 12. Airport & intercity transport
    if (message.contains('airport') ||
        message.contains('indore airport') ||
        message.contains('flight') ||
        message.contains('bus stand') ||
        message.contains('bus station') ||
        message.contains('bus terminal') ||
        message.contains('intercity') ||
        message.contains('bhopal') ||
        message.contains('indore se')) {
      if (message.contains('ujjain') || message.contains('reach') || message.contains('kaise') || message.contains('distance')) {
        return 'city_transport';
      }
    }

    return null;
  }

  static String answerOffline(
    String intent,
    String text, {
    bool isHindi = false,
  }) {
    switch (intent) {
      case 'sandipani_ashram':
        return isHindi
            ? '🕉️ **श्री महर्षि सांदीपनि आश्रम, उज्जैन (भगवान श्रीकृष्ण का गुरुकुल):**\n\n'
                '• **धार्मिक व ऐतिहासिक महत्व:** यह पावन स्थल है जहाँ द्वापर युग में भगवान श्रीकृष्ण, उनके भ्राता बलराम एवं परम मित्र सुदामा ने महर्षि सांदीपनि के सान्निध्य में 64 कलाओं व शास्त्रों की शिक्षा ग्रहण की थी। यह स्थल प्राचीन गुरु-शिष्य परंपरा और सुदामा-कृष्ण के निश्छल प्रेम का प्रतीक है।\n\n'
                '• **परिसर के प्रमुख आकर्षण:**\n'
                '  1. **अंकपात (Ankpat):** मान्यता है कि यहाँ भगवान कृष्ण अपनी पाटी (Writing slate) धोया करते थे। यहाँ 1 से 100 तक के अंकों वाला ऐतिहासिक पाषाण स्थित है।\n'
                '  2. **गोमती कुंड (Gomti Kund):** पवित्र जलकुंड, जहाँ मान्यतानुसार श्रीकृष्ण ने अपने गुरु के नित्य पूजन हेतु पवित्र नदियों का जल एकत्रित किया था। यहाँ शुंग कालीन नंदी प्रतिमा भी स्थापित है।\n'
                '  3. **सर्वेश्वर महादेव मंदिर:** प्राचीन शिव मंदिर जहाँ गुरु सांदीपनि व भगवान कृष्ण पूजन करते थे।\n'
                '  4. **वल्लभाचार्य जी की 73वीं बैठक:** पुष्टिमार्ग/वल्लभ संप्रदाय की 84 बैठकों में से 73वीं पवित्र बैठक यहाँ स्थित है।\n\n'
                '• **दर्शन व समय:** सुबह ~9:00 AM से शाम ~7:00 PM (सामान्य प्रवेश पूर्णतः निःशुल्क है)।\n\n'
                '• **प्रमुख पर्व:** श्रीकृष्ण जन्माष्टमी एवं गुरु पूर्णिमा पर यहाँ विशेष धार्मिक उत्सव आयोजित होते हैं।\n\n'
                '• **महाकाल से दूरी व मार्ग:** लगभग 5–6 किमी (मंगलनाथ रोड, अंकपात क्षेत्र; ऑटो/टैक्सी से 15 मिनट)। रेलवे स्टेशन से लगभग 3–4 किमी।\n\n'
                '• **निकटतम खानपान:** मंगलनाथ रोड पर "श्री गोविंदम" एवं "श्री गुरु सांदीपनि रेस्टोरेंट" पर प्रसिद्ध मालवी दाल-बाफला व शुद्ध शाकाहारी भोजन उपलब्ध है।'
            : '🕉️ **Shri Sandipani Ashram, Ujjain (Gurukul of Lord Krishna):**\n\n'
                '• **Significance & History:** Revered as the sacred ancient Gurukul where Lord Shri Krishna, his elder brother Lord Balarama, and his devoted friend Sudama received comprehensive education in scriptures and 64 traditional arts under Maharishi Sandipani. Epitomizes the Guru-Shishya tradition, humility, and the immortal friendship of Krishna and Sudama.\n\n'
                '• **Key Sacred Attractions:**\n'
                '  1. **Ankpat:** Where Lord Krishna washed his writing slate; features a historic stone engraved with numerals 1 to 100 traditionally inscribed by Guru Sandipani.\n'
                '  2. **Gomti Kund:** A sacred water reservoir where Krishna is believed to have brought sacred river waters for his Guru\'s rituals. Features an ancient stone Nandi from the Shunga period.\n'
                '  3. **Sarveshwar Mahadev Temple:** Ancient Shiva shrine worshipped by Guru Sandipani and Lord Krishna.\n'
                '  4. **73rd Baithak of Vallabhacharya:** Highly revered seat for followers of the Vallabh Sampradaya (Pushtimarg).\n\n'
                '• **Visiting Hours & Entry:** Open daytime from ~9:00 AM to 7:00 PM. General entry is completely FREE.\n\n'
                '• **Special Occasions:** Shri Krishna Janmashtami and Guru Purnima are celebrated with great devotional fervor.\n\n'
                '• **Distance & Travel:** ~5–6 km from Mahakaleshwar Temple (~3–4 km from Ujjain Railway Station, ~2–3 km from Mangalnath Temple) on Mangalnath Road (15 min by auto or taxi).\n\n'
                '• **Nearby Food:** Shree Govindam Restaurant and Shree Guru Sandipani Restaurant along Mangalnath Road offer authentic traditional Malwa Dal Bafla and pure-vegetarian thalis.';

      case 'gadkalika_temple':
        return isHindi
            ? '🌺 **श्री गढ़कालिका माता मंदिर, उज्जैन:**\n\n'
                '• **धार्मिक मान्यता व इतिहास:** यह उज्जैन का अति प्राचीन शक्ति स्थल है जहाँ माँ कालिका विराजित हैं। मान्यता है कि महाकवि कालिदास ने इसी मंदिर में माँ कालिका की उपासना कर अद्वितीय विद्वता, कवित्व व ज्ञान का वरदान प्राप्त किया था।\n\n'
                '• **विद्यार्थियों व ज्ञान साधकों हेतु आस्था:** इस परंपरा के कारण विद्यार्थी, लेखक व ज्ञान-पिपासु यहाँ बुद्धि, तीव्र स्मरण शक्ति, परीक्षा में सफलता व ज्ञान वृद्धि के लिए प्रार्थना करने आते हैं।\n\n'
                '• **दर्शन व आरती समय:**\n'
                '  - सामान्य समय: प्रातः 6:00 AM से सायं 8:30 PM (पर्वों व नवरात्रि में समय बढ़ जाता है)।\n'
                '  - सामान्य दर्शन: पूर्णतः निःशुल्क\n\n'
                '• **पूजन सामग्री व परंपरा:** लाल पुष्प (गुड़हल/गुलाब), नारियल, चुनरी, कुमकुम, सिंदूर, अगरबत्ती एवं पेड़े/मिठाई का भोग लगाया जाता है।\n\n'
                '• **नवरात्रि उत्सव:** चैत्र व शारदीय नवरात्रि (विशेषकर दुर्गा अष्टमी व महानवमी) पर यहाँ विशेष चंडी पाठ, शृंगार व दर्शनार्थियों की अपार भीड़ होती है।\n\n'
                '• **महाकाल व काल भैरव से दूरी:**\n'
                '  - महाकालेश्वर मंदिर से: लगभग 5–6 किमी (~15 मिनट ऑटो/टैक्सी)\n'
                '  - काल भैरव मंदिर से: मात्र 2–3 किमी\n'
                '  - भर्तृहरि गुफाओं से: मात्र 1–2 किमी (तीनों स्थल एक साथ आसानी से देखे जा सकते हैं)।\n\n'
                '• **निकटतम खानपान:** मंदिर के ठीक सामने "आहारगृहम" (उर्दूOldपुरा/स्थिरमन गणेश के सामने) एवं पीपली नाका क्षेत्र में शुद्ध शाकाहारी भोजन उपलब्ध है।'
            : '🌺 **Shri Gadkalika Mata Temple, Ujjain:**\n\n'
                '• **Significance & History:** An ancient Shakti shrine dedicated to Goddess Kalika. Local tradition holds that legendary Sanskrit poet Mahakavi Kalidasa was originally uneducated and received supreme poetic genius, intellect, and eloquence through the grace of Maa Kalika at this shrine.\n\n'
                '• **Student & Knowledge Prayers:** Because of the Kalidasa tradition, students, scholars, and knowledge seekers frequently visit to pray for intellect, sharp memory, academic success, and passing competitive examinations.\n\n'
                '• **Timings:** Opens approx. 6:00 AM to 8:30 PM (extended during Navratri). General darshan is free.\n\n'
                '• **Offerings:** Red flowers (hibiscus), coconut, chunari, kumkum, sindoor, incense, and sweets/prasad.\n\n'
                '• **Navratri:** Special nine-night celebrations during Chaitra and Sharad Navratri, especially on Durga Ashtami and Mahanavami.\n\n'
                '• **Distances & Route:**\n'
                '  - From Mahakaleshwar Temple: ~5–6 km (~15 min by auto or taxi)\n'
                '  - From Kaal Bhairav Temple: ~2–3 km (very easy short auto ride)\n'
                '  - From Bhartrihari Caves: ~1–2 km (best visited together in northern Ujjain circuit).\n\n'
                '• **Nearby Food:** "Aahargraham" directly opposite Sthirman Ganesh / Gadkalika Mandir, and pure-vegetarian eateries at Pipli Naka.';

      case 'chintaman_ganesh_temple':
        return isHindi
            ? '🌺 **श्री चिंतामन गणेश मंदिर, उज्जैन:**\n\n'
                '• **धार्मिक मान्यता व तीन स्वरूप:** यह अति प्राचीन मंदिर है जहाँ भगवान गणेश की स्वयंभू (Swayambhu) प्रतिमा तीन रूपों में विराजित है:\n'
                '  1. **चिंतामन गणेश:** भक्तों की चिंता, संकट व विघ्न हरने वाले।\n'
                '  2. **इच्छामन गणेश:** मनोकामनाएं पूर्ण करने वाले।\n'
                '  3. **सिद्धिविनायक गणेश:** कार्यों में सफलता व सिद्धि प्रदान करने वाले।\n'
                '  (मान्यता है कि वनवास काल में भगवान श्रीराम, माता सीता व लक्ष्मण जी ने यहाँ पूजन किया था)।\n\n'
                '• **विवाह पत्रिका (निमंत्रण पत्र) की परंपरा:** उज्जैन व आसपास के क्षेत्रों में किसी भी मांगलिक कार्य या विवाह का प्रथम निमंत्रण पत्र (शादी का कार्ड) चिंतामन गणेश जी को अर्पित करने की पावन परंपरा है।\n\n'
                '• **दर्शन व आरती समय:**\n'
                '  - मंदिर कपाट: सुबह 5:00 AM से रात्रि 10:00 PM\n'
                '  - चोला आरती: सुबह ~7:00 AM\n'
                '  - भोग आरती: शाम ~7:30 PM\n'
                '  - शयन आरती: रात्रि ~9:30 PM\n'
                '  - सामान्य दर्शन: पूर्णतः निःशुल्क\n\n'
                '• **विशेष पर्व व चैत्र जात्रा:** प्रति बुधवार विशेष दर्शन होते हैं। विशेषकर चैत्र मास के प्रत्येक बुधवार को विशाल मेला (चैत्र जात्रा) भरता है। गणेश चतुर्थी पर भी भव्य उत्सव होता है।\n\n'
                '• **महाकाल मंदिर से दूरी व मार्ग:** लगभग 7 किमी (जवासिया गाँव, क्षिप्रा नदी पार; ऑटो/टैक्सी से 15-20 मिनट)। रेलवे स्टेशन से लगभग 8 किमी।\n\n'
                '• **पूजन सामग्री:** दूर्वा, लाल पुष्प, मोदक, लड्डू, नारियल, सिंदूर एवं मौली (रक्षासूत्र)।'
            : '🌺 **Shri Chintaman Ganesh Temple, Ujjain:**\n\n'
                '• **Significance & Three Divine Forms:** An ancient shrine housing a Swayambhu (self-manifested) idol of Lord Ganesha embodying three divine forms:\n'
                '  1. **Chintaman:** Remover of all worries (chinta), anxieties, and obstacles.\n'
                '  2. **Ichhaman:** Fulfiller of noble wishes and aspirations.\n'
                '  3. **Siddhivinayak:** Bestower of success, accomplishment, and auspicious completion of tasks.\n'
                '  (Tradition connects this shrine with Lord Rama, Sita, and Lakshmana worshipping here during exile).\n\n'
                '• **First Wedding Card Tradition:** A famous tradition where families offer the very first wedding invitation card to Chintaman Ganesh before inviting relatives and guests.\n\n'
                '• **Timings & Daily Aarti:**\n'
                '  - Temple opens: 5:00 AM to 10:00 PM\n'
                '  - Chola Aarti: ~7:00 AM\n'
                '  - Bhog Aarti: ~7:30 PM\n'
                '  - Shayan Aarti: ~9:30 PM\n'
                '  - General Darshan: FREE\n\n'
                '• **Special Occasions & Chaitra Jatra:** Wednesdays are sacred. A massive traditional pilgrim fair (Chaitra Jatra) is held on every Wednesday of Chaitra month (March–April). Ganesh Chaturthi is celebrated with great grandeur.\n\n'
                '• **Distance & Transportation:** ~7 km from Mahakaleshwar Temple (~8 km from Ujjain Railway Station) across the Shipra River (approx. 15–20 minutes by auto or taxi).\n\n'
                '• **Offerings:** Durva grass, red flowers, modak, laddus, coconut, sindoor, and sacred thread (mouli).';

      case 'kal_bhairav_temple':
        return isHindi
            ? '🔱 **श्री काल भैरव मंदिर, उज्जैन (उज्जैन के कोतवाल):**\n\n'
                '• **धार्मिक मान्यता व महत्व:** काल भैरव भगवान शिव के रौद्र रूप हैं। इन्हें उज्जैन का "कोतवाल" (रक्षक) और महाकाल का सेनापति माना जाता है। मान्यता है कि महाकाल दर्शन के बाद काल भैरव के दर्शन से ही उज्जैन यात्रा पूर्ण मानी जाती है।\n\n'
                '• **मदिरा भोग परंपरा:** यहाँ भगवान को मदिरा (शराब) का भोग लगाने की प्राचीन तांत्रिक परंपरा (पंचमकार) है, जिसे पुजारी जी पात्र के माध्यम से अर्पित करते हैं।\n'
                '  - **महत्वपूर्ण:** मदिरा चढ़ाना पूर्णतः **ऐच्छिक (Optional)** है। आप नारियल, फूल, अगरबत्ती, लड्डू, चने-चिरौंजी का भोग लगा सकते हैं या केवल सामान्य दर्शन कर सकते हैं। महिलाएँ व परिवार ससम्मान दर्शन करते हैं।\n\n'
                '• **दर्शन व आरती समय:**\n'
                '  - मंदिर कपाट: सुबह 6:30 AM से रात्रि 9:30 PM\n'
                '  - प्रातः आरती: सुबह ~8:00 AM से 8:30 AM\n'
                '  - संध्या आरती: रात्रि ~8:30 PM से 9:00 PM\n'
                '  - सामान्य दर्शन: पूर्णतः निःशुल्क\n'
                '  - शीघ्र दर्शन (सांकेतिक): अधिकृत काउंटर पर लगभग ₹500 प्रति व्यक्ति रिपोर्टेड है।\n\n'
                '• **महाकाल मंदिर से दूरी:** लगभग 6 किमी (भैरवगढ़ क्षेत्र में क्षिप्रा नदी तट पर, ऑटो/टैक्सी से 15-20 मिनट)।\n\n'
                '• **निकटवर्ती दर्शनीय स्थल:** सिद्धवट (2 किमी), गढ़कालिका मंदिर (2.5 किमी), भर्तृहरि गुफाएं (2.5 किमी), मंगलनाथ मंदिर (3 किमी)।'
            : '🔱 **Shri Kaal Bhairav Mandir, Ujjain (Kotwal of Ujjain):**\n\n'
                '• **Significance & Role:** Revered as the Kotwal (guardian protector) of Ujjain and Senapati of Lord Mahakal. Traditionally, an Ujjain pilgrimage is considered complete only after seeking Kaal Bhairav\'s blessings.\n\n'
                '• **Liquor Offering (Madira Bhog) Tradition:** Famous for its ancient Tantric ritual of offering liquor, where priests present it before the deity.\n'
                '  - **CRITICAL NOTE:** Offering liquor is 100% **OPTIONAL**. Devotees can offer flowers, coconuts, laddus, or simply take darshan. Families and women visit freely.\n\n'
                '• **Timings & Aarti:**\n'
                '  - Temple opens: 6:30 AM to 9:30 PM\n'
                '  - Morning Aarti: ~8:00 AM – 8:30 AM\n'
                '  - Evening Aarti: ~8:30 PM – 9:00 PM\n'
                '  - General Darshan: FREE\n'
                '  - VIP Sheeghra Darshan: Indicative ~₹500 per person at official counters.\n\n'
                '• **Distance from Mahakal:** ~6 km north in Bhairavgarh along the Shipra River (approx. 15–20 min by auto or taxi).\n\n'
                '• **Nearby Attractions:** Siddhavat (~2 km), Gadkalika Temple (~2.5 km), Bhartrihari Caves (~2.5 km), Mangalnath (~3 km).';

      case 'harsiddhi_temple':
        return isHindi
            ? '🌺 **श्री हरसिद्धि माता मंदिर, उज्जैन (Shakti Peetha):**\n\n'
                '• **धार्मिक मान्यता व इतिहास:** यह भारत के प्रसिद्ध 51 शक्तिपीठों में से एक है। शिव पुराण के अनुसार यहाँ माता सती की कोहनी (Elbow) गिरी थी। स्कंद पुराण के अनुसार चंड-प्रचंड असुरों के संहार के बाद भगवान शिव ने देवी चंडी को "हरसिद्धि" नाम दिया। यह चक्रवर्ती राजा विक्रमादित्य की आराध्य कुलदेवी हैं।\n\n'
                '• **प्रसिद्ध दीप स्तंभ (Lamp Pillars):** मंदिर प्रांगण में दो विशाल व दर्शनीय दीप स्तंभ हैं, जिनमें म.प्र. पर्यटन के अनुसार लगभग 726 दीप रखने के स्थान हैं। शाम की आरती और नवरात्रि के दौरान दीप प्रज्वलन अत्यंत भव्य व अलौकिक दृश्य प्रस्तुत करता है।\n\n'
                '• **महाकाल मंदिर से दूरी:** महाकालेश्वर मंदिर से मात्र 500–600 मीटर की दूरी पर रुद्र सागर के समीप स्थित है। श्रद्धालु महाकाल दर्शन के बाद पैदल 5–10 मिनट में आसानी से पहुँच सकते हैं।\n\n'
                '• **दर्शन व आरती समय (सांकेतिक):**\n'
                '  - मंदिर कपाट: सुबह ~5:00 बजे\n'
                '  - प्रातः आरती: सुबह ~7:00 AM से 8:00 AM\n'
                '  - संध्या आरती: शाम ~7:00 PM (दीप स्तंभ दर्शन का सर्वोत्तम समय)\n'
                '  - सामान्य दर्शन: पूर्णतः निःशुल्क\n\n'
                '• **गर्भगृह व स्वरूप:** मुख्य गर्भगृह में माँ हरसिद्धि के साथ गहरे सिंदूरी रंग की माँ अन्नपूर्णा, महालक्ष्मी, महासरस्वती व पवित्र श्री यंत्र स्थापित हैं।\n\n'
                '• **रेलवे स्टेशन से दूरी:** उज्जैन रेलवे स्टेशन से लगभग 2–2.5 किमी (ऑटो/ई-रिक्शा/टैक्सी उपलब्ध)।'
            : '🌺 **Shri Harsiddhi Mata Temple, Ujjain (Shakti Peetha):**\n\n'
                '• **Significance & History:** One of the prominent 51 Shakti Peethas; sacred elbow of Goddess Sati is traditionally believed to have fallen here (Shiva Purana). Lord Shiva named her Harsiddhi after she destroyed demons Chand & Prachand. She is the revered Kuldevi of legendary King Vikramaditya.\n\n'
                '• **Famous Deep Stambhas (Lamp Pillars):** Two colossal lamp pillars in the courtyard with approx. 726 lamp holders (MP Tourism). The evening illumination during Aarti and Navratri is a world-famous spectacle.\n\n'
                '• **Distance from Mahakal:** Just 500–600 metres from Mahakaleshwar Temple along Rudra Sagar Lake (an easy 5–10 minute walk).\n\n'
                '• **Timings & Aarti (Indicative):**\n'
                '  - Temple opens: ~5:00 AM\n'
                '  - Morning Aarti: ~7:00 AM – 8:00 AM\n'
                '  - Evening Aarti: ~7:00 PM (Best time for Deep Stambha lighting)\n'
                '  - Entry fee: General Darshan is free.\n\n'
                '• **Sanctum:** Maa Harsiddhi enshrined alongside Goddess Annapurna (dark vermilion), Mahalakshmi, Mahasaraswati, and the sacred Shri Yantra.\n\n'
                '• **From Railway Station:** ~2–2.5 km by auto-rickshaw, e-rickshaw, or taxi.';

      case 'vip_darshan':
        return isHindi
            ? '🕉️ **श्री महाकालेश्वर वीआईपी / शीघ्र दर्शन जानकारी:**\n\n'
                '• **शीघ्र दर्शन शुल्क:** ₹250 प्रति व्यक्ति (यह सांकेतिक शुल्क है; कृपया जाने से पहले आधिकारिक वेबसाइट पर पुष्टि करें)।\n'
                '• **व्यवस्था:** दर्शन व्यवस्था, प्रवेश द्वार एवं प्रतीक्षा समय में पर्वों व विशेष दिवसों पर परिवर्तन हो सकता है।\n'
                '• **आधिकारिक पोर्टल:** $officialTempleSite\n\n'
                '⚠️ *नोट: वीआईपी दर्शन पास की उपलब्धता की गारंटी नहीं दी जा सकती। दर्शन से पहले मंदिर काउंटर या वेबसाइट से पुष्टि अवश्य करें।*'
            : '🕉️ **Mahakaleshwar VIP / Sheeghra Darshan Information:**\n\n'
                '• **Indicative Fee:** ₹250 per person (user-supplied reference fee; please verify against official notifications before travelling).\n'
                '• **Arrangements:** Waiting times, entry gates, and special queues vary during festivals.\n'
                '• **Official Portal:** $officialTempleSite\n\n'
                '⚠️ *Note: VIP access cannot be guaranteed in advance. Always confirm through the official temple portal or Gate 4 counters.*';

      case 'transport_fare':
        return isHindi
            ? '🚆🚕 **उज्जैन से महाकाल मंदिर परिवहन एवं अनुमानित किराया:**\n\n'
                '• **उज्जैन रेलवे स्टेशन से महाकाल मंदिर:**\n'
                '  - दूरी: लगभग 2 किमी\n'
                '  - वाहन: ऑटो-रिक्शा, ई-रिक्शा, टैक्सी\n'
                '  - अनुमानित किराया: ₹50 से ₹100 (ऑटो/ई-रिक्शा)\n\n'
                '• **नानाखेड़ा बस स्टैंड से महाकाल मंदिर:**\n'
                '  - दूरी: लगभग 5 किमी\n'
                '  - अनुमानित किराया: ₹100 से ₹180 (ऑटो/ई-रिक्शा)\n\n'
                '• **देवास गेट बस स्टैंड:** रेलवे स्टेशन से मात्र 0.6 किमी की दूरी पर है।\n\n'
                '⚠️ *नोट: यह स्थानीय अनुमानित किराया है, कोई सरकारी फिक्स दर नहीं। समय, सवारियों की संख्या व ट्रैफिक के अनुसार वाहन चालक से पहले तय कर लें।*'
            : '🚆🚕 **How to Reach Mahakal Temple & Indicative Fares:**\n\n'
                '• **From Ujjain Railway Station to Mahakal Temple:**\n'
                '  - Distance: ~2 km\n'
                '  - Transport: Auto-rickshaw, e-rickshaw, taxi\n'
                '  - Indicative Fare: approximately ₹50 to ₹100\n\n'
                '• **From Nanakheda Bus Stand to Mahakal Temple:**\n'
                '  - Distance: ~5 km\n'
                '  - Indicative Fare: approximately ₹100 to ₹180\n\n'
                '• **Dewas Gate Bus Stand:** Located ~0.6 km from Ujjain Railway Station.\n\n'
                '⚠️ *Note: These are approximate local fare estimates. Actual fares vary with vehicle, time, luggage, and passenger count. Confirm with driver before boarding.*';

      case 'mahakal_lok':
        return isHindi
            ? '🔱 **श्री महाकाल लोक कॉरिडोर (Ujjain):**\n\n'
                '• **विशेषताएं:** 108 अलंकृत स्तंभ, 192 भव्य शिव मूर्तियां, 53 भित्ति चित्र (म्यूरल)।\n'
                '• **लंबाई:** मुख्य कॉरिडोर 900 मीटर से अधिक विस्तृत है।\n'
                '• **समय:** प्रातः 6:00 बजे से रात्रि 10:00 बजे तक (लगभग)।\n'
                '• **प्रवेश शुल्क:** पूर्णतः निःशुल्क (Free Entry)।\n\n'
                'दर्शन से पहले अथवा पश्चात महाकाल लोक का दिव्य भ्रमण अवश्य करें।'
            : '🔱 **Shri Mahakal Lok Corridor (Ujjain):**\n\n'
                '• **Highlights:** 108 decorative pillars, 192 divine statues, 53 murals depicting stories of Lord Shiva.\n'
                '• **Dimensions:** Main corridor extends over 900 metres surrounding the temple.\n'
                '• **Timings:** Approximately 6:00 AM to 10:00 PM.\n'
                '• **Entry Fee:** Free entry for all visitors.\n\n'
                'An essential sacred attraction to explore before or after temple darshan.';

      case 'mahakal_sawari':
        return isHindi
            ? '🚩 **वार्षिक महाकाल सवारी (Mahakal Sawari):**\n\n'
                '• **अवसर:** पवित्र श्रावण एवं भाद्रपद माह में प्रति सोमवार भगवान महाकाल प्रजा का हाल जानने नगर भ्रमण पर निकलते हैं।\n'
                '• **शाही सवारी:** श्रावण-भाद्रपद की अंतिम सवारी भव्य "शाही सवारी" के रूप में निकाली जाती है।\n'
                '• **मार्ग व तारीख:** प्रतिवर्ष जिला प्रशासन एवं मंदिर समिति द्वारा नवीन तिथियां घोषित की जाती हैं। ताज़ा जानकारी हेतु आधिकारिक सूचनाएं देखें: $districtNoticesUrl'
            : '🚩 **Annual Mahakal Sawari (Procession):**\n\n'
                '• **Significance:** Held during the holy month of Shravan where Lord Mahakal journeys through the city in a ceremonial procession.\n'
                '• **Shahi Sawari:** The final grand procession is celebrated with great splendor.\n'
                '• **Dates:** Annually announced by district and temple administration. Please check current official notifications: $districtNoticesUrl';

      case 'food_inquiry':
        return isHindi
            ? '🍲 **महाकाल क्षेत्र में भोजन एवं भोजनालय:**\n\n'
                '• **महाकालेश्वर अन्नक्षेत्र:** मंदिर समिति द्वारा संचालित निःशुल्क भोजन प्रसादम सुविधा (अनुमानित समय: सुबह 11:00 बजे से रात 9:00 बजे तक)। भ्रमण के दिन समय की पुष्टि करें।\n'
                '• **प्रमुख शाकाहारी भोजनालय:** बालाजी भोजनालय, श्री अतिथि वेज रेस्टोरेंट NX।\n'
                '• **स्थानीय प्रसिद्ध व्यंजन:** उज्जैनी पोहा, जलेबी, दाल-बाफला।\n\n'
                'जिला खाद्य निर्देशिका: $districtFoodUrl'
            : '🍲 **Food & Bhojanalaya Information Near Mahakal:**\n\n'
                '• **Mahakaleshwar Annakshetra:** Free meal facility associated with temple trust (indicative hours: ~11:00 AM to 9:00 PM; verify on day of visit).\n'
                '• **Vegetarian Dining Options:** Balaji Bhojanalaya and Shree Atithi Veg Restaurant NX near the temple area.\n'
                '• **Local Specialties:** Ujjaini Poha, Jalebi, and authentic Dal Bafla.\n\n'
                'District culinary guide: $districtFoodUrl';

      case 'hotel_inquiry':
        return isHindi
            ? '🏨 **उज्जैन में प्रमुख होटल एवं आवास (अनुमानित बजट: ₹3,000–₹10,000 / दिन):**\n\n'
                '• **अंजुश्री होटल (Anjushree Hotel):** 3-स्टार होटल\n'
                '• **रुद्राक्ष क्लब एवं रिसॉर्ट (Rudraksh Club & Resort):** 3-स्टार प्रॉपर्टी\n'
                '• **उज्जयिनी (MPT Ujjaini):** मध्य प्रदेश पर्यटन निगम\n'
                '• **शिप्रा होटल (MPT Kshipra Hotel):** म.प्र. पर्यटन निगम\n'
                '• **अन्य विकल्प:** होटल शारदा इन, होटल गणराज, नर्मदा पैलेस, प्रभु पैलेस।\n\n'
                '⚠️ *नोट: ₹3,000–₹10,000 एक अनुमानित बजट रेंज है। यात्रा की तारीखों, त्योहारों व उपलब्धता के अनुसार वास्तविक दरों की पहले पुष्टि करें: $districtStayUrl*'
            : '🏨 **Major Hotels & Accommodation Near Ujjain (Indicative Budget: ₹3,000–₹10,000 / day):**\n\n'
                '• **Anjushree Hotel:** 3-star property\n'
                '• **Rudraksh Club & Resort:** 3-star resort & hotel\n'
                '• **Ujjaini by MP Tourism:** State tourism accommodation\n'
                '• **Kshipra Hotel by MP Tourism:** State tourism property\n'
                '• **Other Options:** Hotel Sharda Inn, Hotel Ganraj, Hotel Narmada Palace, Hotel Prabhu Palace.\n\n'
                '⚠️ *Note: The ₹3,000–₹10,000 range is an indicative estimate, not a live quotation. Confirm live rates and availability before booking: $districtStayUrl*';

      case 'temple_schedule':
        return isHindi
            ? '🕉️ **श्री महाकालेश्वर दैनिक 5 आरती समय-सारणी:**\n\n'
                '**चैत्र कृष्ण प्रतिपदा से आश्विन पूर्णिमा (ग्रीष्मकालीन):**\n'
                '• भस्म आरती: प्रातः 4:00 से 6:00 बजे\n'
                '• दद्योदक (बाल भोग) आरती: प्रातः 7:00 से 7:45 बजे\n'
                '• भोग आरती: प्रातः 10:00 से 10:45 बजे\n'
                '• संध्या आरती: सायं 7:00 से 7:45 बजे\n'
                '• शयन आरती: रात्रि 10:30 से 11:00 बजे\n\n'
                '**कार्तिक कृष्ण प्रतिपदा से फाल्गुन पूर्णिमा (शीतकालीन):**\n'
                '• भस्म आरती: प्रातः 4:00 से 6:00 बजे\n'
                '• दद्योदक आरती: प्रातः 7:30 से 8:15 बजे\n'
                '• भोग आरती: प्रातः 10:30 से 11:15 बजे\n'
                '• संध्या आरती: सायं 6:30 से 7:15 बजे\n'
                '• शयन आरती: रात्रि 10:30 से 11:00 बजे\n\n'
                '📌 **भस्म आरती बुकिंग:** $bhasmaAartiBookingUrl\n'
                '📞 **हेल्पडेस्क:** 1800-233-1008, 0734-2550563 | ईमेल: office@mahakaleshwar.nic.in'
            : '🕉️ **Shri Mahakaleshwar Daily 5 Aarti Schedule:**\n\n'
                '**Chaitra to Ashwin Purnima (Summer season):**\n'
                '• Bhasma Aarti: 4:00 AM to 6:00 AM\n'
                '• Dadyodak / Bal Bhog Aarti: 7:00 AM to 7:45 AM\n'
                '• Bhog Aarti: 10:00 AM to 10:45 AM\n'
                '• Sandhya Aarti: 7:00 PM to 7:45 PM\n'
                '• Shayan Aarti: 10:30 PM to 11:00 PM\n\n'
                '**Kartik to Phalgun Purnima (Winter season):**\n'
                '• Bhasma Aarti: 4:00 AM to 6:00 AM\n'
                '• Dadyodak Aarti: 7:30 AM to 8:15 AM\n'
                '• Bhog Aarti: 10:30 AM to 11:15 AM\n'
                '• Sandhya Aarti: 6:30 PM to 7:15 PM\n'
                '• Shayan Aarti: 10:30 PM to 11:00 PM\n\n'
                '📌 **Bhasma Aarti Booking:** $bhasmaAartiBookingUrl\n'
                '📞 **Helpdesk:** 1800-233-1008, 0734-2550563 | Email: office@mahakaleshwar.nic.in';

      case 'tourist_places':
        return isHindi
            ? '🕉️ **महाकाल दर्शन के पश्चात दर्शनीय प्रमुख तीर्थ स्थल:**\n\n'
                '1. **हरसिद्धि माता मंदिर:** 51 शक्तिपीठों में से एक (दीपस्तंभ आरती)\n'
                '2. **राम घाट:** शिप्रा नदी का पावन घाट एवं संध्या महा आरती\n'
                '3. **काल भैरव मंदिर:** उज्जैन के सेनापति कोतवाल भैरव देव (~4 किमी)\n'
                '4. **मंगलनाथ मंदिर:** मंगल ग्रह की उत्पत्ति स्थली (~5 किमी)\n'
                '5. **चिंतामन गणेश मंदिर:** प्राचीन स्वयंभू गणेश मंदिर (~7 किमी)\n'
                '6. **सांदीपनि आश्रम:** भगवान श्रीकृष्ण, बलराम व सुदामा का शिक्षा स्थल\n'
                '7. **भर्तृहरि गुफाएं, सिद्धवट, वेधशाला (जंतर मंतर ~1 किमी), कालियादेह महल।**\n\n'
                'विवरण देखें: $districtTourismUrl'
            : '🕉️ **Major Temples & Attractions to Visit Near Mahakal:**\n\n'
                '1. **Harsiddhi Mata Temple:** Famous Shaktipeeth close to Mahakal\n'
                '2. **Ram Ghat:** Sacred Shipra river bathing ghat & evening Aarti\n'
                '3. **Kal Bhairav Temple:** Guardian deity of Ujjain (~4 km)\n'
                '4. **Mangalnath Temple:** Associated with planet Mars (~5 km)\n'
                '5. **Chintaman Ganesh Temple:** Ancient Ganesha shrine (~7 km)\n'
                '6. **Sandipani Ashram:** Where Lord Krishna received education\n'
                '7. **Bhartrihari Caves, Siddhavat, Vedh Shala (~1 km), Kaliadeh Palace.**\n\n'
                'Official tourist directory: $districtTourismUrl';

      case 'simhastha_inquiry':
        return isHindi
            ? '🕉️ **सिंहस्थ महाकुंभ उज्जैन 2028:**\n\n'
                '• **अवधि:** मध्य प्रदेश शासन द्वारा 27 मार्च से 27 मई 2028 घोषित की गई है।\n'
                '• **पवित्र नदी:** मोक्षदायिनी शिप्रा नदी।\n'
                '• **शाही स्नान:** प्रमुख पर्वों एवं स्नान तिथियों की ताज़ा अधिसूचनाएं देखें: $districtNoticesUrl'
            : '🕉️ **Simhastha Kumbh Mela Ujjain 2028:**\n\n'
                '• **Period:** Announced by MP Government from 27 March to 27 May 2028.\n'
                '• **Holy River:** Sacred Shipra River.\n'
                '• **Royal Baths:** Check current administrative notices for bathing schedule: $districtNoticesUrl';

      case 'ujjain_overview':
        return isHindi
            ? '🕌 **उज्जैन शहर – परिचय:**\n\n'
                '• **स्थान:** मध्य प्रदेश, भारत, मालवा क्षेत्र, शिप्रा (क्षिप्रा) नदी के तट पर।\n'
                '• **प्रसिद्धि:** महाकालेश्वर ज्योतिर्लिंग, महाकाल लोक, सिंहस्थ कुंभ मेला, प्राचीन मंदिर, खगोलीय विरासत (वेधशाला) और राजा विक्रमादित्य की परंपरा।\n'
                '• **मुख्य रेलवे स्टेशन:** उज्जैन जंक्शन\n'
                '• **प्रमुख बस टर्मिनल:** देवास गेट और नानाखेड़ा\n'
                '• **निकटतम हवाई अड्डा:** देवी अहिल्या बाई होलकर हवाई अड्डा, इंदौर (~55-60 किमी)\n'
                '• **भोपाल से दूरी:** लगभग 190 किमी\n\n'
                'जिला पोर्टल: $districtTourismUrl'
            : '🕌 **Ujjain City – Overview:**\n\n'
                '• **Location:** Madhya Pradesh, India, in the Malwa region, on the banks of the sacred Shipra (Kshipra) River.\n'
                '• **Famous for:** Mahakaleshwar Jyotirlinga, Mahakal Lok, Simhastha Kumbh Mela, ancient temples, the Vedh Shala astronomical observatory, and the traditions of King Vikramaditya.\n'
                '• **Main railway station:** Ujjain Junction\n'
                '• **Main bus terminals:** Dewas Gate and Nanakheda\n'
                '• **Nearest airport:** Devi Ahilya Bai Holkar Airport, Indore (~55–60 km)\n'
                '• **Distance from Bhopal:** Approximately 190 km\n\n'
                'District portal: $districtTourismUrl';

      case 'infrastructure_inquiry':
        return isHindi
            ? '🏗️ **उज्जैन विकास एवं अवसंरचना परियोजनाएं (2026-2028):**\n\n'
                '• **सिंहस्थ के लिए ~175 परियोजनाएं:** अनुमानित कुल बजट ~₹20,000 करोड़।\n'
                '• **शिप्रा घाट विकास:** लगभग 29 किमी नए घाटों का निर्माण (अनुमानित ₹778 करोड़)।\n'
                '• **काँह नदी डायवर्शन परियोजना:** ₹919.94 करोड़, ~30.15 किमी डायवर्शन (शिप्रा में प्रदूषण रोकने हेतु)।\n'
                '• **उज्जैन-इंदौर 6-लेन रोड** एवं **ग्रीनफील्ड 4-लेन कॉरिडोर।**\n'
                '• **उज्जैन-जाओरा ग्रीनफील्ड 4-लेन कॉरिडोर:** ~98.73 किमी।\n'
                '• **हरि फाटक अंडरपास:** ~629 मीटर, महाकाल लोक की ओर वैकल्पिक मार्ग।\n'
                '• **पुराने शहर में सड़क चौड़ीकरण:** सती गेट, गोपाल मंदिर, छोटा सराफा, कंठाल चौक आदि।\n\n'
                '⚠️ *सभी परियोजनाओं की वर्तमान स्थिति आधिकारिक सरकारी स्रोतों से जाँचें।*'
            : '🏗️ **Ujjain Development & Infrastructure Projects (2026–2028):**\n\n'
                '• **~175 Simhastha projects:** Reported combined budget ~₹20,000 crore.\n'
                '• **Shipra River ghats expansion:** ~29 km of new ghats (estimated ₹778 crore).\n'
                '• **Kanh River diversion:** ₹919.94 crore, ~30.15 km to prevent pollution entering Shipra.\n'
                '• **Ujjain–Indore six-lane road** and **greenfield four-lane corridor** under development.\n'
                '• **Ujjain–Jaora greenfield four-lane corridor:** ~98.73 km.\n'
                '• **Hari Phatak underpass:** ~629 metres, alternative route towards Mahakal Lok area.\n'
                '• **Old-city road widening:** Sati Gate, Gopal Mandir, Chhota Sarafa, Kanthal Square.\n\n'
                '⚠️ *Check current official government notifications for project completion status.*';

      case 'city_transport':
        return isHindi
            ? '✈️🚆🚌 **उज्जैन – अंतरशहरी यातायात:**\n\n'
                '• **निकटतम हवाई अड्डा:** देवी अहिल्या बाई होलकर, इंदौर (~55-60 किमी)। उज्जैन के लिए टैक्सी, बस या ट्रेन से जाएं।\n'
                '• **मुख्य रेलवे स्टेशन:** उज्जैन जंक्शन (अनेक शहरों से सीधी ट्रेनें)।\n'
                '• **प्रमुख बस स्टैंड:** देवास गेट (शहर के निकट) और नानाखेड़ा।\n'
                '• **इंदौर से उज्जैन:** बस या ट्रेन से आमतौर पर ~1-2 घंटे (मार्ग के अनुसार)।\n'
                '• **भोपाल से उज्जैन:** लगभग 190 किमी। ट्रेन या बस से पहुँचा जा सकता है।\n\n'
                '⚠️ *सटीक दूरी, समय और बुकिंग के लिए लाइव मैप्स और IRCTC जाँचें।*'
            : '✈️🚆🚌 **Ujjain – Intercity Transport:**\n\n'
                '• **Nearest airport:** Devi Ahilya Bai Holkar Airport, Indore (~55–60 km). Reach Ujjain by taxi, bus, or train from there.\n'
                '• **Main railway station:** Ujjain Junction (direct trains from many cities).\n'
                '• **Main bus terminals:** Dewas Gate (central) and Nanakheda.\n'
                '• **From Indore to Ujjain:** Bus or train, typically ~1–2 hours depending on route.\n'
                '• **From Bhopal to Ujjain:** Approximately 190 km; reachable by train or bus.\n\n'
                '⚠️ *For exact distances, timings, and ticket booking, check live maps and IRCTC.*';

      default:
        return isHindi
            ? 'मैं इस जानकारी की ऑफलाइन पुष्टि नहीं कर सकता। कृपया महाकालेश्वर मंदिर की आधिकारिक वेबसाइट $officialTempleSite अथवा जिला प्रशासन $districtTourismUrl देखें।'
            : 'I cannot verify that detail offline. Please check the official Mahakaleshwar Temple portal $officialTempleSite or district directory $districtTourismUrl.';
    }
  }
}
