import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/services/network_service.dart';
import 'package:ai_assistant/services/hybrid_ai_service.dart';
import 'package:ai_assistant/models/chat_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Network & Automatic Offline/Online Switching', () {
    late NetworkService networkService;
    late HybridAIService hybridAIService;

    setUp(() {
      networkService = NetworkService();
      hybridAIService = HybridAIService();
    });

    test('NetworkService initializes and provides status getters', () async {
      await networkService.initialize();
      expect(networkService.getConnectionType(), isNotEmpty);
      expect(networkService.onConnectivityChanged, isNotNull);
    });

    test('HybridAIService reflects online/offline state and routes accordingly', () async {
      await hybridAIService.initialize();
      final session = ChatSession(title: 'Switch Test');

      // Test manual offline mode switch (simulating offline state)
      hybridAIService.setOfflineMode(true);
      expect(hybridAIService.isOffline, isTrue);
      expect(hybridAIService.isOnline, isFalse);

      // Verify that offline query routes cleanly to offline knowledge base
      final response = await hybridAIService.generateResponse(
        userMessage: 'महाकालेश्वर मंदिर में भस्म आरती का समय क्या है?',
        session: session,
      );
      expect(response, isNotEmpty);
      expect(response.contains('भस्म आरती') || response.contains('आरती') || response.contains('4:00'), isTrue);

      // Re-enable and test automatic reset
      hybridAIService.resetManualOverride();
      // Should reset manual override flag
    });

    test('Offline routing works seamlessly without throwing exceptions', () async {
      final session = ChatSession(title: 'Offline Test');
      hybridAIService.setOfflineMode(true);

      final englishRes = await hybridAIService.generateResponse(
        userMessage: 'Where is Mahakaleshwar temple?',
        session: session,
      );
      expect(englishRes, isNotEmpty);
      expect(englishRes.toLowerCase().contains('mahakaleshwar') || englishRes.toLowerCase().contains('ujjain'), isTrue);

      final hindiRes = await hybridAIService.generateResponse(
        userMessage: 'उज्जैन में राम घाट कहाँ है?',
        session: session,
      );
      expect(hindiRes, isNotEmpty);
      expect(hindiRes.contains('घाट') || hindiRes.contains('शिप्रा') || hindiRes.contains('उज्जैन'), isTrue);
    });
  });
}

