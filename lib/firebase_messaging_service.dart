import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

 
  Future<void> init() async {
    
    await _firebaseMessaging.requestPermission();

   
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    
    FirebaseMessaging.onMessage.listen(_onMessage);

  
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

 
   Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
    _showLocalNotification(message);
  }

 
  Future<void> _onMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.notification?.title}");
    _showLocalNotification(message);
  }


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
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
