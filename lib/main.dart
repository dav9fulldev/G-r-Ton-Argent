import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'models/budget_model.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'services/notification_service.dart';
import 'services/gemini_service.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/localization_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    Hive.registerAdapter(BudgetModelAdapter());
    
    // Open Hive boxes
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<BudgetModel>('budgets');

    // Initialize API Service
    final apiService = ApiService();
    await apiService.initialize();

    // Initialize notification service
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
    } catch (e) {
      print('⚠️ Notification service initialization failed: $e');
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
        // ApiService is not a ChangeNotifier; access via singletons in services
        ChangeNotifierProvider<ConnectivityService>(create: (_) => ConnectivityService()),
        // ProfileService removed (Firebase Storage dependency). Reintroduce when backend endpoints are ready.
        ChangeNotifierProvider<LocalizationService>(create: (_) => LocalizationService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Configurer le callback de rechargement des transactions
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final transactionService = Provider.of<TransactionService>(context, listen: false);
            authService.setOnUserLoadedCallback(() {
              print('🔄 Main: User loaded, reloading transactions');
              transactionService.forceRefresh();
            });
          });
          
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}
