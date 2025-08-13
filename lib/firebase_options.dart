// Mock Firebase options for development/testing
// This file will be replaced with real Firebase configuration later

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Mock [FirebaseOptions] class for development
class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? authDomain;
  final String? storageBucket;
  final String? iosBundleId;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.storageBucket,
    this.iosBundleId,
  });
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// This is a mock implementation for development/testing.
/// Replace with real Firebase configuration when ready.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'mock-web-api-key',
    appId: 'mock-web-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'gertonargent',
    authDomain: 'gertonargent.firebaseapp.com',
    storageBucket: 'gertonargent.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'mock-android-api-key',
    appId: 'mock-android-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'gertonargent',
    storageBucket: 'gertonargent.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'mock-ios-api-key',
    appId: 'mock-ios-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'gertonargent',
    storageBucket: 'gertonargent.appspot.com',
    iosBundleId: 'com.example.gerTonArgent',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'mock-macos-api-key',
    appId: 'mock-macos-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'gertonargent',
    storageBucket: 'gertonargent.appspot.com',
    iosBundleId: 'com.example.gerTonArgent',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'mock-windows-api-key',
    appId: 'mock-windows-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'gertonargent',
    storageBucket: 'gertonargent.appspot.com',
  );
}
