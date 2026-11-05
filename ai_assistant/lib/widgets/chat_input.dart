import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/speech_provider.dart';
import '../constants/app_constants.dart';
import '../services/network_service.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String) onSendVoiceMessage;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _micAnimationController;
  late Animation<double> _micScaleAnimation;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  bool _isListening = false;
  String _currentSpeechText = '';
  String _baseSpeechText = '';

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _micScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _micAnimationController,
      curve: Curves.easeOutBack,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _micAnimationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isListening)
                  _buildListeningIndicator(),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextInput(),
                    ),
                    const SizedBox(width: 8),
                    _buildMicButton(speechProvider),
                    const SizedBox(width: 8),
                    _buildSendButton(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundWaves() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final t = _waveController.value * 2 * math.pi;
              final phase = index * 0.8;
              final sine = (math.sin(t + phase) + 1.0) / 2.0;
              final height = 6.0 + (sine * 18.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3.5,
                height: height,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB300),
                      Color(0xFFFF3D00),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildListeningIndicator() {
    final hasPartial = _currentSpeechText.trim().isNotEmpty;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.devotional.withValues(
              alpha: 0.08 + (_pulseController.value * 0.04),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.devotional.withValues(
                alpha: 0.35 + (_pulseController.value * 0.25),
              ),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              _buildSoundWaves(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasPartial ? _currentSpeechText : 'Listening... Speak your question',
                      style: TextStyle(
                        color: hasPartial
                            ? AppColors.textPrimary
                            : AppColors.devotional,
                        fontSize: 14,
                        fontWeight: hasPartial ? FontWeight.w600 : FontWeight.w500,
                        fontStyle: hasPartial ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Capturing voice to text — pause speaking or tap Send (➤) when done.',
                      style: TextStyle(
                        color: AppColors.devotional.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _cancelListening,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.devotional.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.devotional,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      maxLines: null,
      maxLength: AppConstants.maxMessageLength,
      textInputAction: TextInputAction.send,
      style: const TextStyle(
        fontSize: 14.5,
        color: AppColors.textPrimary,
      ),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Ask about Mahakal, Stays, Snan, Food...',
        hintStyle: TextStyle(
          color: AppColors.textLight.withValues(alpha: 0.8),
          fontSize: 13.5,
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.inputFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
      ),
      onSubmitted: _sendTextMessage,
    );
  }

  Widget _buildMicButton(SpeechProvider speechProvider) {
    return AnimatedBuilder(
      animation: _micScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _micScaleAnimation.value,
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: _isListening 
                  ? const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? AppColors.devotional : AppColors.primary)
                      .withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: widget.enabled ? () => _toggleListening(speechProvider) : null,
              padding: EdgeInsets.zero,
              icon: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 22,
              ),
              tooltip: _isListening ? 'Stop Microphone' : 'Voice Input',
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    final hasText = _textController.text.trim().isNotEmpty;
    
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        gradient: hasText && widget.enabled ? AppColors.primaryGradient : null,
        color: hasText && widget.enabled ? null : AppColors.divider,
        borderRadius: BorderRadius.circular(22),
        boxShadow: hasText && widget.enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: hasText && widget.enabled ? () => _sendTextMessage(_textController.text) : null,
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.send_rounded,
          color: hasText && widget.enabled ? Colors.white : AppColors.textLight,
          size: 20,
        ),
        tooltip: 'Send Message',
      ),
    );
  }

  void _sendTextMessage(String text) async {
    if (_isListening) {
      final speechProvider = context.read<SpeechProvider>();
      await speechProvider.stopListening().catchError((_) => null);
      await _cleanupListening();
    }
    if (text.trim().isNotEmpty && widget.enabled) {
      widget.onSendMessage(text.trim());
      _textController.clear();
      _focusNode.unfocus();
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleListening(SpeechProvider speechProvider) async {
    if (_isListening) {
      // User tapped mic while active: cleanly stop mic without auto-sending
      await speechProvider.stopListening().catchError((_) => null);
      await _cleanupListening();
      if (mounted) setState(() {});
    } else {
      await _startListening(speechProvider);
    }
  }

  Future<void> _startListening(SpeechProvider speechProvider) async {
    // Stop any ongoing TTS playback first to prevent audio clash
    if (speechProvider.isSpeaking) {
      await speechProvider.stopSpeaking();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!speechProvider.hasPermission) {
      await speechProvider.requestPermissions();
      if (!speechProvider.hasPermission) {
        _showPermissionError();
        return;
      }
    }

    if (!mounted) return;

    // Capture existing text as base so any new speech appends seamlessly
    _baseSpeechText = _textController.text.trim();

    setState(() {
      _isListening = true;
      _currentSpeechText = _baseSpeechText;
    });

    _micAnimationController.forward();
    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    final listenStartTime = DateTime.now();
    String? result;
    try {
      result = await speechProvider.startListening(
        timeout: AppConstants.speechTimeoutDuration,
        onPartialResult: (text) {
          if (mounted && text.trim().isNotEmpty) {
            final textTrimmed = text.trim();
            final combined = _baseSpeechText.isEmpty
                ? textTrimmed
                : '$_baseSpeechText $textTrimmed';
            setState(() {
              _currentSpeechText = combined;
              _textController.text = combined;
              _textController.selection =
                  TextSelection.collapsed(offset: combined.length);
            });
          }
        },
      );
    } catch (e) {
      result = null;
    }

    if (!mounted) return;

    final elapsed = DateTime.now().difference(listenStartTime);

    // If result arrived on pause or stop, ensure text field has the complete text
    if (result != null && result.trim().isNotEmpty) {
      final textTrimmed = result.trim();
      final combined = _baseSpeechText.isEmpty
          ? textTrimmed
          : '$_baseSpeechText $textTrimmed';
      _textController.text = combined;
      _textController.selection =
          TextSelection.collapsed(offset: combined.length);
      _currentSpeechText = combined;
    }

    // ═════════════════════════════════════════════════════════════════
    // WORKFLOW RULE:
    // When user pauses for 1–2 seconds:
    // - Preserve transcript in _textController!
    // - Do NOT submit to AI!
    // - Do NOT clear previous words!
    // - Microphone turns off, ready for user to continue speaking or click Submit.
    // ═════════════════════════════════════════════════════════════════
    if (_textController.text.trim().isEmpty && _isListening) {
      _handleSpeechFailure(speechProvider, elapsed);
    }

    await _cleanupListening();
    if (mounted) setState(() {});
  }

  Future<void> _cancelListening() async {
    final speechProvider = context.read<SpeechProvider>();
    await speechProvider.cancelListening();
    await _cleanupListening();
    if (mounted) setState(() {});
  }

  void _handleSpeechFailure(SpeechProvider speechProvider, Duration elapsed) {
    final lastError = speechProvider.lastSpeechError?.toLowerCase();
    final networkService = NetworkService();
    final isOffline = !networkService.isConnected || !networkService.hasInternetAccess;

    if (lastError != null) {
      if (lastError.contains('permission')) {
        _showPermissionError();
        return;
      }

      if (lastError.contains('network') || lastError.contains('server')) {
        if (isOffline) {
          _showSpeechError(
            'Offline voice recognition needs offline speech data in Google Voice Typing settings.',
            actionLabel: 'Retry',
            onAction: () {
              final sp = context.read<SpeechProvider>();
              _startListening(sp);
            },
          );
        } else {
          _showSpeechError(
            'Voice connection failed. Please check internet connection or type your message.',
            actionLabel: 'Retry',
            onAction: () {
              final sp = context.read<SpeechProvider>();
              _startListening(sp);
            },
          );
        }
        return;
      }

      if (lastError.contains('language')) {
        _showSpeechError(
          'Your device has no offline speech data for '
          '${speechProvider.isHindi ? 'Hindi' : 'English'}. Download the language '
          'in your device speech recognition settings, then retry or type your message.',
          actionLabel: 'Retry',
          onAction: () {
            final sp = context.read<SpeechProvider>();
            _startListening(sp);
          },
        );
        return;
      }

      if (lastError.contains('no_match') || lastError.contains('speech_timeout')) {
        _showSpeechError(
          'No speech detected. Please speak clearly into the microphone.',
          actionLabel: 'Retry',
          onAction: () {
            final sp = context.read<SpeechProvider>();
            _startListening(sp);
          },
        );
        return;
      }

      if (lastError.contains('busy')) {
        _showSpeechError(
          'Speech recognizer is busy. Please try again.',
          actionLabel: 'Retry',
          onAction: () {
            final sp = context.read<SpeechProvider>();
            _startListening(sp);
          },
        );
        return;
      }
    }

    if (elapsed.inMilliseconds < 1000) {
      _showSpeechError(
        'Could not capture audio. Please tap mic and speak clearly.',
        actionLabel: 'Retry',
        onAction: () {
          final sp = context.read<SpeechProvider>();
          _startListening(sp);
        },
      );
    } else {
      _showSpeechError(
        'No speech detected. Please speak clearly into the microphone.',
        actionLabel: 'Retry',
        onAction: () {
          final sp = context.read<SpeechProvider>();
          _startListening(sp);
        },
      );
    }
  }

  Future<void> _cleanupListening() async {
    if (mounted) {
      setState(() {
        _isListening = false;
        _currentSpeechText = '';
      });
    }
    _micAnimationController.reverse();
    _pulseController.stop();
    _waveController.stop();
  }

  void _showPermissionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.mic_off, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Microphone permission required for voice input')),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSpeechError(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic_none, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.devotional.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: actionLabel ?? 'Retry',
          textColor: AppColors.accent,
          onPressed: onAction ?? () {
            if (mounted) {
              final sp = context.read<SpeechProvider>();
              _startListening(sp);
            }
          },
        ),
      ),
    );
  }
}
