import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  /// Cleans AI text for clear, natural Text-to-Speech audio output.
  /// Strips URLs, markdown formatting, bullet symbols, and raw technical links.
  static String cleanTextForSpeech(String text) {
    var cleaned = text;
    // Replace markdown links [Label](url) with just Label
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1) ?? '',
    );
    // Remove raw URLs completely so TTS does not spell out characters
    cleaned = cleaned.replaceAll(
      RegExp(r'https?://[^\s<>()]+', caseSensitive: false),
      '',
    );
    // Remove dangling "Google Maps:" or "Directions:" prefixes left after stripping URLs
    cleaned = cleaned.replaceAll(
      RegExp(r'(?:Google Maps|Directions|गूगल मैप्स)\s*:\s*', caseSensitive: false),
      '',
    );
    // Remove markdown formatting characters: *, #, _, `, ~
    cleaned = cleaned.replaceAll(RegExp(r'[*#_`~]'), '');
    // Remove leading bullet symbols
    cleaned = cleaned.replaceAll(RegExp(r'^[•\-\+]\s*', multiLine: true), '');
    // Clean multiple consecutive newlines or extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    return cleaned.trim();
  }

  static String cleanAssistantResponse(String text) {
    final urlPattern = RegExp(r'https?://[^\s<>()]+', caseSensitive: false);
    final urls = urlPattern.allMatches(text).toList();
    if (urls.isEmpty) return text.replaceAll(RegExp(r'[*#]'), '');

    final cleaned = StringBuffer();
    var cursor = 0;
    for (final match in urls) {
      cleaned.write(
        text.substring(cursor, match.start).replaceAll(RegExp(r'[*#]'), ''),
      );
      cleaned.write(match.group(0));
      cursor = match.end;
    }
    cleaned.write(text.substring(cursor).replaceAll(RegExp(r'[*#]'), ''));
    return cleaned.toString();
  }

  // Date and Time formatting
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatDateTime(DateTime dateTime) {
    final dateStr = formatDate(dateTime);
    final timeStr = formatTime(dateTime);

    if (dateStr == 'Today') {
      return timeStr;
    } else {
      return '$dateStr, $timeStr';
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Text utilities
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidUrl(String url) {
    return Uri.tryParse(url) != null;
  }

  // UI utilities
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 4),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Platform utilities
  static bool get isAndroid =>
      Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.android;
  static bool get isIOS =>
      Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS;

  // Animation utilities
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // Storage utilities
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Color utilities
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate the perceptive luminance
    final luminance =
        (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// Global navigator key for accessing context outside of widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Debug logging utility
void debugLog(String message) {
  // ignore: avoid_print
  print(message);
}
