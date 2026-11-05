import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';

class SpeechProvider with ChangeNotifier {
  final SpeechService _speechService = SpeechService();
  final StorageService _storageService = StorageService();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _hasPermission = false;
  String _currentSpeechText = '';
  String? _error;

  // Voice settings
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  double _speechVolume = 0.8;
  String _selectedLanguage = 'hi-IN';
  List<String> _availableLanguages = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get hasPermission => _hasPermission;
  String get currentSpeechText => _currentSpeechText;
  String get lastRecognizedWords => _currentSpeechText.isNotEmpty
      ? _currentSpeechText
      : _speechService.lastRecognizedWords;
  String? get error => _error;
  String? get lastSpeechError => _speechService.lastError;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get speechVolume => _speechVolume;
  String get selectedLanguage => _selectedLanguage;
  List<String> get availableLanguages => _availableLanguages;
  String get responseLanguage => isHindi ? 'hi' : 'en';

  /// Returns true when the active voice language is Hindi (hi-IN / hi_IN)
  bool get isHindi {
    final lang = _selectedLanguage.toLowerCase().replaceAll('-', '_');
    return lang.startsWith('hi');
  }

  /// Toggles voice language between Hindi (hi-IN) and English (en-IN)
  Future<void> toggleLanguage() async {
    final nextLang = isHindi ? 'en-IN' : 'hi-IN';
    _selectedLanguage = nextLang;
    await _speechService.setLanguage(nextLang);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      _clearError();

      // Initialize speech service
      _isInitialized = await _speechService.initialize();
      _availableLanguages = await _speechService.getAvailableLanguages();

      // Load the shared response and voice language even when speech
      // recognition is unavailable on this device.
      await _loadSettings();

      if (_isInitialized) {
        // Check permissions
        _hasPermission = await _speechService.requestPermissions();
        await _storageService.setSpeechPermissionGranted(_hasPermission);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize speech service: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await _storageService.getUserPreferences();

      _speechRate = preferences['speechRate']?.toDouble() ?? 0.5;
      _speechPitch = preferences['speechPitch']?.toDouble() ?? 1.0;
      _speechVolume = preferences['speechVolume']?.toDouble() ?? 0.8;
      final savedLanguage =
          preferences['selectedLanguage']?.toString() ?? 'hi-IN';
      _selectedLanguage = savedLanguage.toLowerCase().startsWith('hi')
          ? 'hi-IN'
          : 'en-IN';

      // Apply settings to speech service
      await _speechService.setSpeechRate(_speechRate);
      await _speechService.setPitch(_speechPitch);
      await _speechService.setLanguage(_selectedLanguage);

      notifyListeners();
    } catch (e) {
      print('Error loading speech settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final preferences = await _storageService.getUserPreferences();
      preferences.addAll({
        'speechRate': _speechRate,
        'speechPitch': _speechPitch,
        'speechVolume': _speechVolume,
        'selectedLanguage': _selectedLanguage,
      });
      await _storageService.saveUserPreferences(preferences);
    } catch (e) {
      print('Error saving speech settings: $e');
    }
  }

  Future<String?> startListening({
    Duration? timeout,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_hasPermission) {
      _hasPermission = await _speechService.requestPermissions();
      if (!_hasPermission) {
        _setError('Microphone permission is required for voice input');
        return null;
      }
      await _storageService.setSpeechPermissionGranted(_hasPermission);
    }

    try {
      _clearError();
      _isListening = true;
      _currentSpeechText = '';
      notifyListeners();

      final result = await _speechService.startListening(
        timeout: timeout,
        onPartialResult: (text) {
          _currentSpeechText = text;
          notifyListeners();
          onPartialResult?.call(text);
        },
      );

      _isListening = false;
      if (result != null) {
        _currentSpeechText = result;
      }
      if (_speechService.lastError != null) {
        _setError(_speechService.lastError!);
      }
      notifyListeners();

      return result;
    } catch (e) {
      _isListening = false;
      _setError('Speech recognition failed: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechService.cancelListening();
      _isListening = false;
      _currentSpeechText = '';
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.trim().isEmpty) return;

    try {
      _clearError();
      _isSpeaking = true;
      notifyListeners();

      await _speechService.speak(text);

      // Note: _isSpeaking will be set to false by the TTS completion handler
      // We don't set it here because speech might still be ongoing
    } catch (e) {
      _isSpeaking = false;
      _setError('Text-to-speech failed: $e');
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _speechService.stopSpeaking();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> pauseSpeaking() async {
    if (_isSpeaking) {
      await _speechService.pauseSpeaking();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 2.0);
    await _speechService.setSpeechRate(_speechRate);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch.clamp(0.5, 2.0);
    await _speechService.setPitch(_speechPitch);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final normalized = languageCode.toLowerCase();
    _selectedLanguage = normalized == 'hi' || normalized.startsWith('hi-')
        ? 'hi-IN'
        : 'en-IN';
    await _speechService.setLanguage(_selectedLanguage);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    try {
      _hasPermission = await _speechService.requestPermissions();
      await _storageService.setSpeechPermissionGranted(_hasPermission);
      notifyListeners();

      if (!_hasPermission) {
        _setError('Microphone permission is required for voice features');
      }
    } catch (e) {
      _setError('Failed to request permissions: $e');
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Update speaking state (called by speech service)
  void setSpeakingState(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
