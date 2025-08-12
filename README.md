## GèrTonArgent (BudgetWise)

Personal finance manager for Côte d'Ivoire: track income, expenses, and your real‑time monthly balance. Cross‑platform with Flutter (Android, iOS, Web), backed by Firebase. Includes proactive budget overrun alerts and an optional AI “pre‑spending advice” feature.

---

### 1) Problem Statement
Many young people (students, young professionals) in Côte d'Ivoire lack a structured tool to manage personal finances. Daily spending happens without a clear overview, leading to frequent budget overruns by month‑end. This project provides a simple, intuitive, and visual tool to manage a monthly budget, track income and expenses, and view the remaining balance in real time.

### 2) Solution Overview
GèrTonArgent (aka “BudgetWise”) is a Flutter application for mobile (Android/iOS) and Web. Users can:
- Create a personal account
- Record income and expenses
- See real‑time remaining balance
- View a pie chart breakdown of expenses by category
- Receive alerts in case of budget overruns

### 3) Feature Breakdown
#### 3.1 User Interface (Flutter)
- **Dashboard**: monthly balance, expense distribution (pie chart), transaction history
- **Transaction Form**: add income/expense; fields for amount, category, date, description; set monthly budget
- **Authentication**: account creation/login with Firebase Auth (email/password)

#### 3.2 Back End / Services (Firebase + Cloud Functions)
- Store users and transactions in Firestore
- Compute balance and statistics
- Send push alerts via Firebase Cloud Messaging when budget is exceeded

#### 3.3 Database (Firestore; Hive for offline)
Collections:
- `users`: email, name, monthlyBudget
- `transactions`: amount, type (income|expense), category, date, userUid

### 4) Technical Architecture
- **Frontend**: Flutter 3.x (mobile + web)
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Offline Storage**: Hive
- **Charts**: `fl_chart`
- **Notifications**: Firebase Cloud Messaging (FCM)

### 5) User Study – Feature Expectations (n=30)
- **Planning of monthly budget**: 78%
- **Budget overrun alerts**: 68%
- **Expense breakdown (chart)**: 58%
- **Transaction history**: 56%
- **Real‑time balance**: 52%
- **Advice before spending**: 2%

These results validate the need for a clear, graphical, and proactive tool. The low selection of “advice before spending” leaves room for future innovation via smart, optional coaching.

### 6) Development Plan
- **Sprint 1**: Auth + Base UI (Home, Login/Register; Firebase Auth), Transaction model
- **Sprint 2**: Transaction Entry (form, save to Firestore, history list)
- **Sprint 3**: Visualization (dashboard + pie chart)
- **Sprint 4**: Monthly Budget + Alerts (limit + FCM notifications)
- **Sprint 5**: Finalization (responsive web, testing across Android/iOS/Web, documentation)

### 7) Deployment
- **Web**: Firebase Hosting
- **Android**: APK/AAB for testing/distribution
- **Data**: Firestore

### 8) Technical Stack Summary
- **Language**: Dart (Flutter)
- **Backend**: Firebase
- **Database**: Firestore (+ Hive offline)
- **Charts**: `fl_chart`
- **Notifications**: Firebase Messaging (FCM)
- **Hosting**: Firebase Hosting

### 9) Artificial Intelligence: Pre‑Spending Advice
Optional AI advice is shown when the user is about to record an expense, to encourage reflection and reduce impulsive spending.

Objectives:
- Deliver personalized prompts like “Do you really need to make this expense now? It might affect your monthly budget.”
- Adapt to remaining balance, percentage of budget used, and expense category (leisure, food, transport, etc.).

Technology:
- GPT API (OpenAI)
- Triggered via a Firebase Cloud Function on new expense
- Dynamic response shown in Flutter UI

Example message:
“Your current balance is 12,500 FCFA. This expense of 5,000 FCFA represents 40% of your remaining monthly funds. Is this essential? You might want to wait or reduce the amount.”

Processing flow:
Flutter Form → Cloud Function → GPT API (OpenAI) → Message to UI

Advantages:
- Supports better decision‑making
- Interactive, intelligent UX
- Differentiating feature

Limitations:
- Advice only; not enforced
- Data anonymized
- Feature can be disabled in settings

---

## Project Structure (high level)
```
lib/
  main.dart
  models/
    transaction_model.dart
    user_model.dart
  screens/
    auth/
      login_screen.dart
      register_screen.dart
    home/
      dashboard_screen.dart
    transactions/
      add_transaction_screen.dart
      transaction_details_screen.dart
    settings/
      settings_screen.dart
    splash_screen.dart
  services/
    auth_service.dart
    transaction_service.dart
    notification_service.dart
  utils/
    theme.dart
  widgets/
    balance_card.dart
    expense_chart.dart
    transaction_list_item.dart
firebase_options.dart
pubspec.yaml
```

---

## Getting Started (Development)

### Prerequisites
- Flutter SDK 3.x installed
- Dart SDK (bundled with Flutter)
- Firebase project created (Auth, Firestore, FCM, Hosting)
- Node.js 18+ (for Cloud Functions if you enable AI advice)

### 1) Install dependencies
```
flutter pub get
```

### 2) Configure Firebase
Use FlutterFire CLI to generate `firebase_options.dart` (already present in this repo, regenerate if needed):
```
dart pub global activate flutterfire_cli
flutterfire configure
```

Enable in Firebase Console:
- Authentication: Email/Password
- Firestore: rules per your needs (start in test mode for dev)
- Cloud Messaging (FCM): set up for Android/iOS/Web

### 3) Run the app
```
flutter run -d chrome      # Web
flutter run -d windows     # Windows (if enabled)
flutter run -d android     # Android
flutter run -d ios         # iOS (on macOS)
```

---

## AI Advice via Cloud Functions (optional)

This feature is optional and off by default. Implementation outline:

1) In your Firebase project, create a Cloud Function that listens to new expense documents in `transactions`.
2) The Function computes remaining budget context, calls the OpenAI API, and writes an `advice` field back or sends it via FCM.
3) Flutter UI displays the returned advice to the user.

Minimal pseudo‑implementation (Node.js):
```js
// functions/index.js (outline)
exports.onExpenseCreate = functions.firestore
  .document('transactions/{id}')
  .onCreate(async (snap, ctx) => {
    const txn = snap.data();
    // Compute remaining budget and context for the user...
    // Call OpenAI (use Functions config for API key):
    // const openaiKey = functions.config().openai.key;
    // const advice = await fetchOpenAiAdvice({...});
    // await snap.ref.update({ advice, adviceGeneratedAt: new Date() });
  });
```

Configure secret:
```
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
firebase deploy --only functions
```

In Flutter, read the `advice` on the transaction document or listen to a dedicated collection/message and show it in the UI. Provide a toggle in settings to disable this feature.

---

## Build & Deployment

### Web (Firebase Hosting)
```
flutter build web
firebase init hosting
firebase deploy --only hosting
```

### Android
```
flutter build apk --release
```

---

## Contributing
- Use clear commit messages.
- Run static analysis before pushing:
```
flutter analyze
```
- Format code:
```
dart format .
```

---

## License
MIT (or your chosen license)


