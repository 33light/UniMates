import 'package:flutter/foundation.dart';

/// Utility functions and helpers for the application
class ValidationUtils {
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validate post title
  static bool isValidPostTitle(String title) {
    return title.length >= 5 && title.length <= 100;
  }

  /// Validate post content
  static bool isValidPostContent(String content) {
    return content.length >= 10 && content.length <= 2000;
  }

  /// Validate username
  static bool isValidUsername(String username) {
    return username.length >= 3 && username.length <= 20;
  }
}

/// String formatting utilities
class StringUtils {
  /// Format date to readable format (e.g., "Jan 25, 2026")
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  /// Format number with commas
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Logger utility for debugging
class AppLogger {
  static void debug(String message) {
    debugPrint('🔍 DEBUG: $message');
  }

  static void info(String message) {
    debugPrint('ℹ️ INFO: $message');
  }

  static void warning(String message) {
    debugPrint('⚠️ WARNING: $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('Error Details: $error');
    if (stackTrace != null) debugPrint('Stack: $stackTrace');
  }
}
