class AppConstants {
  // API Configuration
  static const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String placesApiUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Backend Configuration for Simhastha Services
  // For local development (emulator): http://10.0.2.2:3000
  // For local development (same WiFi): http://192.168.x.x:3000
  // For ngrok testing on physical phone: https://your-ngrok-url.ngrok-free.app
  // For production: https://your-production-url.com
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://6434-183-87-13-226.ngrok-free.app', // ✅ Updated with your ngrok URL
  );
  
  // API Keys (supports both OpenAI 'sk-...' and OpenRouter 'sk-or-...')
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String googleApiKey = '';
  
  // Auto-detect online vs offline: if API key is empty, use offline mode only
  static bool get useOnlineMode => openAiApiKey.isNotEmpty;
  static bool get isGemini => openAiApiKey.trim().startsWith('AQ.') || openAiApiKey.trim().startsWith('AIza');
  static bool get isOpenRouter => openAiApiKey.trim().startsWith('sk-or-');
  static String get geminiApiBaseUrl => 'https://generativelanguage.googleapis.com/v1beta/models';
  static String get apiUrl => isGemini ? geminiApiBaseUrl : (isOpenRouter ? openRouterApiUrl : openAiApiUrl);
  
  // App Configuration - Ujjain Live
  static const String appName = 'Ujjain Live';
  static const String appTagline = 'Your Digital Guide to Sacred Ujjain';
  static const int maxMessageLength = 4000;
  static const int maxConversationHistory = 25; // Increased for pilgrimage context
  static const Duration speechTimeoutDuration = Duration(minutes: 30); // Continuous voice capture without timer cutoff
  static const Duration responseTimeoutDuration = Duration(seconds: 30);
  
  // Storage Keys
  static const String chatSessionsKey = 'simhastha_chat_sessions';
  static const String userPreferencesKey = 'pilgrim_preferences';
  static const String locationPermissionKey = 'ujjain_location_permission';
  static const String speechPermissionKey = 'spiritual_speech_permission';
  
  // UI Configuration - Spiritual theme
  static const double messageBubbleRadius = 18.0; // Slightly rounded for warmth
  static const double fabSize = 60.0; // Larger for easier temple use
  static const double avatarSize = 36.0; // Bigger for spiritual imagery
  
  // Speech Configuration - Spiritual context

  static const String speechLocaleId = 'hi-IN'; // Hindi as the first-run voice language

  static const double speechRate = 0.45; // Slower for spiritual content
  static const double speechPitch = 1.0;
  static const double speechVolume = 0.85; // Slightly louder for temple environments
  
  // Location Configuration - Ujjain specific
  static const double ujjainLatitude = 23.1827; // Mahakaleshwar temple latitude
  static const double ujjainLongitude = 75.7682; // Mahakaleshwar temple longitude
  static const double locationAccuracyMeters = 50.0; // Higher accuracy for temple locations
  static const Duration locationTimeoutDuration = Duration(seconds: 20);
  static const int nearbySearchRadius = 2000; // 2km radius for Ujjain city size
  
  // Simhastha specific constants
  static const String primaryDeity = 'Lord Mahakaleshwar';
  static const String sacredRiver = 'Shipra';
  static const String holyCity = 'Ujjain';
  static const int simhasthaInterval = 12; // Every 12 years
  static const String nextSimhastha = '2028';
  
  // Temple timings
  static const String bhasmaArtiTime = '4:00 AM';
  static const String regularDarshanStart = '6:00 AM';
  static const String regularDarshanEnd = '11:00 PM';
  
  // Error Messages - Spiritual context
  static const String genericErrorMessage = 'Something went wrong in your spiritual journey. Let\'s try again with divine blessings.';
  static const String networkErrorMessage = 'Please check your connection to continue your digital pilgrimage.';
  static const String speechErrorMessage = 'The divine voice recognition needs another try. Please speak again.';
  static const String locationErrorMessage = 'Location access helps us guide you better in Ujjain. Please enable location services.';
  static const String permissionDeniedMessage = 'We need your permission to serve you better on this spiritual journey.';
  
  // Welcome messages
  static const String welcomeMessage = 'Welcome to your Simhastha digital companion!';
  static const String spiritualGreeting = 'Har Har Mahadev! How can I assist your pilgrimage today?';
  
  // Common spiritual phrases
  static const List<String> spiritualGreetings = [
    'Namaste',
    'Har Har Mahadev',
    'Om Namah Shivaya',
    'Jai Mahakal',
    'Divine Blessings'
  ];
  
  // Pilgrimage tips
  static const List<String> pilgrimTips = [
    'Visit Mahakaleshwar early morning for peaceful darshan',
    'Book Bhasma Aarti tickets in advance',
    'Carry minimal luggage during temple visits',
    'Respect local customs and traditions',
    'Stay hydrated and eat sattvic food',
    'Follow crowd management guidelines during Simhastha'
  ];
}
