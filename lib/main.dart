import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/mock_auth_service.dart';
import 'services/mock_transaction_service.dart';
import 'services/mock_notification_service.dart';
import 'services/ai_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize mock services for testing
  final notificationService = MockNotificationService();
  await notificationService.initialize();
  
  // Initialize mock data
  final authService = MockAuthService();
  final transactionService = MockTransactionService();
  
  authService.initializeWithMockUser();
  transactionService.initializeWithMockData();
  
  runApp(const GerTonArgentApp());
}

class GerTonArgentApp extends StatelessWidget {
  const GerTonArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockAuthService()),
        ChangeNotifierProvider(create: (_) => MockTransactionService()),
        ChangeNotifierProvider(create: (_) => MockNotificationService()),
        ChangeNotifierProvider(create: (_) => AIService()),
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
