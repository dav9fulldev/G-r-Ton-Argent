import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  Future<void> deleteFcmToken(String uid) async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }
}

