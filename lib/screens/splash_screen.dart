import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
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
    
    // Safety timeout - force navigation after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        print('⚠️ SplashScreen: Safety timeout reached, forcing navigation to Login');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    print('🚀 SplashScreen: Starting auth check...');
    
    try {
      // Wait for Firebase to initialize and auth state to be determined
      await Future.delayed(const Duration(seconds: 3));
      print('⏰ SplashScreen: After 3s delay');
      
      if (mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final transactionService = Provider.of<TransactionService>(context, listen: false);
        
        print('🔍 SplashScreen: AuthService obtained, isAuthenticated: ${authService.isAuthenticated}');
        
        // Wait a bit more for auth state to be loaded
        await Future.delayed(const Duration(milliseconds: 1000));
        print('⏰ SplashScreen: After 1s delay');
        
        if (mounted) {
          if (authService.isAuthenticated && authService.currentUser != null) {
            print('✅ SplashScreen: User authenticated, loading data and navigating to Dashboard');
            
            // Load user data and transactions
            try {
              print('📊 SplashScreen: Loading user data for: ${authService.currentUser!.name}');
              
              // Force refresh transactions from Firestore
              await transactionService.forceRefresh(authService.currentUser!.uid);
              
              // Debug data consistency
              await transactionService.debugDataConsistency(authService.currentUser!.uid);
              
              print('✅ SplashScreen: Data loaded successfully, navigating to Dashboard');
              
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            } catch (e) {
              print('❌ SplashScreen: Error loading data: $e');
              // Still navigate to dashboard even if data loading fails
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            }
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
    } catch (e) {
      print('❌ SplashScreen: Error during auth check: $e');
      // Force navigation to login on error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreenWidget();
  }
}
