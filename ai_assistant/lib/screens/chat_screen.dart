import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/speech_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/connection_status_bar.dart';
import '../constants/app_colors.dart';
import '../models/message.dart';
import '../utils/app_utils.dart';
import 'chat_sessions_screen.dart';
import 'settings_screen.dart';
import 'offline_demo_screen.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool? _lastOnlineStatus;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      final speechProvider = context.read<SpeechProvider>();
      if (!chatProvider.isInitialized) {
        chatProvider.initialize();
      }
      if (!speechProvider.isInitialized) {
        speechProvider.initialize();
      }

      // Automatically speak incoming AI responses if Auto-Listen is enabled
      chatProvider.onResponseReceived = (message) {
        if (!mounted) return;
        final sp = context.read<SpeechProvider>();
        if (sp.autoSpeakResponse) {
          final speechText = AppUtils.cleanTextForSpeech(message.content);
          if (speechText.trim().isNotEmpty) {
            sp.speak(speechText, messageId: message.id);
          }
        }
      };

      if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _sendMessage(chatProvider, widget.initialMessage!.trim(), MessageType.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Show scroll-to-bottom button ONLY when user has scrolled UP away from latest messages
    final distanceFromBottom = maxScroll - currentScroll;
    if (distanceFromBottom > 160 && maxScroll > 200) {
      if (_fabAnimationController.status != AnimationStatus.forward &&
          _fabAnimationController.value < 1.0) {
        _fabAnimationController.forward();
      }
    } else {
      if (_fabAnimationController.status != AnimationStatus.reverse &&
          _fabAnimationController.value > 0.0) {
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (_lastOnlineStatus != null &&
              _lastOnlineStatus != chatProvider.isOnline) {
            final nowOnline = chatProvider.isOnline;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        nowOnline ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nowOnline
                              ? 'इंटरनेट कनेक्ट हुआ • ऑनलाइन AI सक्रिय (Online)'
                              : 'इंटरनेट बंद हुआ • ऑफलाइन दर्शन मोड सक्रिय (Offline)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: nowOnline
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD84315),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(12),
                ),
              );
            });
          }
          _lastOnlineStatus = chatProvider.isOnline;

          if (chatProvider.isLoading) {
            return _buildLoadingView();
          }

          if (chatProvider.error != null) {
            return _buildErrorView(chatProvider);
          }

          return Column(
            children: [
              const ConnectionStatusBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildMessagesList(chatProvider),
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: _buildScrollToBottomFab(),
                    ),
                  ],
                ),
              ),
              ChatInput(
                onSendMessage: (message) =>
                    _sendMessage(chatProvider, message, MessageType.text),
                onSendVoiceMessage: (message) =>
                    _sendMessage(chatProvider, message, MessageType.voice),
                enabled: !chatProvider.isGeneratingResponse,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 68,
      titleSpacing: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      ),
      elevation: 2,
      shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.templeGold, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/simhastha_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'ॐ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ujjain Live',
                  style: TextStyle(
                    fontSize: 15.5,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Consumer<SpeechProvider>(
                  builder: (context, speechProvider, child) {
                    return SizedBox(
                      height: 20,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: speechProvider.isHindi ? 'hi' : 'en',
                          isDense: true,
                          dropdownColor: AppColors.primaryDark,
                          icon: const Icon(
                            Icons.expand_more,
                            color: Colors.white70,
                            size: 13,
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                          ],
                          onChanged: (language) {
                            if (language != null) {
                              speechProvider.setLanguage(
                                language == 'hi' ? 'hi-IN' : 'en-IN',
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Auto-Listen (Auto TTS) Pill Badge
        Consumer<SpeechProvider>(
          builder: (context, speechProvider, child) {
            final isAuto = speechProvider.autoSpeakResponse;
            final isSpeaking = speechProvider.isSpeaking;
            return GestureDetector(
              onTap: () {
                if (isSpeaking) {
                  speechProvider.stopSpeaking();
                } else {
                  speechProvider.toggleAutoSpeakResponse();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        speechProvider.autoSpeakResponse
                            ? 'ऑटो लिसन चालू (Auto-Listen ON: AI answers will be spoken aloud)'
                            : 'ऑटो लिसन बंद (Auto-Listen OFF: Silent reading mode)',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isSpeaking
                      ? AppColors.devotional.withValues(alpha: 0.6)
                      : (isAuto
                          ? AppColors.templeGold.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSpeaking
                        ? Colors.redAccent
                        : (isAuto ? AppColors.templeGold : Colors.white38),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : (isAuto ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                      color: isSpeaking
                          ? Colors.white
                          : (isAuto ? AppColors.templeGold : Colors.white60),
                      size: 11,
                    ),
                    const SizedBox(width: 2.5),
                    Text(
                      isSpeaking
                          ? 'Speaking'
                          : (isAuto ? 'Listen ON' : 'Listen OFF'),
                      style: TextStyle(
                        color: isSpeaking
                            ? Colors.white
                            : (isAuto ? AppColors.templeGold : Colors.white70),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Network status pill badge
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final isOnline = chatProvider.isOnline;
            return GestureDetector(
              onTap: () => _showConnectionStatus(context, chatProvider),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.shade800.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOnline ? Colors.white70 : AppColors.goldLight,
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.bolt : Icons.temple_hindu,
                      color: isOnline ? Colors.white : AppColors.templeGold,
                      size: 11,
                    ),
                    const SizedBox(width: 2.5),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Location Refresh Icon
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final hasLoc = chatProvider.currentLocation != null;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                hasLoc ? Icons.location_on : Icons.location_off_outlined,
                color: hasLoc
                    ? AppColors.templeGold
                    : Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              onPressed: () => chatProvider.refreshLocation(),
              tooltip: hasLoc
                  ? 'Location: ${chatProvider.currentLocation!.city ?? "Ujjain"}'
                  : 'Detect location in Ujjain',
            );
          },
        ),

        // Overflow Menu (Contains City Guide & Live Map, History, Settings)
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          onSelected: (value) => _handleMenuAction(value),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'city_guide',
              child: Row(
                children: [
                  Icon(Icons.explore_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('City Guide & Live Map'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sessions',
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Chat History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_chat',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('New Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_current',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.devotional),
                  SizedBox(width: 10),
                  Text('Clear Current'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'offline_demo',
              child: Row(
                children: [
                  Icon(Icons.offline_bolt_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Offline Testing Lab'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Voice & Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '॥ जय श्री महाकाल ॥',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Initializing Ujjain Live...',
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ChatProvider chatProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Spiritual Connection Paused',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              chatProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                chatProvider.clearError();
                chatProvider.initialize();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    final messages = chatProvider.currentMessages;

    if (messages.isEmpty) {
      return _buildPilgrimWelcomeHub();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          onRetry: message.status == MessageStatus.error
              ? () => chatProvider.retryMessage(
                  message.id,
                  responseLanguage: context
                      .read<SpeechProvider>()
                      .responseLanguage,
                )
              : null,
        );
      },
    );
  }

  /// The Pilgrim's Sacred Sanctuary Hub - Rich Simhastha Empty State
  Widget _buildPilgrimWelcomeHub() {
    final chatProvider = context.read<ChatProvider>();
    final speechProvider = context.watch<SpeechProvider>();
    final isHindi = speechProvider.isHindi;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // Sacred Emblem & Blessing Badge
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.templeGold, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/simhastha_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.templeGradient,
                  ),
                  child: const Icon(
                    Icons.temple_hindu_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Invocation Heading
          const Text(
            '॥ हर हर महादेव ॥',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            isHindi
                ? 'सिंहस्थ 2028 डिजिटल मार्गदर्शक'
                : 'Simhastha 2028 Digital Margdarshak',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isHindi
                  ? 'उज्जैन दर्शन, भस्म आरती, शिप्रा स्नान, आश्रम व सात्विक भोजन के बारे में पूछें। 100% ऑफलाइन सक्रिय!'
                  : 'Your digital guide to sacred Ujjain. Tap any question below or ask in your own words via voice or text. Works 100% offline!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Section Title: Frequently Asked Questions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'अक्सर पूछे जाने वाले प्रश्न' : 'POPULAR QUESTIONS TO ASK',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.templeGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 11,
                      color: AppColors.devotional,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isHindi ? 'टैप करके पूछें' : 'Tap to ask',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.devotional,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Question 1: Mahakaleshwar & Bhasma Aarti
          _buildQuestionActionCard(
            emoji: '🕉️',
            categoryTag: isHindi ? 'भस्म आरती व दर्शन' : 'Bhasma Aarti & Darshan',
            question: isHindi
                ? 'महाकाल भस्म आरती कैसे बुक करें और दर्शन का समय क्या है?'
                : 'How do I book Mahakal Bhasma Aarti & what are darshan timings?',
            subtitle: isHindi
                ? 'सुबह 4:00 बजे आरती के नियम, ऑनलाइन स्लॉट, VIP दर्शन व गेट विवरण'
                : '4:00 AM booking rules, VIP protocol, gates & offline quota',
            prompt: isHindi
                ? 'महाकालेश्वर मंदिर में भस्म आरती बुकिंग के नियम और सामान्य दर्शन का समय क्या है?'
                : 'How can I book Bhasma Aarti at Mahakaleshwar temple and what are the daily darshan timings?',
            isHindi: isHindi,
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          // Question 2: Simhastha 2028 & Shahi Snan
          _buildQuestionActionCard(
            emoji: '🚩',
            categoryTag: isHindi ? 'सिंहस्थ 2028 कुंभ' : 'Simhastha 2028 Kumbh',
            question: isHindi
                ? 'सिंहस्थ 2028 में शाही स्नान की तिथियां और मुख्य घाट कौन से हैं?'
                : 'When are the Simhastha 2028 Shahi Snan dates & best ghats?',
            subtitle: isHindi
                ? 'राम घाट, दत्त अखाड़ा व शाही स्नान के शुभ मुहूर्त और अखाड़ा पेशवाई'
                : 'Auspicious dates, Ram Ghat holy dips & Akhara processions',
            prompt: isHindi
                ? 'सिंहस्थ 2028 में शाही स्नान की मुख्य तारीखें और स्नान के प्रमुख घाट कौन से हैं?'
                : 'What are the auspicious Shahi Snan dates and holy bathing ghats for Simhastha Kumbh 2028 in Ujjain?',
            isHindi: isHindi,
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          // Question 3: Dharamshalas & Stays
          _buildQuestionActionCard(
            emoji: '🏨',
            categoryTag: isHindi ? 'आश्रम व धर्मशालाएं' : 'Pilgrim Stays & Ashrams',
            question: isHindi
                ? 'महाकाल मंदिर के पास अच्छी धर्मशाला और ठहरने की व्यवस्था कहाँ है?'
                : 'Where can I find budget dharamshalas & stays near Mahakal?',
            subtitle: isHindi
                ? 'मंदिर के समीप स्वच्छ आश्रम, ट्रस्ट की धर्मशालाएं और बजट होटल'
                : 'Clean trust dharamshalas, ashrams & hotels within walking distance',
            prompt: isHindi
                ? 'महाकालेश्वर मंदिर के पास अच्छी और सस्ती धर्मशालाएं व होटल कौन से हैं?'
                : 'What are the best dharamshalas, ashrams, and budget hotels near Mahakaleshwar temple?',
            isHindi: isHindi,
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          // Question 4: Sattvic Food & Prasadam
          _buildQuestionActionCard(
            emoji: '🥘',
            categoryTag: isHindi ? 'सात्विक भोजन व प्रसादम' : 'Pure Food & Prasadam',
            question: isHindi
                ? 'उज्जैन का प्रसिद्ध पोहा, सात्विक भोजन और महाकाल प्रसादम कहाँ मिलेगा?'
                : 'Where to get authentic Ujjaini poha, sattvic food & prasad?',
            subtitle: isHindi
                ? 'टॉवर चौक का पोहा-जलेबी, सराफा नाइट फूड और मंदिर का शुद्ध लड्डू प्रसाद'
                : 'Tower Chowk breakfast, Sarafa Night Market & temple laddu prasad',
            prompt: isHindi
                ? 'उज्जैन का प्रसिद्ध सात्विक भोजन, पोहा-जलेबी और महाकाल मंदिर का लड्डू प्रसाद कहाँ मिलता है?'
                : 'Where can I get authentic Ujjaini poha, malpua, and Mahakal temple laddoo prasad?',
            isHindi: isHindi,
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          const SizedBox(height: 16),

          // Quick Prompt Question Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flash_on_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                isHindi ? 'त्वरित सवाल (Quick queries)' : 'More quick questions',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: isHindi
                ? [
                    _buildSuggestionChip('काल भैरव दर्शन समय?'),
                    _buildSuggestionChip('हरसिद्धि शक्तिपीठ दीपमालिका?'),
                    _buildSuggestionChip('मंगलनाथ भात पूजा?'),
                    _buildSuggestionChip('राम घाट संध्या आरती?'),
                  ]
                : [
                    _buildSuggestionChip('Kal Bhairav visit rules?'),
                    _buildSuggestionChip('Harsiddhi Deepmalika timing?'),
                    _buildSuggestionChip('Mangalnath Bhat Puja cost?'),
                    _buildSuggestionChip('Ram Ghat evening aarti?'),
                  ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuestionActionCard({
    required String emoji,
    required String categoryTag,
    required String question,
    required String subtitle,
    required String prompt,
    required Function(String) onTap,
    required bool isHindi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(prompt),
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Bar: Category Tag on left, "Ask AI ➔" pill on right
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryTag,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 11,
                            color: AppColors.templeGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isHindi ? 'पूछें' : 'Ask AI',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Question Body: Left Squircle Emoji + Question Text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF7ED),
                            Color(0xFFFFEDD5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.34,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      avatar: const Icon(
        Icons.chat_bubble_outline_rounded,
        size: 13,
        color: AppColors.primary,
      ),
      label: Text(text),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      onPressed: () {
        final chatProvider = context.read<ChatProvider>();
        _sendMessage(chatProvider, text, MessageType.text);
      },
      backgroundColor: Colors.white,
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.3),
        width: 1,
      ),
      elevation: 1,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Widget _buildScrollToBottomFab() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        if (_fabAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }
        return FadeTransition(
          opacity: _fabAnimation,
          child: ScaleTransition(
            scale: _fabAnimation,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _scrollToBottom,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendMessage(
    ChatProvider chatProvider,
    String content,
    MessageType type,
  ) {
    // If text-to-speech audio is playing, stop it so the user can interact freely
    final speechProvider = context.read<SpeechProvider>();
    if (speechProvider.isSpeaking) {
      speechProvider.stopSpeaking();
    }

    chatProvider.sendMessage(
      content,
      type: type,
      responseLanguage: speechProvider.responseLanguage,
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleMenuAction(String action) async {
    final chatProvider = context.read<ChatProvider>();

    switch (action) {
      case 'city_guide':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;

      case 'sessions':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ChatSessionsScreen()),
        );
        break;

      case 'new_chat':
        await chatProvider.createNewChatSession();
        break;

      case 'clear_current':
        if (chatProvider.currentSession != null) {
          final confirmed = await AppUtils.showConfirmDialog(
            context,
            title: 'Clear Current Pilgrimage Chat',
            content:
                'Are you sure you want to clear this conversation? Your session will be removed.',
            confirmText: 'Clear',
          );
          if (confirmed == true) {
            await chatProvider.deleteChatSession(
              chatProvider.currentSession!.id,
            );
          }
        }
        break;

      case 'offline_demo':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OfflineDemoScreen()),
        );
        break;

      case 'settings':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
    }
  }

  void _showConnectionStatus(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              chatProvider.isOnline ? Icons.bolt : Icons.temple_hindu,
              color: chatProvider.isOnline
                  ? AppColors.success
                  : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              chatProvider.isOnline
                  ? 'Online AI Connected'
                  : 'Offline Spiritual Mode',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${chatProvider.connectionStatus}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 10),
            if (chatProvider.isOnline)
              const Text(
                '✅ OpenAI GPT online connection is active with live assistance.',
              )
            else ...[
              const Text(
                '🕉️ You are operating in 100% Offline Spiritual Mode.',
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete Ujjain knowledge is loaded locally: Mahakaleshwar darshan & Bhasma Aarti, Kal Bhairav, Harsiddhi, Shipra Ghats, Simhastha 2028 schedule, 6+ hotels & stays, and pure vegetarian food guides.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (chatProvider.isOnline) {
                chatProvider.toggleOfflineMode();
              } else {
                chatProvider.refreshConnectivity();
              }
            },
            child: Text(
              chatProvider.isOnline
                  ? 'Force Offline Mode'
                  : 'Reconnect / Refresh',
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
