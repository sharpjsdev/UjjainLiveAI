import 'dart:async';
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

  // Continuous listening state: accumulate across speech segments until explicitly stopped
  String _accumulatedWords = '';
  String _currentSegmentWords = '';
  bool _userExplicitlyStopped = false;
  Function(String)? _activePartialCallback;
  String? _currentTargetLocale;
  bool _useOnDevice = false;

  // TTS callbacks
  void Function()? onTtsStart;
  void Function()? onTtsComplete;
  void Function()? onTtsError;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
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
        onTtsStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        debugLog('TTS completed');
        _isSpeaking = false;
        onTtsComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        debugLog('TTS cancelled');
        _isSpeaking = false;
        onTtsComplete?.call();
      });

      _flutterTts.setErrorHandler((error) {
        debugLog('TTS Error: $error');
        _isSpeaking = false;
        onTtsError?.call();
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
      debugLog('Starting continuous voice listening (never stops until user clicks stop/submit)...');

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

      // Stop any prior active listening session cleanly
      _userExplicitlyStopped = true;
      if (_isListening || _speechToText.isListening) {
        debugLog('Already listening, stopping prior session...');
        await _speechToText.cancel();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
        _listeningCompleter!.complete(null);
      }

      // Reset state for new continuous listening session
      _userExplicitlyStopped = false;
      _lastError = null;
      _lastRecognizedWords = '';
      _accumulatedWords = '';
      _currentSegmentWords = '';
      _activePartialCallback = onPartialResult;
      _listeningCompleter = Completer<String?>();
      _isListening = true;

      final targetLocale =
          _cachedLocaleId ??
          await _resolveBestLocale() ??
          AppConstants.speechLocaleId;
      _currentTargetLocale = targetLocale;

      final isOffline = !_networkService.hasInternetAccess;
      _useOnDevice = isOffline;

      debugLog(
        'Launching persistent continuous session: locale=$targetLocale, onDevice=$_useOnDevice',
      );

      final started = await _launchUnderlyingListen();
      if (!started && !_useOnDevice && !isOffline) {
        // Try fallback to onDevice
        _useOnDevice = true;
        await _launchUnderlyingListen();
      }

      // Wait until user explicitly stops via stopListening() / cancelListening()
      final result = await _listeningCompleter!.future;
      debugLog('Continuous listening completed with final result: "$result"');
      return result;
    } catch (e) {
      debugLog('Error during startListening: $e');
      _lastError = e.toString();
      _isListening = false;
      _finishListening();
      return null;
    }
  }

  /// Internal: Starts or restarts the native SpeechToText engine without closing the user session
  Future<bool> _launchUnderlyingListen() async {
    if (_userExplicitlyStopped) return false;

    try {
      final options = stt.SpeechListenOptions(
        listenFor: const Duration(minutes: 30), // Long session window
        pauseFor: const Duration(seconds: 15), // Do not cut off on pause/breath
        partialResults: true,
        localeId: _currentTargetLocale,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        onDevice: _useOnDevice,
      );

      await _speechToText.listen(
        onResult: (result) {
          if (_userExplicitlyStopped) return;

          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            _currentSegmentWords = words;
            _notifyCurrentFullText();
          }

          if (result.finalResult) {
            debugLog('Segment final result received: "$words"');
            if (words.isNotEmpty) {
              if (_accumulatedWords.isEmpty) {
                _accumulatedWords = words;
              } else if (!_accumulatedWords.endsWith(words)) {
                _accumulatedWords = '$_accumulatedWords $words';
              }
              _currentSegmentWords = '';
              _notifyCurrentFullText();
            }

            // DO NOT stop listening! If native recognizer wrapped up the segment,
            // immediately restart to keep mic open for the next sentence.
            if (!_userExplicitlyStopped) {
              _scheduleAutoRestart(100);
            }
          }
        },
        listenOptions: options,
      );
      _isListening = true;
      return true;
    } catch (e) {
      debugLog('Native listen launch error: $e');
      return false;
    }
  }

  void _notifyCurrentFullText() {
    final full = _getFullTranscribedText();
    _lastRecognizedWords = full;
    if (_activePartialCallback != null && full.isNotEmpty) {
      _activePartialCallback!(full);
    }
  }

  String _getFullTranscribedText() {
    final acc = _accumulatedWords.trim();
    final seg = _currentSegmentWords.trim();
    if (acc.isEmpty) return seg;
    if (seg.isEmpty) return acc;
    if (acc.endsWith(seg)) return acc;
    return '$acc $seg';
  }

  void _scheduleAutoRestart([int delayMs = 250]) {
    if (_userExplicitlyStopped) return;
    _silenceTimer?.cancel();
    _silenceTimer = Timer(Duration(milliseconds: delayMs), () async {
      if (_userExplicitlyStopped) return;
      debugLog('Auto-restarting native STT to keep listening continuously...');
      try {
        if (!_speechToText.isListening) {
          await _launchUnderlyingListen();
        }
      } catch (e) {
        debugLog('Error in auto-restart: $e');
      }
    });
  }

  void _finishListening() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _isListening = false;
    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      final finalWords = _getFullTranscribedText().trim();
      _listeningCompleter!.complete(finalWords.isNotEmpty ? finalWords : null);
    }
  }

  /// USER ACTION: Called ONLY when user taps Stop Mic or Submits the message
  Future<void> stopListening() async {
    try {
      debugLog('User initiated stopListening()...');
      _userExplicitlyStopped = true;
      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      _isListening = false;
      _finishListening();
    } catch (e) {
      debugLog('Error stopping listening: $e');
      _userExplicitlyStopped = true;
      _isListening = false;
      _finishListening();
    }
  }

  /// USER ACTION: Cancel and discard listening
  Future<void> cancelListening() async {
    try {
      debugLog('User cancelled listening...');
      _userExplicitlyStopped = true;
      _silenceTimer?.cancel();
      _silenceTimer = null;
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
      _isListening = false;
      _accumulatedWords = '';
      _currentSegmentWords = '';
      if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
        _listeningCompleter!.complete(null);
      }
    } catch (e) {
      debugLog('Error cancelling listening: $e');
      _userExplicitlyStopped = true;
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
        onTtsComplete?.call();
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
      case 'notListening':
        // If the user has NOT clicked stop/submit, keep listening by auto-restarting
        if (!_userExplicitlyStopped && _isListening) {
          debugLog('Native status is "$status" but user has not clicked stop -> auto-restarting listen session');
          _scheduleAutoRestart(150);
        } else {
          _isListening = false;
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

    // If user explicitly stopped, wrap up
    if (_userExplicitlyStopped) {
      _finishListening();
      return;
    }

    final lower = (errorMsg ?? '').toLowerCase();
    // Common non-fatal pauses/silences on Android (e.g. error_speech_timeout, error_no_match)
    // NEVER stop listening on these â automatically restart the native engine!
    if (lower.contains('no_match') ||
        lower.contains('speech_timeout') ||
        lower.contains('error_no_match') ||
        lower.contains('error_speech_timeout')) {
      debugLog('Speech pause/silence timeout ($errorMsg) -> restarting native listener to stay active');
      _scheduleAutoRestart(200);
      return;
    }

    // On busy or other transient errors, retry restarting unless user explicitly clicked stop
    if (lower.contains('busy') || lower.contains('client')) {
      debugLog('Transient engine error ($errorMsg) -> restarting native listener');
      _scheduleAutoRestart(300);
      return;
    }

    // For any other unexpected error, attempt auto-restart so the user's mic stays alive
    debugLog('Encountered error ($errorMsg), auto-restarting native session');
    _scheduleAutoRestart(350);
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
