import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<void> init() async {
    // Every step is independently guarded: on iOS Safari (where FCM web
    // push is unsupported) any single failure must degrade to "no push"
    // instead of crashing main() into a blank white page.
    try {
      if (!await _isMessagingSupported()) {
        log('FCM not supported on this browser, skipping notifications.');
        return;
      }
    } catch (e) {
      log('FCM support check failed, skipping notifications: $e');
      return;
    }

    // 1. Request notification permission
    try {
      await _requestPermission();
    } catch (e) {
      log('Notification permission request failed: $e');
    }

    // 2. Initialize local notifications
    try {
      await _initializeLocalNotifications();
    } catch (e) {
      log('Local notifications init failed: $e');
    }

    // 3. Create Android notification channel
    try {
      await _createNotificationChannel();
    } catch (e) {
      log('Notification channel creation failed: $e');
    }

    // 4. Get FCM token (never throws: returns null on failure)
    await _getFcmToken();

    // 5. Listen for foreground messages
    try {
      FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (Object e) => log('onMessage stream error: $e'),
      );
    } catch (e) {
      log('Failed to subscribe to foreground messages: $e');
    }

    // 6. Handle notification tap when app is in background
    try {
      FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
        onError: (Object e) => log('onMessageOpenedApp stream error: $e'),
      );
    } catch (e) {
      log('Failed to subscribe to notification taps: $e');
    }

    // 7. Handle notification tap when app was terminated
    try {
      await _handleInitialMessage();
    } catch (e) {
      log('getInitialMessage failed: $e');
    }
  }

  /// Returns false on browsers without FCM support (notably iOS Safari).
  /// Never throws: any error means "unsupported".
  Future<bool> _isMessagingSupported() async {
    if (!kIsWeb) return true;
    try {
      return await _messaging.isSupported();
    } catch (e) {
      log('isSupported check threw: $e');
      return false;
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    // flutter_local_notifications has no web implementation for the
    // show() path used here; initializing it on web only risks a Safari
    // crash with zero benefit (foreground web push is rendered by the
    // browser/service worker instead).
    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        log('Notification clicked: ${response.payload}');
      },
    );
  }

  Future<void> _createNotificationChannel() async {
    // Platform from dart:io is not supported on web and throws.
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// Web Push certificate (VAPID) key pair: Firebase Console > Project
  /// settings > Cloud Messaging > Web configuration. Injected at build time
  /// (`--dart-define=FCM_VAPID_KEY=...`) so no per-environment key is
  /// committed to the repository.
  static const String _webVapidKey = String.fromEnvironment('FCM_VAPID_KEY');

  Future<String?> getFcmToken() async {
    // Web Push cannot issue a token without a VAPID key pair. Fail early
    // with an actionable message instead of an opaque exception.
    if (kIsWeb && _webVapidKey.isEmpty) {
      log(
        'FCM token skipped: no VAPID key. Run with '
        '--dart-define=FCM_VAPID_KEY=<key from Firebase Console>.',
      );
      return null;
    }

    try {
      final token = await _messaging.getToken(
        vapidKey: kIsWeb ? _webVapidKey : null,
      );
      return token;
    } catch (e, st) {
      // The reason matters: no-app means Firebase.initializeApp failed,
      // SERVICE_NOT_AVAILABLE means missing Google Play services, and
      // apns-token-not-set means the iOS push capability is missing.
      log(
        'Failed to get FCM token '
        '(platform: ${kIsWeb ? 'web' : defaultTargetPlatform.name}, '
        'firebaseApps: ${Firebase.apps.length}): $e',
      );
      log('$st');
      return null;
    }
  }

  Future<void> _getFcmToken() async {
    try {
      final token = await getFcmToken();

      log('==============================');
      log('FCM TOKEN:');
      log(token ?? 'null');
      log('==============================');
    } catch (e) {
      log('FCM token fetch failed (non-fatal): $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Foreground message received');

    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    final notification = message.notification;

    if (notification == null) return;

    // On web the browser/service worker renders foreground push; calling
    // the local-notifications plugin there is unsupported and can throw
    // on Safari, so just log and return.
    if (kIsWeb) return;

    try {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      log('Failed to show local notification: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('Notification clicked');
    log('Data: ${message.data}');

    // هنا بعدين نعمل navigation
    // حسب الـ data القادمة من Backend.
  }

  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message == null) return;

    log('App opened from notification');
    log('Data: ${message.data}');

    // هنا بعدين نعمل navigation
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('Background message received');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
}
