import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Easy Localization with explicit locale list
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

    // Initialize Firebase only if not on web or if web initialization succeeds
    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase initialization failed: $e');
      // Continue without Firebase for web development
    }
    
    // Initialize notification service only if Firebase is available
    if (firebaseInitialized) {
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
      } catch (e) {
        print('⚠️ Notification service initialization failed: $e');
      }
    }

    // 🔹 Écoute notifications en arrière-plan (only if Firebase is initialized)
    if (firebaseInitialized) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Explicitly define supported locales to avoid loading es-ES.json
    const supportedLocales = [
      Locale('fr', 'FR'), // Français
      Locale('en', 'US'), // Anglais
    ];

    runApp(
      EasyLocalization(
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('fr', 'FR'),
        useOnlyLangCode: false,
        child: const GerTonArgentApp(),
      ),
    );
  } catch (e) {
    print('🔥 Critical error during app initialization: $e');
    // Run app even if there are initialization errors
    const supportedLocales = [
      Locale('fr', 'FR'), // Français
      Locale('en', 'US'), // Anglais
    ];
    
    runApp(
      EasyLocalization(
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('fr', 'FR'),
        useOnlyLangCode: false,
        child: const GerTonArgentApp(),
      ),
    );
  }
}

class GerTonArgentApp extends StatelessWidget {
  const GerTonArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<TransactionService>(create: (_) => TransactionService()),
        ChangeNotifierProvider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<GeminiService>(create: (_) => GeminiService()),

        ChangeNotifierProvider<ConnectivityService>(create: (_) => ConnectivityService()),
        ChangeNotifierProvider<ProfileService>(create: (_) => ProfileService()),
        ChangeNotifierProvider<LocalizationService>(create: (_) => LocalizationService()),
      ],
      child: MaterialApp(
        title: 'GèrTonArgent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...context.localizationDelegates,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const SplashScreen(),
      ),
    );
  }
}
