import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'services/notification_service.dart';
import 'services/gemini_service.dart';
import 'services/connectivity_service.dart';
import 'services/profile_service.dart';
import 'services/localization_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 🔹 Handler pour notifications reçues en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 Notification reçue en arrière-plan: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();
  
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

  // 🔹 Écoute notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
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

  // 🔹 Notification FCM en premier plan
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

  // 🔹 Gérer le clic sur une notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📲 Notification cliquée : ${message.data}");
    // Tu peux ajouter ici une navigation vers une page spécifique
  });

  runApp(const GerTonArgentApp());
}

class GerTonArgentApp extends StatelessWidget {
  const GerTonArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<TransactionService>(
          create: (_) => TransactionService(),
        ),
        ChangeNotifierProvider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        ChangeNotifierProvider<GeminiService>(
          create: (_) => GeminiService(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
        ChangeNotifierProvider<ProfileService>(
          create: (_) => ProfileService(),
        ),
        ChangeNotifierProvider<LocalizationService>(
          create: (_) => LocalizationService(),
        ),
      ],
      child: EasyLocalization(
        supportedLocales: LocalizationService.supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('fr', 'FR'),
        child: MaterialApp(
          title: 'GèrTonArgent',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
