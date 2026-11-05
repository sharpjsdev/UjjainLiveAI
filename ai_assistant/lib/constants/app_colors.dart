import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Radiant Kesariya & Saffron for Simhastha
  static const Color primary = Color(0xFFFF7A00); // Radiant Saffron Kesariya
  static const Color primaryDark = Color(0xFFD85300); // Deep Vedic Saffron
  static const Color primaryLight = Color(0xFFFFA534); // Warm Light Saffron
  
  // Secondary Colors - Sacred Rudraksha & Temple Terracotta
  static const Color secondary = Color(0xFF3E2723); // Deep Rudraksha Brown
  static const Color secondaryDark = Color(0xFF26140E); // Sanctum Dark
  static const Color secondaryLight = Color(0xFF5D4037); // Warm Terracotta
  
  // Spiritual accent colors
  static const Color accent = Color(0xFFFFC107); // Sacred Temple Gold
  static const Color sacred = Color(0xFF7B1FA2); // Deep Spiritual Amethyst
  static const Color devotional = Color(0xFFC62828); // Sacred Sindoor / Tilak Red
  static const Color tilak = Color(0xFFC62828); // Tilak Crimson
  static const Color tilaka = Color(0xFFC62828); // Backward compatibility
  
  // Background Colors - Chandan & Sacred Sandalwood
  static const Color background = Color(0xFFFDFBF7); // Pure Chandan Parchment
  static const Color backgroundDark = Color(0xFF1C0E08); // Cosmic Night Sanctum
  static const Color surface = Color(0xFFFFF9EE); // Sandalwood Cream Surface
  static const Color surfaceDark = Color(0xFF2D1810); // Dark temple surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C1608); // Deep Rudraksha
  static const Color textSecondary = Color(0xFF6D4C41); // Medium Brown
  static const Color textLight = Color(0xFF9E8176); // Soft Sandalwood Brown
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on saffron
  static const Color textOnSacred = Color(0xFFFFFFFF); // White on sacred
  
  // Message Bubble Colors - Spiritual theme
  static const Color userMessageBubble = Color(0xFFFF7A00); // Saffron Kesariya
  static const Color assistantMessageBubble = Color(0xFFFFFBF0); // Chandan Cream
  static const Color userMessageText = Color(0xFFFFFFFF); // Pure White
  static const Color assistantMessageText = Color(0xFF2C1608); // Deep Rudraksha
  
  // Status Colors - Traditional auspicious colors
  static const Color success = Color(0xFF2E7D32); // Tulsi Sacred Green
  static const Color warning = Color(0xFFF57C00); // Auspicious Deep Amber
  static const Color error = Color(0xFFD32F2F); // Crimson
  static const Color info = Color(0xFF0288D1); // Shipra Holy Blue
  
  // Chat Interface Colors
  static const Color inputFieldBorder = Color(0xFFE8D7C0); // Sandalwood Border
  static const Color inputFieldFocus = Color(0xFFFF7A00); // Saffron Glow
  static const Color micButtonActive = Color(0xFFC62828); // Crimson when recording
  static const Color micButtonInactive = Color(0xFFA1887F); // Soft Rudraksha
  
  // Card and Elevation Colors
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White Card
  static const Color cardShadow = Color(0x1F2C1608); // Warm Rudraksha Shadow
  static const Color divider = Color(0xFFF0E4D4); // Soft Sandalwood Divider
  
  // Temple/Spiritual specific colors
  static const Color templeGold = Color(0xFFFFC107); // Sacred Temple Gold
  static const Color goldLight = Color(0xFFFFE082); // Shimmering Gold
  static const Color holyWater = Color(0xFF0288D1); // Shipra Holy Water
  static const Color shipraBlue = Color(0xFF0288D1); // Shipra River
  static const Color prasadam = Color(0xFFFF9800); // Warm Prasadam Orange
  static const Color ashVibhuti = Color(0xFFE0E0E0); // Sacred Bhasma / Vibhuti
  
  // Gradient Colors - Spiritual gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF7A00), Color(0xFFFFB300)], // Radiant Saffron to Golden Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient spiritualGradient = LinearGradient(
    colors: [Color(0xFFFF7A00), Color(0xFFC62828)], // Saffron to Tilak Crimson
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFF8F00)], // Pure Gold to Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFDF8), Color(0xFFFFF5E6)], // Chandan cream gradient
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient templeGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFF7A00)], // Shimmering Gold to Saffron
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sanctumGradient = LinearGradient(
    colors: [Color(0xFF1E0A04), Color(0xFF3E170A), Color(0xFF5D2412)], // Cosmic Sanctum
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient bubbleUserGradient = LinearGradient(
    colors: [Color(0xFFFF7A00), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}