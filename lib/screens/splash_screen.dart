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
    // Wait for Firebase to initialize and auth state to be determined
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Wait a bit more for auth state to be loaded
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        if (authService.isAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreenWidget();
  }
}
