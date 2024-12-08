import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  Future<void> init() async {
    // Request for notification permissions (iOS)
    await _firebaseMessaging.requestPermission();

    // Configure background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Initialize local notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Configure foreground message handler
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Get the FCM token (this is used for sending notifications from the server)
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  // Background message handler
   Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
    _showLocalNotification(message);
  }

  // Foreground message handler
  Future<void> _onMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.notification?.title}");
    _showLocalNotification(message);
  }

  // Show Local Notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
