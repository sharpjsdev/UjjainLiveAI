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
      toolbarHeight: 72,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      ),
      elevation: 2,
      shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ujjain Live',
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Consumer<SpeechProvider>(
                  builder: (context, speechProvider, child) {
                    return SizedBox(
                      height: 28,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: speechProvider.isHindi ? 'hi' : 'en',
                          isDense: true,
                          dropdownColor: AppColors.primaryDark,
                          icon: const Icon(
                            Icons.expand_more,
                            color: Colors.white70,
                            size: 16,
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
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
        // Network status pill badge
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final isOnline = chatProvider.isOnline;
            return GestureDetector(
              onTap: () => _showConnectionStatus(context, chatProvider),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.shade800.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOnline ? Colors.white : AppColors.goldLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.bolt : Icons.temple_hindu,
                      color: isOnline ? Colors.white : AppColors.templeGold,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
              icon: Icon(
                hasLoc ? Icons.location_on : Icons.location_off_outlined,
                color: hasLoc
                    ? AppColors.templeGold
                    : Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              onPressed: () => chatProvider.refreshLocation(),
              tooltip: hasLoc
                  ? 'Location: ${chatProvider.currentLocation!.city ?? "Ujjain"}'
                  : 'Detect location in Ujjain',
            );
          },
        ),

        // Overflow Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (context) => [
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

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

          const SizedBox(height: 14),

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

          const Text(
            'Simhastha 2028 Digital Margdarshak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your digital guide to sacred Ujjain. Ask questions about Bhasma Aarti timings, Shipra snan, dharamshalas, pure food, or Simhastha events. Works 100% offline!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Four Interactive Simhastha Pilgrimage Cards
          _buildSpiritualActionCard(
            emoji: '🕉️',
            title: 'Mahakaleshwar & Bhasma Aarti',
            subtitle:
                'Darshan timings, Aarti booking rules & sacred ash ritual',
            prompt:
                'Tell me about Mahakaleshwar temple timings and how to attend Bhasma Aarti',
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          const SizedBox(height: 10),

          _buildSpiritualActionCard(
            emoji: '🚩',
            title: 'Simhastha 2028 & Shahi Snan',
            subtitle:
                'Auspicious dates, Ram Ghat holy dips & Akhara processions',
            prompt:
                'When is Simhastha Kumbh Mela 2028 and what are the holy bathing dates?',
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          const SizedBox(height: 10),

          _buildSpiritualActionCard(
            emoji: '🏨',
            title: 'Dharamshalas & Pilgrim Stays',
            subtitle: 'Budget & luxury accommodation near Mahakal temple',
            prompt:
                'Best hotels and dharamshalas near Mahakaleshwar temple in Ujjain',
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          const SizedBox(height: 10),

          _buildSpiritualActionCard(
            emoji: '🥘',
            title: 'Sattvic Food & Prasadam',
            subtitle: 'Authentic Ujjaini Poha, Malpua & pure veg restaurants',
            prompt:
                'Best pure vegetarian restaurants and temple prasadam in Ujjain',
            onTap: (query) =>
                _sendMessage(chatProvider, query, MessageType.text),
          ),

          const SizedBox(height: 20),

          // Quick prompt chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Temple circuit order'),
              _buildSuggestionChip('Kal Bhairav timing'),
              _buildSuggestionChip('Harsiddhi Mata Shakti Peeth'),
              _buildSuggestionChip('Budget stay prices'),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSpiritualActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String prompt,
    required Function(String) onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(prompt),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
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
    chatProvider.sendMessage(
      content,
      type: type,
      responseLanguage: context.read<SpeechProvider>().responseLanguage,
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
