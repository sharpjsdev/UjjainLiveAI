import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speech_provider.dart';
import '../services/offline_ai_service.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../constants/app_colors.dart';
import '../utils/offline_demo.dart';
import '../utils/app_utils.dart';

class OfflineDemoScreen extends StatefulWidget {
  const OfflineDemoScreen({super.key});

  @override
  State<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
}

class _OfflineDemoScreenState extends State<OfflineDemoScreen> {
  final OfflineAIService _offlineAI = OfflineAIService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _demoMessages = [];
  final ChatSession _session = ChatSession(title: 'Offline Demo');
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.offline_bolt_rounded,
              color: AppColors.templeGold,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Offline Darshan Lab',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildInfoCard(),
          Expanded(child: _buildMessagesList()),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.temple_hindu,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Spiritual Intelligence Simulation',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Demonstrates how the app interprets temple questions, hotel searches, Bhasma Aarti rules, and math without internet.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_demoMessages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Test Offline Simhastha AI',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap one of the quick test queries below or enter your own query',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildQuickTestButtons(),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: _demoMessages.length,
      itemBuilder: (context, index) {
        final message = _demoMessages[index];
        return _buildDemoMessageBubble(message);
      },
    );
  }

  Widget _buildQuickTestButtons() {
    final examples = OfflineDemo.getOfflineExampleQueries();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: examples
          .map(
            (query) => ActionChip(
              label: Text(query),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _sendTestMessage(query),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDemoMessageBubble(Map<String, String> message) {
    final isUser = message['type'] == 'user';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.temple_hindu,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.bubbleUserGradient : null,
                color: isUser ? null : AppColors.assistantMessageBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border(
                        left: const BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                        top: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        right: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
              ),
              child: Text(
                message['content']!,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Try: "Hotels in Ujjain" or "25 + 17"',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight.withValues(alpha: 0.8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _sendMessage,
                enabled: !_isProcessing,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: IconButton(
                onPressed: _isProcessing
                    ? null
                    : () => _sendMessage(_controller.text),
                padding: EdgeInsets.zero,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendTestMessage(String message) {
    _controller.text = message;
    _sendMessage(message);
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _demoMessages.add({'type': 'user', 'content': message.trim()});
    });

    _controller.clear();

    try {
      _session.messages.add(
        Message(
          content: message.trim(),
          type: MessageType.text,
          isFromUser: true,
        ),
      );

      final rawResponse = await _offlineAI.generateOfflineResponse(
        userMessage: message.trim(),
        session: _session,
        responseLanguage: context.read<SpeechProvider>().responseLanguage,
      );
      final response = AppUtils.cleanAssistantResponse(rawResponse);

      _session.messages.add(
        Message(content: response, type: MessageType.text, isFromUser: false),
      );

      if (mounted) {
        setState(() {
          _demoMessages.add({'type': 'ai', 'content': response});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _demoMessages.add({
            'type': 'ai',
            'content': 'Sorry, I encountered an error: $e',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
