import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'services/notification_service.dart';
import 'services/ai_service.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('offline_queue');
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Request notification permissions
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');
    
    // Get FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Fallback to mock services if Firebase fails
  }
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  // Notification FCM
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel', // Même ID que dans AndroidManifest
          'Default Notifications',
          channelDescription: 'Used for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
});

  runApp(const GerTonArgentApp());
}

class GerTonArgentApp extends StatelessWidget {
  const GerTonArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use real services if Firebase is available, otherwise fallback to mock services
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<TransactionService>(
          create: (_) => TransactionService(),
        ),
        ChangeNotifierProvider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        ChangeNotifierProvider<AIService>(
          create: (_) => AIService(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
      ],
      child: MaterialApp(
        title: 'GèrTonArgent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
