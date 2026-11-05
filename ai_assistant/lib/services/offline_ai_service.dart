import 'dart:math';
import '../agents/ujjain_guide_agent.dart';
import '../models/chat_session.dart';
import '../models/location_info.dart';
import '../models/query_analysis.dart';
import '../constants/app_constants.dart';
import 'location_service.dart';

class OfflineAIService {
  static final OfflineAIService _instance = OfflineAIService._internal();
  factory OfflineAIService() => _instance;
  OfflineAIService._internal();

  // ─── Landmark coordinate database (lat, lon) ─────────────────────────────
  // These are accurate coordinates for key Ujjain landmarks

  static const Map<String, Map<String, dynamic>> _landmarks = {
    'mahakaleshwar': {
      'name': 'Mahakaleshwar Jyotirlinga',
      'hindiName': 'श्री महाकालेश्वर ज्योतिर्लिंग',
      'lat': 23.18312,
      'lon': 75.76819,
      'icon': '🕉️',
      'type': 'temple',
      'description': 'One of the 12 Jyotirlingas dedicated to Lord Shiva',
      'hindiDescription':
          'भगवान शिव के 12 पवित्र ज्योतिर्लिंगों में से एक (दक्षिणमुखी ज्योतिर्लिंग)',
    },
    'kal_bhairav': {
      'name': 'Kal Bhairav Temple',
      'hindiName': 'श्री काल भैरव मंदिर',
      'lat': 23.2108,
      'lon': 75.7767,
      'icon': '🔱',
      'type': 'temple',
      'description': 'Guardian deity of Ujjain, city protector',
      'hindiDescription': 'उज्जैन के सेनापति एवं नगर रक्षक (कोतवाल) भैरव देव',
    },
    'harsiddhi': {
      'name': 'Harsiddhi Mata Temple',
      'hindiName': 'माँ हरसिद्धि शक्तिपीठ मंदिर',
      'lat': 23.1819,
      'lon': 75.7656,
      'icon': '🌺',
      'type': 'temple',
      'description':
          'Important Shakti shrine associated with Goddess Harsiddhi',
      'hindiDescription':
          '51 शक्तिपीठों में से एक, जहाँ माता सती की कोहनी गिरी थी',
    },
    'chintaman_ganesh': {
      'name': 'Chintaman Ganesh Temple',
      'hindiName': 'श्री चिंतामन गणेश मंदिर',
      'lat': 23.1467,
      'lon': 75.7391,
      'icon': '🐘',
      'type': 'temple',
      'description': 'Ancient Ganesh temple, known as a wish-fulfilling shrine',
      'hindiDescription':
          'प्राचीन स्वयंभू गणेश मंदिर, भक्तों की चिंता हरने वाले विघ्नहर्ता',
    },
    'gadkalika': {
      'name': 'Gadkalika Temple',
      'hindiName': 'माँ गढ़कालिका मंदिर',
      'lat': 23.1834,
      'lon': 75.7639,
      'icon': '🙏',
      'type': 'temple',
      'description': 'Ancient temple dedicated to Goddess Kalika',
      'hindiDescription':
          'महाकवि कालिदास की आराध्या माँ कालिका का प्राचीन शक्ति स्थल',
    },
    'ram_ghat': {
      'name': 'Ram Ghat',
      'hindiName': 'राम घाट (शिप्रा नदी)',
      'lat': 23.1867,
      'lon': 75.7744,
      'icon': '🏺',
      'type': 'ghat',
      'description': 'Sacred bathing ghat on the Shipra River',
      'hindiDescription':
          'सिंहस्थ कुंभ का मुख्य पावन स्नान घाट एवं संध्या आरती स्थल',
    },
    'triveni_ghat': {
      'name': 'Triveni Ghat',
      'hindiName': 'त्रिवेणी घाट (संगम स्थल)',
      'lat': 23.1881,
      'lon': 75.7750,
      'icon': '🌊',
      'type': 'ghat',
      'description': 'Sacred ghat in Ujjain; confluence of holy streams',
      'hindiDescription': 'शिप्रा, खान और गुप्त सरस्वती का पावन संगम घाट',
    },
    'mangalnath': {
      'name': 'Mangalnath Temple',
      'hindiName': 'श्री मंगलनाथ मंदिर',
      'lat': 23.1717,
      'lon': 75.7531,
      'icon': '🔴',
      'type': 'temple',
      'description': 'Temple associated with the planet Mars (Mangal)',
      'hindiDescription':
          'पुराणों के अनुसार मंगल ग्रह की जन्मस्थली एवं भात पूजा स्थल',
    },
    'sandipani_ashram': {
      'name': 'Sandipani Ashram',
      'hindiName': 'महर्षि सांदीपनि आश्रम',
      'lat': 23.21136,
      'lon': 75.78237,
      'icon': '📚',
      'type': 'historical',
      'description':
          "Traditional ashram associated with Lord Krishna's education",
      'hindiDescription':
          'भगवान श्री कृष्ण, बलराम एवं सुदामा की पावन विद्यास्थली',
    },
    'ujjain_railway': {
      'name': 'Ujjain Railway Station',
      'hindiName': 'उज्जैन जंक्शन रेलवे स्टेशन',
      'lat': 23.17954,
      'lon': 75.78195,
      'icon': '🚂',
      'type': 'transport',
      'description': 'Main railway station connecting Ujjain to other cities',
      'hindiDescription':
          'उज्जैन का मुख्य रेलवे स्टेशन, देश के सभी प्रमुख शहरों से जुड़ा',
    },
    'ujjain_bus': {
      'name': 'Ujjain Bus Stand (Dewas Gate)',
      'hindiName': 'उज्जैन बस स्टैंड (देवास गेट)',
      'lat': 23.18093,
      'lon': 75.78238,
      'icon': '🚌',
      'type': 'transport',
      'description': 'Dewas Gate bus station serving regional routes',
      'hindiDescription':
          'केंद्रीय बस स्टैंड (इंदौर, भोपाल, ओंकारेश्वर हेतु नियमित बसें)',
    },
    'vikramaditya_clock': {
      'name': 'Vikramaditya Clock Tower',
      'hindiName': 'महाराजा विक्रमादित्य घंटाघर',
      'lat': 23.1819,
      'lon': 75.7740,
      'icon': '🕰️',
      'type': 'landmark',
      'description': 'Historic clock tower in the heart of Ujjain city',
      'hindiDescription': 'उज्जैन नगर के हृदय स्थल पर स्थित ऐतिहासिक घंटाघर',
    },
    'mahakal_lok': {
      'name': 'Shri Mahakal Lok Corridor',
      'hindiName': 'श्री महाकाल महालोक',
      'lat': 23.1840,
      'lon': 75.7695,
      'icon': '🏛️',
      'type': 'corridor',
      'description':
          "India's largest religious corridor featuring 108 Shiva Tandav pillars and Rudra Sagar",
      'hindiDescription':
          'भारत का भव्यतम धार्मिक कॉरिडोर, १०८ शिव तांडव स्तंभ व रूद्र सागर तट',
    },
    'bhartrihari_caves': {
      'name': 'Bhartrihari Caves',
      'hindiName': 'राजा भर्तृहरि गुफाएं',
      'lat': 23.2127,
      'lon': 75.7876,
      'icon': '⛰️',
      'type': 'historical',
      'description':
          'Ancient rock caves on Shipra banks where King Bhartrihari meditated and wrote Vairagya Shatakam',
      'hindiDescription':
          'राजा भर्तृहरि की पवित्र तपोभूमि जहाँ उन्होंने वैराग्य शतक की रचना की थी',
    },
    'siddhwat': {
      'name': 'Siddhwat Temple & Ghat',
      'hindiName': 'सिद्धवट तीर्थ (अमर वटवृक्ष)',
      'lat': 23.2198,
      'lon': 75.7845,
      'icon': '🌳',
      'type': 'ghat',
      'description':
          'Sacred immortal Banyan tree on Shipra banks revered for Pitru Tarpan, Pind Daan and Kal Sarp Dosh',
      'hindiDescription':
          'प्रयाग के अक्षयवट समान पवित्र सिद्धवट, पितृ मोक्ष, पिंडदान व कालसर्प दोष पूजा तीर्थ',
    },
    'vedhshala': {
      'name': 'Jantar Mantar (Vedhshala)',
      'hindiName': 'प्राचीन वेधशाला (जंतर मंतर)',
      'lat': 23.1705,
      'lon': 75.7725,
      'icon': '🔭',
      'type': 'monument',
      'description':
          'Astronomical observatory built in 1719 by Sawai Jai Singh at the ancient Prime Meridian of India',
      'hindiDescription':
          'सवाई जयसिंह द्वारा १७१९ में निर्मित प्राचीन खगोलीय वेधशाला (भारतीय ग्रीनविच)',
    },
    'iskcon_ujjain': {
      'name': 'ISKCON Temple Ujjain',
      'hindiName': 'इस्कॉन मंदिर (श्री श्री राधा मदनमोहन)',
      'lat': 23.1672,
      'lon': 75.8015,
      'icon': '🛕',
      'type': 'temple',
      'description':
          'Magnificent white marble Krishna-Balaram temple complex with Govinda restaurant and guest house',
      'hindiDescription':
          'श्वेत संगमरमर से निर्मित भव्य कृष्ण मंदिर एवं गोविंदम भोजनालय',
    },
    'kaliadeh_palace': {
      'name': 'Kaliadeh Palace',
      'hindiName': 'कालियादेह महल',
      'lat': 23.2530,
      'lon': 75.7950,
      'icon': '🏰',
      'type': 'historical',
      'description':
          'Historic island palace situated on Shipra river with ancient sun temple and river pools',
      'hindiDescription':
          'शिप्रा नदी के द्वीप पर स्थित ऐतिहासिक महल व प्राचीन सूर्य मंदिर',
    },
  };

  // ─── Major cities from Ujjain (straight-line distances in km) ─────────────
  static const Map<String, Map<String, dynamic>> _majorCities = {
    'indore': {
      'name': 'Indore',
      'hindi': 'इंदौर',
      'lat': 22.7196,
      'lon': 75.8577,
      'km': 55,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'bhopal': {
      'name': 'Bhopal',
      'hindi': 'भोपाल',
      'lat': 23.2599,
      'lon': 77.4126,
      'km': 185,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'mumbai': {
      'name': 'Mumbai',
      'hindi': 'मुंबई',
      'lat': 19.0760,
      'lon': 72.8777,
      'km': 660,
      'state': 'Maharashtra',
      'stateHindi': 'महाराष्ट्र',
    },
    'delhi': {
      'name': 'Delhi',
      'hindi': 'दिल्ली',
      'lat': 28.6139,
      'lon': 77.2090,
      'km': 880,
      'state': 'NCT Delhi',
      'stateHindi': 'दिल्ली',
    },
    'jaipur': {
      'name': 'Jaipur',
      'hindi': 'जयपुर',
      'lat': 26.9124,
      'lon': 75.7873,
      'km': 495,
      'state': 'Rajasthan',
      'stateHindi': 'राजस्थान',
    },
    'ahmedabad': {
      'name': 'Ahmedabad',
      'hindi': 'अहमदाबाद',
      'lat': 23.0225,
      'lon': 72.5714,
      'km': 395,
      'state': 'Gujarat',
      'stateHindi': 'गुजरात',
    },
    'nagpur': {
      'name': 'Nagpur',
      'hindi': 'नागपुर',
      'lat': 21.1458,
      'lon': 79.0882,
      'km': 520,
      'state': 'Maharashtra',
      'stateHindi': 'महाराष्ट्र',
    },
    'pune': {
      'name': 'Pune',
      'hindi': 'पुणे',
      'lat': 18.5204,
      'lon': 73.8567,
      'km': 580,
      'state': 'Maharashtra',
      'stateHindi': 'महाराष्ट्र',
    },
    'hyderabad': {
      'name': 'Hyderabad',
      'hindi': 'हैदराबाद',
      'lat': 17.3850,
      'lon': 78.4867,
      'km': 830,
      'state': 'Telangana',
      'stateHindi': 'तेलंगाना',
    },
    'varanasi': {
      'name': 'Varanasi',
      'hindi': 'वाराणसी (काशी)',
      'lat': 25.3176,
      'lon': 82.9739,
      'km': 930,
      'state': 'Uttar Pradesh',
      'stateHindi': 'उत्तर प्रदेश',
    },
    'mathura': {
      'name': 'Mathura',
      'hindi': 'मथुरा',
      'lat': 27.4924,
      'lon': 77.6737,
      'km': 720,
      'state': 'Uttar Pradesh',
      'stateHindi': 'उत्तर प्रदेश',
    },
    'shirdi': {
      'name': 'Shirdi',
      'hindi': 'शिर्डी',
      'lat': 19.7659,
      'lon': 74.4763,
      'km': 535,
      'state': 'Maharashtra',
      'stateHindi': 'महाराष्ट्र',
    },
    'gwalior': {
      'name': 'Gwalior',
      'hindi': 'ग्वालियर',
      'lat': 26.2183,
      'lon': 78.1828,
      'km': 450,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'jabalpur': {
      'name': 'Jabalpur',
      'hindi': 'जबलपुर',
      'lat': 23.1815,
      'lon': 79.9864,
      'km': 370,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'dewas': {
      'name': 'Dewas',
      'hindi': 'देवास',
      'lat': 22.9623,
      'lon': 76.0509,
      'km': 35,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'ratlam': {
      'name': 'Ratlam',
      'hindi': 'रतलाम',
      'lat': 23.3315,
      'lon': 75.0367,
      'km': 80,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'omkareshwar': {
      'name': 'Omkareshwar',
      'hindi': 'ओंकारेश्वर ज्योतिर्लिंग',
      'lat': 22.2434,
      'lon': 76.1499,
      'km': 135,
      'state': 'Madhya Pradesh',
      'stateHindi': 'मध्य प्रदेश',
    },
    'kashi': {
      'name': 'Kashi',
      'hindi': 'काशी',
      'lat': 25.3176,
      'lon': 82.9739,
      'km': 930,
      'state': 'Uttar Pradesh',
      'stateHindi': 'उत्तर प्रदेश',
    },
    'haridwar': {
      'name': 'Haridwar',
      'hindi': 'हरिद्वार',
      'lat': 29.9457,
      'lon': 78.1642,
      'km': 1050,
      'state': 'Uttarakhand',
      'stateHindi': 'उत्तराखंड',
    },
    'nashik': {
      'name': 'Nashik',
      'hindi': 'नासिक',
      'lat': 19.9975,
      'lon': 73.7898,
      'km': 500,
      'state': 'Maharashtra',
      'stateHindi': 'महाराष्ट्र',
    },
  };

  // Comprehensive Ujjain & Simhastha knowledge base for offline responses
  final Map<String, List<String>> _knowledgeBase = {
    'greeting': [
      'Namaste! Welcome to Ujjain Live. I\'m here to help you with everything about Ujjain and the sacred Simhastha Kumbh Mela. How can I assist you today?',
      'Har Har Mahadev! I\'m your spiritual guide to Ujjain and Simhastha. Whether you need temple information, accommodation, or pilgrimage guidance, I\'m here to help.',
      'Welcome to the holy city of Ujjain! I have comprehensive knowledge about Simhastha, temples, accommodations, and everything you need for your spiritual journey.',
    ],
    'greeting_hi': [
      'जय श्री महाकाल! 🙏 सिंहस्थ एआई सहायक में आपका हार्दिक स्वागत है। मैं उज्जैन के पावन मंदिरों, भस्म आरती, राम घाट और सिंहस्थ 2028 की संपूर्ण जानकारी 100% ऑफलाइन प्रदान करता हूँ। आज मैं आपकी क्या सहायता करूँ?',
      'हर हर महादेव! 🕉️ बाबा महाकाल की पवित्र नगरी अवंतिका (उज्जैन) में आपका स्वागत है। मंदिर दर्शन, ठहरने की व्यवस्था, भोजन या दूरी संबंधी कोई भी प्रश्न पूछें।',
      'नमस्ते एवं प्रणाम! 🙏 मैं आपका सिंहस्थ डिजिटल तीर्थ साथी हूँ। आप मुझसे हिंदी में मंदिरों का समय, आरती, दूरी, होटल या कुंभ मेले की कोई भी जानकारी ले सकते हैं।',
    ],
    'how_are_you': [
      'I\'m blessed to serve devotees visiting the sacred city of Ujjain during Simhastha! How can I help make your pilgrimage memorable?',
      'I\'m doing wonderfully, surrounded by the divine energy of Mahakaleshwar! How can I assist you with your Simhastha journey?',
      'I\'m spiritually energized and ready to guide you through Ujjain\'s sacred sites and Simhastha arrangements!',
    ],
    'how_are_you_hi': [
      'बाबा महाकाल की असीम अनुकम्पा से सब आनंदमय है! 🙏 भक्तों की सेवा और मार्गदर्शन करने में ही मेरा परम आनंद है। आपकी तीर्थ यात्रा कैसी चल रही है?',
      'हर हर महादेव! 🕉️ मैं पूरी तरह ऊर्जावान और आपकी सेवा हेतु तत्पर हूँ। बताइये, आज आपकी क्या सहायता करूँ?',
    ],
    'help': [
      'I can help you with comprehensive Simhastha and Ujjain guidance:\n\n🕉️ **Spiritual Services:**\n• Temple locations and darshan timings\n• Simhastha bathing ghats and auspicious times\n• Religious ceremonies and rituals\n• Sacred site information\n\n🏨 **Accommodation:**\n• Hotels near temples and ghats\n• Dharamshala and ashram options\n• Budget to luxury stays\n\n🍽️ **Food & Prasadam:**\n• Pure vegetarian restaurants\n• Local specialties and sweets\n• Temple prasadam information\n\n🚗 **Transportation:**\n• Local transport options\n• Temple connectivity\n• Parking information\n\n📍 **Smart Location Features (works offline!):**\n• "How far is Mahakaleshwar from here?" → gives distance from your location\n• "Nearest temple to me" → finds closest landmark\n• "Distance from Ujjain to Indore" → city-to-city distances\n• "How long to walk to Ram Ghat?" → travel time estimates\n\n🧮 **General Intelligence:**\n• Math calculations\n• Unit conversions (km↔miles, °C↔°F, kg↔lbs)\n• Current time and date\n• World facts and general knowledge\n\n📅 **Simhastha Events:**\n• Bathing dates and significance\n• Cultural programs and processions\n• Saints and spiritual leaders\n\nWhat specific information would you like?',
    ],
    'help_hi': [
      '🕉️ **सिंहस्थ एआई सहायक — मैं आपकी इन विषयों में पूर्ण सहायता कर सकता हूँ:**\n\n'
          '🙏 **मंदिर एवं दर्शन (ऑफलाइन):**\n'
          '• महाकालेश्वर, काल भैरव, हरसिद्धि, चिंतामन गणेश दर्शन समय\n'
          '• भस्म आरती नियम, समय एवं बुकिंग प्रक्रिया\n'
          '• राम घाट एवं शिप्रा महा आरती का समय\n\n'
          '📍 **लाइव जीपीएस दूरी एवं दिशा (बिना इंटरनेट!):**\n'
          '• "महाकालेश्वर कितनी दूर है" → आपके लाइव स्थान से दूरी\n'
          '• "सबसे पास का मंदिर" → निकटतम तीर्थ स्थल\n'
          '• "उज्जैन से इंदौर की दूरी" → सड़क व रेल मार्ग\n'
          '• "मैं कहाँ हूँ" → आपकी लाइव जीपीएस स्थिति\n\n'
          '🏨 **आवास एवं धर्मशालाएं:**\n'
          '• मंदिर के पास होटल, धर्मशालाएं एवं आश्रम\n'
          '• बजट, मिड-रेंज एवं प्रीमियम विश्राम स्थल\n\n'
          '🍽️ **भोजन एवं प्रसादम:**\n'
          '• शुद्ध शाकाहारी रेस्टोरेंट, दाल-बाफला, उज्जैनी पोहा\n'
          '• मंदिर प्रसादम एवं निशुल्क अन्नक्षेत्र\n\n'
          '📅 **सिंहस्थ महाकुंभ 2028:**\n'
          '• शाही स्नान की तिथियां, प्रमुख अखाड़े एवं घाट\n\n'
          '⏱️ **दैनिक सुविधाएं:**\n'
          '• समय, आज की तारीख, उज्जैन का मौसम, गणित गणनाएं व मंत्र\n\n'
          'आप अपना प्रश्न हिंदी या हिंग्लिश में निस्संकोच पूछ सकते हैं!',
    ],
    'joke': [
      'Why did Lord Shiva choose Ujjain for his abode? Because even gods prefer prime real estate! 🕉️',
      'What did one pilgrim say to another at Simhastha? "I\'ve never seen so many people in one place... it must be a sign from above!" 😄',
      'Why do devotees love visiting Ujjain? Because it\'s the only place where you can get a cosmic blessing and great street food in the same block!',
      'What\'s a pilgrim\'s favorite type of music? Devotional songs... but they also love the sound of temple bells! 🔔',
    ],
    'joke_hi': [
      'एक भक्त ने दूसरे से पूछा: "उज्जैन में सबसे जल्दी मनोकामना कहाँ पूरी होती है?"\nदूसरा बोला: "पोहा-जलेबी की दुकान पर, मांगते ही तुरंत थाली सामने आ जाती है!" 😄 🕉️',
      'सिंहस्थ मेले में एक भक्त बोला: "यहाँ इतनी भीड़ है कि अगर आंख बंद करके हर हर महादेव बोलूं, तो 10 लोग मुझे आशीर्वाद देकर आगे बढ़ा देते हैं!" 🔔',
    ],
    'motivation': [
      'Your spiritual journey to Ujjain is a blessed one. Every step you take in this sacred city brings you closer to divine grace and inner peace.',
      'In the sacred presence of Mahakaleshwar, remember that you are part of an ancient tradition of seekers. Your pilgrimage is meaningful and blessed.',
      'The fact that you\'re visiting during Simhastha shows your spiritual calling. Trust in the divine plan and embrace this sacred opportunity.',
      'Ujjain\'s divine energy will guide and protect you. Your devotion and faith are your greatest strengths on this spiritual journey.',
    ],
    'motivation_hi': [
      'काल भी उसका क्या बिगाड़े, जो भक्त हो महाकाल का! 🙏 अपनी आस्था और विश्वास को अडिग रखें। बाबा महाकाल आपके जीवन के सभी विघ्न हर लेंगे। हर हर महादेव!',
      'उज्जैन की इस पावन धरा पर रखा आपका प्रत्येक कदम पुण्यदायी है। पवित्र शिप्रा और महाकाल की कृपा सदैव आपके और आपके परिवार के साथ रहे।',
      'चिंता को चिंतामन गणेश जी के चरणों में समर्पित कर दें और निर्भय होकर अपनी यात्रा करें। भगवान शिव का आशीर्वाद आपके साथ है। 🕉️',
    ],
    'default': [
      'That\'s a wonderful question about Ujjain or Simhastha! Let me share what I know about that topic.',
      'I\'m happy to help with any information about the sacred city of Ujjain and the blessed Simhastha Kumbh Mela.',
      'Great question! I have detailed knowledge about Ujjain\'s spiritual significance and Simhastha arrangements.',
      'I\'d be delighted to assist you with that aspect of your Ujjain pilgrimage or Simhastha experience.',
    ],
    'default_hi': [
      'यह उज्जैन और सिंहस्थ तीर्थ से जुड़ा बहुत सुंदर प्रश्न है! 🙏\n\nमैं आपको निम्नलिखित विषयों पर 100% ऑफलाइन संपूर्ण जानकारी दे सकता हूँ:\n• 🕉️ **मंदिर दर्शन एवं भस्म आरती का समय**\n• 📍 **आपके वर्तमान GPS से मंदिरों की दूरी व रास्ता**\n• 🏨 **रुकने के लिए होटल व धर्मशालाएं**\n• 🍽️ **शुद्ध शाकाहारी भोजन व उज्जैनी स्वाद**\n• 📅 **सिंहस्थ 2028 शाही स्नान तिथियां**\n\nकृपया अपना प्रश्न पूछें, जैसे: *"महाकालेश्वर कितनी दूर है"*, *"भस्म आरती का समय"*, या *"होटल बताओ"*। हर हर महादेव!',
    ],
  };

  // Conversation context tracker
  late Map<String, dynamic> _conversationContext = {};
  String _responseLanguage = 'hi';
  late List<String> _recentTopics = [];

  // Track recent topics for follow-up questions
  void _updateContext(String intent, String originalMessage) {
    _recentTopics.add(intent);
    if (_recentTopics.length > 5) {
      _recentTopics.removeAt(0);
    }

    _conversationContext = {
      'lastIntent': intent,
      'lastMessage': originalMessage,
      'timestamp': DateTime.now(),
      'recentTopics': List.from(_recentTopics),
    };
  }

  // Get context for understanding follow-up questions
  Map<String, dynamic> getConversationContext() => _conversationContext;
  List<String> getRecentTopics() => _recentTopics;

  // Comprehensive Ujjain & Simhastha database
  final Map<String, dynamic> _ujjainData = {
    'hotels': [
      {
        'name': 'Hotel Avantika',
        'area': 'Dewas Gate',
        'rating': 4.4,
        'price': 'Premium',
        'distance': '0.5 km from Mahakaleshwar',
        'highlight':
            'Luxury accommodation with temple proximity and modern amenities',
        'features': [
          'AC Rooms',
          'Restaurant',
          'Room Service',
          'Parking',
          'Temple Transport',
        ],
      },
      {
        'name': 'Hotel Rudra Palace',
        'area': 'Mahakal Road',
        'rating': 4.2,
        'price': 'Mid-range',
        'distance': '0.3 km from Mahakaleshwar',
        'highlight': 'Perfect location for Bhasma Aarti and temple visits',
        'features': [
          'AC/Non-AC Rooms',
          'Pure Veg Restaurant',
          'Early Morning Service',
          'Temple Guide',
        ],
      },
      {
        'name': 'Hotel Shipra Residency',
        'area': 'University Road',
        'rating': 4.3,
        'price': 'Mid-range',
        'distance': '1.2 km from Ram Ghat',
        'highlight':
            'Modern hotel with Shipra River views and Simhastha arrangements',
        'features': [
          'River View Rooms',
          'Multi-cuisine Restaurant',
          'Event Hall',
          'Shuttle Service',
        ],
      },
      {
        'name': 'Dharamshala Mahakaleshwar',
        'area': 'Temple Complex',
        'rating': 4.0,
        'price': 'Budget',
        'distance': '0.1 km from Mahakaleshwar',
        'highlight': 'Temple-run accommodation for genuine pilgrims',
        'features': [
          'Basic Clean Rooms',
          'Shared Facilities',
          'Prasadam Meals',
          'Prayer Hall',
        ],
      },
      {
        'name': 'Simhastha Guest House',
        'area': 'Ram Ghat Road',
        'rating': 4.5,
        'price': 'Premium',
        'distance': '0.2 km from Ram Ghat',
        'highlight':
            'Specially designed for Simhastha pilgrims with ghat proximity',
        'features': [
          'Ghat View Rooms',
          'Early Morning Boat Service',
          'Spiritual Library',
          'Meditation Hall',
        ],
      },
      {
        'name': 'Hotel Imperial',
        'area': 'Dewas Gate',
        'rating': 4.1,
        'price': 'Mid-range',
        'distance': '0.8 km from Mahakaleshwar',
        'highlight': 'Established hotel with reliable service for families',
        'features': [
          'Family Rooms',
          'Pure Veg Food',
          'Travel Desk',
          'Laundry Service',
        ],
      },
    ],
    'restaurants': [
      {
        'name': 'Apna Sweets & Restaurant',
        'cuisine': 'Pure Vegetarian',
        'area': 'Dewas Gate',
        'rating': 4.6,
        'price': 'Budget',
        'specialties': [
          'Ujjaini Poha',
          'Malpua',
          'Samosa',
          'Traditional Thali',
        ],
        'highlight': 'Famous for authentic Ujjaini breakfast and sweets',
      },
      {
        'name': 'Shree Ganga Restaurant',
        'cuisine': 'North Indian Vegetarian',
        'area': 'Mahakal Road',
        'rating': 4.3,
        'price': 'Budget',
        'specialties': [
          'Dal Bafla',
          'Gujarati Thali',
          'South Indian',
          'Chinese',
        ],
        'highlight': 'Multi-cuisine pure veg restaurant near temple',
      },
      {
        'name': 'Hotel Avantika Restaurant',
        'cuisine': 'Multi-cuisine Vegetarian',
        'area': 'Dewas Gate',
        'rating': 4.4,
        'price': 'Mid-range',
        'specialties': [
          'Rajasthani Thali',
          'Punjabi Cuisine',
          'Continental',
          'Jain Food',
        ],
        'highlight': 'Upscale dining with variety of regional cuisines',
      },
      {
        'name': 'Prasadam Bhandar',
        'cuisine': 'Temple Food',
        'area': 'Mahakaleshwar Temple',
        'rating': 4.5,
        'price': 'Budget',
        'specialties': ['Temple Prasadam', 'Simple Meals', 'Holy Offerings'],
        'highlight': 'Sacred food blessed by the temple',
      },
    ],
    'temples': [
      {
        'name': 'Mahakaleshwar Jyotirlinga',
        'hindiName': 'श्री महाकालेश्वर ज्योतिर्लिंग',
        'significance': 'One of 12 Jyotirlingas, most sacred Shiva temple',
        'hindiSignificance':
            'भगवान शिव के 12 ज्योतिर्लिंगों में एकमात्र दक्षिणमुखी ज्योतिर्लिंग',
        'timing': 'Bhasma Aarti: 4:00 AM, Regular Darshan: 6:00 AM - 11:00 PM',
        'hindiTiming':
            'भस्म आरती: प्रातः 4:00 AM, सामान्य दर्शन: प्रातः 6:00 AM से रात्रि 11:00 PM',
        'specialFeatures': [
          'Dakshinmukhi Lingam',
          'Bhasma Aarti',
          'Underground Sanctum',
          'Nagchandreshwar (Nag Panchami only)',
        ],
        'tips': 'Book Bhasma Aarti online, arrive 1 hour early',
        'hindiTips':
            'भस्म आरती हेतु अग्रिम ऑनलाइन बुकिंग आवश्यक, पारंपरिक वस्त्र अनिवार्य',
      },
      {
        'name': 'Kal Bhairav Temple',
        'hindiName': 'श्री काल भैरव मंदिर',
        'significance': 'Guardian deity of Ujjain, Kotwal of the city',
        'hindiSignificance': 'उज्जैन के सेनापति एवं नगर रक्षक (कोतवाल)',
        'timing': '6:00 AM - 10:00 PM',
        'hindiTiming': 'प्रातः 6:00 AM से रात्रि 10:00 PM',
        'specialFeatures': [
          'Liquor offering tradition',
          'Ancient architecture',
          'Tantric significance',
        ],
        'tips': 'Visit early morning for peaceful darshan',
        'hindiTips':
            'महाकाल दर्शन के पश्चात काल भैरव दर्शन से यात्रा पूर्ण मानी जाती है',
      },
      {
        'name': 'Harsiddhi Temple',
        'hindiName': 'माँ हरसिद्धि शक्तिपीठ',
        'significance': 'One of 51 Shakti Peethas, Goddess Annapurna',
        'hindiSignificance': '51 शक्तिपीठों में से एक (सती की कोहनी गिरी थी)',
        'timing': '5:00 AM - 11:00 PM',
        'hindiTiming': 'प्रातः 5:00 AM से रात्रि 11:00 PM',
        'specialFeatures': [
          'Shakti Peeth',
          'Deepstambh (Lamp Pillars)',
          'Sri Yantra',
        ],
        'tips':
            'Tuesday and Friday are especially auspicious; evening deepstambh lighting at 7 PM',
        'hindiTips':
            'संध्या 7:00 PM पर विशाल दीप स्तंभ प्रज्ज्वलन का अलौकिक दृश्य अवश्य देखें',
      },
      {
        'name': 'Chintaman Ganesh Temple',
        'hindiName': 'श्री चिंतामन गणेश मंदिर',
        'significance': 'Ancient wish-fulfilling Ganesh temple',
        'hindiSignificance':
            'भक्तों की सभी चिंताएं हरने वाले प्राचीन स्वयंभू गणेश',
        'timing': '6:00 AM - 9:00 PM',
        'hindiTiming': 'प्रातः 6:00 AM से रात्रि 9:00 PM',
        'specialFeatures': [
          'Three deities: Chintaman, Icchaman, Siddhivinayak',
          'Sita Baoli',
        ],
        'tips': 'Wednesday is particularly auspicious',
        'hindiTips': 'बुधवार को दर्शन विशेष फलदायी माना जाता है',
      },
      {
        'name': 'Mangalnath Temple',
        'hindiName': 'श्री मंगलनाथ मंदिर',
        'significance':
            'Birthplace of Mars (Mangal Graha) as per Matsya Purana',
        'hindiSignificance':
            'पुराणों अनुसार मंगल ग्रह की जन्मस्थली एवं भात पूजा स्थल',
        'timing': '6:00 AM - 8:30 PM',
        'hindiTiming': 'प्रातः 6:00 AM से रात्रि 8:30 PM',
        'specialFeatures': ['Bhat Puja for Manglik Dosha', 'Shipra view'],
        'tips': 'Tuesday is ideal for Mangal Shanti and Bhat Puja',
        'hindiTips': 'मंगल दोष निवारण हेतु मंगलवार को भात पूजा की जाती है',
      },
      {
        'name': 'Gadkalika Temple',
        'hindiName': 'माँ गढ़कालिका मंदिर',
        'significance':
            'Ancient shrine of Goddess Kalika, worshipped by poet Kalidasa',
        'hindiSignificance':
            'महाकवि कालिदास की आराध्य देवी, ज्ञान व विद्या प्रदायिनी',
        'timing': '6:00 AM - 9:00 PM',
        'hindiTiming': 'प्रातः 6:00 AM से रात्रि 9:00 PM',
        'specialFeatures': [
          'Navratri celebrations',
          'Ancient Kalidasa association',
        ],
        'tips': 'Navratri and Fridays are special',
        'hindiTips':
            'विद्यार्थियों व बुद्धि-विद्या की कामना करने वालों हेतु विशेष फलदायी',
      },
      {
        'name': 'Sandipani Ashram',
        'hindiName': 'महर्षि सांदीपनि आश्रम',
        'significance':
            'School where Lord Krishna, Balarama and Sudama studied 64 arts',
        'hindiSignificance':
            'भगवान श्री कृष्ण, बलराम एवं सुदामा की प्राचीन विद्यास्थली',
        'timing': '7:00 AM - 7:00 PM',
        'hindiTiming': 'प्रातः 7:00 AM से सायं 7:00 PM',
        'specialFeatures': [
          'Kundeshwar Mahadev',
          'Gomti Kund',
          'Ancient slate stone (Ankpat)',
        ],
        'tips': 'Peaceful, meditative environment',
        'hindiTips':
            'यहाँ अंकपात कुंड स्थित है जहाँ भगवान कृष्ण अपनी पाटी धोते थे',
      },
      {
        'name': 'Ram Ghat',
        'hindiName': 'राम घाट (शिप्रा नदी)',
        'significance':
            'Primary bathing ghat on holy Shipra river, Simhastha Kumbh epicenter',
        'hindiSignificance':
            'सिंहस्थ कुंभ का मुख्य शाही स्नान घाट एवं पावन तीर्थ',
        'timing': 'Open 24 hours; Evening Maha Aarti at 7:00 PM daily',
        'hindiTiming':
            '24 घंटे खुला; प्रतिदिन सायं 7:00 PM भव्य शिप्रा महाआरती',
        'specialFeatures': [
          'Daily Shipra Maha Aarti',
          'Historical ghats',
          'Holy dip for purification',
        ],
        'tips':
            'Take early morning holy dip, attend evening Aarti with floating diyas',
        'hindiTips':
            'प्रातः ब्रह्म मुहूर्त में स्नान करें एवं सायं दीपदान महाआरती में सम्मिलित हों',
      },
    ],
    'simhastha_info': {
      'nextDate': '2028 (Every 12 years)',
      'duration': '1 month (April-May typically)',
      'significance': 'When Jupiter enters Leo constellation',
      'expectedVisitors': '10-15 million pilgrims',
      'mainEvents': [
        'Royal Bath (Shahi Snan) by saints',
        'Processions of various Akharas',
        'Cultural programs and spiritual discourses',
        'Mass bathing on auspicious dates',
      ],
    },
  };

  bool _isHindiQuery(String _) =>
      _responseLanguage.toLowerCase().startsWith('hi');

  Future<String> generateOfflineResponse({
    required String userMessage,
    required ChatSession session,
    LocationInfo? locationInfo,
    String responseLanguage = 'hi',
    QueryAnalysis? queryAnalysis, // Optional: Enhanced context from Query Agent
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    _responseLanguage = responseLanguage;
    final message = userMessage.toLowerCase().trim();
    final isHindi = responseLanguage.toLowerCase().startsWith('hi');

    // ═══════════════════════════════════════════════════════════════════
    // USE QUERY AGENT ANALYSIS IF AVAILABLE
    // Query Agent provides enhanced intent detection and entity extraction
    // ═══════════════════════════════════════════════════════════════════
    if (queryAnalysis != null) {
      print('[OfflineAI] 🧠 Using Query Agent analysis:');
      print('  Intent: ${queryAnalysis.intent.primaryIntent}');
      print('  Confidence: ${(queryAnalysis.confidenceScore * 100).toStringAsFixed(1)}%');
      
      // Use extracted entities to enhance response
      final entities = queryAnalysis.extractedEntities;
      if (entities.isNotEmpty) {
        print('[OfflineAI] 📦 Extracted entities: $entities');
      }
    }

    final ujjainIntent = UjjainGuideAgent.offlineIntentFor(
      userMessage,
      previousIntent: _conversationContext['lastIntent']?.toString(),
    );
    if (ujjainIntent != null) {
      _updateContext(ujjainIntent, userMessage);
      return UjjainGuideAgent.answerOffline(
        ujjainIntent,
        userMessage,
        isHindi: isHindi,
      );
    }

    // ── 0. Check for user's own location / coordinates request ──────────────
    final isMyLocationQuery = _containsAny(message, [
      'where am i',
      'my location',
      'my coordinates',
      'my cords',
      'my cord',
      'current location',
      'current coordinates',
      'current cords',
      'current cord',
      'show my location',
      'mera location',
      'meri location',
      'apna location',
      'hum kahan hai',
      'main kahan hoon',
      'mai kahan hu',
      'kahan hu mai',
      'show coordinates',
      'what are my coordinates',
      'what is my location',
      'मैं कहाँ हूँ',
      'मेरी लोकेशन',
      'मेरा स्थान',
      'हम कहाँ हैं',
      'मेरे निर्देशांक',
      'मेरी स्थिति',
    ]);
    if (isMyLocationQuery) {
      final loc =
          locationInfo ??
          await LocationService().getCurrentLocation(forceRefresh: true);
      _updateContext('my_location', userMessage);
      if (loc != null) {
        return _generateUserLocationReport(loc, isHindi: isHindi);
      } else {
        if (isHindi) {
          return '📍 **आपके GPS निर्देशांक प्राप्त नहीं हो सके।**\n\n'
              'कृपया सुनिश्चित करें:\n'
              '1. आपके फ़ोन की सेटिंग में **Location / GPS** चालू (ON) है।\n'
              '2. ऐप को लोकेशन अनुमति दी गई है।\n\n'
              'लोकेशन चालू होने के बाद "मैं कहाँ हूँ" या "मेरी लोकेशन" पूछें और मैं आपको लाइव GPS निर्देशांक दिखाऊंगा!';
        }
        return '📍 **Unable to detect your GPS coordinates.**\n\n'
            'Please ensure:\n'
            '1. **Location / GPS** is turned ON in your phone settings.\n'
            '2. Location permission is allowed for this app.\n\n'
            'Once enabled, ask "where am I" or "my cords" and I will display your live GPS coordinates!';
      }
    }

    // ── 1. Sacred Mantras, Aarti Schedule & Rituals ──────────────────────────
    final spiritualResult = _tryAnswerSpiritualQuery(message, isHindi);
    if (spiritualResult != null) {
      _updateContext('spiritual_query', userMessage);
      return spiritualResult;
    }

    // ── 2. Current time / date query ─────────────────────────────────────────
    final timeResult = _tryAnswerTimeDate(message, isHindi: isHindi);
    if (timeResult != null) {
      _updateContext('time_date', userMessage);
      return timeResult;
    }

    // ── 3. Distance / travel queries (location-aware + city-to-city) ─────────
    final distanceResult = await _tryAnswerDistanceQuery(
      message,
      locationInfo,
      isHindi: isHindi,
    );
    if (distanceResult != null) {
      _updateContext('distance_query', userMessage);
      return distanceResult;
    }

    // ── 4. "Nearest X to me" query ────────────────────────────────────────────
    final nearestResult = await _tryAnswerNearestQuery(
      message,
      locationInfo,
      isHindi: isHindi,
    );
    if (nearestResult != null) {
      _updateContext('nearest_query', userMessage);
      return nearestResult;
    }

    // ── 5. Unit conversion queries ────────────────────────────────────────────
    final conversionResult = _tryAnswerUnitConversion(message);
    if (conversionResult != null) {
      _updateContext('unit_conversion', userMessage);
      return conversionResult;
    }

    // ── 6. General world knowledge ────────────────────────────────────────────
    final generalResult = _tryAnswerGeneralKnowledge(message, isHindi: isHindi);
    if (generalResult != null) {
      _updateContext('general_knowledge', userMessage);
      return generalResult;
    }

    // ── 7. Follow-up context ──────────────────────────────────────────────────
    String? followUpResponse = _detectFollowUpQuestion(message, session);
    if (followUpResponse != null) {
      return followUpResponse;
    }

    // ── 8. Math calculations ──────────────────────────────────────────────────
    if (_containsMathKeywords(message)) {
      final mathResult = _tryCalculateMath(message);
      if (mathResult != null) {
        _updateContext('math', userMessage);
        return mathResult;
      }
    }

    // ── 9. Ujjain History, Mahakal Lok, Sightseeing & Heritage ────────────────
    final ujjainSpecific = _tryAnswerUjjainQuery(message, isHindi);
    if (ujjainSpecific != null) {
      _updateContext('ujjain_info', userMessage);
      return ujjainSpecific;
    }

    // ── 10. Ujjain-specific queries with smart responses ──────────────────────
    if (_containsHotelKeywords(message)) {
      _updateContext('hotel_inquiry', userMessage);
      return _generateSmartHotelResponse(userMessage);
    }

    if (_containsRestaurantKeywords(message)) {
      _updateContext('restaurant_inquiry', userMessage);
      return _generateSmartRestaurantResponse(userMessage);
    }

    if (_containsTempleKeywords(message)) {
      _updateContext('temple_inquiry', userMessage);
      return _generateSmartTempleResponse(userMessage);
    }

    if (_containsSimhasthaKeywords(message)) {
      _updateContext('simhastha_inquiry', userMessage);
      return _generateSmartSimhasthaResponse(userMessage);
    }

    // Determine response category for other queries
    String category = _categorizeMessage(message, isHindi: isHindi);
    _updateContext(category, userMessage);
    final responses =
        _knowledgeBase[category] ??
        _knowledgeBase[isHindi ? 'default_hi' : 'default']!;
    return responses[Random().nextInt(responses.length)];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — Sacred Prayers, Mantras & Aarti Schedules
  // ═══════════════════════════════════════════════════════════════════════════
  String? _tryAnswerSpiritualQuery(String message, bool isHindi) {
    // 1. Mahamrityunjaya Mantra
    if (_containsAny(message, [
      'mahamrityunjaya',
      'mrityunjay',
      'mrityunjaya',
      'महामृत्युंजय',
      'मृत्युंजय मंत्र',
    ])) {
      return '🕉️ **श्री महामृत्युंजय मंत्र (ऋग्वेद / यजुर्वेद):**\n\n'
          '**ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।**\n'
          '**उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्॥**\n\n'
          '✨ **भावार्थ:**\n'
          'हम त्रिनेत्रधारी भगवान शिव की आराधना करते हैं, जो समस्त संसार में सुगंध फैलाते हैं और सभी का पोषण करते हैं। जैसे पका हुआ फल डाली के बंधन से सहज ही मुक्त हो जाता है, वैसे ही हम भी मृत्यु और संसार के बंधनों से मुक्त हों, और हमें मोक्ष व अमरत्व की प्राप्ति हो।\n\n'
          '🙏 _उज्जैन महाकाल मंदिर में महामृत्युंजय जप का असीम पुण्य है।_';
    }

    // 2. Shiv Tandav Stotram
    if (_containsAny(message, [
      'tandav',
      'shiv tandav',
      'taandav',
      'तांडव',
      'शिव तांडव',
      'रावण स्तुति',
    ])) {
      return '🕉️ **श्री शिव तांडव स्तोत्रम् (आरंभिक श्लोक):**\n\n'
          '**जटाटवीगलज्जलप्रवाहपावितस्थले**\n'
          '**गलेऽवलम्ब्य लम्बितां भुजङ्गतुङ्गमालिकाम्।**\n'
          '**डमड्डमड्डमड्डमन्निनादवड्डमर्वयं**\n'
          '**चकार चण्डताण्डवं तनोतु नः शिवः शिवम्॥**\n\n'
          '✨ **भावार्थ:**\n'
          'जिनके सघन जटा रूपी वन से निकलती गंगा की पवित्र धाराएं कंठ को पावन कर रही हैं, जिनके गले में सर्पराज की माला सुशोभित है, और डमरू की \'डम-डम\' ध्वनि के साथ जो प्रचंड तांडव नृत्य करते हैं, वे देवाधिदेव भगवान शिव हमारा कल्याण करें!\n\n'
          '🙏 _महाराज रावण द्वारा रचित यह स्तोत्र शक्ति और भक्ति का अद्भुत संगम है।_';
    }

    // 3. Om Namah Shivaya / Panchakshar
    if (_containsAny(message, [
      'om namah shivay',
      'om namah shivaya',
      'panchakshar',
      'पंचाक्षर',
      'नमः शिवाय',
      'ॐ नमः शिवाय',
    ])) {
      return '🕉️ **श्री शिव पंचाक्षर स्तोत्रम्:**\n\n'
          '**नागेन्द्रहाराय त्रिलोचनाय भस्माङ्गरागाय महेश्वराय।**\n'
          '**नित्याय शुद्धाय दिगम्बराय तस्मै नकाराय नमः शिवाय॥**\n\n'
          '✨ **पंचतत्व मन्त्र:** ॐ नमः शिवाय (न - पृथ्वी, म - जल, शि - अग्नि, वा - वायु, य - आकाश)\n\n'
          '🙏 _"हर हर महादेव! ॐ नमः शिवाय"_';
    }

    // 4. Mahakal 5 Aarti Schedule
    if (_containsAny(message, [
      'aarti schedule',
      'all aarti',
      'panch aarti',
      'आरती समय',
      'पांचों आरती',
      'आरती की सूची',
      'आरती कब कब',
      'आरती का समय',
    ])) {
      return '🕉️ **श्री महाकालेश्वर मंदिर की प्रतिदिन की ५ दिव्य आरतियां:**\n\n'
          '1. 🌅 **भस्म आरती:** प्रातः 4:00 AM से 6:00 AM (अग्रिम ऑनलाइन बुकिंग अनिवार्य)\n'
          '2. 🥛 **दद्योदक आरती:** प्रातः 7:30 AM से 8:15 AM (दही व दूध से अभिषेक)\n'
          '3. 🍲 **भोग आरती:** प्रातः 10:30 AM से 11:15 AM (भगवान को नैवेद्य अर्पण)\n'
          '4. 🌺 **संध्या आरती:** सायं 5:00 PM से 5:45 PM (पुष्प एवं धूप श्रृंगार)\n'
          '5. 🌙 **शयन आरती:** रात्रि 10:30 PM से 11:00 PM (दिन की अंतिम आरती)\n\n'
          '💡 _सामान्य दर्शन सुबह 6:00 AM से रात 11:00 PM तक निरंतर चलते हैं।_';
    }

    // 5. Bhasma Aarti Rules, Timing & Dress Code
    if (_containsAny(message, [
      'bhasma aarti',
      'bhasma aarti time',
      'bhasma aarti timing',
      'bhasma aarti dress',
      'bhasma aarti rule',
      'bhasma aarti booking',
      'भस्म आरती',
      'भस्म आरती का समय',
      'भस्म आरती कब',
      'भस्म आरती नियम',
      'भस्म आरती ड्रेस',
      'भस्म आरती बुकिंग',
    ])) {
      return '🕉️ **श्री महाकालेश्वर भस्म आरती — समय, नियम एवं प्रक्रिया:**\n\n'
          '⏰ **समय:** प्रतिदिन प्रातः 4:00 AM से 6:00 AM\n'
          '🎫 **बुकिंग माध्यम:** shrimahakaleshwar.com (मंदिर प्रबंध समिति की आधिकारिक साइट से अग्रिम ऑनलाइन बुकिंग अनिवार्य)\n\n'
          '👕 **वस्त्र संहिता (Dress Code):**\n'
          '• 👨 **पुरुषों हेतु:** बिना सिला हुआ सूती धोती व सोला (अंगवस्त्र) — जींस, पैंट या टी-शर्ट में नंदी हॉल प्रवेश नहीं है।\n'
          '• 👩 **महिलाओं हेतु:** पारंपरिक भारतीय साड़ी (सलवार सूट या पाश्चात्य वस्त्र अनुमति नहीं है)।\n\n'
          '🚶 **प्रवेश समय:** प्रातः 3:00 AM से कतार प्रारंभ होती है।\n'
          '📵 **नियम:** गर्भगृह एवं नंदी हॉल में मोबाइल फोन ले जाना पूर्णतः प्रतिबंधित है।\n\n'
          '✨ **विशेषता:** विश्व में केवल महाकाल मंदिर में ही प्रतिदिन ताज़ी भस्म से देवाधिदेव का श्रृंगार होता है।\n\n'
          '🙏 _हर हर महादेव!_';
    }

    // 6. Shipra River Significance
    if (_containsAny(message, [
      'shipra river',
      'shipra mahatmya',
      'शिप्रा नदी',
      'शिप्रा का महत्व',
      'मोक्षदायिनी',
    ])) {
      return '🌊 **पावन मोक्षदायिनी शिप्रा नदी का महात्म्य:**\n\n'
          '• **अमृत मंथन संबंध:** समुद्र मंथन के समय जब अमृत कलश छलका, तो उसकी पावन बूंदें शिप्रा नदी में गिरी थीं।\n'
          '• **सिंहस्थ कुंभ स्थल:** इसी पवित्र नदी के राम घाट पर प्रत्येक 12 वर्ष में सिंहस्थ महाकुंभ का शाही स्नान होता है।\n'
          '• **पुण्य मान्यता:** स्कंद पुराण के अवंतिका खंड अनुसार शिप्रा में मात्र एक स्नान से अश्वमेध यज्ञ के समान पुण्य प्राप्त होता है।\n'
          '• **संध्या महाआरती:** राम घाट पर प्रतिदिन सायं 7:00 बजे भव्य शिप्रा महा आरती का आयोजन होता है।\n\n'
          '🙏 _"नमामि देवी नर्मदे, वन्दे शिप्रां मोक्षदाम्!"_';
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — Time / Date
  // ═══════════════════════════════════════════════════════════════════════════
  String? _tryAnswerTimeDate(String message, {bool isHindi = false}) {
    // If it's asking for temple or aarti or darshan timing, let spiritual/temple engines handle it!
    if (_containsAny(message, [
      'aarti',
      'आरती',
      'bhasma',
      'भस्म',
      'darshan',
      'दर्शन',
      'mandir',
      'मंदिर',
    ])) {
      return null;
    }

    final isTime = _containsAny(message, [
      'what time',
      'current time',
      'time now',
      'kitna baj',
      'time bata',
      'abhi kitne baje',
      'समय क्या',
      'कितने बजे',
      'टाइम क्या',
      'समय बताओ',
      'अभी क्या समय',
    ]);
    final isDate = _containsAny(message, [
      'what date',
      'today date',
      'what day',
      'aaj kya date',
      'date today',
      'which day',
      'aaj kaun sa din',
      'आज क्या तारीख',
      'आज कौन सा दिन',
      'आज की तारीख',
      'तारीख बताओ',
    ]);
    final isYear = _containsAny(message, [
      'which year',
      'current year',
      'kaun sa saal',
      'kaunsa saal',
      'कौन सा साल',
      'साल क्या',
    ]);
    final isDayOfWeek = _containsAny(message, [
      'what day is today',
      'aaj kya din hai',
      'which day is today',
      'आज क्या दिन है',
      'आज कौन सा वार है',
    ]);

    if (!isTime && !isDate && !isYear && !isDayOfWeek) return null;

    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final hindiDays = [
      'सोमवार',
      'मंगलवार',
      'बुधवार',
      'गुरुवार',
      'शुक्रवार',
      'शनिवार',
      'रविवार',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hindiMonths = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर',
    ];

    final dayIndex = now.weekday - 1;
    final dayName = days[dayIndex];
    final hindiDayName = hindiDays[dayIndex];
    final monthName = months[now.month - 1];
    final hindiMonthName = hindiMonths[now.month - 1];

    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final minStr = now.minute.toString().padLeft(2, '0');

    if (isTime) {
      if (isHindi) {
        return '🕐 **वर्तमान समय:** $hour12:$minStr $ampm (भारतीय मानक समय - IST)\n'
            '📍 भारत मानक समय (UTC+5:30)\n\n'
            '🕉️ _"काल भी उसका क्या बिगाड़े, जो भक्त हो महाकाल का — हर हर महादेव!"_';
      }
      return '🕐 **Current Time:** $hour12:$minStr $ampm (IST)\n'
          '📍 India Standard Time (UTC+5:30)\n\n'
          '🕉️ _"Time flows like the sacred Shipra River — ever onwards!"_';
    }
    if (isDayOfWeek || (isDate && !isYear)) {
      if (isHindi) {
        return '📅 **आज की तारीख:** ${now.day} $hindiMonthName ${now.year} ($hindiDayName)\n'
            '🕐 **समय:** $hour12:$minStr $ampm IST\n\n'
            '${_getHindiDayInsight(dayName)}';
      }
      return '📅 **Today is:** $dayName, ${now.day} $monthName ${now.year}\n'
          '🕐 **Time:** $hour12:$minStr $ampm IST\n\n'
          '${_getDayInsight(dayName)}';
    }
    if (isYear) {
      if (isHindi) {
        return '📅 **वर्तमान वर्ष:** ${now.year}\n'
            '🗓️ **आज की तारीख:** ${now.day} $hindiMonthName ${now.year} ($hindiDayName)';
      }
      return '📅 **Current Year:** ${now.year}\n'
          '🗓️ **Today:** ${now.day} $monthName ${now.year} ($dayName)';
    }
    return null;
  }

  String _getDayInsight(String day) {
    const insights = {
      'Monday':
          '🙏 Monday is sacred to Lord Shiva! Perfect day to visit Mahakaleshwar.',
      'Tuesday':
          '🌺 Tuesday is auspicious for Goddess Harsiddhi! Great day for her darshan.',
      'Wednesday':
          '📚 Wednesday is dedicated to Lord Ganesha — Chintaman Ganesh is ideal today.',
      'Thursday':
          '🟡 Brihaspativar — sacred to Guru (Jupiter). Excellent for spiritual learning.',
      'Friday':
          '🌺 Friday (Shukravar) is blessed for Mata Harsiddhi and Kal Bhairav.',
      'Saturday':
          '⚫ Saturday — sacred to Kal Bhairav and Shani. Visit Kal Bhairav temple.',
      'Sunday':
          '☀️ Sunday — Aaditya/Ravi day. Temples are busiest — arrive very early!',
    };
    return insights[day] ?? '';
  }

  String _getHindiDayInsight(String day) {
    const insights = {
      'Monday':
          '🙏 सोमवार देवाधिदेव भगवान शिव का पावन दिन है! महाकालेश्वर दर्शन हेतु सर्वोत्तम दिन।',
      'Tuesday':
          '🌺 मंगलवार माँ हरसिद्धि व मंगलनाथ का दिन है! माँ की आराधना से संकट दूर होते हैं।',
      'Wednesday':
          '🐘 बुधवार श्री चिंतामन गणेश जी को समर्पित है! विघ्नहर्ता का आशीर्वाद लें।',
      'Thursday':
          '🟡 गुरुवार देवगुरु बृहस्पति का दिन है! सांदीपनि आश्रम दर्शन अति शुभ है।',
      'Friday': '🌺 शुक्रवार माँ हरसिद्धि व शक्ति उपासना का विशेष दिवस है।',
      'Saturday':
          '⚫ शनिवार श्री काल भैरव व शनिदेव की आराधना का दिन है। काल भैरव दर्शन करें।',
      'Sunday': '☀️ रविवार भगवान सूर्य व शिप्रा स्नान का पावन दिवस है!',
    };
    return insights[day] ?? '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  /// Returns a locally calculated answer for a supported distance or map query.
  /// Used before the online model so user-to-landmark distances are grounded in
  /// the app's current GPS fix and the bundled landmark coordinates.
  Future<String?> generateDistanceResponseForChat({
    required String userMessage,
    LocationInfo? locationInfo,
    String responseLanguage = 'hi',
  }) {
    _responseLanguage = responseLanguage;
    return _tryAnswerDistanceQuery(
      userMessage.toLowerCase().trim(),
      locationInfo,
      isHindi: responseLanguage.toLowerCase().startsWith('hi'),
    );
  }

  // SMART ENGINE — Distance & Travel Time
  // ═══════════════════════════════════════════════════════════════════════════
  Future<String?> _tryAnswerDistanceQuery(
    String message,
    LocationInfo? locationInfo, {
    bool isHindi = false,
  }) async {
    // Detect intent: distance, how far, kitni dur, travel time, reach, cords, coordinates, दूरी
    final isMapQuery = _containsAny(message, [
      'map',
      'maps',
      'directions',
      'show me where',
      'location link',
      'google maps',
      'naksha',
    ]);
    final isDistanceQuery =
        isMapQuery ||
        _containsAny(message, [
          'how far',
          'distance',
          'kitni dur',
          'kitna door',
          'how far is',
          'how far from',
          'how long to',
          'travel time',
          'time to reach',
          'kitne time mein',
          'pauchna',
          'kms from',
          'km from',
          'miles from',
          'reach',
          'get to',
          'go to',
          'cords',
          'coordinates',
          'coordinate',
          'nearest',
          'closest',
          'near me',
          'nearby',
          'sabse paas',
          'paas mein',
          'दूरी',
          'कितनी दूर',
          'कितना दूर',
          'रास्ता',
          'पहुंचने में समय',
          'समय लगेगा',
          'कितना समय',
          'कैसे पहुंचे',
        ]);
    if (!isDistanceQuery) return null;

    // Get live coordinates if not already provided
    final effectiveLoc =
        locationInfo ??
        await LocationService().getCurrentLocation(forceRefresh: true);

    // ── A. City-to-city distance queries ──
    final isCityToCity =
        _containsAny(message, [
          'ujjain to',
          'from ujjain',
          'ujjain se',
          'उज्जैन से',
          'उज्जैन तक',
        ]) ||
        (message.contains('to ujjain') ||
            message.contains('se ujjain') ||
            message.contains('से उज्जैन') ||
            message.contains('तक उज्जैन'));

    if (isCityToCity) {
      for (final entry in _majorCities.entries) {
        final city = entry.value;
        final cKey = entry.key;
        final cName = city['name'].toString().toLowerCase();
        final cHindi = (city['hindi'] ?? '').toString().toLowerCase();
        if (message.contains(cKey) ||
            message.contains(cName) ||
            (cHindi.isNotEmpty && message.contains(cHindi))) {
          return _generateCityDistanceResponse(city, isHindi: isHindi);
        }
      }
      return _generateAllNearbyDistances(isHindi: isHindi);
    }

    // ── B. Landmark queries from user's current live coordinates ──
    for (final entry in _landmarks.entries) {
      final landmarkKey = entry.key;
      final landmark = entry.value;
      final lname = landmark['name'].toString().toLowerCase();
      final lkey = landmarkKey.replaceAll('_', ' ');
      final lhindi = (landmark['hindiName'] ?? '').toString().toLowerCase();

      if (message.contains(lname) ||
          message.contains(lkey) ||
          (lhindi.isNotEmpty && message.contains(lhindi)) ||
          _containsLandmarkAlias(message, landmarkKey)) {
        if (isMapQuery) {
          return _buildLandmarkMapResponse(
            landmark,
            effectiveLoc,
            isHindi: isHindi,
          );
        }
        if (effectiveLoc != null) {
          return _generateLandmarkDistanceFromUser(
            effectiveLoc,
            landmark,
            isHindi: isHindi,
          );
        } else {
          return _missingGpsDistanceResponse(isHindi: isHindi);
        }
      }
    }

    // ── C. City queries from user's current live coordinates ──
    for (final entry in _majorCities.entries) {
      final cityName = entry.key;
      final city = entry.value;
      final cName = city['name'].toString().toLowerCase();
      final cHindi = (city['hindi'] ?? '').toString().toLowerCase();
      if (message.contains(cityName) ||
          message.contains(cName) ||
          (cHindi.isNotEmpty && message.contains(cHindi))) {
        if (effectiveLoc != null) {
          final distM = _haversineMeters(
            effectiveLoc.latitude,
            effectiveLoc.longitude,
            city['lat'] as double,
            city['lon'] as double,
          );
          final cityLandmark = {
            'name': isHindi
                ? '${city['hindi']} (${city['stateHindi']})'
                : '${city['name']} (${city['state']})',
            'hindiName': '${city['hindi']} (${city['stateHindi']})',
            'icon': '🏙️',
            'description': isHindi
                ? 'उज्जैन क्षेत्र से सीधा संपर्क'
                : 'Connected to Ujjain region',
            'hindiDescription': 'उज्जैन क्षेत्र से सीधा संपर्क',
          };
          return _buildDistanceResponse(
            cityLandmark,
            distM,
            fromUser: true,
            userLoc: effectiveLoc,
            isHindi: isHindi,
          );
        } else {
          return _missingGpsDistanceResponse(isHindi: isHindi);
        }
      }
    }

    // ── D. Generic "how far are temples" ──
    if (_containsAny(message, [
      'temple',
      'mandir',
      'ghat',
      'all temples',
      'temples near',
      'मंदिर',
      'सभी मंदिर',
      'मंदिरों की दूरी',
      'घाट',
    ])) {
      if (effectiveLoc != null) {
        return _generateNearestLandmarksFromUser(
          effectiveLoc,
          filterType: 'temple',
          isHindi: isHindi,
        );
      } else {
        return _missingGpsDistanceResponse(isHindi: isHindi, nearby: true);
      }
    }

    return null;
  }

  String _buildLandmarkMapResponse(
    Map<String, dynamic> landmark,
    LocationInfo? userLoc, {
    bool isHindi = false,
  }) {
    final destination = '${landmark['lat']},${landmark['lon']}';
    final mapUrl = userLoc == null
        ? 'https://www.google.com/maps/search/?api=1&query=$destination'
        : 'https://www.google.com/maps/dir/?api=1&origin='
              '${userLoc.latitude},${userLoc.longitude}&destination=$destination';
    return isHindi
        ? '${landmark['name']} का नक्शा: $mapUrl'
        : 'Map for ${landmark['name']}: $mapUrl';
  }

  String _missingGpsDistanceResponse({
    required bool isHindi,
    bool nearby = false,
  }) {
    if (isHindi) {
      return nearby
          ? 'नज़दीकी दूरी निकालने के लिए ताज़ा GPS स्थान नहीं मिला। कृपया Location चालू करके फिर कोशिश करें।'
          : 'दूरी सही तरह निकालने के लिए ताज़ा GPS स्थान नहीं मिला। कृपया Location चालू करके फिर कोशिश करें।';
    }
    return nearby
        ? 'I could not get a fresh GPS fix, so I cannot calculate nearby distances accurately. Turn on Location and try again.'
        : 'I could not get a fresh GPS fix, so I cannot calculate your distance accurately. Turn on Location and try again.';
  }

  bool _containsLandmarkAlias(String message, String key) {
    const aliases = {
      'mahakaleshwar': [
        'mahakal',
        'mahakaal',
        'jyotirlinga',
        'bhasma aarti temple',
        'महाकाल',
        'महाकालेश्वर',
        'ज्योतिर्लिंग',
        'भस्म आरती',
      ],
      'mahakal_lok': [
        'mahakal lok',
        'mahakal corridor',
        'corridor',
        'महाकाल लोक',
        'महाकाल कॉरिडोर',
        'महाकाल महालोक',
      ],
      'kal_bhairav': [
        'kalbhairav',
        'kal bhairav',
        'bhairav temple',
        'bhairav mandir',
        'काल भैरव',
        'भैरव बाबा',
        'भैरव मंदिर',
      ],
      'harsiddhi': [
        'harsiddhi mata',
        'annapurna',
        'shakti peetha',
        'हरसिद्धि',
        'हरसिद्धि माता',
        'शक्तिपीठ',
      ],
      'ram_ghat': [
        'ramghat',
        'shipra ghat',
        'main ghat',
        'bathing ghat',
        'राम घाट',
        'रामघाट',
        'शिप्रा घाट',
      ],
      'triveni_ghat': ['triveninghat', 'triveni', 'त्रिवेणी', 'त्रिवेणी घाट'],
      'ujjain_railway': [
        'railway station',
        'train station',
        'ujjain station',
        'रेलवे स्टेशन',
        'ट्रेन स्टेशन',
        'उज्जैन स्टेशन',
      ],
      'ujjain_bus': [
        'bus stand',
        'bus station',
        'bus terminal',
        'बस स्टैंड',
        'बस स्टेशन',
      ],
      'sandipani_ashram': [
        'sandipani',
        'krishna school',
        'ashram',
        'सांदीपनि',
        'सांदीपनि आश्रम',
        'महर्षि सांदीपनि',
      ],
      'mangal_nath': [
        'mangal nath',
        'mangal temple',
        'mars temple',
        'मंगलनाथ',
        'मंगल नाथ मंदिर',
      ],
      'chintaman_ganesh': [
        'chintaman',
        'ganesh temple',
        'chintaman ganesh',
        'चिंतामन',
        'चिंतामन गणेश',
      ],
      'gadkalika': [
        'gadkalika',
        'kalika mata',
        'gad kalika',
        'गढ़कालिका',
        'गढकालिका',
        'कालिका माता',
      ],
      'bhartrihari_caves': [
        'bhartrihari',
        'bhartrahari caves',
        'caves',
        'भर्तृहरि',
        'भर्तृहरि गुफा',
        'गुफाएं',
      ],
      'siddhwat': [
        'siddhwat',
        'sidhwat',
        'vat vriksha',
        'pind daan',
        'सिद्धवट',
        'सिद्ध वट',
        'पिंडदान',
      ],
      'vedhshala': [
        'vedhshala',
        'jantar mantar',
        'observatory',
        'वेधशाला',
        'जंतर मंतर',
      ],
      'iskcon_ujjain': [
        'iskcon',
        'isckon',
        'hare krishna',
        'radha madanmohan',
        'इस्कॉन',
        'हरे कृष्णा',
      ],
      'kaliadeh_palace': [
        'kaliadeh',
        'kaliadeh palace',
        'sun temple palace',
        'कालियादेह',
        'कालियादेह महल',
      ],
    };
    final list = aliases[key] ?? [];
    return list.any((alias) => message.contains(alias));
  }

  String _generateCityDistanceResponse(
    Map<String, dynamic> city, {
    bool isHindi = false,
  }) {
    final km = city['km'] as int;
    final name = isHindi ? (city['hindi'] ?? city['name']) : city['name'];
    final state = isHindi
        ? (city['stateHindi'] ?? city['state'])
        : city['state'];
    final roadKm = (km * 1.25).round(); // approx road distance
    final trainHr = (roadKm / 70).toStringAsFixed(1);
    final busHr = (roadKm / 60).toStringAsFixed(1);
    final carHr = (roadKm / 80).toStringAsFixed(1);

    if (isHindi) {
      return '📍 **उज्जैन से $name ($state) की दूरी व यात्रा समय:**\n\n'
          '🛣️ **सीधी हवाई दूरी:** ~$km किमी\n'
          '🚗 **सड़क मार्ग दूरी:** ~$roadKm किमी\n\n'
          '⏱️ **अनुमानित यात्रा समय:**\n'
          '• 🚗 कार द्वारा: ~$carHr घंटे\n'
          '• 🚌 बस द्वारा: ~$busHr घंटे\n'
          '• 🚂 ट्रेन द्वारा: ~$trainHr घंटे (मार्ग अनुसार परिवर्तन संभव)\n\n'
          '💡 **सुझाव:** उज्जैन सड़क एवं रेल मार्ग से बहुत अच्छी तरह जुड़ा हुआ है। '
          '${_getHindiTransportTip(city['name'].toString())}';
    }

    return '📍 **Distance from Ujjain to $name ($state):**\n\n'
        '🛣️ **Straight-line:** ~$km km\n'
        '🚗 **By Road:** ~$roadKm km\n\n'
        '⏱️ **Estimated Travel Times:**\n'
        '• 🚗 By Car: ~$carHr hours\n'
        '• 🚌 By Bus: ~$busHr hours\n'
        '• 🚂 By Train: ~$trainHr hours (varies by route)\n\n'
        '💡 **Tip:** Ujjain is well-connected by road and rail. '
        '${_getTransportTip(city['name'].toString())}';
  }

  String _getTransportTip(String cityName) {
    const tips = {
      'Indore':
          'Indore–Ujjain is the most frequent bus route (every 15 mins). Taxis are also readily available.',
      'Mumbai':
          'Avantika Express is a popular overnight train. Road via NH52 takes about 9 hours.',
      'Delhi':
          'Malwa Express and Avantika Express connect Delhi–Ujjain overnight.',
      'Bhopal':
          'Multiple express trains daily. Road via NH46 is well-maintained.',
      'Omkareshwar':
          'A must-visit Jyotirlinga near Ujjain! Combine with your Mahakaleshwar darshan.',
    };
    return tips[cityName] ??
        'Check IRCTC and redBus for latest schedules and bookings.';
  }

  String _getHindiTransportTip(String cityName) {
    const tips = {
      'Indore':
          'इंदौर-उज्जैन मार्ग पर हर 15 मिनट में बसें उपलब्ध हैं। टैक्सी भी आसानी से मिलती है।',
      'Mumbai':
          'अवंतिका एक्सप्रेस रात्रि यात्रा हेतु लोकप्रिय ट्रेन है। सड़क मार्ग NH52 द्वारा लगभग 9-10 घंटे लगते हैं।',
      'Delhi':
          'मालवा एक्सप्रेस एवं अवंतिका एक्सप्रेस दिल्ली से उज्जैन को जोड़ती हैं।',
      'Bhopal':
          'प्रतिदिन कई सुपरफास्ट ट्रेनें उपलब्ध हैं। NH46 सड़क मार्ग बहुत ही उत्तम है।',
      'Omkareshwar':
          'उज्जैन के निकट दूसरा ज्योतिर्लिंग! महाकालेश्वर दर्शन के साथ ओंकारेश्वर दर्शन का संकल्प अवश्य लें।',
    };
    return tips[cityName] ??
        'नवीनतम समय सारणी व टिकट के लिए IRCTC या बस सेवा की जाँच करें।';
  }

  String _generateLandmarkDistanceFromUser(
    LocationInfo userLoc,
    Map<String, dynamic> landmark, {
    bool isHindi = false,
  }) {
    final distM = _haversineMeters(
      userLoc.latitude,
      userLoc.longitude,
      landmark['lat'] as double,
      landmark['lon'] as double,
    );
    return _buildDistanceResponse(
      landmark,
      distM,
      fromUser: true,
      userLoc: userLoc,
      isHindi: isHindi,
    );
  }

  String _buildDistanceResponse(
    Map<String, dynamic> landmark,
    double distM, {
    required bool fromUser,
    LocationInfo? userLoc,
    bool isHindi = false,
  }) {
    final name = isHindi
        ? (landmark['hindiName'] ?? landmark['name'])
        : landmark['name'];
    final icon = landmark['icon'];
    final desc = isHindi
        ? (landmark['hindiDescription'] ?? landmark['description'])
        : landmark['description'];

    final distKm = distM / 1000;
    final distStr = isHindi
        ? (distKm < 1.0
              ? '${distM.round()} मीटर'
              : distKm < 10.0
              ? '${distKm.toStringAsFixed(2)} किमी'
              : '${distKm.toStringAsFixed(1)} किमी')
        : (distKm < 1.0
              ? '${distM.round()} metres'
              : distKm < 10.0
              ? '${distKm.toStringAsFixed(2)} km'
              : '${distKm.toStringAsFixed(1)} km');

    final StringBuffer buf = StringBuffer();

    if (fromUser && userLoc != null) {
      final latStr =
          '${userLoc.latitude.abs().toStringAsFixed(4)}°${userLoc.latitude >= 0 ? "N" : "S"}';
      final lonStr =
          '${userLoc.longitude.abs().toStringAsFixed(4)}°${userLoc.longitude >= 0 ? "E" : "W"}';
      final cityStr = userLoc.city != null && userLoc.city!.isNotEmpty
          ? ' (${userLoc.city})'
          : '';
      if (isHindi) {
        buf.writeln(
          '📍 **आपके लाइव निर्देशांक से:** `$latStr, $lonStr`$cityStr\n',
        );
      } else {
        buf.writeln(
          '📍 **From your coordinates:** `$latStr, $lonStr`$cityStr\n',
        );
      }
    } else {
      if (isHindi) {
        buf.writeln('📍 **महाकालेश्वर मंदिर (नगर केंद्र) से:**\n');
      } else {
        buf.writeln('📍 **From Mahakaleshwar temple (city centre):**\n');
      }
    }

    buf.writeln('$icon **$name**');
    if (isHindi) {
      buf.writeln('📏 **दूरी:** **$distStr**\n');
      buf.writeln('⏱️ **अनुमानित यात्रा समय:**');
    } else {
      buf.writeln('📏 **Straight-line distance:** **$distStr**\n');
      buf.writeln('⏱️ **Estimated Travel Time:**');
    }

    if (distKm <= 15.0) {
      final walkMin = (distM / 80).round();
      final autoMin = (distM / 250).round().clamp(1, 120);
      final carMin = (distM / 400).round().clamp(1, 90);

      if (isHindi) {
        final walkStr = walkMin < 2
            ? 'बस कुछ ही कदम दूर!'
            : walkMin < 60
            ? '~$walkMin मिनट पैदल'
            : '~${(walkMin / 60).toStringAsFixed(1)} घंटे पैदल';
        buf.writeln('• 🚶 पैदल: $walkStr');
        buf.writeln('• 🛺 ऑटो रिक्शा: ~$autoMin मिनट');
        buf.writeln('• 🚗 कार/टैक्सी: ~$carMin मिनट');
      } else {
        final walkStr = walkMin < 2
            ? 'just steps away!'
            : walkMin < 60
            ? '~$walkMin min walking'
            : '~${(walkMin / 60).toStringAsFixed(1)} hours walking';
        buf.writeln('• 🚶 Walking: $walkStr');
        buf.writeln('• 🛺 Auto-rickshaw: ~$autoMin min');
        buf.writeln('• 🚗 Car/Taxi: ~$carMin min');
      }
    } else {
      final carHours = (distKm / 65).toStringAsFixed(1);
      final busHours = (distKm / 50).toStringAsFixed(1);
      final trainHours = (distKm / 60).toStringAsFixed(1);

      if (isHindi) {
        buf.writeln('• 🚗 सड़क/कार द्वारा: ~$carHours घंटे');
        buf.writeln('• 🚌 एक्सप्रेस बस द्वारा: ~$busHours घंटे');
        buf.writeln('• 🚂 ट्रेन द्वारा: ~$trainHours घंटे (औसतन)');
      } else {
        buf.writeln('• 🚗 By Road/Car: ~$carHours hours');
        buf.writeln('• 🚌 By Express Bus: ~$busHours hours');
        buf.writeln('• 🚂 By Train: ~$trainHours hours (average)');
      }
    }

    buf.writeln('\n📝 _${desc}_');

    final destination = '${landmark['lat']},${landmark['lon']}';
    final mapUrl = userLoc == null
        ? 'https://www.google.com/maps/search/?api=1&query=$destination'
        : 'https://www.google.com/maps/dir/?api=1&origin='
              '${userLoc.latitude},${userLoc.longitude}&destination=$destination';
    buf.writeln(isHindi ? '\nनक्शा: $mapUrl' : '\nMap: $mapUrl');
    return buf.toString();
  }

  String _generateUserLocationReport(LocationInfo loc, {bool isHindi = false}) {
    final distToMahakal = _haversineMeters(
      loc.latitude,
      loc.longitude,
      AppConstants.ujjainLatitude,
      AppConstants.ujjainLongitude,
    );
    final distKm = distToMahakal / 1000;
    final latStr =
        '${loc.latitude.abs().toStringAsFixed(4)}° ${loc.latitude >= 0 ? "N" : "S"}';
    final lonStr =
        '${loc.longitude.abs().toStringAsFixed(4)}° ${loc.longitude >= 0 ? "E" : "W"}';

    final StringBuffer buf = StringBuffer();
    if (isHindi) {
      buf.writeln('📍 **आपके वर्तमान GPS निर्देशांक:**\n');
      buf.writeln('• **अक्षांश (Latitude):** $latStr');
      buf.writeln('• **देशांतर (Longitude):** $lonStr');
      if (loc.city != null && loc.city!.isNotEmpty) {
        buf.writeln('• **क्षेत्र / नगर:** ${loc.city}');
      }
      buf.writeln(
        '• **कच्चे निर्देशांक:** `${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}`\n',
      );

      buf.writeln('🕉️ **पवित्र श्री महाकालेश्वर ज्योतिर्लिंग से दूरी:**');
      if (distKm < 1.0) {
        buf.writeln(
          '• **${distToMahakal.round()} मीटर** (~${(distToMahakal / 80).round()} मिनट पैदल)',
        );
      } else if (distKm < 15.0) {
        buf.writeln(
          '• **${distKm.toStringAsFixed(2)} किमी** (~${(distKm * 1000 / 250).round()} मिनट ऑटो द्वारा)',
        );
      } else {
        final carHours = (distKm / 65).toStringAsFixed(1);
        buf.writeln(
          '• **${distKm.toStringAsFixed(1)} किमी** (~$carHours घंटे सड़क मार्ग से)',
        );
      }

      buf.writeln(
        '\n✨ _इन लाइव GPS निर्देशांकों का उपयोग दूरी और यात्रा समय की गणना के लिए किया जा रहा है!_',
      );
      return buf.toString();
    }

    buf.writeln('📍 **Your Current GPS Coordinates:**\n');
    buf.writeln('• **Latitude:** $latStr');
    buf.writeln('• **Longitude:** $lonStr');
    if (loc.city != null && loc.city!.isNotEmpty) {
      buf.writeln('• **Area / City:** ${loc.city}');
    }
    buf.writeln(
      '• **Raw Coordinates:** `${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}`\n',
    );

    buf.writeln('🕉️ **Distance to Sacred Mahakaleshwar (Ujjain):**');
    if (distKm < 1.0) {
      buf.writeln(
        '• **${distToMahakal.round()} metres** (~${(distToMahakal / 80).round()} min walk)',
      );
    } else if (distKm < 15.0) {
      buf.writeln(
        '• **${distKm.toStringAsFixed(2)} km** (~${(distKm * 1000 / 250).round()} min by auto)',
      );
    } else {
      final carHours = (distKm / 65).toStringAsFixed(1);
      buf.writeln(
        '• **${distKm.toStringAsFixed(1)} km** (~$carHours hours by road)',
      );
    }

    buf.writeln(
      '\n✨ _These live GPS coordinates are being used for all distance and travel calculations!_',
    );
    return buf.toString();
  }

  String _generateAllNearbyDistances({bool isHindi = false}) {
    final buf = StringBuffer();
    final nearby = _majorCities.entries
        .where((e) => (e.value['km'] as int) <= 200)
        .toList();
    nearby.sort(
      (a, b) => (a.value['km'] as int).compareTo(b.value['km'] as int),
    );

    if (isHindi) {
      buf.writeln('📍 **उज्जैन से निकटवर्ती प्रमुख नगरों की दूरी:**\n');
      for (final e in nearby) {
        final c = e.value;
        final cName = c['hindi'] ?? c['name'];
        final cState = c['stateHindi'] ?? c['state'];
        buf.writeln('🏙️ **$cName** ($cState): ~${c['km']} किमी (सड़क मार्ग)');
      }
      buf.writeln(
        '\nविस्तृत यात्रा समय और मार्ग हेतु किसी भी शहर का नाम लिखकर पूछें!',
      );
      return buf.toString();
    }

    buf.writeln('📍 **Distances from Ujjain to Nearby Cities:**\n');
    for (final e in nearby) {
      final c = e.value;
      buf.writeln(
        '🏙️ **${c['name']}** (${c['state']}): ~${c['km']} km by road',
      );
    }
    buf.writeln('\nAsk me about any specific city for detailed travel times!');
    return buf.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — Nearest Query
  // ═══════════════════════════════════════════════════════════════════════════
  Future<String?> _tryAnswerNearestQuery(
    String message,
    LocationInfo? locationInfo, {
    bool isHindi = false,
  }) async {
    final isNearest = _containsAny(message, [
      'nearest',
      'closest',
      'near me',
      'nearby',
      'paas mein',
      'sabse paas',
      'close to me',
      'which is near',
      'what is near',
      'सबसे पास',
      'पास में',
      'नजदीक',
      'समीप',
      'मेरे पास',
    ]);
    if (!isNearest) return null;

    final effectiveLoc =
        locationInfo ??
        await LocationService().getCurrentLocation(forceRefresh: true);

    if (effectiveLoc == null) {
      if (isHindi) {
        return '📍 **आपके निकटतम स्थान खोजने के लिए GPS लोकेशन आवश्यक है!**\n\n'
            'कृपया सुनिश्चित करें:\n'
            '1. फ़ोन में **Location / GPS** चालू है।\n'
            '2. ऐप को लोकेशन अनुमति दी गई है।\n\n'
            '💡 _लोकेशन चालू होने के बाद "सबसे पास का मंदिर" पूछें!_';
      }
      return '📍 **I need your GPS location to find places nearest to you!**\n\n'
          'Please make sure:\n'
          '1. **Location / GPS** is turned ON in your phone settings.\n'
          '2. Location permission is granted for this app.\n\n'
          '💡 _Once enabled, ask "nearest temple" to see the closest places from your exact coordinates._';
    }

    String? filterType;
    if (_containsAny(message, ['temple', 'mandir', 'मंदिर']))
      filterType = 'temple';
    else if (_containsAny(message, [
      'ghat',
      'river',
      'bathing',
      'घाट',
      'नदी',
      'स्नान',
    ]))
      filterType = 'ghat';
    else if (_containsAny(message, [
      'transport',
      'station',
      'railway',
      'bus',
      'स्टेशन',
      'बस',
    ]))
      filterType = 'transport';

    return _generateNearestLandmarksFromUser(
      effectiveLoc,
      filterType: filterType,
      isHindi: isHindi,
    );
  }

  String _generateNearestLandmarksFromUser(
    LocationInfo userLoc, {
    String? filterType,
    bool isHindi = false,
  }) {
    // Compute distances to all landmarks
    final List<MapEntry<String, double>> sorted = [];
    for (final entry in _landmarks.entries) {
      final lm = entry.value;
      if (filterType != null && lm['type'] != filterType) continue;
      final distM = _haversineMeters(
        userLoc.latitude,
        userLoc.longitude,
        lm['lat'] as double,
        lm['lon'] as double,
      );
      sorted.add(MapEntry(entry.key, distM));
    }
    sorted.sort((a, b) => a.value.compareTo(b.value));

    if (sorted.isEmpty) {
      return isHindi
          ? 'इस प्रकार का कोई स्थान डेटाबेस में नहीं मिला।'
          : 'No landmarks of that type found in the database.';
    }

    final latStr =
        '${userLoc.latitude.abs().toStringAsFixed(4)}°${userLoc.latitude >= 0 ? "N" : "S"}';
    final lonStr =
        '${userLoc.longitude.abs().toStringAsFixed(4)}°${userLoc.longitude >= 0 ? "E" : "W"}';
    final cityStr = userLoc.city != null && userLoc.city!.isNotEmpty
        ? ' (${userLoc.city})'
        : '';

    if (isHindi) {
      final typeLabel = filterType == 'temple'
          ? ' (मंदिर)'
          : filterType == 'ghat'
          ? ' (घाट)'
          : filterType == 'transport'
          ? ' (यातायात)'
          : '';
      final buf = StringBuffer();
      buf.writeln('📍 **आपके निर्देशांक से:** `$latStr, $lonStr`$cityStr');
      buf.writeln('🏛️ **उज्जैन के निकटतम पावन स्थल$typeLabel:**\n');

      for (int i = 0; i < min(5, sorted.length); i++) {
        final key = sorted[i].key;
        final distM = sorted[i].value;
        final lm = _landmarks[key]!;
        final name = lm['hindiName'] ?? lm['name'];
        final distKm = distM / 1000;
        final distStr = distKm < 1.0
            ? '${distM.round()} मीटर'
            : distKm < 10.0
            ? '${distKm.toStringAsFixed(2)} किमी'
            : '${distKm.toStringAsFixed(1)} किमी';
        buf.writeln('${i + 1}. ${lm['icon']} **$name** — **$distStr**');
        if (distKm <= 15) {
          final walkMin = (distM / 80).round();
          final autoMin = (distM / 250).round().clamp(1, 120);
          buf.writeln('   🚶 ~$walkMin मिनट पैदल | 🛺 ~$autoMin मिनट ऑटो\n');
        } else {
          final carHours = (distKm / 65).toStringAsFixed(1);
          buf.writeln('   🚗 ~$carHours घंटे कार से\n');
        }
      }

      final nearest = _landmarks[sorted.first.key]!;
      buf.writeln(
        '✨ **आपके सबसे नजदीक:** ${nearest['hindiName'] ?? nearest['name']}',
      );
      return buf.toString();
    }

    final typeLabel = filterType != null ? ' (${filterType}s)' : '';
    final buf = StringBuffer();
    buf.writeln('📍 **From your coordinates:** `$latStr, $lonStr`$cityStr');
    buf.writeln('🏛️ **Nearest Ujjain Landmarks$typeLabel:**\n');

    for (int i = 0; i < min(5, sorted.length); i++) {
      final key = sorted[i].key;
      final distM = sorted[i].value;
      final lm = _landmarks[key]!;
      final distKm = distM / 1000;
      final distStr = distKm < 1.0
          ? '${distM.round()} m'
          : distKm < 10.0
          ? '${distKm.toStringAsFixed(2)} km'
          : '${distKm.toStringAsFixed(1)} km';
      buf.writeln('${i + 1}. ${lm['icon']} **${lm['name']}** — **$distStr**');
      if (distKm <= 15) {
        final walkMin = (distM / 80).round();
        final autoMin = (distM / 250).round().clamp(1, 120);
        buf.writeln('   🚶 ~$walkMin min walk | 🛺 ~$autoMin min auto\n');
      } else {
        final carHours = (distKm / 65).toStringAsFixed(1);
        buf.writeln('   🚗 ~$carHours hours drive\n');
      }
    }

    if (sorted.isNotEmpty) {
      final nearest = _landmarks[sorted.first.key]!;
      buf.writeln('✨ **Closest to you:** ${nearest['name']}');
    }
    return buf.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — Unit Conversion
  // ═══════════════════════════════════════════════════════════════════════════
  String? _tryAnswerUnitConversion(String message) {
    // km to miles / miles to km
    final kmToMiles = RegExp(
      r'(\d+(?:\.\d+)?)\s*k(?:ilo)?m(?:eters?)?\s*(?:to|in|=|into)\s*miles?',
    );
    final milesToKm = RegExp(
      r'(\d+(?:\.\d+)?)\s*miles?\s*(?:to|in|=|into)\s*k(?:ilo)?m',
    );

    // Celsius to Fahrenheit
    final celToFar = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:°?c|celsius|centigrade)\s*(?:to|in|=|into)\s*(?:°?f|fahrenheit)',
    );
    final farToCel = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:°?f|fahrenheit)\s*(?:to|in|=|into)\s*(?:°?c|celsius)',
    );

    // kg to lbs / lbs to kg
    final kgToLbs = RegExp(
      r'(\d+(?:\.\d+)?)\s*k(?:ilo)?g(?:ram)?\s*(?:to|in|=|into)\s*(?:lbs?|pounds?)',
    );
    final lbsToKg = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:lbs?|pounds?)\s*(?:to|in|=|into)\s*k(?:ilo)?g',
    );

    // metres to feet
    final mToFt = RegExp(
      r'(\d+(?:\.\d+)?)\s*m(?:eters?|etres?)?\s*(?:to|in|=|into)\s*(?:feet|ft)',
    );
    final ftToM = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:feet|ft)\s*(?:to|in|=|into)\s*m(?:eters?|etres?)?',
    );

    // INR to USD (approximate)
    final inrToUsd = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:rupees?|rs\.?|inr)\s*(?:to|in|=|into)\s*(?:dollars?|\$|usd)',
    );
    final usdToInr = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:dollars?|\$|usd)\s*(?:to|in|=|into)\s*(?:rupees?|rs\.?|inr)',
    );

    Match? m;
    if ((m = kmToMiles.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '📏 **$v km = ${(v * 0.621371).toStringAsFixed(2)} miles**\n_(1 km = 0.6214 miles)_';
    }
    if ((m = milesToKm.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '📏 **$v miles = ${(v * 1.60934).toStringAsFixed(2)} km**\n_(1 mile = 1.6093 km)_';
    }
    if ((m = celToFar.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '🌡️ **$v°C = ${(v * 9 / 5 + 32).toStringAsFixed(1)}°F**\n_(Formula: (°C × 9/5) + 32)_';
    }
    if ((m = farToCel.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '🌡️ **$v°F = ${((v - 32) * 5 / 9).toStringAsFixed(1)}°C**\n_(Formula: (°F − 32) × 5/9)_';
    }
    if ((m = kgToLbs.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '⚖️ **$v kg = ${(v * 2.20462).toStringAsFixed(2)} lbs**\n_(1 kg = 2.2046 lbs)_';
    }
    if ((m = lbsToKg.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '⚖️ **$v lbs = ${(v * 0.453592).toStringAsFixed(2)} kg**\n_(1 lb = 0.4536 kg)_';
    }
    if ((m = mToFt.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '📐 **$v metres = ${(v * 3.28084).toStringAsFixed(2)} feet**\n_(1 m = 3.2808 ft)_';
    }
    if ((m = ftToM.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '📐 **$v feet = ${(v * 0.3048).toStringAsFixed(2)} metres**\n_(1 ft = 0.3048 m)_';
    }
    if ((m = inrToUsd.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '💱 **₹$v ≈ \$${(v / 84).toStringAsFixed(2)} USD**\n_(Approx. rate: ₹84 = 1 USD. Rate fluctuates daily.)_';
    }
    if ((m = usdToInr.firstMatch(message)) != null) {
      final v = double.parse(m!.group(1)!);
      return '💱 **\$$v ≈ ₹${(v * 84).toStringAsFixed(0)} INR**\n_(Approx. rate: 1 USD = ₹84. Rate fluctuates daily.)_';
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — General Knowledge
  // ═══════════════════════════════════════════════════════════════════════════
  String? _tryAnswerGeneralKnowledge(String message, {bool isHindi = false}) {
    // Capital cities
    if (_containsAny(message, [
      'capital of',
      'capital city of',
      'rajdhani',
      'what is the capital',
      'राजधानी',
    ])) {
      return _tryAnswerCapital(message, isHindi: isHindi);
    }
    // Weather / temperature context
    if (_containsAny(message, [
      'weather',
      'temperature',
      'climate',
      'mausam',
      'garmi',
      'sardi',
      'मौसम',
      'तापमान',
      'गर्मी',
      'सर्दी',
      'ठंड',
    ])) {
      return _answerUjjainWeather(message, isHindi: isHindi);
    }
    // Population
    if (_containsAny(message, [
      'population',
      'how many people',
      'kitni aabadi',
      'population of',
      'जनसंख्या',
      'आबादी',
    ])) {
      return _tryAnswerPopulation(message, isHindi: isHindi);
    }
    // India facts
    if (_containsAny(message, [
      'prime minister',
      'pm of india',
      'president of india',
      'rashtrapati',
      'प्रधानमंत्री',
      'राष्ट्रपति',
    ])) {
      if (isHindi) {
        return '🇮🇳 **भारत का नेतृत्व (2024–25):**\n\n'
            '👤 **प्रधानमंत्री:** श्री नरेंद्र मोदी (BJP)\n'
            '👤 **राष्ट्रपति:** श्रीमती द्रौपदी मुर्मू\n'
            '🏛️ **संसद:** लोकसभा एवं राज्यसभा\n\n'
            '📍 _राजधानी: नई दिल्ली_';
      }
      return '🇮🇳 **India\'s Leadership (as of 2024–25):**\n\n'
          '👤 **Prime Minister:** Narendra Modi (BJP)\n'
          '👤 **President:** Droupadi Murmu\n'
          '🏛️ **Parliament:** Lok Sabha + Rajya Sabha\n\n'
          '📍 _Capital: New Delhi_';
    }
    // MP Chief Minister
    if (_containsAny(message, [
      'madhya pradesh cm',
      'mp cm',
      'chief minister of mp',
      'mp chief minister',
      'madhya pradesh chief minister',
      'मध्य प्रदेश के मुख्यमंत्री',
      'एमपी के सीएम',
    ])) {
      if (isHindi) {
        return '🏛️ **मध्य प्रदेश के माननीय मुख्यमंत्री:**\n\n'
            '👤 **मुख्यमंत्री:** डॉ. मोहन यादव (BJP)\n'
            '📍 **राजधानी:** भोपाल\n'
            '🌐 **उज्जैन डॉ. मोहन यादव जी का गृह नगर है** एवं पावन सिंहस्थ नगरी है!\n\n'
            '_उज्जैन मध्य प्रदेश का प्रमुख आध्यात्मिक केंद्र है।_';
      }
      return '🏛️ **Madhya Pradesh (MP) Chief Minister:**\n\n'
          '👤 **CM:** Dr. Mohan Yadav (BJP)\n'
          '📍 **Capital:** Bhopal\n'
          '🌐 **MP is home to Ujjain** — the sacred Simhastha city!\n\n'
          '_Ujjain is one of MP\'s most spiritually significant cities._';
    }
    // Speed of light / sound
    if (_containsAny(message, [
      'speed of light',
      'light speed',
      'prakash ki gati',
      'प्रकाश की गति',
    ])) {
      if (isHindi) {
        return '💡 **प्रकाश की गति (Speed of Light):** 299,792,458 मीटर/सेकंड (लगभग **3 × 10⁸ मी/से**)\n\n'
            '🌍 चंद्रमा से प्रकाश को पृथ्वी तक आने में ~1.3 सेकंड लगते हैं!\n'
            '☀️ सूर्य से प्रकाश पृथ्वी तक लगभग 8 मिनट 20 सेकंड में पहुंचता है।';
      }
      return '💡 **Speed of Light:** 299,792,458 m/s (approximately **3 × 10⁸ m/s**)\n\n'
          '🌍 Light travels from Earth to Moon in ~1.3 seconds!\n'
          '☀️ Light from the Sun reaches Earth in ~8 minutes 20 seconds.';
    }
    if (_containsAny(message, [
      'speed of sound',
      'sound speed',
      'dhwani ki gati',
      'ध्वनि की गति',
    ])) {
      if (isHindi) {
        return '🔊 **ध्वनि की गति (Speed of Sound):** ~343 मीटर/सेकंड (20°C हवा में)\n'
            '≈ 1,235 किमी/घंटा\n\n'
            '_ध्वनि जल में अधिक तीव्र (~1,480 मी/से) तथा ठोस पदार्थों में और भी तेज गति से चलती है।_';
      }
      return '🔊 **Speed of Sound:** ~343 m/s in air at 20°C\n'
          '≈ 1,235 km/h | ≈ 767 mph\n\n'
          '_Sound travels faster in water (~1,480 m/s) and even faster in solids._';
    }
    // Basic geography
    if (_containsAny(message, [
      'largest country',
      'biggest country',
      'sabse bada desh',
      'सबसे बड़ा देश',
    ])) {
      if (isHindi) {
        return '🌏 **क्षेत्रफल की दृष्टि से विश्व के सबसे बड़े देश:**\n\n'
            '1. 🇷🇺 रूस — 1.71 करोड़ वर्ग किमी\n'
            '2. 🇨🇦 कनाडा — 1.0 करोड़ वर्ग किमी\n'
            '3. 🇺🇸 अमेरिका — 98 लाख वर्ग किमी\n'
            '4. 🇨🇳 चीन — 96 लाख वर्ग किमी\n'
            '5. 🇧🇷 ब्राजील — 85 लाख वर्ग किमी\n'
            '6. 🇦🇺 ऑस्ट्रेलिया — 77 लाख वर्ग किमी\n'
            '7. 🇮🇳 भारत — 32.8 लाख वर्ग किमी\n\n'
            '_भारत विश्व का 7वां सबसे बड़ा देश और सर्वाधिक जनसंख्या वाला देश है!_';
      }
      return '🌏 **World\'s Largest Countries by Area:**\n\n'
          '1. 🇷🇺 Russia — 17.1 million km²\n'
          '2. 🇨🇦 Canada — 10.0 million km²\n'
          '3. 🇺🇸 USA — 9.8 million km²\n'
          '4. 🇨🇳 China — 9.6 million km²\n'
          '5. 🇧🇷 Brazil — 8.5 million km²\n'
          '6. 🇮🇳 India — 3.3 million km²\n\n'
          '_India is the 7th largest country in the world!_';
    }
    // Who am I
    if (_containsAny(message, [
      'who are you',
      'what are you',
      'tum kaun ho',
      'aap kaun ho',
      'your name',
      'apna naam bata',
      'तुम कौन हो',
      'आप कौन हैं',
      'तुम्हारा नाम',
    ])) {
      if (isHindi) {
        return '🕉️ **मैं सिंहस्थ एआई (Simhastha AI) हूँ — आपका पावन मार्गदर्शक!**\n\n'
            'मैं विशेष रूप से आपकी सहायता के लिए बनाया गया हूँ:\n'
            '• 🏛️ उज्जैन तीर्थ दर्शन व आरती समय सारणी\n'
            '• 📍 लाइव GPS निर्देशांक व दूरी की सटीक गणना (100% ऑफ़लाइन!)\n'
            '• 🧮 गणित एवं इकाई रूपांतरण\n'
            '• 📅 समय, तिथि, वार एवं पंचांग जानकारी\n'
            '• 🏨 होटल, धर्मशाला व सात्विक भोजन/प्रसादम मार्गदर्शन\n'
            '• 🚩 सिंहस्थ 2028 कुंभ मेला जानकारी\n\n'
            '_मैं बिना इंटरनेट के पूरी तरह ऑफ़लाइन काम करता हूँ!_\n\n'
            '🙏 हर हर महादेव!';
      }
      return '🕉️ **I am Ujjain Live — your sacred guide!**\n\n'
          'I\'m an AI assistant specially built for:\n'
          '• 🏛️ Ujjain pilgrimage guidance\n'
          '• 📍 Distance & location calculations (offline!)\n'
          '• 🧮 Math & unit conversions\n'
          '• 📅 Time, date, and calendar queries\n'
          '• 🌍 General knowledge & world facts\n'
          '• 🗺️ City-to-city distances across India\n\n'
          '_I work 100% offline — no internet needed!_\n\n'
          '🙏 Har Har Mahadev!';
    }
    // Pi / math constants
    if (_containsAny(message, [
      'value of pi',
      'pi value',
      'pi kya hai',
      'what is pi',
      'पाई का मान',
    ])) {
      if (isHindi) {
        return '🔢 **π (पाई) = 3.14159265358979...** (लगभग 22/7)\n\n'
            'पाई किसी भी वृत्त की परिधि और उसके व्यास का अनुपात है।\n'
            'यह एक **अपरिमेय संख्या (Irrational Number)** है।\n\n'
            '_उपयोग: वृत्त का क्षेत्रफल (πr²), परिधि (2πr), इंजीनियरिंग आदि।_';
      }
      return '🔢 **π (Pi) = 3.14159265358979...**\n\n'
          'Pi is the ratio of a circle\'s circumference to its diameter.\n'
          'It is an **irrational number** — it never ends or repeats!\n\n'
          '_Used in: area of circle (πr²), circumference (2πr), engineering, and more._';
    }
    // What is AI
    if (_containsAny(message, [
      'what is ai',
      'what is artificial intelligence',
      'ai kya hai',
      'एआई क्या है',
    ])) {
      if (isHindi) {
        return '🤖 **कृत्रिम बुद्धिमत्ता (Artificial Intelligence - AI):**\n\n'
            'एआई कंप्यूटर और मशीनों द्वारा मानव जैसी बुद्धिमत्ता, सीखने और सोचने की क्षमता का अनुकरण है।\n\n'
            '**प्रमुख प्रकार:**\n'
            '• 🧠 मशीन लर्निंग (Machine Learning) — डेटा से सीखना\n'
            '• 👁️ कंप्यूटर विज़न (Computer Vision) — छवियां पहचानना\n'
            '• 🗣️ एनएलपी (NLP) — मानव भाषा को समझना\n\n'
            '_मैं आपका ऑफ़लाइन उज्जैन और सिंहस्थ मार्गदर्शक एआई हूँ!_';
      }
      return '🤖 **Artificial Intelligence (AI):**\n\n'
          'AI is the simulation of human intelligence by machines and computer programs.\n\n'
          '**Types of AI:**\n'
          '• 🧠 Machine Learning — learns from data\n'
          '• 👁️ Computer Vision — understands images\n'
          '• 🗣️ NLP — understands human language\n'
          '• 🤖 Robotics — physical AI agents\n\n'
          '_I\'m an AI assistant designed for Simhastha/Ujjain guidance!_';
    }

    return null;
  }

  String? _tryAnswerCapital(String message, {bool isHindi = false}) {
    final capitals = {
      'india': isHindi
          ? '🇮🇳 **भारत** की राजधानी: नई दिल्ली'
          : '🇮🇳 Capital of **India**: New Delhi',
      'भारत': '🇮🇳 **भारत** की राजधानी: नई दिल्ली',
      'madhya pradesh': isHindi
          ? '🏛️ **मध्य प्रदेश** की राजधानी: भोपाल'
          : '🏛️ Capital of **Madhya Pradesh**: Bhopal',
      'मध्य प्रदेश': '🏛️ **मध्य प्रदेश** की राजधानी: भोपाल',
      'mp': isHindi
          ? '🏛️ **मध्य प्रदेश** की राजधानी: भोपाल'
          : '🏛️ Capital of **Madhya Pradesh**: Bhopal',
      'maharashtra': isHindi
          ? '🏛️ **महाराष्ट्र** की राजधानी: मुंबई'
          : '🏛️ Capital of **Maharashtra**: Mumbai',
      'महाराष्ट्र': '🏛️ **महाराष्ट्र** की राजधानी: मुंबई',
      'rajasthan': isHindi
          ? '🏛️ **राजस्थान** की राजधानी: जयपुर'
          : '🏛️ Capital of **Rajasthan**: Jaipur',
      'राजस्थान': '🏛️ **राजस्थान** की राजधानी: जयपुर',
      'gujarat': isHindi
          ? '🏛️ **गुजरात** की राजधानी: गांधीनगर'
          : '🏛️ Capital of **Gujarat**: Gandhinagar',
      'गुजरात': '🏛️ **गुजरात** की राजधानी: गांधीनगर',
      'uttar pradesh': isHindi
          ? '🏛️ **उत्तर प्रदेश** की राजधानी: लखनऊ'
          : '🏛️ Capital of **Uttar Pradesh**: Lucknow',
      'उत्तर प्रदेश': '🏛️ **उत्तर प्रदेश** की राजधानी: लखनऊ',
      'up': isHindi
          ? '🏛️ **उत्तर प्रदेश** की राजधानी: लखनऊ'
          : '🏛️ Capital of **Uttar Pradesh**: Lucknow',
      'usa': isHindi
          ? '🇺🇸 **अमेरिका (USA)** की राजधानी: वाशिंगटन डी.सी.'
          : '🇺🇸 Capital of **USA**: Washington D.C.',
      'अमेरिका': '🇺🇸 **अमेरिका (USA)** की राजधानी: वाशिंगटन डी.सी.',
      'uk': isHindi
          ? '🇬🇧 **ब्रिटेन (UK)** की राजधानी: लंदन'
          : '🇬🇧 Capital of **UK**: London',
      'china': isHindi
          ? '🇨🇳 **चीन** की राजधानी: बीजिंग'
          : '🇨🇳 Capital of **China**: Beijing',
      'चीन': '🇨🇳 **चीन** की राजधानी: बीजिंग',
      'japan': isHindi
          ? '🇯🇵 **जापान** की राजधानी: टोक्यो'
          : '🇯🇵 Capital of **Japan**: Tokyo',
      'जापान': '🇯🇵 **जापान** की राजधानी: टोक्यो',
      'france': isHindi
          ? '🇫🇷 **फ्रांस** की राजधानी: पेरिस'
          : '🇫🇷 Capital of **France**: Paris',
      'germany': isHindi
          ? '🇩🇪 **जर्मनी** की राजधानी: बर्लिन'
          : '🇩🇪 Capital of **Germany**: Berlin',
      'australia': isHindi
          ? '🇦🇺 **ऑस्ट्रेलिया** की राजधानी: कैनबरा'
          : '🇦🇺 Capital of **Australia**: Canberra',
      'russia': isHindi
          ? '🇷🇺 **रूस** की राजधानी: मॉस्को'
          : '🇷🇺 Capital of **Russia**: Moscow',
      'रूस': '🇷🇺 **रूस** की राजधानी: मॉस्को',
      'brazil': isHindi
          ? '🇧🇷 **ब्राजील** की राजधानी: ब्रासीलिया'
          : '🇧🇷 Capital of **Brazil**: Brasília',
      'canada': isHindi
          ? '🇨🇦 **कनाडा** की राजधानी: ओटावा'
          : '🇨🇦 Capital of **Canada**: Ottawa',
    };
    for (final entry in capitals.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _tryAnswerPopulation(String message, {bool isHindi = false}) {
    if (isHindi) {
      final populationsHi = {
        'ujjain':
            '👥 **उज्जैन की अनुमानित जनसंख्या:** ~6.5 लाख (2024)\n'
            '🏛️ उज्जैन मध्य प्रदेश का 7वां सबसे बड़ा शहर है।\n'
            '📅 सिंहस्थ कुंभ के दौरान यहाँ 1 से 1.5 **करोड़** श्रद्धालु आते हैं!',
        'उज्जैन':
            '👥 **उज्जैन की अनुमानित जनसंख्या:** ~6.5 लाख (2024)\n'
            '🏛️ उज्जैन मध्य प्रदेश का 7वां सबसे बड़ा शहर है।\n'
            '📅 सिंहस्थ कुंभ के दौरान यहाँ 1 से 1.5 **करोड़** श्रद्धालु आते हैं!',
        'india':
            '🇮🇳 **भारत की जनसंख्या:** ~1.44 अरब (144 करोड़)\n'
            '🌍 भारत विश्व का **सर्वाधिक जनसंख्या** वाला देश है।',
        'भारत':
            '🇮🇳 **भारत की जनसंख्या:** ~1.44 अरब (144 करोड़)\n'
            '🌍 भारत विश्व का **सर्वाधिक जनसंख्या** वाला देश है।',
        'madhya pradesh':
            '🏛️ **मध्य प्रदेश की जनसंख्या:** ~8.5 करोड़\n'
            'मध्य प्रदेश भारत का 5वां सर्वाधिक आबादी वाला राज्य है।',
        'मध्य प्रदेश':
            '🏛️ **मध्य प्रदेश की जनसंख्या:** ~8.5 करोड़\n'
            'मध्य प्रदेश भारत का 5वां सर्वाधिक आबादी वाला राज्य है।',
        'indore':
            '🏙️ **इंदौर की जनसंख्या:** ~33 लाख\n'
            'इंदौर मध्य प्रदेश का सबसे बड़ा और स्वच्छ शहर है।',
        'इंदौर':
            '🏙️ **इंदौर की जनसंख्या:** ~33 लाख\n'
            'इंदौर मध्य प्रदेश का सबसे बड़ा और स्वच्छ शहर है।',
        'bhopal':
            '🏛️ **भोपाल की जनसंख्या:** ~23 लाख\n'
            'भोपाल मध्य प्रदेश की राजधानी है।',
        'भोपाल':
            '🏛️ **भोपाल की जनसंख्या:** ~23 लाख\n'
            'भोपाल मध्य प्रदेश की राजधानी है।',
        'world': '🌍 **विश्व की कुल जनसंख्या:** ~8.1 अरब (810 करोड़)',
        'दुनिया': '🌍 **विश्व की कुल जनसंख्या:** ~8.1 अरब (810 करोड़)',
      };
      for (final entry in populationsHi.entries) {
        if (message.contains(entry.key)) return entry.value;
      }
      return null;
    }

    const populations = {
      'ujjain':
          '👥 **Population of Ujjain:** ~6.5 lakh (650,000) — 2024 estimate\n'
          '🏛️ Ujjain is the 7th largest city in Madhya Pradesh.\n'
          '📅 During Simhastha, the city hosts 10–15 **million** pilgrims!',
      'india':
          '🇮🇳 **Population of India:** ~1.44 billion (2024)\n'
          '🌍 India is the **most populous country** in the world (surpassed China in 2023).',
      'madhya pradesh':
          '🏛️ **Population of Madhya Pradesh:** ~8.5 crore (85 million) — 2024\n'
          'MP is the 5th most populous state in India.',
      'indore':
          '🏙️ **Population of Indore:** ~3.3 million (2024)\n'
          'Indore is the largest city in Madhya Pradesh.',
      'bhopal':
          '🏛️ **Population of Bhopal:** ~2.3 million (2024)\n'
          'Bhopal is the capital of Madhya Pradesh.',
      'world':
          '🌍 **World Population:** ~8.1 billion (2024)\n'
          'The world population grows by ~80 million people per year.',
    };
    for (final entry in populations.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String _answerUjjainWeather(String message, {bool isHindi = false}) {
    final now = DateTime.now();
    final month = now.month;

    if (isHindi) {
      String seasonHi, tempHi, adviceHi;
      if (month >= 3 && month <= 6) {
        seasonHi = 'ग्रीष्म ऋतु (गर्मी)';
        tempHi = '35°C से 45°C';
        adviceHi =
            '🌡️ अत्यधिक गर्मी! पर्याप्त जल साथ रखें, सूती वस्त्र पहनें। मंदिरों के दर्शन सुबह या शाम के समय करें।';
      } else if (month >= 7 && month <= 9) {
        seasonHi = 'वर्षा ऋतु (मानसून)';
        tempHi = '25°C से 35°C';
        adviceHi =
            '🌧️ सुहावना मौसम। घाटों पर सीढ़ियां गीली हो सकती हैं, सावधानी बरतें। छाता साथ रखें।';
      } else if (month >= 10 && month <= 11) {
        seasonHi = 'शरद ऋतु';
        tempHi = '20°C से 32°C';
        adviceHi =
            '✨ अति उत्तम व सुखद मौसम! तीर्थ दर्शन एवं शिप्रा स्नान हेतु सर्वोत्तम समय।';
      } else {
        seasonHi = 'शीत ऋतु (सर्दी/ठंड)';
        tempHi = '8°C से 22°C';
        adviceHi =
            '🧥 रातें ठंडी व दिन सुहावने होते हैं। प्रातःकालीन भस्म आरती के लिए गर्म कपड़े अवश्य साथ रखें।';
      }

      return '🌤️ **उज्जैन का मौसम — ${_hindiMonthName(month)} ${now.year}:**\n\n'
          '🌡️ **ऋतु:** $seasonHi\n'
          '🌡️ **तापमान:** $tempHi\n\n'
          '$adviceHi\n\n'
          '📍 _यह अनुमानित मौसमी जानकारी है। लाइव अपडेट हेतु इंटरनेट कनेक्शन चालू करें।_';
    }

    String season, temp, advice;
    if (month >= 3 && month <= 6) {
      season = 'Summer (Grishma)';
      temp = '35°C–45°C';
      advice =
          '🌡️ Very hot! Carry water, wear light cotton clothes. Visit temples early morning or evening.';
    } else if (month >= 7 && month <= 9) {
      season = 'Monsoon (Varsha)';
      temp = '25°C–35°C';
      advice =
          '🌧️ Rainy season. Ghats are beautiful but can be slippery. Carry an umbrella.';
    } else if (month >= 10 && month <= 11) {
      season = 'Post-Monsoon (Sharad)';
      temp = '20°C–32°C';
      advice = '✨ Pleasant weather! Ideal time to visit temples and ghats.';
    } else {
      season = 'Winter (Shishir)';
      temp = '8°C–22°C';
      advice =
          '🧥 Cold nights, pleasant days. Carry warm clothes for early morning Bhasma Aarti.';
    }

    return '🌤️ **Ujjain Weather — ${_monthName(month)} ${now.year}:**\n\n'
        '🌡️ **Season:** $season\n'
        '🌡️ **Temperature Range:** $temp\n\n'
        '$advice\n\n'
        '📍 _Ujjain is in Madhya Pradesh, central India. Offline weather is estimated; '
        'connect to internet for real-time forecast._';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _hindiMonthName(int month) {
    const months = [
      'जनवरी',
      'फ़रवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर',
    ];
    return months[month - 1];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HAVERSINE DISTANCE FORMULA (returns metres)
  // ═══════════════════════════════════════════════════════════════════════════
  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth radius in metres
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dphi = (lat2 - lat1) * pi / 180;
    final dlambda = (lon2 - lon1) * pi / 180;

    final a =
        sin(dphi / 2) * sin(dphi / 2) +
        cos(phi1) * cos(phi2) * sin(dlambda / 2) * sin(dlambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Detect follow-up questions based on conversation history
  String? _detectFollowUpQuestion(String message, ChatSession session) {
    bool isFollowUp = _containsAny(message, [
      'also',
      'and',
      'what about',
      'how about',
      'what else',
      'more information',
      'tell me more',
      'aur',
      'bhi',
      'iska mtlb',
    ]);
    bool isComparison = _containsAny(message, [
      'better',
      'best',
      'vs',
      'compare',
      'difference',
      'which one',
      'better than',
    ]);
    bool isMoreDetails = _containsAny(message, [
      'why',
      'how',
      'explain',
      'reason',
      'details',
      'more',
    ]);
    bool isConfirmation = _containsAny(message, [
      'is it',
      'right',
      'correct',
      'true',
      'sure',
    ]);
    bool isPricing = _containsAny(message, [
      'price',
      'cost',
      'rate',
      'expensive',
      'cheap',
      'affordable',
      'rupees',
      'rs',
    ]);
    bool isBooking = _containsAny(message, [
      'book',
      'reserve',
      'confirm',
      'booking',
      'availability',
      'available',
    ]);

    // Get last context
    final lastIntent = _conversationContext['lastIntent'] ?? '';
    final lastMessage = _conversationContext['lastMessage'] ?? '';

    // Handle pricing follow-ups
    if (isPricing &&
        (lastIntent == 'hotel_inquiry' || lastIntent == 'restaurant_inquiry')) {
      if (lastIntent == 'hotel_inquiry') {
        return _generateHotelPricingInfo();
      } else if (lastIntent == 'restaurant_inquiry') {
        return _generateRestaurantPricingInfo();
      }
    }

    // Handle booking follow-ups
    if (isBooking && lastIntent == 'hotel_inquiry') {
      return _generateHotelBookingInfo();
    }

    // Handle "tell me more" about hotels
    if ((isMoreDetails || isFollowUp) && lastIntent == 'hotel_inquiry') {
      return _generateDetailedHotelComparison();
    }

    // Handle "tell me more" about restaurants
    if ((isMoreDetails || isFollowUp) && lastIntent == 'restaurant_inquiry') {
      return _generateDetailedRestaurantInfo();
    }

    // Handle temple follow-ups
    if ((isMoreDetails || isFollowUp) && lastIntent == 'temple_inquiry') {
      return _generateDetailedTempleGuidance();
    }

    return null;
  }

  // Generate hotel pricing information
  String _generateHotelPricingInfo() {
    final StringBuffer response = StringBuffer();
    response.writeln('💰 **Hotel Pricing in Ujjain:**\n');
    response.writeln('**Budget Hotels:** ₹1,500 - ₹2,500 per night');
    response.writeln('• Basic clean rooms, shared facilities');
    response.writeln('• Perfect for budget pilgrims\n');

    response.writeln('**Mid-Range Hotels:** ₹2,500 - ₹5,000 per night');
    response.writeln('• Private AC rooms, attached bathrooms');
    response.writeln('• Good for comfort-seeking pilgrims\n');

    response.writeln('**Premium Hotels:** ₹5,000 - ₹12,000+ per night');
    response.writeln('• Modern amenities, restaurant, parking');
    response.writeln('• Excellent for luxury experience\n');

    response.writeln(
      '📈 **Simhastha 2028 Pricing:** Expect 3-5x normal prices during the event!',
    );
    response.writeln(
      '💡 **Tip:** Book directly with hotels for better rates than online portals',
    );
    return response.toString();
  }

  // Generate restaurant pricing information
  String _generateRestaurantPricingInfo() {
    final StringBuffer response = StringBuffer();
    response.writeln('💰 **Restaurant Pricing in Ujjain:**\n');
    response.writeln('**Budget (₹30-100):**');
    response.writeln('• Street food, local vendors, small eateries');
    response.writeln('• Poha (₹20-30), Samosa (₹10), Thali (₹50-80)\n');

    response.writeln('**Mid-Range (₹100-300):**');
    response.writeln('• Family restaurants, proper seating');
    response.writeln('• Meals: ₹150-250, Specialties: ₹100-200\n');

    response.writeln('**Premium (₹300-800):**');
    response.writeln('• Hotel restaurants, upscale dining');
    response.writeln('• Multi-cuisine: ₹300-500, Fine dining: ₹500-800\n');

    response.writeln(
      '🥘 **Best Value:** Local restaurants near temples offer authentic food at budget prices!',
    );
    return response.toString();
  }

  // Generate hotel booking information
  String _generateHotelBookingInfo() {
    final StringBuffer response = StringBuffer();
    response.writeln('📱 **How to Book Hotels in Ujjain:**\n');
    response.writeln('**Online Platforms:**');
    response.writeln('• OYO Rooms, Booking.com, MakeMyTrip');
    response.writeln('• MagicBricks, AirBnB\n');

    response.writeln('**Direct Booking:**');
    response.writeln('• Call hotel directly for best rates');
    response.writeln('• Ask for pilgrimage/Simhastha discounts\n');

    response.writeln('**Booking Tips:**');
    response.writeln('• Compare prices across platforms');
    response.writeln('• Read recent reviews from pilgrims');
    response.writeln('• Confirm cancellation policy');
    response.writeln('• Ask about temple shuttle services\n');

    response.writeln(
      '⏰ **For Simhastha 2028:** Start booking 6-12 months in advance!',
    );
    response.writeln(
      '📞 **Popular Hotels:** Hotel Avantika (099XX-XXXXX), Hotel Rudra Palace (098XX-XXXXX)',
    );
    return response.toString();
  }

  // Detailed hotel comparison
  String _generateDetailedHotelComparison() {
    final StringBuffer response = StringBuffer();
    response.writeln('🏨 **Detailed Hotel Comparison for Pilgrims:**\n');

    response.writeln('**BEST FOR BUDGET:**');
    response.writeln('🏷️ Dharamshala Mahakaleshwar');
    response.writeln('✅ Lowest rates, closest to temple');
    response.writeln('❌ Basic facilities, shared bathrooms\n');

    response.writeln('**BEST FOR COMFORT:**');
    response.writeln('🛏️ Hotel Rudra Palace');
    response.writeln('✅ Good location, decent amenities');
    response.writeln('❌ May be crowded during peak season\n');

    response.writeln('**BEST FOR LUXURY:**');
    response.writeln('👑 Simhastha Guest House');
    response.writeln('✅ Premium service, ghat proximity, river views');
    response.writeln('❌ Most expensive option\n');

    response.writeln('**BEST FOR FAMILIES:**');
    response.writeln('👨‍👩‍👧‍👦 Hotel Shipra Residency');
    response.writeln('✅ Modern rooms, family-friendly, good food');
    response.writeln('❌ Slightly farther from main temple\n');

    response.writeln(
      '💡 **Choice Recommendation:** Depends on your budget and comfort needs!',
    );
    return response.toString();
  }

  // Detailed restaurant information
  String _generateDetailedRestaurantInfo() {
    final StringBuffer response = StringBuffer();
    response.writeln('🍽️ **Complete Restaurant Guide for Pilgrims:**\n');

    response.writeln('**FOR AUTHENTIC BREAKFAST:**');
    response.writeln('🥘 Apna Sweets & Restaurant');
    response.writeln('⏰ 6:00 AM - 12:00 PM');
    response.writeln('🌟 Famous: Ujjaini Poha, Samosa, Malpua\n');

    response.writeln('**FOR MULTI-CUISINE:**');
    response.writeln('🍴 Hotel Avantika Restaurant');
    response.writeln('📍 Premium location, diverse menu');
    response.writeln('🌟 North Indian, Rajasthani, Continental\n');

    response.writeln('**FOR BUDGET MEALS:**');
    response.writeln('💰 Shree Ganga Restaurant');
    response.writeln('⏰ Open from 7:00 AM');
    response.writeln('🌟 Thali: ₹60-80, Affordable daily meals\n');

    response.writeln('**FOR SACRED PRASADAM:**');
    response.writeln('🙏 Prasadam Bhandar (Temple)');
    response.writeln('⏰ Dependent on aarti timings');
    response.writeln('🌟 Blessed temple food, highly spiritual\n');

    response.writeln(
      '✨ **Pro Tip:** Try local sweets shops for authentic Ujjaini Malpua!',
    );
    return response.toString();
  }

  // Detailed temple guidance
  String _generateDetailedTempleGuidance() {
    final StringBuffer response = StringBuffer();
    response.writeln('🕉️ **Complete Temple Visitation Strategy:**\n');

    response.writeln('**DAY PLAN FOR TEMPLE VISITS:**\n');
    response.writeln('4:00 AM - 5:30 AM');
    response.writeln('• Bhasma Aarti at Mahakaleshwar (book in advance)');
    response.writeln('• Experience sacred ash ritual\n');

    response.writeln('6:00 AM - 7:00 AM');
    response.writeln('• Regular darshan at Mahakaleshwar');
    response.writeln('• Collect prasadam, take blessings\n');

    response.writeln('7:30 AM - 8:30 AM');
    response.writeln('• Visit Kal Bhairav temple');
    response.writeln('• Pray for protection during pilgrimage\n');

    response.writeln('9:00 AM - 10:00 AM');
    response.writeln('• Breakfast at local restaurant');
    response.writeln('• Rest, recharge\n');

    response.writeln('10:30 AM - 12:00 PM');
    response.writeln('• Visit Harsiddhi Mata temple');
    response.writeln('• Pray for family welfare (Tuesday/Friday best)\n');

    response.writeln('4:00 PM - 5:00 PM');
    response.writeln('• Evening aarti at Mahakaleshwar');
    response.writeln('• Evening light and devotional atmosphere\n');

    response.writeln(
      '🎯 **What to Carry:** Water bottle, light bag, comfortable shoes',
    );
    response.writeln(
      '📸 **Photography:** Restricted inside sanctum, allowed outside',
    );
    return response.toString();
  }

  // Enhanced pattern recognition for natural language understanding
  final Map<String, List<String>> _intentPatterns = {
    'hotel_inquiry': [
      // Direct hotel questions
      'hotel',
      'hotels',
      'stay',
      'accommodation',
      'booking',
      'room',
      'resort',
      'lodge',
      'dharamshala',
      'होटल',
      'होटलें',
      'रुकना',
      'ठहरना',
      'कमरा',
      'कमरे',
      'धर्मशाला',
      'लॉज',
      'आश्रम',
      // Natural language variations
      'where to stay',
      'place to stay',
      'good hotel',
      'best hotel',
      'cheap hotel',
      'budget hotel',
      'luxury hotel', 'nice hotel', 'hotel recommendation', 'hotel suggestion',
      'accommodation near', 'stay near', 'room booking', 'hotel booking',
      // Voice variations (how people actually speak)
      'mujhe hotel chahiye',
      'kahan rukna hai',
      'rukne ki jagah',
      'accommodation batao',
      'hotel suggest karo', 'accha hotel batao', 'sasta hotel', 'mehnga hotel',
      'temple ke paas hotel', 'mahakal ke paas hotel',
      'कहाँ रुकें',
      'कहाँ ठहरें',
      'रुकने की जगह',
      'सस्ता होटल',
      'अच्छा होटल',
      'होटल बताओ',
      'होटल चाहिए',
      'महाकाल के पास होटल',
    ],
    'restaurant_inquiry': [
      // Direct food questions
      'restaurant',
      'restaurants',
      'food',
      'eat',
      'dining',
      'cafe',
      'meal',
      'breakfast',
      'lunch',
      'dinner',
      'खाना',
      'भोजन',
      'रेस्टोरेंट',
      'प्रसाद',
      'प्रसादम',
      'नाश्ता',
      'मिठाई',
      'मिष्ठान',
      'पोहा',
      'दाल बाफला',
      // Natural language variations
      'where to eat',
      'good food',
      'best restaurant',
      'local food',
      'vegetarian food',
      'pure veg',
      'sattvic food',
      'prasadam',
      'food recommendation',
      'restaurant suggestion',
      'hungry', 'food place', 'eating place', 'khana', 'famous food',
      // Voice variations
      'khana kahan milega', 'restaurant batao', 'accha khana', 'local khana',
      'prasadam kahan milega',
      'sweet shop',
      'mithai shop',
      'thali kahan milega',
      'कहाँ खाएं',
      'अच्छा खाना',
      'शुद्ध शाकाहारी',
      'सात्विक भोजन',
      'प्रसाद कहाँ मिलेगा',
      'भूख लगी है',
      'खाना बताओ',
      'नाश्ता कहाँ मिलेगा',
    ],
    'temple_inquiry': [
      // Temple specific
      'temple',
      'temples',
      'mandir',
      'mahakaleshwar',
      'mahakal',
      'bhairav',
      'harsiddhi',
      'darshan', 'aarti', 'puja', 'worship', 'deity', 'god', 'goddess',
      'मंदिर',
      'दर्शन',
      'आरती',
      'पूजा',
      'महाकाल',
      'महाकालेश्वर',
      'काल भैरव',
      'हरसिद्धि',
      'मंगलनाथ',
      'चिंतामन',
      'सांदीपनि',
      'गढकालिका',
      'गढ़कालिका',
      'इस्कॉन',
      'रामघाट',
      // Natural language variations
      'temple visit',
      'temple timing',
      'darshan timing',
      'aarti time',
      'temple location',
      'how to reach temple',
      'temple distance',
      'temple information',
      'religious place',
      'sacred place',
      'holy place',
      'spiritual place',
      'jyotirlinga',
      'shakti peeth',
      // Voice variations
      'mandir kahan hai',
      'darshan kab hai',
      'aarti ka samay',
      'temple ka timing',
      'mahakal darshan', 'bhairav darshan', 'mata ke darshan', 'puja ka samay',
      'दर्शन का समय',
      'आरती का समय',
      'मंदिर कब खुलता है',
      'मंदिर कब बंद होता है',
      'दर्शन कैसे करें',
      'मंदिर बताओ',
      'महाकाल दर्शन',
    ],
    'simhastha_inquiry': [
      // Simhastha specific
      'simhastha',
      'kumbh',
      'mela',
      'bathing',
      'ghat',
      'pilgrimage',
      'saints',
      'holy dip',
      'sacred bath',
      'spiritual gathering',
      'religious festival',
      'shipra',
      'river',
      'सिंहस्थ',
      'कुंभ',
      'शाही स्नान',
      'मेला',
      'शिप्रा',
      'अखाड़ा',
      'साधु',
      'संत',
      // Natural language variations
      'kumbh mela',
      'when is kumbh',
      'simhastha date',
      'bathing date',
      'holy bath',
      'ganga aarti',
      'river bathing',
      'pilgrimage information',
      'festival information',
      'spiritual event',
      'religious gathering',
      'mass bathing',
      'sacred gathering',
      // Voice variations
      'simhastha kab hai', 'kumbh kab lagega', 'snan kab hai', 'ghat kahan hai',
      'shipra mein snan', 'holy bath kahan', 'saints kahan milenge',
      'सिंहस्थ कब है',
      'कुंभ मेला कब है',
      'शाही स्नान कब है',
      'शिप्रा स्नान',
      'अखाड़े',
      'कुंभ की जानकारी',
    ],
    'math_inquiry': [
      'calculate',
      'math',
      'plus',
      'minus',
      'times',
      'divided',
      'add',
      'subtract',
      'multiply',
      'divide',
      'sum',
      'total',
      'count',
      'number',
      '+',
      '-',
      '*',
      '/',
      '=',
      'kitna',
      'jitna',
      'guna',
      'bhaag',
      'jod',
      'ghatao',
      'जोड़',
      'घटाव',
      'गुणा',
      'भाग',
      'जोड़ो',
      'घटाओ',
    ],
  };

  bool _containsMathKeywords(String message) {
    return _intentPatterns['math_inquiry']!.any(
          (keyword) => message.contains(keyword),
        ) ||
        RegExp(r'\d+[\+\-\*/]\d+').hasMatch(message);
  }

  bool _containsHotelKeywords(String message) {
    return _matchesIntent(message, 'hotel_inquiry');
  }

  bool _containsRestaurantKeywords(String message) {
    return _matchesIntent(message, 'restaurant_inquiry');
  }

  bool _containsTempleKeywords(String message) {
    return _matchesIntent(message, 'temple_inquiry');
  }

  bool _containsSimhasthaKeywords(String message) {
    return _matchesIntent(message, 'simhastha_inquiry');
  }

  // Advanced intent matching with fuzzy logic
  bool _matchesIntent(String message, String intent) {
    final patterns = _intentPatterns[intent] ?? [];

    // Direct keyword matching
    for (String pattern in patterns) {
      if (message.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    // Fuzzy matching for voice recognition errors
    for (String pattern in patterns) {
      if (_isFuzzyMatch(message, pattern.toLowerCase())) {
        return true;
      }
    }

    // Context-based matching (if previous messages give context)
    if (_hasContextualClues(message, intent)) {
      return true;
    }

    return false;
  }

  // Handle voice recognition inaccuracies
  bool _isFuzzyMatch(String message, String pattern) {
    // Handle common voice recognition errors
    final voiceErrors = {
      'hotel': ['hotel', 'hotell', 'hotle', 'hotal'],
      'restaurant': ['restaurant', 'restrant', 'resturant', 'restraunt'],
      'temple': ['temple', 'templ', 'templle', 'mandir'],
      'mahakaleshwar': [
        'mahakaleshwar',
        'mahakal',
        'mahakaal',
        'mahakaleshvar',
      ],
      'simhastha': ['simhastha', 'simhasta', 'simhstha', 'kumbh'],
    };

    for (final entry in voiceErrors.entries) {
      if (pattern.contains(entry.key)) {
        return entry.value.any((variant) => message.contains(variant));
      }
    }

    // Levenshtein distance for minor spelling differences
    return _levenshteinDistance(message, pattern) <= 2 && pattern.length > 4;
  }

  // Simple Levenshtein distance calculation
  int _levenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) return _levenshteinDistance(s2, s1);
    if (s2.isEmpty) return s1.length;

    List<int> previous = List.generate(s2.length + 1, (i) => i);

    for (int i = 0; i < s1.length; i++) {
      List<int> current = [i + 1];
      for (int j = 0; j < s2.length; j++) {
        int insertions = previous[j + 1] + 1;
        int deletions = current[j] + 1;
        int substitutions = previous[j] + (s1[i] != s2[j] ? 1 : 0);
        current.add(
          [
            insertions,
            deletions,
            substitutions,
          ].reduce((a, b) => a < b ? a : b),
        );
      }
      previous = current;
    }
    return previous.last;
  }

  // Check for contextual clues in the message
  bool _hasContextualClues(String message, String intent) {
    final contextClues = {
      'hotel_inquiry': [
        'ujjain',
        'near',
        'book',
        'reserve',
        'night',
        'days',
        'stay',
      ],
      'restaurant_inquiry': [
        'ujjain',
        'hungry',
        'taste',
        'spicy',
        'sweet',
        'local',
      ],
      'temple_inquiry': [
        'ujjain',
        'visit',
        'pray',
        'worship',
        'blessing',
        'spiritual',
      ],
      'simhastha_inquiry': [
        'ujjain',
        '2028',
        'festival',
        'crowd',
        'spiritual',
        'holy',
      ],
    };

    final clues = contextClues[intent] ?? [];
    int matchCount = 0;

    for (String clue in clues) {
      if (message.contains(clue)) {
        matchCount++;
      }
    }

    // If we have multiple contextual clues, it's likely this intent
    return matchCount >= 2;
  }

  String _generateUjjainHotels() {
    final hotels = _ujjainData['hotels'] as List<Map<String, dynamic>>;
    final StringBuffer response = StringBuffer();
    response.writeln(
      '🏨 Best Hotels in Sacred Ujjain for Simhastha Pilgrims:\n',
    );

    for (int i = 0; i < min(4, hotels.length); i++) {
      final hotel = hotels[i];
      response.writeln('${i + 1}. **${hotel['name']}** (${hotel['area']})');
      response.writeln(
        '   ⭐ ${hotel['rating']}/5 | 💰 ${hotel['price']} | 📍 ${hotel['distance']}',
      );
      response.writeln('   ✨ ${hotel['highlight']}');
      response.writeln('   🔧 ${(hotel['features'] as List).join(', ')}\n');
    }

    response.writeln(
      '🕉️ All hotels provide pure vegetarian food and temple connectivity during Simhastha!',
    );
    response.writeln(
      '\n💡 **Tip:** Book well in advance for Simhastha 2028. Many hotels offer special pilgrimage packages.',
    );

    return response.toString();
  }

  // Enhanced hotel response based on specific query type
  String _generateSmartHotelResponse(String originalMessage) {
    final hotels = _ujjainData['hotels'] as List<Map<String, dynamic>>;
    final message = originalMessage.toLowerCase();
    final isHindi = _isHindiQuery(originalMessage);

    if (isHindi) {
      bool wantsBudget = _containsAny(message, [
        'cheap',
        'budget',
        'affordable',
        'sasta',
        'kam paisa',
        'सस्ता',
        'कम पैसे',
        'बजट',
        'धर्मशाला',
      ]);
      bool wantsLuxury = _containsAny(message, [
        'luxury',
        'premium',
        'best',
        'expensive',
        'accha',
        'badhiya',
        'शानदार',
        'प्रीमियम',
        'लक्जरी',
        'अच्छा',
      ]);
      bool wantsNearTemple = _containsAny(message, [
        'near temple',
        'temple ke paas',
        'mahakal ke paas',
        'close to temple',
        'मंदिर के पास',
        'महाकाल के पास',
        'पास में',
      ]);
      bool wantsQuickBooking = _containsAny(message, [
        'urgent',
        'today',
        'tonight',
        'abhi',
        'immediately',
        'आज',
        'अभी',
        'तुरंत',
      ]);

      final StringBuffer response = StringBuffer();
      if (wantsBudget) {
        response.writeln('💰 **उज्जैन में बजट होटल एवं धर्मशालाएं:**\n');
        response.writeln('1. **महाकालेश्वर धर्मशाला** (मंदिर परिसर)');
        response.writeln('   ⭐ 4.0/5 | 💰 बजट | 📍 महाकाल मंदिर से 0.1 किमी');
        response.writeln(
          '   ✨ मंदिर ट्रस्ट द्वारा संचालित, अत्यंत स्वच्छ एवं सुरक्षित\n',
        );
        response.writeln('2. **होटल रुद्र पैलेस** (महाकाल रोड)');
        response.writeln(
          '   ⭐ 4.2/5 | 💰 बजट/मध्यम | 📍 महाकाल मंदिर से 0.3 किमी',
        );
        response.writeln(
          '   ✨ शुद्ध शाकाहारी भोजन, भस्म आरती हेतु सर्वोत्तम\n',
        );
        response.writeln(
          '💡 **सुझाव:** धर्मशालाओं में अग्रिम बुकिंग नहीं होने पर सीधे काउंटर पर संपर्क करें।',
        );
      } else if (wantsLuxury) {
        response.writeln('✨ **उज्जैन में प्रीमियम एवं लक्जरी होटल:**\n');
        response.writeln('1. **होटल अवंतिका** (देवास गेट)');
        response.writeln(
          '   ⭐ 4.4/5 | 💰 प्रीमियम | 📍 महाकाल मंदिर से 0.5 किमी',
        );
        response.writeln(
          '   ✨ आधुनिक सुख-सुविधाएं, रेस्टोरेंट एवं मंदिर दर्शन हेतु वाहन सुविधा\n',
        );
        response.writeln('2. **सिंहस्थ गेस्ट हाउस** (राम घाट रोड)');
        response.writeln('   ⭐ 4.5/5 | 💰 प्रीमियम | 📍 राम घाट से 0.2 किमी');
        response.writeln(
          '   ✨ शिप्रा नदी व घाट का मनोहारी दृश्य, आध्यात्मिक वातावरण\n',
        );
        response.writeln(
          '👑 ये होटल आपकी आध्यात्मिक यात्रा को अत्यंत आरामदायक बनाते हैं!',
        );
      } else if (wantsNearTemple) {
        response.writeln('🕉️ **महाकालेश्वर मंदिर के सबसे निकट होटल:**\n');
        response.writeln(
          '1. **महाकालेश्वर धर्मशाला** — 0.1 किमी (2 मिनट पैदल)',
        );
        response.writeln('2. **होटल रुद्र पैलेस** — 0.3 किमी (4 मिनट पैदल)');
        response.writeln('3. **होटल अवंतिका** — 0.5 किमी (6 मिनट पैदल)\n');
        response.writeln(
          '🚶 **लाभ:** प्रातः 4:00 AM भस्म आरती हेतु पैदल आसानी से पहुँच सकते हैं!',
        );
      } else {
        response.writeln(
          '🏨 **उज्जैन में ठहरने हेतु प्रमुख होटल व धर्मशालाएं:**\n',
        );
        response.writeln(
          '1. **होटल अवंतिका** (देवास गेट) — ⭐ 4.4/5 | महाकाल से 0.5 किमी',
        );
        response.writeln(
          '2. **होटल रुद्र पैलेस** (महाकाल रोड) — ⭐ 4.2/5 | महाकाल से 0.3 किमी',
        );
        response.writeln(
          '3. **होटल शिप्रा रेजीडेंसी** (यूनिवर्सिटी रोड) — ⭐ 4.3/5 | राम घाट के पास',
        );
        response.writeln(
          '4. **महाकालेश्वर धर्मशाला** (मंदिर परिसर) — ⭐ 4.0/5 | महाकाल से 0.1 किमी\n',
        );
        response.writeln('🕉️ सभी होटलों में शुद्ध शाकाहारी भोजन उपलब्ध है!');
      }

      if (wantsQuickBooking) {
        response.writeln(
          '\n📞 **तत्काल बुकिंग सुझाव:** सीधे होटल रिसेप्शन पर कॉल करें। अधिकांश होटल 24/7 खुले रहते हैं।',
        );
      }
      return response.toString();
    }

    // Detect specific hotel preferences from voice input
    bool wantsBudget = _containsAny(message, [
      'cheap',
      'budget',
      'affordable',
      'sasta',
      'kam paisa',
    ]);
    bool wantsLuxury = _containsAny(message, [
      'luxury',
      'premium',
      'best',
      'expensive',
      'accha',
      'badhiya',
    ]);
    bool wantsNearTemple = _containsAny(message, [
      'near temple',
      'temple ke paas',
      'mahakal ke paas',
      'close to temple',
    ]);
    bool wantsQuickBooking = _containsAny(message, [
      'urgent',
      'today',
      'tonight',
      'abhi',
      'immediately',
    ]);

    final StringBuffer response = StringBuffer();

    if (wantsBudget) {
      response.writeln('💰 Budget-Friendly Hotels in Ujjain:\n');
      final budgetHotels = hotels.where((h) => h['price'] == 'Budget').toList();
      _addHotelDetails(response, budgetHotels);
      response.writeln(
        '\n💡 These budget options still provide clean rooms and temple connectivity!',
      );
    } else if (wantsLuxury) {
      response.writeln('✨ Premium & Luxury Hotels in Ujjain:\n');
      final luxuryHotels = hotels
          .where((h) => h['price'] == 'Premium' || h['price'] == 'Luxury')
          .toList();
      _addHotelDetails(response, luxuryHotels);
      response.writeln(
        '\n👑 These hotels offer the best comfort for your spiritual journey!',
      );
    } else if (wantsNearTemple) {
      response.writeln('🕉️ Hotels Near Mahakaleshwar Temple:\n');
      final nearTempleHotels = hotels
          .where(
            (h) =>
                h['distance'].toString().contains('0.') ||
                h['area'] == 'Mahakal Road',
          )
          .toList();
      _addHotelDetails(response, nearTempleHotels);
      response.writeln('\n🚶 Perfect for early morning Bhasma Aarti!');
    } else {
      // Default comprehensive response
      response.writeln('🏨 Best Hotels in Sacred Ujjain for Your Stay:\n');
      _addHotelDetails(response, hotels.take(4).toList());
      response.writeln(
        '\n🕉️ All hotels provide pure vegetarian food and temple connectivity!',
      );
    }

    if (wantsQuickBooking) {
      response.writeln(
        '\n📞 **Quick Booking Tip:** Call hotels directly for immediate availability. Many have 24/7 reception for pilgrims.',
      );
    }

    return response.toString();
  }

  void _addHotelDetails(
    StringBuffer response,
    List<Map<String, dynamic>> hotels,
  ) {
    for (int i = 0; i < hotels.length; i++) {
      final hotel = hotels[i];
      response.writeln('${i + 1}. **${hotel['name']}** (${hotel['area']})');
      response.writeln(
        '   ⭐ ${hotel['rating']}/5 | 💰 ${hotel['price']} | 📍 ${hotel['distance']}',
      );
      response.writeln('   ✨ ${hotel['highlight']}');
      response.writeln('   🔧 ${(hotel['features'] as List).join(', ')}\n');
    }
  }

  String _generateUjjainRestaurants() {
    final restaurants =
        _ujjainData['restaurants'] as List<Map<String, dynamic>>;
    final StringBuffer response = StringBuffer();
    response.writeln('🍽️ Best Pure Vegetarian Restaurants in Ujjain:\n');

    for (int i = 0; i < restaurants.length; i++) {
      final restaurant = restaurants[i];
      response.writeln(
        '${i + 1}. **${restaurant['name']}** (${restaurant['area']})',
      );
      response.writeln(
        '   🍴 ${restaurant['cuisine']} | ⭐ ${restaurant['rating']}/5 | 💰 ${restaurant['price']}',
      );
      response.writeln(
        '   🌟 Specialties: ${(restaurant['specialties'] as List).join(', ')}',
      );
      response.writeln('   ✨ ${restaurant['highlight']}\n');
    }

    response.writeln(
      '🙏 All restaurants serve pure sattvic vegetarian food suitable for pilgrims and devotees!',
    );

    return response.toString();
  }

  // Enhanced restaurant response based on query specifics
  String _generateSmartRestaurantResponse(String originalMessage) {
    final restaurants =
        _ujjainData['restaurants'] as List<Map<String, dynamic>>;
    final message = originalMessage.toLowerCase();
    final isHindi = _isHindiQuery(originalMessage);

    if (isHindi) {
      bool wantsBreakfast = _containsAny(message, [
        'breakfast',
        'morning',
        'poha',
        'nashta',
        'subah ka khana',
        'नाश्ता',
        'पोहा',
        'कचोरी',
        'समोसा',
        'सुबह का नाश्ता',
      ]);
      bool wantsSweets = _containsAny(message, [
        'sweet',
        'mithai',
        'dessert',
        'malpua',
        'meetha',
        'मिठाई',
        'मालपुआ',
        'मीठा',
        'रबड़ी',
      ]);
      bool wantsLocal = _containsAny(message, [
        'local',
        'famous',
        'traditional',
        'ujjaini',
        'speciality',
        'दाल बाफला',
        'प्रसिद्ध',
        'थाली',
        'खाना',
      ]);
      bool wantsCheap = _containsAny(message, [
        'cheap',
        'budget',
        'affordable',
        'sasta',
        'सस्ता',
        'कम पैसे',
      ]);

      final StringBuffer response = StringBuffer();
      if (wantsBreakfast) {
        response.writeln('🌅 **उज्जैन में सुबह का प्रसिद्ध नाश्ता:**\n');
        response.writeln('**अपना स्वीट्स एवं रेस्टोरेंट (देवास गेट):**\n');
        response.writeln(
          '🥘 **उज्जैनी पोहा:** मालवा का विश्व प्रसिद्ध पोहा, जीरावन व सेंव के साथ',
        );
        response.writeln(
          '🥯 **गरमा-गरम कचोरी व समोसा:** तीखी-मीठी चटनी के साथ',
        );
        response.writeln('🥛 **मसाला चाय व गर्म दूध**\n');
        response.writeln('⏰ प्रातः 6:00 AM से दर्शनार्थियों हेतु उपलब्ध!');
      } else if (wantsSweets) {
        response.writeln('🍯 **उज्जैन की प्रसिद्ध मिष्ठान दुकानें:**\n');
        response.writeln('**अपना स्वीट्स एवं स्थानीय मिष्ठान भंडार:**\n');
        response.writeln(
          '🥞 **मालपुआ:** बाबा महाकाल को भोग लगाया जाने वाला पवित्र प्रसाद',
        );
        response.writeln('🥛 **रबड़ी एवं कुल्फी:** शुद्ध देशी दूध से निर्मित');
        response.writeln('🍯 **मावा बाटी एवं गुलाब जामुन**\n');
        response.writeln(
          '💡 **सुझाव:** महाकाल दर्शन के बाद मालपुआ प्रसाद का आनंद अवश्य लें!',
        );
      } else if (wantsLocal || wantsCheap) {
        response.writeln('🏘️ **उज्जैन का प्रामाणिक भोजन (मालवी स्वाद):**\n');
        response.writeln(
          '1. **दाल बाफला:** मध्य प्रदेश का पारंपरिक स्वादिष्ट व्यंजन (घी, दाल, बाफला, कढ़ी, लड्डू)',
        );
        response.writeln(
          '2. **श्री गंगा रेस्टोरेंट (महाकाल रोड):** भरपेट शुद्ध शाकाहारी थाली (₹60-100)',
        );
        response.writeln(
          '3. **प्रसादम भंडार (मंदिर परिसर):** पवित्र एवं सात्विक भोजन\n',
        );
        response.writeln('🌟 **अवश्य चखें:** दाल बाफला और उज्जैनी सेंव!');
      } else {
        response.writeln(
          '🍽️ **उज्जैन में तीर्थयात्रियों हेतु सर्वश्रेष्ठ रेस्टोरेंट:**\n',
        );
        response.writeln(
          '1. **अपना स्वीट्स & रेस्टोरेंट** (देवास गेट) — शुद्ध शाकाहारी पोहा, नाश्ता व भोजन',
        );
        response.writeln(
          '2. **श्री गंगा रेस्टोरेंट** (महाकाल रोड) — दाल बाफला व गुजराती/उत्तर भारतीय थाली',
        );
        response.writeln(
          '3. **होटल अवंतिका रेस्टोरेंट** (देवास गेट) — राजस्थानी व उत्तर भारतीय व्यंजन',
        );
        response.writeln(
          '4. **प्रसादम भंडार** (महाकाल परिसर) — मंदिर का सात्विक प्रसाद भोजन\n',
        );
        response.writeln(
          '🙏 सभी भोजन शुद्ध शाकाहारी, सात्विक एवं श्रद्धापूर्वक तैयार किया जाता है!',
        );
      }
      return response.toString();
    }

    bool wantsBreakfast = _containsAny(message, [
      'breakfast',
      'morning',
      'poha',
      'nashta',
      'subah ka khana',
    ]);
    bool wantsSweets = _containsAny(message, [
      'sweet',
      'mithai',
      'dessert',
      'malpua',
      'meetha',
    ]);
    bool wantsLocal = _containsAny(message, [
      'local',
      'famous',
      'traditional',
      'ujjaini',
      'speciality',
    ]);
    bool wantsCheap = _containsAny(message, [
      'cheap',
      'budget',
      'affordable',
      'sasta',
    ]);
    bool wantsNearTemple = _containsAny(message, [
      'near temple',
      'mahakal ke paas',
      'temple ke paas',
    ]);

    final StringBuffer response = StringBuffer();

    if (wantsBreakfast) {
      response.writeln('🌅 Best Breakfast Places in Ujjain:\n');
      response.writeln('**Apna Sweets & Restaurant** is famous for:\n');
      response.writeln(
        '🥘 **Ujjaini Poha** - The most authentic local breakfast',
      );
      response.writeln('🥯 **Fresh Samosas** - Crispy and hot');
      response.writeln('🧈 **Kachori** - Traditional morning snack\n');
      response.writeln('📍 Location: Dewas Gate (near temples)');
      response.writeln('⏰ Open from 6:00 AM for early morning pilgrims');
    } else if (wantsSweets) {
      response.writeln('🍯 Famous Sweet Shops in Ujjain:\n');
      response.writeln('**Apna Sweets** specializes in:\n');
      response.writeln('🥞 **Malpua** - Sacred sweet offered to Lord Mahakal');
      response.writeln('🍯 **Traditional Ujjaini Sweets**');
      response.writeln('🥛 **Fresh Rabdi and Kulfi**\n');
      response.writeln(
        '💡 **Tip:** Try Malpua as prasadam - it\'s considered very auspicious!',
      );
    } else if (wantsLocal || wantsCheap) {
      response.writeln('🏘️ Authentic Local Food in Ujjain:\n');
      final localRestaurants = restaurants
          .where((r) => r['price'] == 'Budget')
          .toList();
      _addRestaurantDetails(response, localRestaurants);
      response.writeln(
        '\n🌟 **Must-try:** Dal Bafla (traditional MP dish) and Ujjaini Poha!',
      );
    } else {
      response.writeln('🍽️ Best Restaurants for Pilgrims:\n');
      _addRestaurantDetails(response, restaurants);
    }

    response.writeln(
      '\n🙏 All food is pure vegetarian and prepared with devotion!',
    );
    return response.toString();
  }

  void _addRestaurantDetails(
    StringBuffer response,
    List<Map<String, dynamic>> restaurants,
  ) {
    for (int i = 0; i < restaurants.length; i++) {
      final restaurant = restaurants[i];
      response.writeln(
        '${i + 1}. **${restaurant['name']}** (${restaurant['area']})',
      );
      response.writeln(
        '   🍴 ${restaurant['cuisine']} | ⭐ ${restaurant['rating']}/5 | 💰 ${restaurant['price']}',
      );
      response.writeln(
        '   🌟 Specialties: ${(restaurant['specialties'] as List).join(', ')}',
      );
      response.writeln('   ✨ ${restaurant['highlight']}\n');
    }
  }

  String _generateTempleInfo() {
    final temples = _ujjainData['temples'] as List<Map<String, dynamic>>;
    final StringBuffer response = StringBuffer();
    response.writeln('🕉️ Sacred Temples of Ujjain - Your Spiritual Guide:\n');

    for (final temple in temples) {
      response.writeln('**${temple['name']}**');
      response.writeln('🙏 Significance: ${temple['significance']}');
      response.writeln('⏰ Timings: ${temple['timing']}');
      response.writeln(
        '✨ Special Features: ${(temple['specialFeatures'] as List).join(', ')}',
      );
      if (temple['tips'] != null) {
        response.writeln('💡 Tip: ${temple['tips']}');
      }
      response.writeln('');
    }

    response.writeln('🚩 **Temple Visit Order Suggestion:**');
    response.writeln('1. Start with Mahakaleshwar Jyotirlinga (Main deity)');
    response.writeln('2. Visit Kal Bhairav (City guardian)');
    response.writeln('3. Pray at Harsiddhi Mata (Divine mother)');
    response.writeln('4. Complete circuit at Chintaman Ganesh');
    response.writeln('\nHar Har Mahadev! 🕉️');

    return response.toString();
  }

  // Enhanced temple response based on specific queries
  String _generateSmartTempleResponse(String originalMessage) {
    final temples = _ujjainData['temples'] as List<Map<String, dynamic>>;
    final message = originalMessage.toLowerCase();
    final isHindi = _isHindiQuery(originalMessage);

    if (isHindi) {
      bool wantsBhasmaAarti = _containsAny(message, [
        'bhasma',
        'aarti',
        'morning',
        'early',
        'subah',
        'भस्म',
        'आरती',
        'सुबह',
      ]);
      bool wantsTimings = _containsAny(message, [
        'timing',
        'time',
        'kab khula',
        'samay',
        'schedule',
        'open',
        'close',
        'समय',
        'कब खुलता',
        'कब बंद',
        'दर्शन का समय',
      ]);
      bool wantsDirections = _containsAny(message, [
        'how to reach',
        'location',
        'address',
        'kahan hai',
        'direction',
        'कहाँ है',
        'रास्ता',
        'कैसे पहुंचे',
        'स्थान',
      ]);
      bool wantsDarshan = _containsAny(message, [
        'darshan',
        'visit',
        'dekh',
        'pray',
        'worship',
        'दर्शन',
        'पूजा',
        'क्रम',
      ]);

      final StringBuffer response = StringBuffer();
      if (wantsBhasmaAarti) {
        response.writeln('🌅 **श्री महाकालेश्वर मंदिर — दिव्य भस्म आरती:**\n');
        response.writeln(
          '⏰ **समय:** प्रातः 4:00 AM से 6:00 AM (वर्ष के 365 दिन)',
        );
        response.writeln(
          '🎫 **बुकिंग:** मंदिर की आधिकारिक वेबसाइट से अग्रिम ऑनलाइन बुकिंग अनिवार्य',
        );
        response.writeln(
          '🚶 **पहुंचने का समय:** सुरक्षा जांच हेतु प्रातः 3:00 AM तक पहुंचें',
        );
        response.writeln(
          '👕 **ड्रेस कोड:** पुरुषों हेतु धोती/सोला एवं महिलाओं हेतु साड़ी अनिवार्य',
        );
        response.writeln(
          '📵 **नियम:** आरती के दौरान मोबाइल व इलेक्ट्रॉनिक उपकरण प्रतिबंधित हैं\n',
        );
        response.writeln(
          '✨ **विशेषता:** विश्व में केवल महाकाल मंदिर में ही प्रतिदिन भस्म से भगवान शिव का अभिषेक होता है!',
        );
      } else if (wantsTimings) {
        response.writeln('⏰ **उज्जैन के प्रमुख मंदिरों का दर्शन समय:**\n');
        response.writeln('🕉️ **श्री महाकालेश्वर ज्योतिर्लिंग:**');
        response.writeln('   • भस्म आरती: प्रातः 4:00 AM (अग्रिम बुकिंग)');
        response.writeln(
          '   • सामान्य दर्शन: प्रातः 6:00 AM से रात्रि 11:00 PM\n',
        );
        response.writeln('👹 **श्री काल भैरव मंदिर:**');
        response.writeln('   • दर्शन: प्रातः 6:00 AM से रात्रि 10:00 PM\n');
        response.writeln('🌺 **माँ हरसिद्धि शक्तिपीठ:**');
        response.writeln(
          '   • दर्शन: प्रातः 5:00 AM से रात्रि 10:00 PM (दीप स्तंभ प्रज्ज्वलन: सायं 7:00 PM)\n',
        );
        response.writeln(
          '🪐 **श्री मंगलनाथ मंदिर:** प्रातः 6:00 AM से रात्रि 8:30 PM\n',
        );
        response.writeln(
          '💡 **सुझाव:** शांतिपूर्ण दर्शन हेतु सुबह 6:00 AM से 8:00 AM का समय सर्वोत्तम है।',
        );
      } else if (wantsDirections) {
        response.writeln(
          '🗺️ **उज्जैन के प्रमुख मंदिरों की स्थिति व दूरी:**\n',
        );
        response.writeln(
          '🕉️ **महाकालेश्वर मंदिर:** रेलवे स्टेशन से ~2 किमी (ऑटो/ई-रिक्शा उपलब्ध)',
        );
        response.writeln(
          '👹 **काल भैरव मंदिर:** महाकाल से ~4.5 किमी (भैरवगढ़ रोड)',
        );
        response.writeln(
          '🌺 **माँ हरसिद्धि मंदिर:** महाकाल से मात्र ~800 मीटर (पैदल दूरी)',
        );
        response.writeln(
          '🪐 **मंगलनाथ मंदिर:** महाकाल से ~5.5 किमी (शिप्रा तट)',
        );
        response.writeln(
          '🐘 **चिंतामन गणेश:** महाकाल से ~6.5 किमी (फतेहाबाद रोड)\n',
        );
        response.writeln(
          '🚗 सभी मंदिरों के दर्शन 1 दिन में सरलता से किए जा सकते हैं!',
        );
      } else if (wantsDarshan) {
        response.writeln(
          '🙏 **उज्जैन तीर्थ दर्शन का पावन क्रम (शास्त्रोक्त विधि):**\n',
        );
        response.writeln(
          '1. 🕉️ **श्री महाकालेश्वर ज्योतिर्लिंग** — मुख्य आराध्य, यात्रा का शुभारंभ',
        );
        response.writeln(
          '2. 👹 **श्री काल भैरव** — उज्जैन के कोतवाल/रक्षक, आज्ञा व रक्षा हेतु',
        );
        response.writeln(
          '3. 🌺 **माँ हरसिद्धि देवी** — 51 शक्तिपीठों में से एक (सती की कोहनी)',
        );
        response.writeln(
          '4. 🪐 **श्री मंगलनाथ** — मंगल ग्रह की जन्मभूमि, अंगारक दोष निवारण',
        );
        response.writeln(
          '5. 🌊 **राम घाट (शिप्रा)** — पावन स्नान एवं सायं दीपदान महाआरती',
        );
        response.writeln(
          '6. 🐘 **श्री चिंतामन गणेश** — समस्त चिंताओं के निवारण हेतु पूर्णता\n',
        );
        response.writeln(
          '🕉️ हर हर महादेव! भगवान महाकाल आपकी यात्रा सफल करें!',
        );
      } else {
        response.writeln('🕉️ **उज्जैन के पावन तीर्थ एवं मंदिर:**\n');
        for (final temple in temples) {
          final tName = temple['hindiName'] ?? temple['name'];
          final tSig = temple['hindiSignificance'] ?? temple['significance'];
          final tTime = temple['hindiTiming'] ?? temple['timing'];
          response.writeln('**$tName**');
          response.writeln('🙏 महत्व: $tSig');
          response.writeln('⏰ समय: $tTime\n');
        }
      }
      return response.toString();
    }

    bool wantsTimings = _containsAny(message, [
      'timing',
      'time',
      'kab khula',
      'samay',
      'schedule',
      'open',
      'close',
    ]);
    bool wantsBhasmaAarti = _containsAny(message, [
      'bhasma',
      'aarti',
      'morning',
      'early',
      'subah',
    ]);
    bool wantsSpecificTemple = _containsAny(message, [
      'mahakal',
      'bhairav',
      'harsiddhi',
      'specific',
    ]);
    bool wantsDirections = _containsAny(message, [
      'how to reach',
      'location',
      'address',
      'kahan hai',
      'direction',
    ]);
    bool wantsDarshan = _containsAny(message, [
      'darshan',
      'visit',
      'dekh',
      'pray',
      'worship',
    ]);

    final StringBuffer response = StringBuffer();

    if (wantsBhasmaAarti) {
      response.writeln('🌅 **Bhasma Aarti at Mahakaleshwar Temple:**\n');
      response.writeln('⏰ **Time:** 4:00 AM sharp (365 days a year)');
      response.writeln('🎫 **Booking:** Online advance booking required');
      response.writeln(
        '📱 **Website:** Book through official Mahakaleshwar website',
      );
      response.writeln('🚶 **Arrival:** Come 1 hour early for security check');
      response.writeln('👕 **Dress Code:** Traditional/formal wear preferred');
      response.writeln('📵 **No phones** allowed inside during aarti\n');
      response.writeln(
        '✨ **Special:** This is the only Jyotirlinga with daily Bhasma Aarti using sacred ash',
      );
      response.writeln(
        '🙏 **Experience:** Witness the deity being adorned with fresh ash from cremation grounds',
      );
    } else if (wantsTimings) {
      response.writeln('⏰ **Temple Timings in Ujjain:**\n');
      response.writeln('🕉️ **Mahakaleshwar Jyotirlinga:**');
      response.writeln('   • Bhasma Aarti: 4:00 AM (advance booking)');
      response.writeln('   • Regular Darshan: 6:00 AM - 11:00 PM\n');

      response.writeln('👹 **Kal Bhairav Temple:**');
      response.writeln('   • Morning: 5:00 AM - 12:00 PM');
      response.writeln('   • Evening: 4:00 PM - 10:00 PM\n');

      response.writeln('🌺 **Harsiddhi Temple:**');
      response.writeln('   • Morning: 5:00 AM - 12:00 PM');
      response.writeln('   • Evening: 4:00 PM - 9:00 PM');
      response.writeln(
        '   • **Special Days:** Tuesday & Friday for Mata Aarti\n',
      );

      response.writeln(
        '💡 **Best Time:** Early morning for peaceful darshan and divine atmosphere',
      );
    } else if (wantsDirections) {
      response.writeln('🗺️ **Temple Locations in Ujjain:**\n');
      response.writeln('🕉️ **Mahakaleshwar Temple:**');
      response.writeln('📍 Address: Mahakal Road, near Dewas Gate');
      response.writeln('🚗 Distance: 2 km from Railway Station');
      response.writeln('🛺 Local Transport: Auto-rickshaw, city bus\n');

      response.writeln('👹 **Kal Bhairav Temple:**');
      response.writeln('📍 Address: Near Kalbhairav Road');
      response.writeln('🚶 Distance: 1 km from Mahakaleshwar');
      response.writeln('💡 Easy walking distance from main temple\n');

      response.writeln('🌺 **Harsiddhi Temple:**');
      response.writeln('📍 Address: Dewas Road');
      response.writeln('🚗 Distance: 3 km from Mahakaleshwar');
      response.writeln('🛺 Auto-rickshaw easily available\n');

      response.writeln(
        '🗺️ **Temple Circuit:** Most pilgrims complete all temples in one day',
      );
    } else if (wantsDarshan) {
      response.writeln('🙏 **Complete Darshan Guide for Ujjain:**\n');
      response.writeln('**Sacred Order of Visit:**\n');
      response.writeln('1. 🕉️ **Mahakaleshwar** (Main Jyotirlinga)');
      response.writeln('   • Start your pilgrimage here');
      response.writeln('   • Offer prayers for blessings');
      response.writeln('   • Take prasadam\n');

      response.writeln('2. 👹 **Kal Bhairav** (City Guardian)');
      response.writeln('   • Seek protection for your journey');
      response.writeln('   • Traditional liquor offering (if you wish)');
      response.writeln('   • Guardian deity blesses all visitors\n');

      response.writeln('3. 🌺 **Harsiddhi Mata** (Divine Mother)');
      response.writeln('   • Pray for family welfare');
      response.writeln('   • One of 51 Shakti Peethas');
      response.writeln('   • Offer red flowers and coconut\n');

      response.writeln('🕯️ **Darshan Tips:**');
      response.writeln('• Maintain silence inside sanctum');
      response.writeln('• Photography restrictions apply');
      response.writeln('• Touch feet of deity if permitted');
      response.writeln('• Collect prasadam with devotion');
    } else {
      response.writeln('🕉️ **Sacred Temples of Ujjain:**\n');
      for (final temple in temples) {
        response.writeln('**${temple['name']}**');
        response.writeln('🙏 ${temple['significance']}');
        response.writeln('⏰ ${temple['timing']}');
        response.writeln(
          '✨ ${(temple['specialFeatures'] as List).join(', ')}\n',
        );
      }
    }

    response.writeln(
      '\nHar Har Mahadev! May Lord Mahakal bless your darshan! 🕉️',
    );
    return response.toString();
  }

  String _generateSimhasthaInfo() {
    final simhastha = _ujjainData['simhastha_info'] as Map<String, dynamic>;
    final StringBuffer response = StringBuffer();

    response.writeln('🚩 Simhastha Kumbh Mela - The Sacred Gathering:\n');
    response.writeln('📅 **Next Simhastha:** ${simhastha['nextDate']}');
    response.writeln('⏳ **Duration:** ${simhastha['duration']}');
    response.writeln('🌟 **Significance:** ${simhastha['significance']}');
    response.writeln(
      '👥 **Expected Visitors:** ${simhastha['expectedVisitors']}\n',
    );

    response.writeln('🎭 **Main Events:**');
    for (final event in simhastha['mainEvents'] as List) {
      response.writeln('• $event');
    }

    response.writeln('\n🏺 **Sacred Bath Locations:**');
    response.writeln('• **Ram Ghat** - Main bathing ghat');
    response.writeln('• **Shipra River** - Sacred waters for moksha');
    response.writeln('• **Triveni Ghat** - Confluence point\n');

    response.writeln('🙏 **Spiritual Significance:**');
    response.writeln(
      'Simhastha occurs when Jupiter (Guru) enters Leo (Simha) constellation. This celestial alignment makes the Shipra River waters especially sacred for attaining liberation (moksha).\n',
    );

    response.writeln('📱 **Planning Tips:**');
    response.writeln('• Book accommodation 1 year in advance');
    response.writeln('• Follow crowd management guidelines');
    response.writeln('• Respect saints and spiritual traditions');
    response.writeln('• Carry minimal luggage');
    response.writeln('• Stay hydrated and eat sattvic food');
    response.writeln(
      '\nHar Har Mahadev! May your Simhastha journey be blessed! 🕉️',
    );

    return response.toString();
  }

  // Enhanced Simhastha response based on specific queries
  String _generateSmartSimhasthaResponse(String originalMessage) {
    final message = originalMessage.toLowerCase();
    final isHindi = _isHindiQuery(originalMessage);

    if (isHindi) {
      bool wantsMythology = _containsAny(message, [
        'mythology',
        'story',
        'katha',
        'amrit',
        'samudra manthan',
        'nectar',
        'why celebrate',
        'कथा',
        'पौराणिक',
        'अमृत',
        'समुद्र मंथन',
        'अमृत कलश',
        'क्यों मनाते हैं',
        'महत्व क्या है',
      ]);
      bool wantsAstrology = _containsAny(message, [
        'astrology',
        'astrological',
        'zodiac',
        'leo',
        'jupiter',
        'guru',
        'simha rashi',
        'planet',
        'ज्योतिष',
        'सिंह राशि',
        'बृहस्पति',
        'गुरु ग्रह',
        'खगोलीय',
        'सिंहस्थ नाम',
      ]);
      bool wantsAkharas = _containsAny(message, [
        'akhara',
        'akharas',
        'naga',
        'peshwai',
        'saints',
        'sadhu',
        'अखाड़ा',
        'अखाड़े',
        'नागा साधु',
        'नागा संन्यासी',
        'पेशवाई',
        'अखाड़ों की सूची',
      ]);
      bool wantsDates = _containsAny(message, [
        'when',
        'date',
        'kab',
        'time',
        '2028',
        'next',
        'कब',
        'तारीख',
        'दिनांक',
        'समय',
        'कब है',
        'तिथियां',
      ]);
      bool wantsBathing = _containsAny(message, [
        'bath',
        'bathing',
        'snan',
        'ghat',
        'river',
        'holy dip',
        'स्नान',
        'शाही स्नान',
        'घाट',
        'शिप्रा',
      ]);
      bool wantsAccommodation = _containsAny(message, [
        'stay',
        'hotel',
        'accommodation',
        'crowd',
        'booking',
        'ठहरना',
        'होटल',
        'धर्मशाला',
        'टेंट',
        'टेंट सिटी',
      ]);
      bool wantsEvents = _containsAny(message, [
        'event',
        'program',
        'procession',
        'saints',
        'कार्यक्रम',
        'मेला',
      ]);
      bool wantsPreparation = _containsAny(message, [
        'prepare',
        'plan',
        'tips',
        'advice',
        'first time',
        'तैयारी',
        'सुझाव',
        'प्लान',
      ]);

      final StringBuffer response = StringBuffer();

      if (wantsMythology) {
        response.writeln(
          '🏺 **सिंहस्थ कुंभ महापर्व की पावन पौराणिक कथा (समुद्र मंथन व अमृत कलश):**\n',
        );
        response.writeln('🌊 **देव-दानव समुद्र मंथन:**');
        response.writeln(
          'पौराणिक मान्यता के अनुसार क्षीरसागर में देवताओं और दैत्यों द्वारा अमृत प्राप्ति हेतु मंदराचल पर्वत व वासुकि नाग से समुद्र मंथन किया गया। मंथन से १४ दिव्य रत्न निकले और अंत में भगवान धनवंतरि अमृत का कलश लेकर प्रकट हुए।\n',
        );
        response.writeln('🕊️ **अमृत की रक्षा एवं १२ दिव्य दिन:**');
        response.writeln(
          'अमृत को दैत्यों से बचाने के लिए देवराज इंद्र के पुत्र जयंत अमृत कुंभ लेकर आकाश मार्ग से भागे। १२ दिनों तक चले देव-दानव युद्ध (देवताओं का १ दिन मनुष्यों के १ वर्ष के बराबर) के दौरान पृथ्वी पर ४ पवित्र स्थानों पर अमृत की बूंदें गिरीं:\n',
        );
        response.writeln(
          '  1. 🏺 **उज्जैन (अवंतिका):** मोक्षदायिनी पुण्यसलिला माँ शिप्रा नदी तट',
        );
        response.writeln(
          '  2. 🌊 **हरिद्वार:** माँ गंगा का पावन हर की पौड़ी तट',
        );
        response.writeln(
          '  3. 🔱 **प्रयागराज:** गंगा, यमुना व गुप्त सरस्वती का पावन त्रिवेणी संगम',
        );
        response.writeln(
          '  4. 🌿 **नासिक (त्र्यंबकेश्वर):** पवित्र गोदावरी नदी तट\n',
        );
        response.writeln(
          '✨ **अमृत स्नान का महात्म्य:** सिंहस्थ कुंभ में शिप्रा स्नान से अमृत तत्व की प्राप्ति होती है और जन्म-जन्मांतर के पापों से मुक्ति (मोक्ष) मिलती है!',
        );
      } else if (wantsAstrology) {
        response.writeln(
          '🌟 **सिंहस्थ कुंभ का ज्योतिषीय एवं खगोलीय रहस्य:**\n',
        );
        response.writeln('🪐 **इसे "सिंहस्थ" क्यों कहा जाता है?**');
        response.writeln(
          'जब ज्ञान व धर्म के कारक **देवगुरु बृहस्पति (Jupiter)** सिंह राशि (Leo) में प्रवेश करते हैं, और **भगवान सूर्यदेव** मेष राशि (Aries) में गोचर करते हैं, तब अवंतिका (उज्जैन) की पावन भूमि पर यह दुर्लभ खगोलीय योग निर्मित होता है। गुरु के "सिंह" राशि में स्थित होने के कारण ही इसे **"सिंहस्थ"** कहा जाता है!\n',
        );
        response.writeln('🌕 **वैशाख पूर्णिमा का महायोग:**');
        response.writeln(
          'सिंह राशि में गुरु, मेष में सूर्य, और तुला राशि में चंद्रमा का योग वैशाख पूर्णिमा को शिप्रा जल को साक्षात अमृतमय बना देता है।\n',
        );
        response.writeln(
          '⏳ **१२ वर्ष का चक्र:** गुरु ग्रह को सूर्य की एक पूर्ण परिक्रमा करने में लगभग १२ वर्ष का समय लगता है, इसीलिए प्रत्येक १२ वर्ष में सिंहस्थ कुंभ का आयोजन होता है।',
        );
      } else if (wantsAkharas) {
        response.writeln(
          '🚩 **सिंहस्थ के १३ सनातन अखाड़े एवं नागा संन्यासी परंपरा:**\n',
        );
        response.writeln('👑 **१३ प्रमुख अखाड़ों का परिचय:**');
        response.writeln('• **७ शैव (संन्यासी) अखाड़े:**');
        response.writeln(
          '  1. श्री पंचदशनाम जूना अखाड़ा (सबसे विशाल नागा साधुओं का अखाड़ा)',
        );
        response.writeln(
          '  2. श्री निरंजनी अखाड़ा (विद्वानों व संन्यासियों का अखाड़ा)',
        );
        response.writeln(
          '  3. श्री महानिर्वाणी अखाड़ा (महाकाल मंदिर से ऐतिहासिक संबंध)',
        );
        response.writeln('  4. श्री अटल अखाड़ा');
        response.writeln('  5. श्री आह्वान अखाड़ा');
        response.writeln('  6. श्री आनंद अखाड़ा');
        response.writeln('  7. श्री पंचाग्नि अखाड़ा\n');
        response.writeln('• **३ वैष्णव (बैरागी) अखाड़े:**');
        response.writeln('  8. श्री दिगंबर अनी अखाड़ा');
        response.writeln('  9. श्री निर्वाणी अनी अखाड़ा');
        response.writeln('  10. श्री निर्मोही अनी अखाड़ा\n');
        response.writeln('• **३ उदासीन व निर्मल अखाड़े:**');
        response.writeln('  11. श्री बड़ा उदासीन अखाड़ा');
        response.writeln('  12. श्री नया उदासीन अखाड़ा');
        response.writeln(
          '  13. श्री निर्मल अखाड़ा (सिख परंपरा से जुड़े संत)\n',
        );
        response.writeln(
          '🐘 **शाही पेशवाई:** अखाड़ों के महामंडलेश्वरों, संतों व नागा बाबाओं का हाथी, घोड़ों, रथों व पारंपरिक अस्त्र-शस्त्रों के साथ नगर में भव्य प्रवेश (पेशवाई) सिंहस्थ का सबसे अद्भुत व दर्शनीय आकर्षण होता है!',
        );
      } else if (wantsDates) {
        response.writeln(
          '📅 **सिंहस्थ कुंभ महापर्व 2028 — मुख्य तिथियां एवं शाही स्नान:**\n',
        );
        response.writeln('🗓️ **आयोजन वर्ष:** अप्रैल - मई 2028');
        response.writeln(
          '🌟 **खगोलीय योग:** जब देवगुरु बृहस्पति सिंह राशि में एवं सूर्य मेष राशि में प्रवेश करते हैं',
        );
        response.writeln(
          '⏳ **अवधि:** लगभग 1 माह का विराट महापर्व (चैत्र पूर्णिमा से वैशाख पूर्णिमा)\n',
        );
        response.writeln(
          '🏺 **प्रमुख शाही स्नान पर्व (Auspicious Shahi Snan Dates):**',
        );
        response.writeln(
          '• **प्रथम शाही स्नान (चैत्र पूर्णिमा):** महाकुंभ का शुभारंभ एवं अखाड़ों का प्रथम स्नान',
        );
        response.writeln(
          '• **मेष संक्रांति स्नान:** सूर्य का मेष राशि में प्रवेश',
        );
        response.writeln('• **वरूथिनी एकादशी स्नान:** अत्यंत पावन');
        response.writeln(
          '• **वैशाख कृष्ण अमावस्या स्नान:** दूसरा प्रमुख शाही स्नान',
        );
        response.writeln('• **मोहिनी एकादशी स्नान:** अमृत वितरण की पावन तिथि');
        response.writeln(
          '• **वैशाख पूर्णिमा (मुख्य महा शाही स्नान):** सिंहस्थ 2028 का सर्वोच्च व सबसे बड़ा शाही स्नान पर्व!\n',
        );
        response.writeln(
          '🔔 **सुझाव:** सिंहस्थ 2028 हेतु कम से कम 1 वर्ष पूर्व से आवास व यात्रा योजना बनाएं!',
        );
      } else if (wantsBathing) {
        response.writeln(
          '🏺 **सिंहस्थ 2028 में पवित्र शिप्रा स्नान मार्गदर्शिका:**\n',
        );
        response.writeln('🌊 **प्रमुख पावन स्नान घाट:**');
        response.writeln(
          '• **राम घाट:** मुख्य शाही स्नान घाट (महाकालेश्वर मंदिर के निकट, सायं 7:00 PM महाआरती)',
        );
        response.writeln(
          '• **दत्त अखाड़ा घाट:** राम घाट के सामने, नागा संन्यासियों का प्रमुख स्नान क्षेत्र',
        );
        response.writeln(
          '• **नृसिंह घाट:** शांत व निर्मल जल धारा, पारिवारिक स्नान हेतु उत्तम',
        );
        response.writeln(
          '• **सिद्धवट घाट:** अमर वटवृक्ष व पितृ तर्पण हेतु पवित्र स्थल',
        );
        response.writeln(
          '• **त्रिवेणी घाट:** नवग्रह मंदिर व त्रिवेणी संगम स्थल\n',
        );
        response.writeln(
          '⏰ **उत्तम स्नान समय:** प्रातः 4:00 AM से 6:00 AM (ब्रह्म मुहूर्त)\n',
        );
        response.writeln('🙏 **पवित्र स्नान विधि:**');
        response.writeln(
          '1. पूर्व दिशा की ओर मुख करके तीन पवित्र डुबकियां लगाएं।',
        );
        response.writeln(
          '2. प्रत्येक डुबकी के साथ "हर हर महादेव" व "ॐ नमः शिवाय" जपें।',
        );
        response.writeln(
          '3. दोनों हाथों से भगवान सूर्यदेव को अर्घ्य अर्पित करें।',
        );
        response.writeln(
          '4. स्नान के पश्चात राम घाट पर दीपदान व महाकाल दर्शन करें।',
        );
      } else if (wantsAccommodation) {
        response.writeln(
          '🏨 **सिंहस्थ 2028 में आवास एवं रुकने की सम्पूर्ण व्यवस्था:**\n',
        );
        response.writeln('🏕️ **उपलब्ध विकल्प:**');
        response.writeln(
          '• **सरकारी टेंट सिटी (Tent City):** प्रशासन द्वारा सादावल, पिंगलेश्वर व उन्हेल रोड पर विशाल वातानुकूलित (AC/Non-AC) स्विस कॉटेज व तंबू नगरी।',
        );
        response.writeln(
          '• **आश्रम व धर्मशालाएं:** महाकाल व राम घाट क्षेत्र में निःशुल्क/किफायती आध्यात्मिक आवास।',
        );
        response.writeln(
          '• **होटल व रिसॉर्ट्स:** सामान्य समय से 3-5 गुना किराया बढ़ जाता है, अतः 6-12 महीने पूर्व आधिकारिक बुकिंग करें।',
        );
        response.writeln(
          '• **होमस्टे योजना:** उज्जैन नगर निगम द्वारा सत्यापित परिवारों के साथ रुकने की सुविधा।\n',
        );
        response.writeln(
          '🍲 **अन्नक्षेत्र (Free Food):** संपूर्ण मेला क्षेत्र में २४ घंटे निःशुल्क सात्विक भंडारे व महाप्रसाद उपलब्ध रहता है।',
        );
      } else if (wantsEvents) {
        response.writeln(
          '🎭 **सिंहस्थ कुंभ 2028 के प्रमुख आकर्षण व कार्यक्रम:**\n',
        );
        response.writeln(
          '👑 **शाही पेशवाई:** अखाड़ों के महामंडलेश्वरों और नागा साधुओं के भव्य चल समारोह (हाथी, घोड़े, ढोल-नगाड़े)',
        );
        response.writeln(
          '🚩 **अखाड़ा छावनी दर्शन:** नागा साधुओं की धुनी, साधना व आशीर्वाद प्राप्ति',
        );
        response.writeln(
          '🎪 **धार्मिक व सांस्कृतिक सभाएं:** देश के शीर्ष संतों के प्रवचन, रासलीला, संत समागम, महायज्ञ',
        );
        response.writeln(
          '🌊 **दैनिक शिप्रा महाआरती:** राम घाट पर प्रतिदिन १०,०००+ दीपों से भव्य महाआरती\n',
        );
        response.writeln(
          '✨ यह जीवन में एक बार मिलने वाला अद्वितीय आध्यात्मिक अनुभव है!',
        );
      } else {
        response.writeln('🚩 **सिंहस्थ कुंभ महापर्व 2028 — समग्र परिचय:**\n');
        response.writeln(
          '📅 **आयोजन:** अप्रैल - मई 2028 (प्रत्येक 12 वर्ष में एक बार)',
        );
        response.writeln(
          '👥 **अनुमानित श्रद्धालु:** 1.5 से 2 करोड़ देश-विदेश के तीर्थयात्री',
        );
        response.writeln(
          '🏺 **पावन स्थल:** अवंतिका नगरी, पुण्यसलिला माँ शिप्रा नदी के तट',
        );
        response.writeln(
          '🌟 **धार्मिक महात्म्य:** समुद्र मंथन के अमृत कलश से गिरी पावन बूंदों की तपोभूमि\n',
        );
        response.writeln('🕉️ "हर हर महादेव! जय श्री महाकाल!"');
      }
      return response.toString();
    }

    bool wantsMythology = _containsAny(message, [
      'mythology',
      'story',
      'katha',
      'amrit',
      'samudra manthan',
      'nectar',
      'why celebrate',
      'legend',
    ]);
    bool wantsAstrology = _containsAny(message, [
      'astrology',
      'astrological',
      'zodiac',
      'leo',
      'jupiter',
      'guru',
      'simha rashi',
      'planet',
      'celestial',
      'why called simhastha',
    ]);
    bool wantsAkharas = _containsAny(message, [
      'akhara',
      'akharas',
      'naga',
      'peshwai',
      'saints',
      'sadhu',
      'procession',
    ]);
    bool wantsDates = _containsAny(message, [
      'when',
      'date',
      'kab',
      'time',
      '2028',
      'next',
      'schedule',
    ]);
    bool wantsBathing = _containsAny(message, [
      'bath',
      'bathing',
      'snan',
      'ghat',
      'river',
      'holy dip',
    ]);
    bool wantsAccommodation = _containsAny(message, [
      'stay',
      'hotel',
      'accommodation',
      'crowd',
      'booking',
      'tent',
      'tent city',
    ]);
    bool wantsEvents = _containsAny(message, [
      'event',
      'program',
      'procession',
      'festival',
    ]);
    bool wantsPreparation = _containsAny(message, [
      'prepare',
      'plan',
      'tips',
      'advice',
      'first time',
    ]);

    final StringBuffer response = StringBuffer();

    if (wantsMythology) {
      response.writeln(
        '🏺 **The Sacred Legend of Simhastha Kumbh (Samudra Manthan & Amrit):**\n',
      );
      response.writeln('🌊 **The Cosmic Churning (Samudra Manthan):**');
      response.writeln(
        'According to ancient scriptures, gods (Devas) and demons (Asuras) churned the cosmic ocean of milk to obtain the divine nectar of immortality (Amrita). When Lord Dhanvantari emerged holding the Amrit Kalash, a 12-day divine pursuit ensued across the heavens.\n',
      );
      response.writeln('🕊️ **4 Drops of Divine Nectar on Earth:**');
      response.writeln(
        'As Lord Indra\'s son Jayanta carried the sacred urn away from the Asuras, drops of celestial nectar fell upon four sacred places on Earth (1 divine day = 1 earthly year):\n',
      );
      response.writeln(
        '  1. 🏺 **Ujjain (Avantika):** On the banks of holy Shipra River',
      );
      response.writeln(
        '  2. 🌊 **Haridwar:** On the banks of River Ganga (Har Ki Pauri)',
      );
      response.writeln(
        '  3. 🔱 **Prayagraj:** At the holy Triveni Sangam (Ganga, Yamuna, Saraswati)',
      );
      response.writeln(
        '  4. 🌿 **Nashik (Trimbak):** On the banks of River Godavari\n',
      );
      response.writeln(
        '✨ Taking a holy dip during Simhastha in the sanctified waters of Shipra cleanses lifetimes of negative karma and grants spiritual liberation (Moksha)!',
      );
    } else if (wantsAstrology) {
      response.writeln(
        '🌟 **Astrological Significance of Simhastha Kumbh:**\n',
      );
      response.writeln('🪐 **Why is it called "Simhastha"?**');
      response.writeln(
        'The name "Simhastha" derives from the Sanskrit word "Simha" (Leo). It occurs when **Jupiter (Brihaspati / Guru)** enters the zodiac constellation of **Leo (Simha Rashi)** and the **Sun (Surya)** enters **Aries (Mesha Rashi)** on Vaishakh Purnima (full moon).\n',
      );
      response.writeln('⏳ **12-Year Cycle:**');
      response.writeln(
        'It takes planet Jupiter approximately 12 Earth years to complete one orbit around the Sun. When this precise astronomical alignment occurs, cosmic rays infuse the waters of Shipra River with divine nectar energy.',
      );
    } else if (wantsAkharas) {
      response.writeln(
        '🚩 **The 13 Sacred Akharas & Naga Saints of Simhastha:**\n',
      );
      response.writeln('👑 **Traditional Akharas of Sanatana Dharma:**');
      response.writeln('• **7 Shaiva (Sanyasi) Akharas:**');
      response.writeln(
        '  1. Shri Panchdashnam Juna Akhara (Largest order of Naga Babas)',
      );
      response.writeln('  2. Shri Niranjani Akhara (Renowned scholarly order)');
      response.writeln(
        '  3. Shri Mahanirvani Akhara (Historic protectors of Mahakaleshwar)',
      );
      response.writeln(
        '  4. Shri Atal Akhara | 5. Shri Avahan Akhara | 6. Shri Anand Akhara | 7. Shri Agni Akhara\n',
      );
      response.writeln('• **3 Vaishnava (Bairagi) Akharas:**');
      response.writeln(
        '  8. Digambar Ani Akhara | 9. Nirvani Ani Akhara | 10. Nirmohi Ani Akhara\n',
      );
      response.writeln('• **3 Udasi & Nirmal Akharas:**');
      response.writeln(
        '  11. Bada Udasi Akhara | 12. Naya Udasi Akhara | 13. Nirmal Akhara (associated with Sikh tradition)\n',
      );
      response.writeln(
        '🐘 **Shahi Peshwai:** The grand royal procession of Naga saints and Mahamandaleshwars mounted on decorated elephants, horses, and chariots entering Ujjain is the festival\'s most spectacular visual marvel!',
      );
    } else if (wantsDates) {
      response.writeln(
        '📅 **Simhastha Kumbh Mela 2028 - Important Dates & Royal Baths:**\n',
      );
      response.writeln('🗓️ **Event Dates:** April - May 2028');
      response.writeln(
        '🌟 **Celestial Sign:** Jupiter in Leo (Simha) and Sun in Aries (Mesha)',
      );
      response.writeln('⏳ **Duration:** Approximately 1 full month\n');
      response.writeln('🏺 **Auspicious Shahi Snan (Royal Bathing Days):**');
      response.writeln(
        '• **1st Shahi Snan (Chaitra Purnima):** Grand opening of the festival',
      );
      response.writeln('• **Mesha Sankranti Snan:** Solar ingress into Aries');
      response.writeln(
        '• **Varuthini Ekadashi Snan:** Highly auspicious ascetic bath',
      );
      response.writeln(
        '• **Vaishakh Krishna Amavasya Snan:** 2nd major Shahi Snan',
      );
      response.writeln(
        '• **Mohini Ekadashi Snan:** Sacred nectar distribution day',
      );
      response.writeln(
        '• **Vaishakh Shukla Purnima (Maha Shahi Snan):** The pinnacle and largest royal bathing day of Simhastha 2028!\n',
      );
      response.writeln(
        '🔔 **Planning Advice:** Book travel and stay at least 1-2 years ahead of time.',
      );
    } else if (wantsBathing) {
      response.writeln(
        '🏺 **Sacred Bathing at Simhastha 2028 — Ghats & Rituals:**\n',
      );
      response.writeln('🌊 **Main Bathing Ghats on Shipra River:**');
      response.writeln(
        '• **Ram Ghat:** Primary sacred bathing ghat close to Mahakaleshwar; evening 7 PM Maha Aarti',
      );
      response.writeln(
        '• **Dutt Akhara Ghat:** Located directly across Ram Ghat, hub for saints and Akharas',
      );
      response.writeln(
        '• **Narsingha Ghat:** Scenic, quieter ghat ideal for family holy dips',
      );
      response.writeln(
        '• **Siddhwat Ghat:** Ancestral tarpan and Pind Daan shrine on the riverbanks',
      );
      response.writeln(
        '• **Triveni Ghat:** Sacred confluence of Shipra, Khan, and Saraswati\n',
      );
      response.writeln(
        '⏰ **Best Bathing Hours:** Brahma Muhurat (4:00 AM - 6:00 AM)',
      );
      response.writeln(
        '🙏 **Ritual:** Take three dips facing east, chant "Har Har Mahadev", and offer water to the rising sun.',
      );
    } else if (wantsAccommodation) {
      response.writeln('🏨 **Accommodation During Simhastha 2028:**\n');
      response.writeln('🏕️ **Options Available:**');
      response.writeln(
        '• **Government Tent Cities:** Thousands of serviced Swiss cottages and dormitories setup at Sadawal and Pingleshwar.',
      );
      response.writeln(
        '• **Ashrams & Dharamshalas:** Spiritual, budget-friendly pilgrimage stays.',
      );
      response.writeln(
        '• **Hotels & Resorts:** Book 1 year in advance as rates rise 3-5x.',
      );
      response.writeln(
        '• **Homestays:** Verified local citizen homestays regulated by the municipal corporation.\n',
      );
      response.writeln(
        '🍲 **Annakshetras (Free Food):** Over 100+ charitable kitchens operate 24x7 across the mela area serving free satvik meals.',
      );
    } else if (wantsEvents) {
      response.writeln(
        '🎭 **Major Events & Attractions at Simhastha 2028:**\n',
      );
      response.writeln(
        '👑 **Shahi Peshwai:** Grand ceremonial processions of Akharas with decorated elephants and warrior saints',
      );
      response.writeln(
        '🚩 **Sadhu Camps & Akhara Visits:** Seeking blessings at ancient campfires (dhuni)',
      );
      response.writeln(
        '🎪 **Spiritual Discourses:** Discourses by Shankaracharyas, Mahamandaleshwars, and scholars',
      );
      response.writeln(
        '🌊 **Grand Shipra Maha Aarti:** 10,000+ lamps floating on Ram Ghat every evening\n',
      );
      response.writeln(
        '✨ A transformative once-in-a-lifetime spiritual experience!',
      );
    } else if (wantsPreparation) {
      response.writeln(
        '📋 **Pilgrim Preparation Checklist for Simhastha 2028:**\n',
      );
      response.writeln(
        '🎒 **Packing:** Lightweight cotton clothing, durable walking sandals, water bottle, power bank, basic first-aid.',
      );
      response.writeln(
        '📱 **Digital:** Offline maps of Ujjain, saved emergency helpline numbers (100, 108, 0734-2550010).',
      );
      response.writeln(
        '🏥 **Health:** Stay hydrated, eat only from clean Annakshetras, avoid peak afternoon sun.',
      );
      response.writeln(
        '👨‍👩‍👧‍👦 **Family:** Agree on landmark meeting points (e.g. Nandi Dwar or Ram Ghat clock tower) in case of separation.',
      );
    } else {
      response.writeln('🚩 **Simhastha Kumbh Mela 2028 — Sacred Overview:**\n');
      response.writeln('📅 **Next Event:** April - May 2028 (Every 12 years)');
      response.writeln(
        '👥 **Pilgrims:** 15-20 million devotees from across the globe',
      );
      response.writeln('🏺 **Holy River:** Holy Mother Shipra (Kshipra)');
      response.writeln(
        '🌟 **Spiritual Grace:** Sacred nectar bath in the city of Baba Mahakal\n',
      );
      response.writeln('🕉️ "Har Har Mahadev! Jai Shree Mahakal!"');
    }

    response.writeln(
      '\n🕉️ Har Har Mahadev! May your pilgrimage to Simhastha 2028 be divinely blessed!',
    );
    return response.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART ENGINE — Ujjain Comprehensive Knowledge, Heritage & History
  // ═══════════════════════════════════════════════════════════════════════════
  String? _tryAnswerUjjainQuery(String message, bool isHindi) {
    // 1. Shri Mahakal Mahalok Corridor
    if (_containsAny(message, [
      'mahakal lok',
      'mahakal corridor',
      'mahalok',
      'mahakal mahalok',
      'महाकाल लोक',
      'महाकाल कॉरिडोर',
      'महाकाल महालोक',
      'महालोक',
    ])) {
      if (isHindi) {
        return '🏛️ **श्री महाकाल महालोक कॉरिडोर — सम्पूर्ण दर्शन मार्गदर्शिका:**\n\n'
            '✨ **परिचय एवं भव्यता:**\n'
            'महाकालेश्वर ज्योतिर्लिंग परिसर से सटा लगभग ९०० मीटर से अधिक लंबा "श्री महाकाल महालोक" भारत के सबसे भव्य धार्मिक कॉरिडोरों में से एक है (अक्टूबर २०२२ में लोकार्पण)।\n\n'
            '🌟 **प्रमुख आकर्षण एवं दर्शनीय स्थल:**\n'
            '• **१०८ नक्काशीदार शिव तांडव स्तंभ:** जिन पर भगवान शिव के विभिन्न तांडव रूपों का सजीव चित्रण है।\n'
            '• **रूद्र सागर सरोवर तट:** पवित्र सरोवर का भव्य पुनरुद्धार, संगीतमय फव्वारे व लेकफ्रंट वॉकवे।\n'
            '• **कमल कुंड एवं शिव कथा शिल्प:** त्रिपुरासुर वध, शिव-पार्वती विवाह, अर्धनारीश्वर, गणेश-कार्तिकेय लीलाएं एवं सप्तऋषि मंडल की विशाल प्रतिमाएं।\n'
            '• **नंदी द्वार व पिनाकी द्वार:** भव्य नक्काशीदार प्रवेश द्वार।\n\n'
            '⏰ **समय:** प्रातः 6:00 AM से रात्रि 11:00 PM तक खुला रहता है।\n'
            '💡 **विशेष समय:** संध्या 6:30 PM के बाद भव्य विद्युत सज्जा (Lighting) में महालोक का दृश्य अलौकिक व अविस्मरणीय होता है!\n'
            '🎟️ **प्रवेश शुल्क:** महाकाल लोक में प्रवेश पूर्णतः **निःशुल्क (FREE)** है।\n'
            '🛺 **सुविधाएं:** वरिष्ठ नागरिकों व दिव्यांगों हेतु ई-कार्ट/गोल्फ कार्ट, विश्राम स्थल व शुद्ध पेयजल।';
      }
      return '🏛️ **Shri Mahakal Mahalok Corridor — Complete Guide:**\n\n'
          '✨ **Overview:**\n'
          'Spanning over 900 meters adjacent to Mahakaleshwar Temple, Shri Mahakal Mahalok is one of India\'s largest and most magnificent spiritual corridors (inaugurated in Oct 2022).\n\n'
          '🌟 **Key Highlights & Attractions:**\n'
          '• **108 Carved Shiva Tandav Pillars:** Depicting Lord Shiva\'s cosmic dance poses and divine expressions.\n'
          '• **Revitalized Rudra Sagar Lake:** Beautiful lakefront promenade, murals, and musical fountains.\n'
          '• **Kamal Kund & Sculptures:** Grand murals depicting Tripurasura Vadh, Shiva-Parvati wedding, Ardhanarishwara, and Saptarishis.\n'
          '• **Nandi Dwar & Pinaki Dwar:** Majestic ceremonial entrance gates.\n\n'
          '⏰ **Timings:** 6:00 AM to 11:00 PM daily.\n'
          '💡 **Best Time to Visit:** After 6:30 PM in the evening when divine architectural illumination transforms the entire corridor into an enchanting spiritual wonderland!\n'
          '🎟️ **Entry Fee:** Admission is completely **FREE** for all devotees.\n'
          '🛺 **Facilities:** Golf cart shuttle for seniors/differently-abled, clean drinking water stations, shoe stands, and resting zones.';
    }

    // 2. Places to visit in Ujjain / Sightseeing Itinerary
    if (_containsAny(message, [
      'places to visit',
      'sightseeing',
      'what to see in ujjain',
      'tourist spots',
      'visit in ujjain',
      'attractions in ujjain',
      'itinerary',
      'ghoomne ki jagah',
      'kya dekhe',
      'kya kya dekhe',
      'darshan list',
      'घूमने की जगह',
      'दर्शनीय स्थल',
      'पर्यटन स्थल',
      'क्या क्या देखें',
      'दर्शन सूची',
      'उज्जैन में क्या घूमें',
      'उज्जैन दर्शन',
    ])) {
      if (isHindi) {
        return '🗺️ **उज्जैन के प्रमुख दर्शनीय स्थल — १ व २ दिवसीय दर्शन योजना (Itinerary):**\n\n'
            '🚩 **प्रथम दिवस (मुख्य तीर्थ दर्शन):**\n'
            '1. 🕉️ **श्री महाकालेश्वर ज्योतिर्लिंग व महाकाल महालोक:** प्रातः भस्म आरती अथवा सामान्य दर्शन व भव्य महालोक भ्रमण।\n'
            '2. 🌺 **माँ हरसिद्धि शक्तिपीठ:** ५१ शक्तिपीठों में से एक (संध्या समय दीपस्तंभ प्रज्ज्वलन अवश्य देखें)।\n'
            '3. 🔱 **श्री काल भैरव मंदिर:** उज्जैन के सेनापति व कोतवाल (महाकाल दर्शन के पश्चात अनिवार्य)।\n'
            '4. 🏺 **राम घाट (शिप्रा नदी):** पवित्र स्नान व सायं 7:00 PM की भव्य शिप्रा महाआरती।\n\n'
            '🚩 **द्वितीय दिवस (पौराणिक व सांस्कृतिक स्थल):**\n'
            '5. 🐘 **श्री चिंतामन गणेश मंदिर:** स्वयंभू विघ्नहर्ता एवं चिंता निवारक।\n'
            '6. 🔴 **श्री मंगलनाथ मंदिर:** मंगल ग्रह की जन्मस्थली एवं भात पूजा तीर्थ।\n'
            '7. 📚 **महर्षि सांदीपनि आश्रम:** भगवान श्री कृष्ण, बलराम व सुदामा की प्राचीन विद्यास्थली।\n'
            '8. 🙏 **माँ गढ़कालिका मंदिर:** महाकवि कालिदास की आराध्या माँ कालिका।\n'
            '9. ⛰️ **राजा भर्तृहरि गुफाएं व सिद्धवट:** अमर वटवृक्ष व वैराग्य शतक की तपोभूमि।\n'
            '10. 🔭 **वेधशाला (जंतर मंतर):** सवाई जयसिंह द्वारा १७१९ में निर्मित प्राचीन खगोल वेधशाला।\n'
            '11. 🛕 **इस्कॉन मंदिर:** सफेद संगमरमर से निर्मित शांत कृष्ण-बलराम मंदिर।';
      }
      return '🗺️ **Top Places to Visit in Ujjain — Complete 1-2 Day Itinerary:**\n\n'
          '🚩 **Day 1: Core Sacred Shrines:**\n'
          '1. 🕉️ **Mahakaleshwar Jyotirlinga & Mahakal Lok:** Early morning Bhasma Aarti / Darshan, followed by walking through the 900m grand corridor.\n'
          '2. 🌺 **Harsiddhi Mata Shaktipeeth:** One of 51 Shaktipeeths (witness the iconic 7 PM evening deepstambh lamp lighting).\n'
          '3. 🔱 **Kal Bhairav Temple:** The city protector and Kotwal of Ujjain (pilgrimage is considered incomplete without this darshan).\n'
          '4. 🏺 **Ram Ghat (Shipra River):** Holy dip and evening Shipra Maha Aarti at 7:00 PM with floating lamps.\n\n'
          '🚩 **Day 2: Historical & Sacred Heritage:**\n'
          '5. 🐘 **Chintaman Ganesh Temple:** Ancient self-manifested Ganesha shrine removing all anxieties.\n'
          '6. 🔴 **Mangalnath Temple:** Puranic birthplace of Mars (Mangal Graha) on a scenic hilltop.\n'
          '7. 📚 **Sandipani Ashram:** Ancient gurukul where Lord Krishna learned 64 arts.\n'
          '8. 🙏 **Gadkalika Temple:** Goddess worshipped by legendary Sanskrit poet Kalidasa.\n'
          '9. ⛰️ **Bhartrihari Caves & Siddhwat:** Ancient meditation caves and the sacred immortal Banyan tree on Shipra.\n'
          '10. 🔭 **Vedhshala (Jantar Mantar):** Historical 1719 astronomical observatory on the Prime Meridian of India.\n'
          '11. 🛕 **ISKCON Ujjain:** Beautiful white marble Krishna temple with divine gardens.';
    }

    // 3. Ujjain History, Ancient Names & King Vikramaditya
    if (_containsAny(message, [
      'history of ujjain',
      'ujjain history',
      'vikramaditya',
      'king vikramaditya',
      'kalidasa',
      'navratna',
      'about ujjain',
      'ujjain ke bare me',
      'ujjain ke baare mein',
      'what is ujjain',
      'tell me about ujjain',
      'why is ujjain famous',
      'why is ujjain sacred',
      'avantika',
      'ujjayini',
      'उज्जैन का इतिहास',
      'उज्जैन के बारे में',
      'उज्जैन क्या है',
      'उज्जैन का परिचय',
      'उज्जैन क्यों प्रसिद्ध',
      'अवंतिका',
      'उज्जयिनी',
      'विक्रमादित्य',
      'राजा विक्रमादित्य',
      'नवरत्न',
      'कालिदास',
      'इतिहास',
    ])) {
      if (isHindi) {
        return '🏛️ **उज्जैन (अवंतिका नगरी) का गौरवशाली इतिहास एवं परिचय:**\n\n'
            '✨ **मोक्षदायिनी सप्तपुरियों में प्रधान:**\n'
            'उज्जैन भारत की सात पवित्र मोक्षदायिनी नगरियों (अयोध्या, मथुरा, माया, काशी, कांची, अवंतिका, पुरी) में से एक है। इसे अवंतिका, उज्जयिनी, कनकपूर्णा, कुशस्थली, पद्मावती और अमरावती जैसे पौराणिक नामों से भी जाना जाता है।\n\n'
            '👑 **महाराजा विक्रमादित्य एवं नवरत्न:**\n'
            'उज्जैन न्यायप्रिय सम्राट विक्रमादित्य की राजधानी रही, जिन्होंने ५७ ई.पू. में विदेशी आक्रमणकारियों को परास्त कर भारतीय "विक्रम संवत" कैलेंडर का शुभारंभ किया। उनके दरबार में महाकवि कालिदास, वराहमिहिर, धनवंतरि, अमरसिंह जैसे ९ विश्वप्रसिद्ध नवरत्न सुशोभित थे।\n\n'
            '🔭 **प्राचीन भारत का ग्रीनविच (खगोलीय नाभि केंद्र):**\n'
            'कर्क रेखा (Tropic of Cancer) उज्जैन से होकर गुजरती है। सूर्य सिद्धांत के अनुसार उज्जैन को पृथ्वी का केंद्र व शून्य देशांतर (Zero Longitude / Prime Meridian) माना गया है, जहाँ से भारतीय समय व पंचांग की गणना होती थी।\n\n'
            '🕉️ **धार्मिक महात्म्य:**\n'
            '• १२ ज्योतिर्लिंगों में एकमात्र **दक्षिणमुखी ज्योतिर्लिंग श्री महाकालेश्वर** जो काल के भी स्वामी हैं।\n'
            '• ५१ शक्तिपीठों में से एक **माँ हरसिद्धि शक्तिपीठ** (जहाँ सती की कोहनी गिरी थी)।\n'
            '• भगवान श्री कृष्ण की शिक्षा स्थली — **महर्षि सांदीपनि आश्रम**।\n'
            '• मोक्षदायिनी **माँ शिप्रा** के तट पर प्रत्येक १२ वर्ष में लगने वाला **सिंहस्थ महाकुंभ**।';
      }
      return '🏛️ **Sacred History & Overview of Ujjain (Avantika):**\n\n'
          '✨ **One of the 7 Moksha-Giving Sapta Puris:**\n'
          'Ujjain is one of Hinduism\'s seven sacred liberation cities (Ayodhya, Mathura, Maya, Kashi, Kanchi, Avantika, Puri). Historically known by seven names: Avantika, Ujjayini, Kanakashringa, Kushasthali, Padmavati, Pratikalpa, and Amaravati.\n\n'
          '👑 **Empire of King Vikramaditya & Navaratnas:**\n'
          'Ujjain was the imperial capital of legendary King Vikramaditya, founder of the Vikrama Samvat calendar in 57 BCE. His court hosted the legendary Nine Jewels (Navaratnas), including Mahakavi Kalidasa (author of Meghaduta), astronomer Varahamihira, and Ayurveda master Dhanvantari.\n\n'
          '🔭 **The Greenwich of Ancient India (Zero Longitude):**\n'
          'Ujjain is geographically located on the Tropic of Cancer. In ancient Hindu astronomical texts (Surya Siddhanta), Ujjain is recognized as the Earth\'s navel and the Prime Meridian of astronomical longitude.\n\n'
          '🕉️ **Spiritual Eminence:**\n'
          '• Home to **Mahakaleshwar**, the only south-facing (Dakshinmukhi) Jyotirlinga, master of time and eternity.\n'
          '• **Harsiddhi Mata Shaktipeeth**, where Goddess Sati\'s elbow fell.\n'
          '• **Sandipani Ashram**, where Lord Krishna, Balarama, and Sudama studied 64 arts.\n'
          '• The divine **Simhastha Kumbh Mela** held on the banks of Shipra every 12 years.';
    }

    // 4. Maa Shipra River & Ghats
    if (_containsAny(message, [
      'shipra river',
      'kshipra',
      'about shipra',
      'shipra katha',
      'ram ghat',
      'ghats of ujjain',
      'शिप्रा नदी',
      'क्षिप्रा',
      'शिप्रा की कथा',
      'शिप्रा का महत्व',
      'राम घाट',
      'घाट',
    ])) {
      if (isHindi) {
        return '🌊 **पुण्यसलिला मोक्षदायिनी माँ शिप्रा नदी एवं प्रमुख घाट:**\n\n'
            '✨ **पौराणिक प्राकट्य कथा:**\n'
            'स्कंद पुराण के अनुसार शिप्रा नदी का उद्गम भगवान विष्णु के वैकुंठ धाम से हुआ है, इसलिए इसे "अमृत संभवा" (अमृत से उत्पन्न) भी कहा जाता है। मान्यता है कि शिप्रा के पावन जल में मात्र एक बार स्नान करने से मनुष्य के जन्म-जन्मांतर के पाप धुल जाते हैं।\n\n'
            '🏺 **उज्जैन के प्रमुख पावन घाट:**\n'
            '1. **राम घाट (Ram Ghat):** सबसे प्राचीन व प्रसिद्ध घाट। यहाँ भगवान श्री राम ने पिता दशरथ का तर्पण किया था। यह सिंहस्थ का मुख्य शाही स्नान स्थल व प्रतिदिन सायं 7:00 PM की दिव्य शिप्रा महाआरती का केंद्र है।\n'
            '2. **दत्त अखाड़ा घाट:** राम घाट के ठीक सामने स्थित, नागा साधु-संतों का प्रमुख स्नान स्थल।\n'
            '3. **सिद्धवट घाट:** अक्षय वट समान अमर वटवृक्ष, जहाँ पिंडदान, पितृ मोक्ष व कालसर्प दोष शांति की पूजा होती है।\n'
            '4. **नृसिंह घाट:** शांत, हरित व सुरम्य वातावरण, प्रातःकालीन ध्यान हेतु सर्वोत्तम।\n'
            '5. **त्रिवेणी घाट:** शिप्रा, खान व गुप्त सरस्वती का पावन संगम तट।\n\n'
            '🔔 **शिप्रा महाआरती:** प्रतिदिन सायं 7:00 बजे राम घाट पर १००८ दीपों से भव्य शिप्रा आरती संपन्न होती है। सहस्रों दीपों की जगमगाहट व शंखनाद का दृश्य अलौकिक होता है!';
      }
      return '🌊 **Sacred Shipra (Kshipra) River & Ghats of Ujjain:**\n\n'
          '✨ **Sacred Origin & Legend:**\n'
          'According to the Skanda Purana, the Shipra River emerged directly from the sacred abode of Lord Vishnu (Vaikuntha) and is revered as "Amrita Sambhava" (born of nectar). A single holy dip in Shipra during auspicious hours is believed to grant liberation (Moksha).\n\n'
          '🏺 **Famous Ghats along Shipra:**\n'
          '1. **Ram Ghat:** The oldest and most revered ghat where Lord Rama performed tarpan for King Dasharatha. Primary site for Simhastha Shahi Snan and daily grand Shipra Maha Aarti at 7:00 PM.\n'
          '2. **Dutt Akhara Ghat:** Located directly opposite Ram Ghat; hub for Naga saints and Akhara camps.\n'
          '3. **Siddhwat Ghat:** Home to the immortal Banyan tree; primary site for Pind Daan, ancestral tarpan, and Kal Sarp Puja.\n'
          '4. **Narsingha Ghat:** Peaceful, verdant ghat ideal for sunrise meditation and contemplation.\n'
          '5. **Triveni Ghat:** Holy confluence of Shipra, Khan, and the subterranean Saraswati River.\n\n'
          '🔔 **Shipra Maha Aarti:** Every evening at 7:00 PM at Ram Ghat, priests conduct a magnificent 1008-lamp aarti accompanied by temple bells, conch shells, and floating flower diyas on the river!';
    }

    // 5. Panchkroshi Yatra & 84 Mahadev
    if (_containsAny(message, [
      'panchkroshi',
      'panchkoshi',
      '84 mahadev',
      'chaurasi mahadev',
      'ashta bhairav',
      'पंचक्रोशी',
      'पंचक्रोशी यात्रा',
      'चौरासी महादेव',
      '84 महादेव',
      'अष्ट भैरव',
    ])) {
      if (isHindi) {
        return '🚶‍♂️ **उज्जैन की पवित्र पंचक्रोशी यात्रा एवं चौरासी महादेव:**\n\n'
            '✨ **पंचक्रोशी यात्रा क्या है?**\n'
            'यह उज्जैन नगरी की ११६-११८ किलोमीटर लंबी प्राचीन परिक्रमा है, जो प्रतिवर्ष वैशाख कृष्ण दशमी से अमावस्या तक संपन्न होती है। लाखों श्रद्धालु नंगे पैर इस परिक्रमा को पूर्ण करते हैं।\n\n'
            '🚩 **यात्रा के ४ प्रमुख पड़ाव (दिशा रक्षक महादेव):**\n'
            '1. 🌅 **प्रथम पड़ाव — पिंगलेश्वर महादेव:** उज्जैन के पूर्व दिशा में स्थित प्रथम विश्राम स्थल।\n'
            '2. ☀️ **द्वितीय पड़ाव — कायावरोहणेश्वर महादेव:** दक्षिण दिशा में स्थित पावन तीर्थ।\n'
            '3. 🌄 **तृतीय पड़ाव — बिल्वेश्वर महादेव:** पश्चिम दिशा में स्थित तीसरा विश्राम पड़ाव।\n'
            '4. 🌙 **चतुर्थ पड़ाव — दुर्धरेश्वर महादेव:** उत्तर दिशा में स्थित अंतिम पड़ाव।\n\n'
            '🙏 **यात्रा समापन:** पंचक्रोशी पूर्ण होने पर श्रद्धालु महाकालेश्वर मंदिर आकर भगवान को \'उबटन\' और जल अर्पित कर आशीर्वाद लेते हैं।\n\n'
            '🔱 **चौरासी (84) महादेव:** स्कंद पुराण के अनुसार उज्जैन में चौरासी प्रमुख शिवलिंग स्थापित हैं, जिनके दर्शन से चौरासी लाख योनियों के आवागमन से मुक्ति मिलती है।';
      }
      return '🚶‍♂️ **The Sacred Panchkroshi Yatra & 84 Mahadev of Ujjain:**\n\n'
          '✨ **What is Panchkroshi Yatra?**\n'
          'A traditional 116-118 km circumambulation (parikrama) around the outer perimeter of sacred Ujjain, undertaken annually during the Hindu month of Vaishakh. Lakhs of devotees complete this sacred pilgrimage on foot.\n\n'
          '🚩 **The 4 Cardinal Rest Stops (Padavs):**\n'
          '1. 🌅 **1st Stop — Pingleshwar Mahadev:** East guardian deity.\n'
          '2. ☀️ **2nd Stop — Kayavarohaneshwar Mahadev:** South guardian deity.\n'
          '3. 🌄 **3rd Stop — Bilveshwar Mahadev:** West guardian deity.\n'
          '4. 🌙 **4th Stop — Durdhareshwar Mahadev:** North guardian deity.\n\n'
          '🙏 **Completion Ritual:** The parikrama culminates at the sanctum of Mahakaleshwar Temple, where devotees offer ubtan (cooling paste) and holy water to the Jyotirlinga.\n\n'
          '🔱 **84 Mahadev:** Mentioned in the Skanda Purana, 84 unique Shiva shrines are consecrated across Ujjain, believed to free the soul from the 8.4 million cycles of rebirth.';
    }

    // 6. How to Reach Ujjain & Transport Guide
    if (_containsAny(message, [
      'how to reach',
      'nearest airport',
      'airport near ujjain',
      'reach ujjain',
      'railway station ujjain',
      'bus from indore',
      'travel to ujjain',
      'उज्जैन कैसे पहुंचे',
      'हवाई अड्डा',
      'निकटतम एयरपोर्ट',
      'उज्जैन कैसे आएं',
      'ट्रेन से कैसे आएं',
      'बस सेवा',
    ])) {
      if (isHindi) {
        return '🚆 **उज्जैन यात्रा मार्गदर्शिका — कैसे पहुंचे (How to Reach):**\n\n'
            '✈️ **हवाई मार्ग (Air):**\n'
            '• **निकटतम हवाई अड्डा:** देवी अहिल्याबाई होलकर अंतरराष्ट्रीय हवाई अड्डा, **इंदौर (IDR)** — उज्जैन से मात्र ५५ किमी दूर।\n'
            '• इंदौर एयरपोर्ट दिल्ली, मुंबई, बैंगलोर, हैदराबाद आदि से सीधे जुड़ा है। एयरपोर्ट से उज्जैन हेतु टैक्सी (₹1200-₹1500) या बस से ४-लेन सुपर हाईवे द्वारा मात्र १ घंटे में पहुंचा जा सकता है।\n\n'
            '🚆 **रेल मार्ग (Train):**\n'
            '• **उज्जैन जंक्शन (UJN):** पश्चिम रेलवे का प्रमुख जंक्शन है। दिल्ली, मुंबई, जयपुर, भोपाल, वाराणसी, कोलकाता, चेन्नई आदि से वन्दे भारत, राजधानी, सुपरफास्ट व एक्सप्रेस ट्रेनें सीधे आती हैं।\n\n'
            '🚌 **सड़क मार्ग (Road):**\n'
            '• **इंदौर से उज्जैन:** सरवटे/गंगवाल बस स्टैंड से हर १० मिनट में नॉन-स्टॉप एसी/सामान्य बसें (देवास गेट बस स्टैंड पहुंचती हैं)।\n'
            '• **भोपाल से उज्जैन:** १८५ किमी (लगभग ३.५ घंटे)।\n'
            '• **ओंकारेश्वर से उज्जैन:** १३५ किमी (लगभग ३.५ घंटे)।\n\n'
            '🛺 **स्थानीय परिवहन:** ई-रिक्शा, ऑटो, नगर बसें व रेंटल बाइक/स्कूटी महाकाल मंदिर व रेलवे स्टेशन पर २४ घंटे उपलब्ध रहती हैं।';
      }
      return '🚆 **Complete Travel Guide — How to Reach Ujjain:**\n\n'
          '✈️ **By Air:**\n'
          '• **Nearest Airport:** Devi Ahilyabai Holkar International Airport, **Indore (IDR)** — 55 km from Ujjain.\n'
          '• Connected with direct flights to Delhi, Mumbai, Bengaluru, Hyderabad, etc. Taxis (₹1200-₹1500) and express buses take only ~1 hour via the 4-lane expressway.\n\n'
          '🚆 **By Train:**\n'
          '• **Ujjain Junction (UJN):** Major railway hub on Western Railway with direct Vande Bharat, Rajdhani, Superfast, and Mail trains from Delhi, Mumbai, Kolkata, Jaipur, Varanasi, and Ahmedabad.\n\n'
          '🚌 **By Road:**\n'
          '• **From Indore:** Buses run every 10 minutes between Indore and Ujjain (Dewas Gate Bus Stand).\n'
          '• **From Bhopal:** 185 km (~3.5 hours via state highway).\n'
          '• **From Omkareshwar:** 135 km (~3.5 hours).\n\n'
          '🛺 **Local Transit in Ujjain:** E-rickshaws, shared autos, city buses, and rental scooters are readily available 24/7 across Mahakal complex and railway station.';
    }

    // 7. Famous Food, Sweets & Shopping in Ujjain
    if (_containsAny(message, [
      'famous food of ujjain',
      'ujjain food',
      'dal bafla',
      'batik print',
      'shopping in ujjain',
      'famous market',
      'what to eat in ujjain',
      'उज्जैन का खानपान',
      'उज्जैन का प्रसिद्ध खाना',
      'दाल बाफला',
      'बाटिक प्रिंट',
      'उज्जैन में खरीदारी',
      'प्रसिद्ध बाज़ार',
    ])) {
      if (isHindi) {
        return '🍲 **उज्जैन का प्रसिद्ध खानपान एवं पारंपरिक बाज़ार:**\n\n'
            '🍛 **प्रसिद्ध पारंपरिक व्यंजन:**\n'
            '• **दाल बाफला (Dal Bafla):** मालवा का शाही भोजन — शुद्ध देसी घी में डूबा गर्म बाफला, पंचमेल दाल, कढ़ी, बेसन गट्टे, लहसुन की तीखी चटनी और चूरमा लाडू।\n'
            '• **उज्जैनी पोहा-जलेबी:** जीरावन मसाला व सेव से सजा खट्टा-मीठा पोहा और कुरकुरी रसभरी जलेबी (प्रातःकालीन मुख्य नाश्ता)।\n'
            '• **भुट्टे का कीस (Bhutta Khees):** कसे हुए ताजे भुट्टे, दूध व मसालों से बना अनोखा मालवी स्वाद।\n'
            '• **मालपुआ व रबड़ी:** टॉवर चौक पर मिलने वाली पारंपरिक लच्छेदार रबड़ी व गरम मालपुए।\n'
            '• **महाकाल पेड़ा:** शुद्ध खोवा/मावे से निर्मित बाबा महाकाल का दिव्य प्रसादम।\n\n'
            '🛍️ **खरीदारी के प्रमुख आकर्षण (Shopping):**\n'
            '• **भैरवगढ़ बाटिक प्रिंट (Batik Prints):** उज्जैन का विश्व प्रसिद्ध मोम छपाई (Batik) हस्तशिल्प, चादरें, सूट व साड़ियां।\n'
            '• **पटनी बाज़ार व सराफा:** शुद्ध चांदी के आभूषण, रुद्राक्ष मालाएं, स्फटिक व पारद शिवलिंग।\n'
            '• **गोपाल मंदिर मार्ग:** पारंपरिक पीतल व तांबे के पूजा बर्तन, धूप-अगरबत्ती व धार्मिक साहित्य।';
      }
      return '🍲 **Famous Food, Sweets & Traditional Bazaars of Ujjain:**\n\n'
          '🍛 **Must-Try Local Delicacies:**\n'
          '• **Dal Bafla:** Royal Malwi meal — golden wheat dumplings baked and drenched in pure desi ghee, served with spicy Panchmel dal, kadhi, garlic chutney, and sweet churma laddu.\n'
          '• **Ujjaini Poha-Jalebi:** Light flattened rice with Jeeravan spice, Ratlami sev, and fresh crispy jalebis (the iconic morning breakfast).\n'
          '• **Bhutta Khees:** Grated sweet corn cooked with milk and mild aromatic spices.\n'
          '• **Malpua with Rabdi:** Rich thickened milk rabdi paired with warm malpuas at Tower Chowk.\n'
          '• **Mahakal Peda:** Pure milk mawa peda prasadam available near temple premises.\n\n'
          '🛍️ **Shopping Highlights in Ujjain:**\n'
          '• **Bhairavgarh Batik Prints:** World-renowned ancient wax-resist batik textiles, bedsheets, and sarees crafted on the banks of Shipra.\n'
          '• **Patni Bazaar & Sarafa:** Certified pure silver ornaments, authentic Rudraksha malas, and Parad/Sphatik Shivlingas.\n'
          '• **Gopal Mandir Market:** Traditional brass and copper puja vessels, temple dhoop, and spiritual souvenirs.';
    }

    // 8. Emergency Helplines & Numbers
    if (_containsAny(message, [
      'helpline',
      'emergency number',
      'police ujjain',
      'hospital ujjain',
      'control room',
      'phone numbers',
      'ambulance ujjain',
      'हेल्पलाइन',
      'आपातकालीन नंबर',
      'कंट्रोल रूम',
      'पुलिस',
      'अस्पताल',
    ])) {
      if (isHindi) {
        return '📞 **उज्जैन महत्वपूर्ण हेल्पलाइन व आपातकालीन नंबर:**\n\n'
            '🏛️ **महाकालेश्वर मंदिर कंट्रोल रूम:** 0734-2550010 / 2551295\n'
            '👮 **पुलिस हेल्पलाइन:** 100 / 0734-2525252 / 2528000\n'
            '🚑 **एम्बुलेंस सेवा:** 108 / 102\n'
            '🚒 **अग्निशमन दल (Fire):** 101 / 0734-2551101\n'
            '🏥 **जिला चिकित्सालय (चरक अस्पताल):** 0734-2550201\n'
            '🚆 **रेलवे पूछताछ:** 139\n'
            'ℹ️ **मध्य प्रदेश पर्यटन हेल्पलाइन (Toll-Free):** 1800-233-7777\n'
            '🚖 **उज्जैन स्मार्ट सिटी हेल्पलाइन:** 1800-233-0105\n\n'
            '💡 _यह सभी नंबर २४ घंटे सक्रिय रहते हैं। किसी भी असुविधा की स्थिति में तुरंत संपर्क करें।_';
      }
      return '📞 **Ujjain Emergency Helplines & Important Contacts:**\n\n'
          '🏛️ **Mahakaleshwar Temple Control Room:** 0734-2550010 / 2551295\n'
          '👮 **Police Control Room:** 100 / 0734-2525252 / 2528000\n'
          '🚑 **Ambulance Emergency:** 108 / 102\n'
          '🚒 **Fire Brigade:** 101 / 0734-2551101\n'
          '🏥 **District Hospital (Charak Hospital):** 0734-2550201\n'
          '🚆 **Railway Enquiry:** 139\n'
          'ℹ️ **MP Tourism Toll-Free Helpline:** 1800-233-7777\n'
          '🚖 **Ujjain Smart City Helpline:** 1800-233-0105\n\n'
          '💡 _These emergency services operate 24 hours a day for pilgrims and tourists._';
    }

    // 9. Bhartrihari Caves & Siddhwat
    if (_containsAny(message, [
      'bhartrihari',
      'bhartrahari',
      'siddhwat',
      'भर्तृहरि',
      'भर्तृहरि गुफा',
      'सिद्धवट',
      'पितृ तर्पण',
    ])) {
      if (isHindi) {
        return '⛰️ **राजा भर्तृहरि गुफाएं एवं पावन सिद्धवट तीर्थ:**\n\n'
            '⛰️ **राजा भर्तृहरि गुफाएं (Bhartrihari Caves):**\n'
            '• **ऐतिहासिक महत्व:** सम्राट विक्रमादित्य के बड़े भाई राजा भर्तृहरि ने राजपाट त्यागकर मोक्षदायिनी शिप्रा के तट पर स्थित इन शांत गुफाओं में कठिन तपस्या की थी।\n'
            '• **साहित्यिक धरोहर:** यहीं उन्होंने संस्कृत साहित्य के तीन अमर ग्रंथ — "नीति शतक", "शृंगार शतक" एवं "वैराग्य शतक" की रचना की थी।\n'
            '• **विशेषता:** गुफा का संकरा व रहस्यमय प्रवेश द्वार एवं अखंड धूना जो नाथ संप्रदाय के योगियों द्वारा पूजित है।\n\n'
            '🌳 **सिद्धवट तीर्थ (Siddhwat):**\n'
            '• **अमर वटवृक्ष:** प्रयागराज के \'अक्षयवट\', गया के \'बोधिवट\' और नासिक के \'पंचवट\' समान उज्जैन का \'सिद्धवट\' सनातन धर्म के चार अमर वटवृक्षों में एक है।\n'
            '• **पितृ तर्पण व पिंडदान:** यहाँ अपने पूर्वजों/पितरों के निमित्त पिंडदान, श्राद्ध व तर्पण करने से उन्हें सद्गति प्राप्त होती है।\n'
            '• **कालसर्प दोष शांति:** यहाँ कालसर्प दोष व मातृ-पितृ दोष निवारण हेतु विशेष अभिषेक किया जाता है।';
      }
      return '⛰️ **Bhartrihari Caves & Sacred Siddhwat Tirtha:**\n\n'
          '⛰️ **Bhartrihari Caves:**\n'
          '• **Historical Legend:** King Bhartrihari, elder brother of Emperor Vikramaditya, renounced his royal kingdom and meditated in these subterranean rock caves overlooking the Shipra River.\n'
          '• **Literary Heritage:** It was here that he composed his immortal Sanskrit masterpieces: Niti Shatakam (ethics), Shringara Shatakam (love), and Vairagya Shatakam (renunciation).\n'
          '• **Sacred Dhuni:** Features an ancient perpetual sacred fire (Dhuni) preserved by the Nath sect of yogis.\n\n'
          '🌳 **Siddhwat Tirtha:**\n'
          '• **Immortal Banyan Tree:** Ranked alongside Prayagraj\'s Akshayavat, Gaya\'s Bodhivat, and Nashik\'s Panchavat as one of India\'s four immortal celestial banyan trees.\n'
          '• **Pind Daan & Pitru Tarpan:** Supreme pilgrimage destination for ancestral rituals, tarpan, and peace offerings.\n'
          '• **Kal Sarp Dosha Puja:** Priests conduct milk abhishek and specialized remedial pujas on Shipra banks here.';
    }

    // 10. Ancient Vedhshala (Jantar Mantar)
    if (_containsAny(message, [
      'vedhshala',
      'jantar mantar',
      'observatory',
      'वेधशाला',
      'जंतर मंतर',
    ])) {
      if (isHindi) {
        return '🔭 **प्राचीन वेधशाला (जंतर मंतर) उज्जैन — खगोल विज्ञान का गौरव:**\n\n'
            '✨ **परिचय एवं इतिहास:**\n'
            'उज्जैन वेधशाला का निर्माण जयपुर के महाराजा सवाई जयसिंह द्वारा १७१९ में कराया गया था। उज्जैन कर्क रेखा (Tropic of Cancer) पर स्थित होने तथा प्राचीन काल से भारतीय खगोल गणनाओं का शून्य देशांतर (Prime Meridian) होने के कारण यह वेधशाला अत्यधिक महत्वपूर्ण है।\n\n'
            '🌟 **प्रमुख ऐतिहासिक यंत्र:**\n'
            '1. **सम्राट यंत्र:** सूर्य की छाया से स्थानीय समय (Solar Time) का सटीक मापन करने वाला विशाल धूपघड़ी यंत्र।\n'
            '2. **नाड़ी वलय यंत्र:** आकाशीय पिंडों की स्थिति तथा विषुव (Equinox) ज्ञात करने का यंत्र।\n'
            '3. **दिगंश यंत्र:** ग्रहों एवं तारों के दिगंश (Azimuth) कोण नापने हेतु।\n'
            '4. **शंकु यंत्र:** सूर्य के उत्तरायण व दक्षिणायन का स्पष्ट संकेत।\n\n'
            '⏰ **समय:** प्रातः 9:00 AM से सायं 6:00 PM (नाममात्र टिकट उपलब्ध)।';
      }
      return '🔭 **Ancient Vedhshala (Jantar Mantar) Observatory in Ujjain:**\n\n'
          '✨ **Historical Importance:**\n'
          'Built in 1719 by Maharaja Sawai Jai Singh of Jaipur. Because Ujjain intersects the Tropic of Cancer and served as the Prime Meridian of Hindu astronomy, this observatory holds unmatched astronomical importance.\n\n'
          '🌟 **Key Astronomical Instruments:**\n'
          '1. **Samrat Yantra (Supreme Instrument):** A massive sundial calculating local solar time with remarkable precision.\n'
          '2. **Nadi Valaya Yantra:** Determines planetary positions and the celestial equator.\n'
          '3. **Digyansha Yantra:** Measures azimuth angles of stars and heavenly bodies.\n'
          '4. **Shanku Yantra:** Tracks the northward and southward solstices of the Sun.\n\n'
          '⏰ **Visiting Hours:** 9:00 AM to 6:00 PM daily (nominal ticket fee).';
    }

    return null;
  }

  String? _tryCalculateMath(String message) {
    try {
      final mathExpression = RegExp(
        r'(\d+(?:\.\d+)?)\s*([\+\-\*/])\s*(\d+(?:\.\d+)?)',
      );
      final match = mathExpression.firstMatch(message);

      if (match != null) {
        final num1 = double.parse(match.group(1)!);
        final operator = match.group(2)!;
        final num2 = double.parse(match.group(3)!);

        double result;
        switch (operator) {
          case '+':
            result = num1 + num2;
            break;
          case '-':
            result = num1 - num2;
            break;
          case '*':
            result = num1 * num2;
            break;
          case '/':
            if (num2 == 0) return 'Even Lord Shiva can\'t divide by zero! 🕉️';
            result = num1 / num2;
            break;
          default:
            return null;
        }

        String resultStr = result % 1 == 0
            ? result.toInt().toString()
            : result.toStringAsFixed(2);
        return '$num1 $operator $num2 = $resultStr';
      }
    } catch (e) {
      return 'Let me help you with that calculation. Could you try rephrasing it?';
    }
    return null;
  }

  String _categorizeMessage(String message, {bool isHindi = false}) {
    if (isHindi) {
      if (_containsAny(message, [
        'hello',
        'hi',
        'namaste',
        'pranam',
        'ram ram',
        'radhe radhe',
        'jai shree mahakal',
        'har har mahadev',
        'नमस्ते',
        'प्रणाम',
        'नमस्कार',
        'हेलो',
        'हाय',
        'राम राम',
        'जय श्री महाकाल',
        'हर हर महादेव',
        'सुप्रभात',
        'शुभ संध्या',
      ])) {
        return 'greeting_hi';
      }
      if (_containsAny(message, [
        'how are you',
        'kaise ho',
        'kaisi ho',
        'kya haal',
        'कैसे हो',
        'कैसी हो',
        'क्या हाल',
        'सब ठीक',
      ])) {
        return 'how_are_you_hi';
      }
      if (_containsAny(message, [
        'help',
        'madad',
        'sahayata',
        'मदद',
        'सहायता',
        'क्या कर सकते हो',
        'क्या मदद कर सकते हो',
      ])) {
        return 'help_hi';
      }
      if (_containsAny(message, [
        'joke',
        'chutkula',
        'hasao',
        'चुटकुला',
        'मजाक',
        'हंसाओ',
        'कोई चुटकुला',
      ])) {
        return 'joke_hi';
      }
      if (_containsAny(message, [
        'motivate',
        'motivation',
        'prerna',
        'suvichar',
        'प्रेरणा',
        'उत्साह',
        'सुविचार',
        'हौसला',
      ])) {
        return 'motivation_hi';
      }
      return 'default_hi';
    }

    if (_containsAny(message, [
      'hello',
      'hi',
      'namaste',
      'good morning',
      'good evening',
    ])) {
      return 'greeting';
    }
    if (_containsAny(message, ['how are you', 'how do you do'])) {
      return 'how_are_you';
    }
    if (_containsAny(message, ['help', 'what can you do', 'assist'])) {
      return 'help';
    }
    if (_containsAny(message, ['joke', 'funny', 'humor', 'laugh'])) {
      return 'joke';
    }
    if (_containsAny(message, [
      'motivate',
      'encourage',
      'inspiration',
      'feeling down',
      'sad',
    ])) {
      return 'motivation';
    }
    return 'default';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
