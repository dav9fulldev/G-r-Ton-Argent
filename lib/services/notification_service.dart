import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission for push notifications
    await requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  Future<void> deleteFcmToken(String uid) async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }

  // Show budget overrun alert
  Future<void> showBudgetOverrunAlert({
    required double currentBalance,
    required double monthlyBudget,
    required double expenseAmount,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget overruns and financial alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final percentageUsed = ((monthlyBudget - currentBalance) / monthlyBudget) * 100;
    
    String message;
    if (currentBalance < 0) {
      message = '⚠️ Budget dépassé! Votre solde est négatif de ${currentBalance.abs().toStringAsFixed(0)} FCFA.';
    } else if (percentageUsed > 80) {
      message = '⚠️ Attention! Vous avez utilisé ${percentageUsed.toStringAsFixed(0)}% de votre budget mensuel.';
    } else {
      message = '💡 Cette dépense de ${expenseAmount.toStringAsFixed(0)} FCFA représente ${((expenseAmount / currentBalance) * 100).toStringAsFixed(0)}% de votre solde restant.';
    }

    await _localNotifications.show(
      0,
      'GèrTonArgent - Alerte Budget',
      message,
      platformChannelSpecifics,
    );
  }

  // Show AI advice notification
  Future<void> showAIAdvice({
    required String advice,
    required double expenseAmount,
    required double currentBalance,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ai_advice',
      'AI Advice',
      channelDescription: 'AI-powered spending advice',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      1,
      '💡 Conseil IA - GèrTonArgent',
      advice,
      platformChannelSpecifics,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Handle navigation based on notification type
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

