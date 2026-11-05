class SnanEvent {
  final String title;
  final String hindiTitle;
  final String date;
  final String tithi;
  final String significance;
  final String hindiSignificance;
  final String location;
  final bool isShahiSnan;
  final String type; // 'shahi_snan', 'parva_snan', 'procession', 'program'

  const SnanEvent({
    required this.title,
    required this.hindiTitle,
    required this.date,
    required this.tithi,
    required this.significance,
    required this.hindiSignificance,
    required this.location,
    required this.isShahiSnan,
    required this.type,
  });
}

class SimhasthaCalendarData {
  static const List<SnanEvent> events = [
    SnanEvent(
      title: 'First Shahi Snan (Royal Bath)',
      hindiTitle: 'प्रथम शाही स्नान (महाप्रारंभ)',
      date: 'April 9, 2028 (Sunday)',
      tithi: 'Chaitra Shukla Purnima (चैत्र पूर्णिमा)',
      significance: 'Grand Opening of Simhastha Kumbh Mela 2028. Sacred royal dip led by Akhara Saints and Naga Babas at sunrise with conch sounds and floral offerings.',
      hindiSignificance: 'सिंहस्थ 2028 का प्रथम एवं ऐतिहासिक शाही स्नान। 13 अखाड़ों के नागा साधुओं एवं संतों द्वारा सूर्योदय पर सर्वप्रथम अमृत डुबकी।',
      location: 'Ram Ghat & Dutt Akhara Ghat, Shipra River',
      isShahiSnan: true,
      type: 'shahi_snan',
    ),
    SnanEvent(
      title: 'Mesha Sankranti Parva Snan',
      hindiTitle: 'मेष संक्रांति पावन स्नान',
      date: 'April 13, 2028 (Thursday)',
      tithi: 'Mesha Sankranti (मेष संक्रांति)',
      significance: 'Auspicious solar transition into Aries while Jupiter is in Leo. Taking a holy bath cleanses negative karmas and bestows vitality.',
      hindiSignificance: 'सूर्य का मेष राशि में प्रवेश। गुरु के सिंह राशि में होने पर यह महासंयोग करोड़ों पापों का नाश करता है।',
      location: 'All 12 Shipra Ghats, Ujjain',
      isShahiSnan: false,
      type: 'parva_snan',
    ),
    SnanEvent(
      title: 'Varuthini Ekadashi Snan',
      hindiTitle: 'वरूथिनी एकादशी पावन स्नान',
      date: 'April 20, 2028 (Thursday)',
      tithi: 'Vaishakh Krishna Ekadashi (वरूथिनी एकादशी)',
      significance: 'Dedicated to Lord Vamana and Vishnu. Grants freedom from worldly afflictions and brings peace to departed ancestors.',
      hindiSignificance: 'भगवान वामन की कृपा प्रदायिनी एकादशी। शिप्रा में स्नान व दान से मोक्ष एवं अखंड सौभाग्य की प्राप्ति होती है।',
      location: 'Ram Ghat & Triveni Sangam Ghat',
      isShahiSnan: false,
      type: 'parva_snan',
    ),
    SnanEvent(
      title: 'Second Shahi Snan (Vaishakh Amavasya)',
      hindiTitle: 'द्वितीय शाही स्नान (वैशाख अमावस्या)',
      date: 'April 24, 2028 (Monday)',
      tithi: 'Vaishakh Krishna Amavasya (वैशाखी अमावस्या)',
      significance: 'The massive second Royal Bath. High planetary alignment for pitru tarpan and liberation; attracts millions of pilgrims and saints.',
      hindiSignificance: 'द्वितीय महा शाही स्नान। पितृ तर्पण एवं आत्मिक शुद्धि का महापुण्य पर्व। समस्त अखाड़ों का विशाल शाही जुलूस।',
      location: 'Ram Ghat, Dutt Akhara & Siddhwat Ghat',
      isShahiSnan: true,
      type: 'shahi_snan',
    ),
    SnanEvent(
      title: 'Mohini Ekadashi Snan',
      hindiTitle: 'मोहिनी एकादशी पावन स्नान',
      date: 'May 5, 2028 (Friday)',
      tithi: 'Vaishakh Shukla Ekadashi (मोहिनी एकादशी)',
      significance: 'Commemorates Lord Vishnu distributing cosmic Amrit (nectar) as Mohini during the Samudra Manthan churning.',
      hindiSignificance: 'समुद्र मंथन पश्चात भगवान विष्णु द्वारा मोहिनी रूप धरकर देवताओं में अमृत वितरण का पावन दिवस।',
      location: 'Ram Ghat & Shipra Riverfront',
      isShahiSnan: false,
      type: 'parva_snan',
    ),
    SnanEvent(
      title: 'Maha Shahi Snan (The Grand Royal Bath)',
      hindiTitle: 'महा शाही स्नान (सिंहस्थ का सर्वोच्च पर्व)',
      date: 'May 8, 2028 (Monday)',
      tithi: 'Vaishakh Shukla Purnima (बुद्ध पूर्णिमा / वैशाख पूर्णिमा)',
      significance: 'The supreme zenith of Simhastha Ujjain 2028! The largest cosmic congregation of humanity on earth taking sacred dips simultaneously.',
      hindiSignificance: 'सिंहस्थ 2028 का सबसे बड़ा एवं अंतिम महा शाही स्नान। करोड़ों संतों व भक्तों का एक साथ शिप्रा में अमृत स्नान।',
      location: 'All Ghats: Ram Ghat, Dutt Akhara, Mangalnath, Narsingha Ghat',
      isShahiSnan: true,
      type: 'shahi_snan',
    ),
    SnanEvent(
      title: 'Grand Peshwai Processions',
      hindiTitle: 'अखाड़ों की भव्य पेशवाई एवं शोभायात्रा',
      date: 'March 25 – April 8, 2028',
      tithi: 'Shukla Paksha Pre-Mela',
      significance: 'Majestic ceremonial royal entry of the 13 Akharas into Ujjain on decorated elephants, horses, and silver chariots demonstrating Vedic heritage.',
      hindiSignificance: '13 अखाड़ों के साधु-संतों का उज्जैन नगर में शाही प्रवेश। सजे-धजे हाथी, घोड़े, चांदी के रथ और अस्त्र-शस्त्र का अद्भुत प्रदर्शन।',
      location: 'Kanthal, Gopal Mandir, Mahakal Marg to Akhara Camp Zone',
      isShahiSnan: false,
      type: 'procession',
    ),
    SnanEvent(
      title: 'Panchkroshi Yatra Pilgrimage',
      hindiTitle: 'पावन 118 किमी पंचक्रोशी यात्रा',
      date: 'April 25 – April 30, 2028',
      tithi: 'Vaishakh Krishna Dashami to Amavasya',
      significance: 'Ancient 118-km barefoot pilgrimage encircling Ujjain across 4 sacred directional Mahadev temples (Pingleshwar, Kayavarohaneshwar, Bilkeshwar, Durdhareshwar).',
      hindiSignificance: 'उज्जैन के चारों दिशाओं के रक्षक महादेवों की 118 किमी पैदल परिक्रमा। लाखों ग्रामीण व भक्त श्रद्धा से यात्रा करते हैं।',
      location: 'Starts & ends at Nagchandreshwar (Patni Bazaar)',
      isShahiSnan: false,
      type: 'program',
    ),
  ];
}

