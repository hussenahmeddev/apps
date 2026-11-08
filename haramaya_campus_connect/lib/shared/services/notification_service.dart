import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages if needed.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'haramaya_campus_connect',
    'Campus Connect Notifications',
    description: 'Notifications for Haramaya Campus Connect',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    try {
      // Request permissions
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      // Firebase messaging not configured or unavailable
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (e) {
      // Local notifications error
    }

    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

      // Subscribe to global topics
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('announcements');
    } catch (e) {
      // Ignore if offline or placeholder credentials
    }
  }

  /// Returns the FCM token for this device.
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Subscribe to a topic.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    // Navigation based on notification data can be handled via a callback.
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap.
  }
}

