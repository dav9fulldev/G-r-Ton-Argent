# Firebase Setup Guide for GèrTonArgent

This guide will help you set up Firebase for the GèrTonArgent project.

## Prerequisites

- Flutter SDK 3.8.0 or higher
- Firebase CLI installed globally
- A Google account

## Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase

```bash
firebase login
```

## Step 3: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 4: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `gertonargent`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 5: Configure Flutter App

Run the following command in your project root:

```bash
flutterfire configure --project=gertonargent
```

This will:
- Configure your Flutter app for all platforms (Android, iOS, Web)
- Generate the `firebase_options.dart` file
- Add necessary configuration files

## Step 6: Update firebase_options.dart

Replace the placeholder values in `lib/firebase_options.dart` with the generated values from FlutterFire CLI.

## Step 7: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

## Step 8: Create Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location (choose closest to your users)
5. Click "Done"

## Step 9: Set Up Firestore Security Rules

Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their own transactions
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## Step 10: Enable Cloud Messaging (Optional)

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Get started"
3. Follow the setup instructions for your platforms

## Step 11: Test the Setup

1. Run the app:
```bash
flutter run
```

2. Try to register a new user
3. Check if the user appears in Firebase Console > Authentication
4. Check if user data appears in Firestore Database

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Make sure `firebase_options.dart` has correct values
   - Check that Firebase is properly initialized in `main.dart`

2. **Authentication errors**
   - Verify Email/Password is enabled in Firebase Console
   - Check Firestore security rules

3. **Permission denied errors**
   - Update Firestore security rules
   - Make sure user is authenticated

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check that all Firebase dependencies are properly added

### Platform-Specific Setup

#### Android

1. Make sure `google-services.json` is in `android/app/`
2. Verify `android/build.gradle` has Google Services plugin
3. Check `android/app/build.gradle` has Firebase dependencies

#### iOS

1. Make sure `GoogleService-Info.plist` is in `ios/Runner/`
2. Add it to Xcode project if not automatically added
3. Verify Firebase dependencies in `ios/Podfile`

#### Web

1. Check that Firebase is properly configured in `web/index.html`
2. Verify Firebase SDK is loaded

## Production Deployment

### Update Security Rules

For production, update Firestore rules to be more restrictive:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId &&
        request.auth.token.email_verified == true;
    }
    
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId &&
        request.auth.token.email_verified == true;
    }
  }
}
```

### Enable Email Verification

1. In Firebase Console > Authentication > Settings
2. Enable "Email verification"
3. Update your app to handle email verification

### Set Up Monitoring

1. Enable Firebase Crashlytics
2. Set up Firebase Analytics
3. Configure error reporting

## Environment Variables

Create a `.env` file in your project root:

```env
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=gertonargent
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
```

## Support

If you encounter issues:

1. Check Firebase Console for error logs
2. Review FlutterFire documentation
3. Check Firebase status page
4. Create an issue in the project repository

## Next Steps

After Firebase is set up:

1. Test all authentication flows
2. Verify data persistence
3. Test offline functionality
4. Set up CI/CD pipeline
5. Configure monitoring and analytics
