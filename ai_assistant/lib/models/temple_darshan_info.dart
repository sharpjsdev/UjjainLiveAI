class TempleDarshanInfo {
  final String templeId;
  final String templeName;
  final String hindiName;
  final String deity;
  final String significance;
  final String timing;
  final String? imageUrl;
  final List<AartiSchedule> aartis;
  final List<String> entryGates;
  final List<String> darshanRoutes;
  final String vipFastTrackRules;
  final String bookingWebsite;
  final String dressCode;
  final String prasadDetails;

  const TempleDarshanInfo({
    required this.templeId,
    required this.templeName,
    required this.hindiName,
    required this.deity,
    required this.significance,
    required this.timing,
    this.imageUrl,
    required this.aartis,
    required this.entryGates,
    required this.darshanRoutes,
    required this.vipFastTrackRules,
    required this.bookingWebsite,
    required this.dressCode,
    required this.prasadDetails,
  });
}

class AartiSchedule {
  final String name;
  final String hindiName;
  final String timingSummer;
  final String timingWinter;
  final String description;

  const AartiSchedule({
    required this.name,
    required this.hindiName,
    required this.timingSummer,
    required this.timingWinter,
    required this.description,
  });
}

class TempleGuideData {
  static const List<TempleDarshanInfo> temples = [
    TempleDarshanInfo(
      templeId: 'mahakaleshwar',
      templeName: 'Shri Mahakaleshwar Jyotirlinga',
      hindiName: 'श्री महाकालेश्वर ज्योतिर्लिंग',
      deity: 'Lord Shiva (Mahakal - Lord of Eternity & Time)',
      significance: 'The only Dakshinmukhi (south-facing) Jyotirlinga in the world. Enshrines the continuous Cosmic Lingam and is world-renowned for the daily sacred Bhasma Aarti with fresh sacred ashes.',
      timing: '4:00 AM – 11:00 PM (Temple doors open at 4:00 AM for Bhasma Aarti)',
      imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop',
      aartis: [
        AartiSchedule(
          name: 'Bhasma Aarti',
          hindiName: 'दिव्य भस्म आरती',
          timingSummer: '4:00 AM – 6:00 AM',
          timingWinter: '4:00 AM – 6:00 AM',
          description: 'Sacred ash ritual performed before dawn. Devotees witness the deity bathed in sacred ash and milk.',
        ),
        AartiSchedule(
          name: 'Naivedya Aarti (Morning)',
          hindiName: 'नैवेद्य आरती (प्रातः)',
          timingSummer: '7:00 AM – 7:30 AM',
          timingWinter: '7:30 AM – 8:00 AM',
          description: 'Morning offering of sacred sweet delicacies and divine milk bath.',
        ),
        AartiSchedule(
          name: 'Bhog Aarti (Afternoon)',
          hindiName: 'भोग आरती (दोपहर)',
          timingSummer: '10:30 AM – 11:15 AM',
          timingWinter: '10:30 AM – 11:15 AM',
          description: 'Midday sanctum offering accompanied by traditional damru drums and conch.',
        ),
        AartiSchedule(
          name: 'Sandhya Aarti (Evening)',
          hindiName: 'संध्या आरती (सायंकालीन)',
          timingSummer: '7:00 PM – 7:45 PM',
          timingWinter: '6:30 PM – 7:15 PM',
          description: 'Grand evening shringar aarti where Lord Mahakal is adorned with exquisite ornaments and flowers.',
        ),
        AartiSchedule(
          name: 'Shayan Aarti (Night)',
          hindiName: 'शयन आरती (रात्रि विश्राम)',
          timingSummer: '10:30 PM – 11:00 PM',
          timingWinter: '10:30 PM – 11:00 PM',
          description: 'Closing night ritual where the deity retires for the night.',
        ),
      ],
      entryGates: [
        'Gate No. 1 (Nandi Dwar): Primary ingress for online pre-booked Bhasma Aarti pilgrims.',
        'Gate No. 4 (Sheegra / Protocol Gate): Paid express darshan (₹250 pass) and senior citizens.',
        'Bada Ganesh Gate / Chhota Chauraha: General public queue during peak festive rush.',
        'Pinaki Dwar & Shankh Dwar (Mahakal Lok): Pedestrian access through the artistic corridor.',
      ],
      darshanRoutes: [
        'General Free Route: Mahakal Lok Entrance -> Zigzag Holding Canopies -> Sabhamandap -> Nandi Hall View -> Sanctum Jaladhari Exit.',
        'Sheegra Darshan Route (₹250): Gate 4 -> Dedicated Tunnel -> Direct Sabhamandap Entry (approx. 20-40 min during normal days).',
        'Garbhagriha Jalabhishek: Permitted only during designated non-rush afternoon slots with traditional attire.',
      ],
      vipFastTrackRules: 'Sheegra Darshan tickets (₹250 per devotee) are available online on the official portal or at counter kiosks near Gate 4. Senior citizens (70+) and differently-abled devotees are provided wheel-chairs and ramp priority.',
      bookingWebsite: 'https://shrimahakaleshwar.mp.gov.in',
      dressCode: 'General Darshan: Decent Indian or modest Western wear.\nGarbhagriha Entry / Bhasma Aarti Jalabhishek: Men must wear unstitched cotton/silk Dhoti-Kurta or Angavastram. Women must wear pure Saree (Salwar suits not allowed inside inner sanctum during ritual).',
      prasadDetails: 'Official Mahakal Laddu Prasad (Besan, Pure Desi Ghee, Dry Fruits) certified by FSSAI available at temple counters from ₹70 (100g) to ₹360 (1kg).',
    ),
    TempleDarshanInfo(
      templeId: 'kal_bhairav',
      templeName: 'Shri Kal Bhairav Temple',
      hindiName: 'श्री काल भैरव मंदिर',
      deity: 'Lord Kal Bhairav (Tantric & City Guardian)',
      significance: 'Regarded as the Senapati (commander) and celestial administrator of Ujjain. The stone deity mysteriously consumes liquid offerings poured into the mouth bowl.',
      timing: '5:00 AM – 10:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1626014303757-6564477318f7?q=80&w=1200&auto=format&fit=crop',
      aartis: [
        AartiSchedule(
          name: 'Pratah Aarti',
          hindiName: 'प्रातः आरती',
          timingSummer: '6:00 AM',
          timingWinter: '6:30 AM',
          description: 'Morning awakening with sindoor and vermilion ornamentation.',
        ),
        AartiSchedule(
          name: 'Sandhya Maha Aarti',
          hindiName: 'संध्या महाआरती',
          timingSummer: '7:30 PM',
          timingWinter: '7:00 PM',
          description: 'Soulful evening tantric aarti with brass bells and camphor lights.',
        ),
      ],
      entryGates: [
        'Main Toran Gate: Entrance from outer Bhairavgarh parking lot.',
        'Sanctum Queue Ramp: Divided into two rails (Offering Queue & Quick Darshan Queue).',
      ],
      darshanRoutes: [
        'Outer courtyard -> Offering basket verification -> Inner Garbhagriha front rail -> Holy Charnamrit distribution -> Exit via backside oil lamp altar.',
      ],
      vipFastTrackRules: 'Special queue counter available for ₹100 during Sunday and Ashtami rush.',
      bookingWebsite: 'https://ujjain.nic.in/en/tourist-places/',
      dressCode: 'Modest traditional or casual clothing. Footwear strictly deposited at outer shoe stalls.',
      prasadDetails: 'Prasad baskets containing coconut, sweets, floral garlands, and traditional offerings sold by official stalls outside.',
    ),
    TempleDarshanInfo(
      templeId: 'harsiddhi',
      templeName: 'Maa Harsiddhi Shaktipeeth',
      hindiName: 'माँ हरसिद्धि शक्तिपीठ',
      deity: 'Goddess Harsiddhi (Durga / Mangala)',
      significance: '13th of the sacred 51 Shaktipeeths where Devi Sati\'s elbow fell. Fabled family deity of King Vikramaditya. Renowned for two colossal 50-feet Deepstambhs with 1008 oil lamps.',
      timing: '5:00 AM – 11:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=1200&auto=format&fit=crop',
      aartis: [
        AartiSchedule(
          name: 'Mangala Aarti',
          hindiName: 'मंगला आरती',
          timingSummer: '6:00 AM',
          timingWinter: '6:30 AM',
          description: 'Early morning Devi invocation and lotus decoration.',
        ),
        AartiSchedule(
          name: 'Deepstambh Deepotsav Aarti',
          hindiName: 'दीपस्तंभ प्रज्वलन एवं महाआरती',
          timingSummer: '7:00 PM – 8:00 PM',
          timingWinter: '6:30 PM – 7:30 PM',
          description: 'Spectacular lighting of 1008 lamps on the towering stone pillars by skilled youth, followed by cosmic chanting.',
        ),
      ],
      entryGates: [
        'Main East Gate (Facing Rudrasagar pathway).',
        'Deepstambh Courtyard South Gate.',
      ],
      darshanRoutes: [
        'Courtyard Entrance -> Deepstambh circumambulation -> Inner Sanctum -> Annapurna Shrine & Vikramaditya Altar -> Exit.',
      ],
      vipFastTrackRules: 'Devotees can sponsor the lighting of the Deepstambh through temple trust desk.',
      bookingWebsite: 'https://ujjain.nic.in/en/places-of-interest/',
      dressCode: 'Traditional Indian attire preferred. Clean clothing required.',
      prasadDetails: 'Chunari, vermilion, dried coconuts, and traditional peda prasad.',
    ),
  ];
}

