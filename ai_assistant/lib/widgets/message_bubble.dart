import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';
import '../constants/app_colors.dart';
import '../providers/speech_provider.dart';
import '../utils/app_utils.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;

  const MessageBubble({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromUser) ...[
            _buildAssistantAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(flex: 4, child: _buildMessageContainer(context)),
          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.templeGold, width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.temple_hindu, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 19, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    final isUser = message.isFromUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.bubbleUserGradient : null,
        color: isUser ? null : AppColors.assistantMessageBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser
            ? null
            : Border(
                left: const BorderSide(color: AppColors.primary, width: 3.5),
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 0.8,
                ),
                right: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 0.8,
                ),
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge for assistant messages
          if (!isUser) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ॐ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'महाकाल मार्गदर्शक',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          if (message.content.isNotEmpty) _buildMessageContent(context),

          if (message.status == MessageStatus.sending) _buildLoadingIndicator(),

          const SizedBox(height: 4),
          _buildMessageFooter(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final isUser = message.isFromUser;
    final content = isUser
        ? message.content
        : AppUtils.cleanAssistantResponse(message.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LinkifiedSelectableText(
          content: content,
          style: TextStyle(
            color: isUser
                ? AppColors.userMessageText
                : AppColors.assistantMessageText,
            fontSize: 14.5,
            height: 1.45,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
          linkColor: isUser ? Colors.white : AppColors.primaryDark,
        ),
        if (!isUser && content.isNotEmpty) _buildSpeakButton(context),
      ],
    );
  }

  Widget _buildSpeakButton(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, child) {
        final isSpeakingThis = speechProvider.isSpeaking &&
            speechProvider.currentlySpeakingMessageId == message.id;

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () {
              if (isSpeakingThis) {
                speechProvider.stopSpeaking();
              } else {
                speechProvider.speak(
                  AppUtils.cleanTextForSpeech(message.content),
                  messageId: message.id,
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSpeakingThis
                    ? AppColors.devotional.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSpeakingThis
                      ? AppColors.devotional
                      : AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSpeakingThis
                        ? Icons.stop_circle_rounded
                        : Icons.volume_up_rounded,
                    size: 15,
                    color: isSpeakingThis
                        ? AppColors.devotional
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isSpeakingThis ? 'Stop' : 'Listen',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isSpeakingThis
                          ? AppColors.devotional
                          : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Divining guidance...',
            style: TextStyle(
              color: AppColors.assistantMessageText.withValues(alpha: 0.7),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter(BuildContext context) {
    final isUser = message.isFromUser;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppUtils.formatTime(message.timestamp),
          style: TextStyle(
            color: isUser
                ? AppColors.userMessageText.withValues(alpha: 0.75)
                : AppColors.assistantMessageText.withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (isUser) ...[const SizedBox(width: 4), _buildMessageStatusIcon()],
        if (message.status == MessageStatus.error && onRetry != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    IconData iconData;
    Color iconColor = AppColors.userMessageText.withValues(alpha: 0.75);

    switch (message.status) {
      case MessageStatus.sending:
        iconData = Icons.schedule;
        break;
      case MessageStatus.sent:
        iconData = Icons.check;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        break;
      case MessageStatus.error:
        iconData = Icons.error_outline;
        iconColor = AppColors.error;
        break;
    }

    return Icon(iconData, size: 13, color: iconColor);
  }
}

class _LinkifiedSelectableText extends StatefulWidget {
  final String content;
  final TextStyle style;
  final Color linkColor;

  const _LinkifiedSelectableText({
    required this.content,
    required this.style,
    required this.linkColor,
  });

  @override
  State<_LinkifiedSelectableText> createState() =>
      _LinkifiedSelectableTextState();
}

class _LinkifiedSelectableTextState extends State<_LinkifiedSelectableText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final spans = <TextSpan>[];
    final urlPattern = RegExp(r'https?://[^\s<>()]+', caseSensitive: false);
    var cursor = 0;

    for (final match in urlPattern.allMatches(widget.content)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: widget.content.substring(cursor, match.start)),
        );
      }

      var url = match.group(0)!;
      var trailing = '';
      while (url.isNotEmpty && '.,!?;:'.contains(url[url.length - 1])) {
        trailing = '${url[url.length - 1]}$trailing';
        url = url.substring(0, url.length - 1);
      }

      final uri = Uri.tryParse(url);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => launchUrl(uri, mode: LaunchMode.externalApplication);
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            text: url,
            style: TextStyle(
              color: widget.linkColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: url));
      }
      if (trailing.isNotEmpty) spans.add(TextSpan(text: trailing));
      cursor = match.end;
    }

    if (cursor < widget.content.length) {
      spans.add(TextSpan(text: widget.content.substring(cursor)));
    }

    return SelectableText.rich(TextSpan(style: widget.style, children: spans));
  }
}
