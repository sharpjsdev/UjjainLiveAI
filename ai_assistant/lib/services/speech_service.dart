import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import 'network_service.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  late stt.SpeechToText _speechToText;
  final FlutterTts _flutterTts = FlutterTts();
  final NetworkService _networkService = NetworkService();

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _cachedLocaleId;
  String? _lastError;

  String _lastRecognizedWords = '';
  Completer<String?>? _listeningCompleter;
  Timer? _silenceTimer;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;n
  String? get lastError => _lastError;
  String get lastRecognizedWords => _lastRecognizedWords;

  Future<bool> initialize() async {
    if (_isInitialized && _isAvailable) return true;

    try {
      _speechToText = stt.SpeechToText();

      debugLog('Initializing speech recognition...');

      _isAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );

      if (!_isAvailable) {
        debugLog('Speech recognition not available on this device');
        _isInitialized = true;
        return false;
      }

      debugLog('Speech to Text initialized successfully (available: true)');

      _cachedLocaleId = await _resolveBestLocale();
      await _initializeTts();

      _isInitialized = true;
      debugLog(
        'Speech service fully initialized with locale: $_cachedLocaleId',
      );
      return true;
    } catch (e) {
      debugLog('Initialization failed: $e');
      _isInitialized = false;
      _isAvailable = false;
      return false;
    }
  }

  Future<void> _initializeTts() async {
    try {
      // Get available TTS languages and pick the best one
      final languages = await _flutterTts.getLanguages;
      final langList = List<String>.from(languages ?? []);
      String ttsLang = AppConstants.speechLocaleId;

      if (langList.isNotEmpty && !langList.contains(ttsLang)) {
        // Try common alternatives in order of preference
        const candidates = ['en-IN', 'en_IN', 'en-US', 'en_US', 'en-GB'];
        String? found;
        for (final c in candidates) {
          if (langList.contains(c)) {
            found = c;
            break;
          }
        }
        ttsLang = found ?? langList.first;
      }

      await _flutterTts.setLanguage(ttsLang);
      await _flutterTts.setSpeechRate(AppConstants.speechRate);
      await _flutterTts.setPitch(AppConstants.speechPitch);
      await _flutterTts.setVolume(AppConstants.speechVolume);

      _flutterTts.setStartHandler(() {
        debugLog('TTS started');
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        debugLog('TTS completed');
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((error) {
        debugLog('TTS Error: $error');
        _isSpeaking = false;
      });

      debugLog('Text to Speech initialized (language: $ttsLang)');
    } catch (e) {
      debugLog('TTS initialization failed: $e');
    }
  }

  /// Picks the best available STT locale: en-IN > hi-IN > system > any English > first
  Future<String?> _resolveBestLocale() async {
    try {
      final locales = await _speechToText.locales();
      final systemLocale = await _speechToText.systemLocale();
      debugLog(
        'Available locales: ${locales.length}, System: ${systemLocale?.localeId}',
      );

      if (locales.isEmpty) {
        return systemLocale?.localeId ?? AppConstants.speechLocaleId;
      }

      // Build normalized map
      final Map<String, String> normalized = {};
      for (final loc in locales) {
        final key = loc.localeId.toLowerCase().replaceAll('-', '_');
        normalized[key] = loc.localeId;
      }

      // Priority 1: Indian English
      if (normalized.containsKey('en_in')) {
        debugLog('Using Indian English locale: ${normalized['en_in']}');
        return normalized['en_in'];
      }

      // Priority 2: Hindi
      if (normalized.containsKey('hi_in')) {
        debugLog('Using Hindi locale: ${normalized['hi_in']}');
        return normalized['hi_in'];
      }

      // Priority 3: System locale if supported
      if (systemLocale != null) {
        final sysKey = systemLocale.localeId.toLowerCase().replaceAll('-', '_');
        if (normalized.containsKey(sysKey)) {
          debugLog('Using system locale: ${systemLocale.localeId}');
          return systemLocale.localeId;
        }
      }

      // Priority 4: Any English locale
      for (final entry in normalized.entries) {
        if (entry.key.startsWith('en_')) {
          debugLog('Using English locale: ${entry.value}');
          return entry.value;
        }
      }

      // Priority 5: First available
      debugLog('Using first available locale: ${locales.first.localeId}');
      return locales.first.localeId;
    } catch (e) {
      debugLog('Locale resolution error: $e');
      return AppConstants.speechLocaleId;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      debugLog('Requesting microphone permission...');
      final microphoneStatus = await Permission.microphone.request();
      final granted = microphoneStatus == PermissionStatus.granted;
      debugLog('Microphone permission: $granted');
      return granted;
    } catch (e) {
      debugLog('Permission request failed: $e');
      return false;
    }
  }

  Future<String?> startListening({
    Function(String)? onPartialResult,
    Duration? timeout,
  }) async {
    try {
      debugLog('Starting voice listening...');

      // Ensure initialized
      if (!_isInitialized) {
        debugLog('Service not initialized, initializing now...');
        final initialized = await initialize();
        if (!initialized) {
          debugLog('Failed to initialize service');
          return null;
        }
      }

      await _networkService.initialize();

      // Stop any ongoing session
      if (_isListening || _speechToText.isListening) {
        debugLog('Already listening, stopping first...');
        await _speechToText.cancel();
        _isListening = false;
        await Future.delayed(const Duration(milliseconds: 250));
      }

      // Cancel any pending completion
      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
        _listeningCompleter!.complete(null);
      }

      _lastError = null;
      _lastRecognizedWords = '';
      _listeningCompleter = Completer<String?>();
      _isListening = true;

      final actualTimeout = timeout ?? AppConstants.speechTimeoutDuration;
      final targetLocale =
          _cachedLocaleId ??
          await _resolveBestLocale() ??
          AppConstants.speechLocaleId;

      debugLog(
        'Starting continuous voice capture without timer cutoff (locale: $targetLocale)',
      );

      // Internal helper to start listening with chosen configuration
      Future<bool> triggerListen({required bool onDevice}) async {
        try {
          final options = stt.SpeechListenOptions(
            listenFor: actualTimeout,
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            localeId: targetLocale,
            cancelOnError: false,
            listenMode: stt.ListenMode.dictation,
            onDevice: onDevice,
          );

          await _speechToText.listen(
            onResult: (result) {
              debugLog(
                'Result: "${result.recognizedWords}" (final: ${result.finalResult}, confidence: ${result.confidence})',
              );

              if (result.recognizedWords.trim().isNotEmpty) {
                _lastRecognizedWords = result.recognizedWords;
                // Notify partial results immediately
                if (!result.finalResult && onPartialResult != null) {
                  onPartialResult(_lastRecognizedWords);
                }
              }

              if (result.finalResult) {
                _isListening = false;
                _silenceTimer?.cancel();
                debugLog('Final result: $_lastRecognizedWords');
                _completeListening();
              }
            },
            listenOptions: options,
          );
          return true;
        } catch (e) {
          debugLog('triggerListen(onDevice=$onDevice) error: $e');
          return false;
        }
      }

      // With no internet, request on-device recognition first so the platform
      // does not try its network recognizer for the selected locale.
      final isOffline = !_networkService.hasInternetAccess;
      bool started;
      if (isOffline) {
        started = await triggerListen(onDevice: true);
      } else {
        started = await triggerListen(onDevice: false);

        // If the standard recognizer cannot start, try its on-device mode.
        if (!started &&
            _listeningCompleter != null &&
            !_listeningCompleter!.isCompleted) {
          debugLog(
            'Standard listen failed to start, trying fallback with onDevice: true...',
          );
          started = await triggerListen(onDevice: true);
        }
      }

      if (!started && _lastRecognizedWords.trim().isEmpty) {
        _isListening = false;
        _completeListening();
        return null;
      }

      debugLog('Listening started, waiting for result...');

      // Continuous listening completes on user pause, stop button, or submit
      final result = await _listeningCompleter!.future.timeout(
        actualTimeout,
        onTimeout: () async {
          debugLog('Continuous listen max duration reached');
          await stopListening();
          return _lastRecognizedWords.trim().isNotEmpty
              ? _lastRecognizedWords.trim()
              : null;
        },
      );

      debugLog('Returning result: "$result"');
      return result;
    } catch (e) {
      debugLog('Error during listening: $e');
      _lastError = e.toString();
      _isListening = false;
      _completeListening();
      return null;
    }
  }

  void _completeListening() {
    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      final words = _lastRecognizedWords.trim();
      _listeningCompleter!.complete(words.isNotEmpty ? words : null);
    }
  }

  Future<void> stopListening() async {
    try {
      debugLog('Stopping listening...');
      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_isListening || _speechToText.isListening) {
        await _speechToText.stop();
        _isListening = false;
        debugLog('Listening stopped');
      }
      _completeListening();
    } catch (e) {
      debugLog('Error stopping listening: $e');
      _isListening = false;
      _completeListening();
    }
  }

  Future<void> cancelListening() async {
    try {
      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_isListening || _speechToText.isListening) {
        await _speechToText.cancel();
        _isListening = false;
        debugLog('Listening cancelled');
      }
      if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
        _listeningCompleter!.complete(null);
      }
    } catch (e) {
      debugLog('Error cancelling listening: $e');
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    try {
      debugLog('Speaking: "$text"');

      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) return;
      }

      if (_isSpeaking) {
        await stopSpeaking();
      }

      if (text.trim().isNotEmpty) {
        await _flutterTts.speak(text);
        debugLog('Speaking started');
      }
    } catch (e) {
      debugLog('Error during speak: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        _isSpeaking = false;
        debugLog('Speaking stopped');
      }
    } catch (e) {
      debugLog('Error stopping speech: $e');
    }
  }

  Future<void> pauseSpeaking() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.pause();
        debugLog('Speaking paused');
      }
    } catch (e) {
      debugLog('Error pausing speech: $e');
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages ?? []);
    } catch (e) {
      debugLog('Error getting languages: $e');
      return [AppConstants.speechLocaleId];
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      final normalized = languageCode.replaceAll('_', '-');
      final languagePrefix = normalized.split('-').first.toLowerCase();

      if (_isAvailable) {
        final locales = await _speechToText.locales();
        final matches = locales
            .where(
              (locale) =>
                  locale.localeId.toLowerCase().startsWith(
                    '$languagePrefix-',
                  ) ||
                  locale.localeId.toLowerCase().startsWith(
                    '${languagePrefix}_',
                  ),
            )
            .toList();
        matches.sort((a, b) {
          final aIndia = a.localeId
              .toLowerCase()
              .replaceAll('_', '-')
              .endsWith('-in');
          final bIndia = b.localeId
              .toLowerCase()
              .replaceAll('_', '-')
              .endsWith('-in');
          return (bIndia ? 1 : 0).compareTo(aIndia ? 1 : 0);
        });
        _cachedLocaleId = matches.isNotEmpty
            ? matches.first.localeId
            : normalized;
      } else {
        _cachedLocaleId = normalized;
      }

      final ttsLanguages = List<String>.from(
        await _flutterTts.getLanguages ?? [],
      );
      final ttsMatches = ttsLanguages.where((locale) {
        final normalizedLocale = locale.toLowerCase().replaceAll('_', '-');
        return normalizedLocale == languagePrefix ||
            normalizedLocale.startsWith('$languagePrefix-');
      }).toList();
      ttsMatches.sort((a, b) {
        final aIndia = a.toLowerCase().replaceAll('_', '-').endsWith('-in');
        final bIndia = b.toLowerCase().replaceAll('_', '-').endsWith('-in');
        return (bIndia ? 1 : 0).compareTo(aIndia ? 1 : 0);
      });
      final ttsLocale = ttsMatches.isNotEmpty ? ttsMatches.first : normalized;
      await _flutterTts.setLanguage(ttsLocale);
      debugLog(
        'Language set to: $normalized (STT: $_cachedLocaleId, TTS: $ttsLocale)',
      );
    } catch (e) {
      debugLog('Error setting language: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      debugLog('Speech rate set to: $rate');
    } catch (e) {
      debugLog('Error setting speech rate: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      debugLog('Pitch set to: $pitch');
    } catch (e) {
      debugLog('Error setting pitch: $e');
    }
  }

  void _onSpeechStatus(String status) {
    debugLog('Speech status: $status');

    switch (status) {
      case 'done':
        _isListening = false;
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(milliseconds: 300), () {
          _completeListening();
        });
        break;

      case 'notListening':
        _isListening = false;
        // Only finalize on notListening if words were already captured
        // Do NOT finalize if words are empty (wait for user or 'done' status)
        if (_lastRecognizedWords.trim().isNotEmpty) {
          _silenceTimer?.cancel();
          _silenceTimer = Timer(const Duration(milliseconds: 500), () {
            _completeListening();
          });
        }
        break;

      case 'listening':
        _isListening = true;
        _silenceTimer?.cancel();
        break;
    }
  }

  void _onSpeechError(dynamic error) {
    debugLog('Speech error: $error');
    String? errorMsg;
    if (error is SpeechRecognitionError) {
      errorMsg = error.errorMsg;
    } else {
      errorMsg = error?.toString();
    }
    _lastError = errorMsg;

    // Never lose recognized words due to an error at the end of speech
    if (_lastRecognizedWords.trim().isNotEmpty) {
      debugLog(
        'Error received but words were captured: "$_lastRecognizedWords"',
      );
      _isListening = false;
      _silenceTimer?.cancel();
      _completeListening();
      return;
    }

    final lower = (errorMsg ?? '').toLowerCase();
    // Non-fatal transient pause/silence errors: allow user a brief window to speak
    if (lower.contains('no_match') || lower.contains('speech_timeout')) {
      debugLog(
        'Transient speech silence ($errorMsg), waiting for speech or natural completion',
      );
      _silenceTimer?.cancel();
      _silenceTimer = Timer(const Duration(milliseconds: 600), () {
        _isListening = false;
        _completeListening();
      });
      return;
    }

    _isListening = false;
    _silenceTimer?.cancel();
    _completeListening();
  }

  void dispose() {
    _silenceTimer?.cancel();
    stopListening();
    stopSpeaking();
  }

  void debugLog(String message) {
    // ignore: avoid_print
    print('[SpeechService] $message');
  }
}
