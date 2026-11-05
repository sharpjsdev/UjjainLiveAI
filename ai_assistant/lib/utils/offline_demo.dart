import '../services/offline_ai_service.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

class OfflineDemo {
  static final OfflineAIService _offlineAI = OfflineAIService();

  static Future<void> demonstrateOfflineCapabilities() async {
    print("🔌 OFFLINE AI ASSISTANT DEMO");
    print("=" * 50);
    
    // Create a demo chat session
    final session = ChatSession(title: 'Offline Demo');
    
    // Test different types of queries
    final testQueries = [
      "Hello there!",
      "How are you doing?",
      "Tell me a joke",
      "What is 25 + 17?",
      "Calculate 144 divided by 12",
      "I'm feeling down today",
      "What's the weather like?",
      "Help me with math",
      "Can you motivate me?",
      "What time is it?",
      "Best hotels in Mumbai",
      "Just wanted to chat"
    ];

    for (String query in testQueries) {
      print("\n👤 User: $query");
      
      try {
        final response = await _offlineAI.generateOfflineResponse(
          userMessage: query,
          session: session,
        );
        print("🤖 AI (Offline): $response");
        
        // Add to session for context
        session.messages.add(Message(
          content: query,
          type: MessageType.text,
          isFromUser: true,
        ));
        session.messages.add(Message(
          content: response,
          type: MessageType.text,
          isFromUser: false,
        ));
        
      } catch (e) {
        print("❌ Error: $e");
      }
      
      // Small delay for readability
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    print("\n" + "=" * 50);
    print("✅ Offline demo completed!");
    print("📊 Session now has ${session.messages.length} messages");
  }

  static Map<String, String> getOfflineCapabilitiesExplanation() {
    return {
      'Greetings': 'Responds to hello, hi, good morning, etc.',
      'Math': 'Calculates simple expressions like "25 + 17" or "what is 144/12"',
      'Jokes': 'Tells pre-stored jokes when asked',
      'Motivation': 'Provides encouraging messages when user feels down',
      'General Chat': 'Maintains basic conversation flow',
      'Context Awareness': 'Remembers recent conversation for better responses',
      'Limitations': 'No real-time data, weather, hotels, or complex reasoning',
    };
  }

  static List<String> getOfflineExampleQueries() {
    return [
      "Hello!",
      "How are you?", 
      "Tell me a joke",
      "What is 15 + 28?",
      "Calculate 200 / 8",
      "I need some motivation",
      "Can you help me with math?",
      "Just want to chat",
      "Thank you!",
    ];
  }

  static List<String> getOnlineOnlyQueries() {
    return [
      "What's the weather today?",
      "Best hotels in Delhi",
      "Current news updates",
      "Restaurant recommendations",
      "What time is it in Tokyo?",
      "Latest stock prices",
      "Real-time traffic information",
    ];
  }
}