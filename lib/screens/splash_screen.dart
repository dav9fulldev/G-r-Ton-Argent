import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/splash_screen.dart';
import 'home/dashboard_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    print('🚀 SplashScreen: Starting auth check...');
    
    // Wait for Firebase to initialize and auth state to be determined
    await Future.delayed(const Duration(seconds: 2));
    print('⏰ SplashScreen: After 2s delay');
    
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      print('🔍 SplashScreen: AuthService obtained, isAuthenticated: ${authService.isAuthenticated}');
      
      // Wait a bit more for auth state to be loaded
      await Future.delayed(const Duration(milliseconds: 500));
      print('⏰ SplashScreen: After 500ms delay');
      
      if (mounted) {
        if (authService.isAuthenticated) {
          print('✅ SplashScreen: User authenticated, navigating to Dashboard');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          print('🔐 SplashScreen: User not authenticated, navigating to Login');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        print('❌ SplashScreen: Widget not mounted after delays');
      }
    } else {
      print('❌ SplashScreen: Widget not mounted after initial delay');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreenWidget();
  }
}
