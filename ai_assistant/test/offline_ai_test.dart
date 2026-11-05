import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/services/offline_ai_service.dart';
import 'package:ai_assistant/models/location_info.dart';
import 'package:ai_assistant/models/chat_session.dart';

void main() {
  group('OfflineAIService Location and Distance Calculation', () {
    late OfflineAIService offlineAI;
    late ChatSession mockSession;

    setUp(() {
      offlineAI = OfflineAIService();
      mockSession = ChatSession(
        id: 'test_session',
        title: 'Test Session',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    });

    test('calculates correct distance from Indore coordinates to Mahakaleshwar', () async {
      // User is located in Indore (22.7196, 75.8577)
      final indoreLoc = LocationInfo(
        latitude: 22.7196,
        longitude: 75.8577,
        city: 'Indore',
      );

      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'how far is Mahakaleshwar',
        session: mockSession,
        locationInfo: indoreLoc,
      );

      // Verify that coordinates are displayed in output
      expect(response.contains('22.7196°N'), isTrue);
      expect(response.contains('75.8577°E'), isTrue);
      // Distance from Indore to Mahakaleshwar should be ~52-54 km, definitely not 0 m
      expect(response.contains('52.') || response.contains('53.') || response.contains('54.'), isTrue);
      expect(response.contains('0 m'), isFalse);
    });

    test('handles "where am I" query and outputs coordinates', () async {
      final userLoc = LocationInfo(
        latitude: 23.1800,
        longitude: 75.7800,
        city: 'Ujjain',
      );

      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'where am I right now',
        session: mockSession,
        locationInfo: userLoc,
      );

      expect(response.contains('23.1800'), isTrue);
      expect(response.contains('75.7800'), isTrue);
      expect(response.contains('Sacred Mahakaleshwar'), isTrue);
    });

    test('nearest query returns landmarks sorted by distance from user', () async {
      // User is near Ram Ghat (23.1867, 75.7744)
      final ghatLoc = LocationInfo(
        latitude: 23.1865,
        longitude: 75.7742,
        city: 'Ujjain',
      );

      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'nearest temple to me',
        session: mockSession,
        locationInfo: ghatLoc,
      );

      expect(response.contains('From your coordinates'), isTrue);
      expect(response.contains('Nearest Ujjain Landmarks'), isTrue);
    });
  });

  group('OfflineAIService Hindi & Spiritual Capabilities', () {
    late OfflineAIService offlineAI;
    late ChatSession mockSession;

    setUp(() {
      offlineAI = OfflineAIService();
      mockSession = ChatSession(
        id: 'test_session_hi',
        title: 'Hindi Test Session',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    });

    test('calculates distance in authentic Hindi using live GPS coordinates', () async {
      final indoreLoc = LocationInfo(
        latitude: 22.7196,
        longitude: 75.8577,
        city: 'Indore',
      );

      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'महाकालेश्वर कितनी दूर है',
        session: mockSession,
        locationInfo: indoreLoc,
      );

      expect(response.contains('आपके लाइव निर्देशांक से'), isTrue);
      expect(response.contains('श्री महाकालेश्वर ज्योतिर्लिंग'), isTrue);
      expect(response.contains('किमी'), isTrue);
      expect(response.contains('अनुमानित यात्रा समय'), isTrue);
    });

    test('answers "मैं कहाँ हूँ" with live GPS coordinates in Hindi', () async {
      final userLoc = LocationInfo(
        latitude: 23.1765,
        longitude: 75.7725,
        city: 'Ujjain',
      );

      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'मैं कहाँ हूँ',
        session: mockSession,
        locationInfo: userLoc,
      );

      expect(response.contains('आपके वर्तमान GPS निर्देशांक'), isTrue);
      expect(response.contains('23.1765'), isTrue);
      expect(response.contains('75.7725'), isTrue);
      expect(response.contains('पवित्र श्री महाकालेश्वर ज्योतिर्लिंग से दूरी'), isTrue);
    });

    test('answers sacred Mahamrityunjaya Mantra in Hindi', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'महामृत्युंजय मंत्र बताओ',
        session: mockSession,
      );

      expect(response.contains('ॐ त्र्यम्बकं यजामहे'), isTrue);
      expect(response.contains('सुगन्धिं पुष्टिवर्धनम्'), isTrue);
    });

    test('answers Shiv Tandav Stotram in Hindi', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'शिव तांडव स्तोत्र सुनाओ',
        session: mockSession,
      );

      expect(response.contains('जटाटवीगलज्जलप्रवाहपावितस्थले'), isTrue);
    });

    test('answers Bhasma Aarti timing in Hindi', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'भस्म आरती का समय क्या है',
        session: mockSession,
      );

      expect(response.contains('प्रातः 4:00 AM से 6:00 AM'), isTrue);
      expect(response.contains('ऑनलाइन बुकिंग'), isTrue);
    });

    test('answers date & time queries in Hindi', () async {
      final dateResponse = await offlineAI.generateOfflineResponse(
        userMessage: 'आज की तारीख क्या है',
        session: mockSession,
      );
      expect(dateResponse.contains('आज की तारीख:'), isTrue);

      final timeResponse = await offlineAI.generateOfflineResponse(
        userMessage: 'समय क्या हुआ है',
        session: mockSession,
      );
      expect(timeResponse.contains('वर्तमान समय:'), isTrue);
    });

    test('answers Hindi hotel inquiries', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'उज्जैन में रुकने के लिए अच्छा और सस्ता होटल बताओ',
        session: mockSession,
      );

      expect(response.contains('होटल') || response.contains('धर्मशाला'), isTrue);
      expect(response.contains('महाकालेश्वर धर्मशाला') || response.contains('रुद्र पैलेस'), isTrue);
    });

    test('answers Hindi food & breakfast inquiries', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'उज्जैन का प्रसिद्ध नाश्ता क्या है',
        session: mockSession,
      );

      expect(response.contains('पोहा') || response.contains('नाश्ता'), isTrue);
    });

    test('answers Simhastha 2028 inquiries in Hindi', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'सिंहस्थ कुंभ मेला कब है',
        session: mockSession,
      );

      expect(response.contains('2028'), isTrue);
      expect(response.contains('अप्रैल - मई') || response.contains('शाही स्नान'), isTrue);
    });

    test('answers General Knowledge in Hindi', () async {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: 'भारत की राजधानी क्या है',
        session: mockSession,
      );

      expect(response.contains('नई दिल्ली'), isTrue);
    });
  });

  group('OfflineAIService Ujjain Deep Heritage & Simhastha 2028 Comprehensive Knowledge', () {
    late OfflineAIService offlineAI;
    late ChatSession mockSession;

    setUp(() {
      offlineAI = OfflineAIService();
      mockSession = ChatSession(
        id: 'test_session_ujjain_simhastha',
        title: 'Ujjain & Simhastha Deep Test',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    });

    test('answers detailed Mahakal Lok Corridor information in Hindi and English', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'श्री महाकाल महालोक कॉरिडोर के बारे में विस्तार से बताओ',
        session: mockSession,
      );
      expect(hindiRes.contains('श्री महाकाल महालोक'), isTrue);
      expect(hindiRes.contains('मीटर'), isTrue);
      expect(hindiRes.contains('शिव तांडव स्तंभ'), isTrue);
      expect(hindiRes.contains('रूद्र सागर') || hindiRes.contains('रुद्र'), isTrue);

      final engRes = await offlineAI.generateOfflineResponse(
        userMessage: 'tell me about Mahakal Mahalok corridor and timings',
        session: mockSession,
      );
      expect(engRes.contains('Mahakal Mahalok Corridor'), isTrue);
      expect(engRes.contains('900 meters'), isTrue);
      expect(engRes.contains('Shiva Tandav Pillars'), isTrue);
    });

    test('answers Ujjain history, ancient names, and King Vikramaditya', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'उज्जैन का प्राचीन इतिहास और राजा विक्रमादित्य के बारे में बताओ',
        session: mockSession,
      );
      expect(hindiRes.contains('अवंतिका'), isTrue);
      expect(hindiRes.contains('उज्जयिनी'), isTrue);
      expect(hindiRes.contains('विक्रमादित्य'), isTrue);
      expect(hindiRes.contains('नवरत्न'), isTrue);

      final engRes = await offlineAI.generateOfflineResponse(
        userMessage: 'what is the ancient history of Ujjain and King Vikramaditya',
        session: mockSession,
      );
      expect(engRes.contains('Avantika') || engRes.contains('Ujjayini'), isTrue);
      expect(engRes.contains('Vikramaditya'), isTrue);
      expect(engRes.contains('Prime Meridian'), isTrue);
    });

    test('answers Simhastha Samudra Manthan mythological story and Amrit drops', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'सिंहस्थ कुंभ की पौराणिक कथा और समुद्र मंथन क्या है',
        session: mockSession,
      );
      expect(hindiRes.contains('समुद्र मंथन'), isTrue);
      expect(hindiRes.contains('अमृत कलश'), isTrue);
      expect(hindiRes.contains('शिप्रा नदी') || hindiRes.contains('माँ शिप्रा'), isTrue);

      final engRes = await offlineAI.generateOfflineResponse(
        userMessage: 'mythological story of Samudra Manthan and nectar in Simhastha',
        session: mockSession,
      );
      expect(engRes.contains('Samudra Manthan') || engRes.contains('Cosmic Churning'), isTrue);
      expect(engRes.contains('Amrit'), isTrue);
    });

    test('answers 13 Akharas and Naga Babas details in Simhastha', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'सिंहस्थ के 13 अखाड़े और नागा संन्यासी कौन हैं',
        session: mockSession,
      );
      expect(hindiRes.contains('अखाड़े'), isTrue);
      expect(hindiRes.contains('जूना अखाड़ा'), isTrue);
      expect(hindiRes.contains('शाही पेशवाई'), isTrue);
      expect(hindiRes.contains('नागा'), isTrue);

      final engRes = await offlineAI.generateOfflineResponse(
        userMessage: 'tell me about 13 traditional akharas and naga sadhus in simhastha',
        session: mockSession,
      );
      expect(engRes.contains('Akharas'), isTrue);
      expect(engRes.contains('Naga') || engRes.contains('Juna Akhara'), isTrue);
    });

    test('answers Panchkroshi Yatra and 84 Mahadev details', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'उज्जैन की पंचक्रोशी यात्रा और 84 महादेव की जानकारी दो',
        session: mockSession,
      );
      expect(hindiRes.contains('पंचक्रोशी यात्रा'), isTrue);
      expect(hindiRes.contains('किलोमीटर'), isTrue);
      expect(hindiRes.contains('महादेव'), isTrue);
      expect(hindiRes.contains('पिंगलेश्वर'), isTrue);
    });

    test('answers sightseeing places to visit & itinerary in Ujjain', () async {
      final hindiRes = await offlineAI.generateOfflineResponse(
        userMessage: 'उज्जैन में क्या क्या देखें दर्शनीय स्थल',
        session: mockSession,
      );
      expect(hindiRes.contains('दर्शनीय स्थल'), isTrue);
      expect(hindiRes.contains('काल भैरव'), isTrue);
      expect(hindiRes.contains('राम घाट'), isTrue);
      expect(hindiRes.contains('मंगलनाथ'), isTrue);

      final engRes = await offlineAI.generateOfflineResponse(
        userMessage: 'what are the best places to visit in Ujjain travel itinerary',
        session: mockSession,
      );
      expect(engRes.contains('Places to Visit'), isTrue);
      expect(engRes.contains('Bhartrihari Caves') || engRes.contains('Kal Bhairav'), isTrue);
    });
  });
}

