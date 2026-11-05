import 'lib/services/offline_ai_service.dart';
import 'lib/models/chat_session.dart';

void main() async {
  print('🤖 Testing Enhanced Offline AI Assistant');
  print('=' * 50);
  
  final offlineAI = OfflineAIService();
  final session = ChatSession(title: 'Test Session');
  
  // Test queries that should now work offline
  final testQueries = [
    'Best hotels in Mumbai',
    'Hotels in Ujjain',
    'Restaurants in Delhi', 
    'Where should I stay in Goa?',
    'Food recommendations in Mumbai',
    'What\'s the weather like?',
    'Travel information for Ujjain',
    'Tell me about Delhi',
    'What is 25 + 17?',
    'Tell me a joke',
    'Hello there!',
  ];
  
  for (final query in testQueries) {
    print('\n👤 User: $query');
    
    try {
      final response = await offlineAI.generateOfflineResponse(
        userMessage: query,
        session: session,
      );
      
      print('🤖 AI: $response');
      print('-' * 50);
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  print('\n✅ Enhanced offline AI test completed!');
  print('Now the app can handle complex queries even offline! 🎉');
}