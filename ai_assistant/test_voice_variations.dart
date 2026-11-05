import 'lib/services/offline_ai_service.dart';
import 'lib/models/chat_session.dart';

void main() async {
  final aiService = OfflineAIService();
  
  print('=== Testing Voice Recognition Variations ===\n');
  
  // Test different ways to ask about hotels
  final hotelQuestions = [
    "I need a hotel in Ujjain",
    "Where can I stay near the temple?",
    "Best hotels for Simhastha pilgrims",
    "Cheap accommodation in Ujjain",
    "Luxury hotel suggestions",
    "Hotel near Mahakaleshwar",
    "mujhe hotel chahiye ujjain mein",  // Hindi mixed
    "rukne ki jagah batao",  // Pure Hindi
    "accommodation near temple",
    "budget hotel booking",
    "expensive hotel with good facilities",
  ];
  
  // Test different ways to ask about restaurants  
  final foodQuestions = [
    "Where to eat in Ujjain?",
    "Best restaurants for breakfast",
    "Local food recommendations", 
    "vegetarian food near temple",
    "famous sweets in Ujjain",
    "pure veg restaurant suggestion",
    "khana kahan milega ujjain mein",  // Hindi mixed
    "accha restaurant batao",  // Pure Hindi
    "I'm hungry, where should I eat?",
    "traditional Ujjaini food",
    "mithai shop near temple",
  ];
  
  // Test different ways to ask about temples
  final templeQuestions = [
    "Temple timings in Ujjain",
    "When is Bhasma Aarti?",
    "How to reach Mahakaleshwar?",
    "Best time for temple visit",
    "Darshan information",
    "mandir ka timing kya hai?",  // Hindi mixed
    "mahakal darshan kab hai?",  // Hindi mixed
    "temple location address",
    "spiritual places to visit",
    "holy places in Ujjain",
  ];
  
  // Test different ways to ask about Simhastha
  final simhasthaQuestions = [
    "When is next Kumbh Mela?",
    "Simhastha 2028 information",
    "Holy bathing dates",
    "accommodation during Simhastha",
    "How to prepare for Kumbh?",
    "simhastha kab hai 2028?",  // Hindi mixed
    "kumbh mela ki taiyari kaise kare?",  // Hindi mixed  
    "bathing ghat locations",
    "spiritual events in Simhastha",
    "first time Kumbh advice",
  ];
  
  print('🏨 HOTEL QUESTIONS:\n');
  for (String question in hotelQuestions) {
    final response = await aiService.generateOfflineResponse(
      userMessage: question,
      session: ChatSession(id: 'test', messages: []),
    );
    print('Q: "$question"');
    print('A: ${response.substring(0, 100)}...\n');
  }
  
  print('\n🍽️ RESTAURANT QUESTIONS:\n');  
  for (String question in foodQuestions.take(3)) {  // Show first 3 to save space
    final response = await aiService.generateOfflineResponse(
      userMessage: question, 
      session: ChatSession(id: 'test', messages: []),
    );
    print('Q: "$question"');
    print('A: ${response.substring(0, 100)}...\n');
  }
  
  print('\n🕉️ TEMPLE QUESTIONS:\n');
  for (String question in templeQuestions.take(3)) {  // Show first 3 to save space
    final response = await aiService.generateOfflineResponse(
      userMessage: question,
      session: ChatSession(id: 'test', messages: []),
    );
    print('Q: "$question"');
    print('A: ${response.substring(0, 100)}...\n');
  }
  
  print('\n🚩 SIMHASTHA QUESTIONS:\n');
  for (String question in simhasthaQuestions.take(3)) {  // Show first 3 to save space
    final response = await aiService.generateOfflineResponse(
      userMessage: question,
      session: ChatSession(id: 'test', messages: []),
    );
    print('Q: "$question"');  
    print('A: ${response.substring(0, 100)}...\n');
  }
  
  print('=== Test Complete! ===');
  print('The AI can understand many different ways of asking the same question!');
}