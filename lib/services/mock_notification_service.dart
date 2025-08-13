import 'package:flutter/foundation.dart';

class MockNotificationService extends ChangeNotifier {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> requestPermission() async {
    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Notification permission requested');
  }

  Future<String?> getToken() async {
    // Return mock token
    return 'mock-fcm-token-12345';
  }

  Future<void> deleteFcmToken(String uid) async {
    // Simulate token deletion
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: FCM token deleted for user $uid');
  }

  // Show budget overrun alert
  Future<void> showBudgetOverrunAlert({
    required double currentBalance,
    required double monthlyBudget,
    required double expenseAmount,
  }) async {
    final percentageUsed = ((monthlyBudget - currentBalance) / monthlyBudget) * 100;
    
    String message;
    if (currentBalance < 0) {
      message = '⚠️ Budget dépassé! Votre solde est négatif de ${currentBalance.abs().toStringAsFixed(0)} FCFA.';
    } else if (percentageUsed > 80) {
      message = '⚠️ Attention! Vous avez utilisé ${percentageUsed.toStringAsFixed(0)}% de votre budget mensuel.';
    } else {
      message = '💡 Cette dépense de ${expenseAmount.toStringAsFixed(0)} FCFA représente ${((expenseAmount / currentBalance) * 100).toStringAsFixed(0)}% de votre solde restant.';
    }

    print('Mock Notification: $message');
  }

  // Show AI advice notification
  Future<void> showAIAdvice({
    required String advice,
    required double expenseAmount,
    required double currentBalance,
  }) async {
    print('Mock AI Advice: $advice');
  }

  void _handleForegroundMessage(dynamic message) {
    print('Mock: Got a message whilst in the foreground!');
    print('Mock: Message data: $message');
  }

  void _handleNotificationTap(dynamic message) {
    print('Mock: Notification tapped: $message');
  }

  void _onNotificationTapped(dynamic response) {
    print('Mock: Local notification tapped: $response');
  }
}
