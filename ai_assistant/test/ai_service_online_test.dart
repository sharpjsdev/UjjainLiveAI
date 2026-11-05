import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/services/ai_service.dart';
import 'package:ai_assistant/models/chat_session.dart';
import 'package:ai_assistant/constants/app_constants.dart';

void main() {
  test('AIService connects to Gemini and returns live response with configured key', () async {
    expect(AppConstants.useOnlineMode, isTrue);
    expect(AppConstants.isGemini, isTrue);

    final aiService = AIService();
    final session = ChatSession(
      title: 'Online Test',
    );

    final response = await aiService.generateResponse(
      userMessage: 'What is the significance of Shipra river in Ujjain? Answer in 1-2 sentences.',
      session: session,
    );

    print('Online Gemini AI Response:\n$response');
    expect(response, isNotEmpty);
    expect(
      response.toLowerCase().contains('shipra') ||
      response.toLowerCase().contains('ujjain') ||
      response.toLowerCase().contains('sacred') ||
      response.toLowerCase().contains('river') ||
      response.toLowerCase().contains('kumbh'),
      isTrue,
    );
  }, timeout: const Timeout(Duration(seconds: 45)));
}
