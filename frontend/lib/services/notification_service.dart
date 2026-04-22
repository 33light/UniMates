import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// A local notification model used within the app
class AppNotification {
  final String id;
  final String type; // 'like', 'comment', 'message', 'resolved', 'found'
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

/// Notification Service — wraps Firebase Messaging + manages in-app list
class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  static NotificationService get instance => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final List<AppNotification> _notifications = [];

  // Listeners to rebuild notification badge
  final List<VoidCallback> _listeners = [];

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());

  void addListener(VoidCallback cb) => _listeners.add(cb);
  void removeListener(VoidCallback cb) => _listeners.remove(cb);
  void _notify() {
    for (final cb in List.of(_listeners)) {
      cb();
    }
  }

  /// Call once after Firebase.initializeApp()
  Future<void> initialize() async {
    // Request permission (iOS / web)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
        'NotificationService: permission=${settings.authorizationStatus}');

    // Get & log FCM token (useful during development)
    try {
      final token = await _fcm.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('FCM token error: $e');
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);

    // App opened from notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final n = AppNotification(
      id: message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: message.data['type'] ?? 'general',
      title: message.notification?.title ?? 'UniMates',
      body: message.notification?.body ?? '',
      createdAt: DateTime.now(),
    );
    _notifications.add(n);
    _notify();
  }

  /// Add a local in-app notification (triggered by service layer events)
  void addLocalNotification({
    required String type,
    required String title,
    required String body,
  }) {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    _notifications.add(n);
    _notify();
    debugPrint('Notification: [$type] $title — $body');
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _notify();
  }

  void markRead(String id) {
    final n = _notifications.firstWhere((n) => n.id == id,
        orElse: () => throw StateError('not found'));
    n.isRead = true;
    _notify();
  }

  void clearAll() {
    _notifications.clear();
    _notify();
  }
}
