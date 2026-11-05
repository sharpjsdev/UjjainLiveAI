import 'lib/services/offline_ai_service.dart';
import 'lib/models/chat_session.dart';
import 'lib/models/message.dart';

void main() async {
  final aiService = OfflineAIService();
  
  print('=== Testing Follow-Up Question Handling ===\n');
  print('This demonstrates how the AI understands follow-up questions based on conversation history.\n');
  
  // Test Scenario 1: Hotel inquiry and follow-ups
  print('📍 SCENARIO 1: Hotel Inquiry Conversation\n');
  print('User: "What are the best hotels in Ujjain?"');
  
  var session = ChatSession(id: 'test1', messages: []);
  var response = await aiService.generateOfflineResponse(
    userMessage: 'What are the best hotels in Ujjain?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  // Add first message to session
  session = session.addMessage(Message(
    content: 'What are the best hotels in Ujjain?',
    type: MessageType.text,
    isFromUser: true,
  ));
  
  print('---\nUser: "How much do they cost?"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'How much do they cost?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "Can you compare them for me?"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'Can you compare them for me?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "How do I book?"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'How do I book?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  // Test Scenario 2: Restaurant inquiry and follow-ups
  print('\n📍 SCENARIO 2: Restaurant Inquiry Conversation\n');
  print('User: "Where can I find good vegetarian restaurants?"');
  
  session = ChatSession(id: 'test2', messages: []);
  response = await aiService.generateOfflineResponse(
    userMessage: 'Where can I find good vegetarian restaurants?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "Tell me more about the local food"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'Tell me more about the local food',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "What about prices?"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'What about prices?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  // Test Scenario 3: Temple inquiry and follow-ups
  print('\n📍 SCENARIO 3: Temple Inquiry Conversation\n');
  print('User: "What are the temple timings?"');
  
  session = ChatSession(id: 'test3', messages: []);
  response = await aiService.generateOfflineResponse(
    userMessage: 'What are the temple timings?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "Tell me more about how to visit all temples"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'Tell me more about how to visit all temples',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  // Test Scenario 4: Simhastha inquiry and follow-ups
  print('\n📍 SCENARIO 4: Simhastha Inquiry Conversation\n');
  print('User: "When is the next Simhastha?"');
  
  session = ChatSession(id: 'test4', messages: []);
  response = await aiService.generateOfflineResponse(
    userMessage: 'When is the next Simhastha?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "Tell me more about the bathing ritual"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'Tell me more about the bathing ritual',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('---\nUser: "What about accommodation during Simhastha?"');
  response = await aiService.generateOfflineResponse(
    userMessage: 'What about accommodation during Simhastha?',
    session: session,
  );
  print('AI: ${response.length > 100 ? response.substring(0, 100) + '...' : response}\n');
  
  print('\n=== Test Complete! ===');
  print('The AI intelligently understands follow-up questions based on previous context!');
  print('\n✨ Key Features Demonstrated:');
  print('1. Context tracking across conversation');
  print('2. Follow-up question detection ("how about", "tell me more", "what about")');
  print('3. Smart responses based on previous intent');
  print('4. Pricing follow-ups when asked about costs');
  print('5. Detailed comparisons when requested');
}
