# GèrTonArgent - Gestionnaire de Budget Personnel

Une application mobile et web moderne pour la gestion de budget personnel, spécialement conçue pour les utilisateurs en Côte d'Ivoire.

## 🚀 Fonctionnalités

### ✅ Fonctionnalités Implémentées
- **Authentification Firebase** - Connexion sécurisée avec email/mot de passe
- **Gestion des Transactions** - Ajout, modification et suppression de transactions
- **Dashboard Interactif** - Vue d'ensemble des finances avec graphiques
- **Planification de Budget** - Définition et suivi du budget mensuel
- **Analyses de Dépenses** - Insights détaillés sur les habitudes de dépenses
- **Conseils IA** - Recommandations personnalisées basées sur les données
- **Stockage Hors Ligne** - Synchronisation automatique avec Hive
- **Notifications Push** - Alertes de dépassement de budget
- **Interface Responsive** - Compatible mobile et web

### 🔄 Fonctionnalités en Développement
- Intégration GPT API complète
- Fonctionnalités sociales
- Commandes vocales
- Paiements QR Code
- Gamification

## 🛠️ Technologies Utilisées

- **Frontend**: Flutter 3.x
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Base de Données**: Firestore + Hive (stockage local)
- **Graphiques**: fl_chart
- **IA**: OpenAI GPT API (optionnel)
- **Notifications**: Firebase Cloud Messaging
- **État**: Provider Pattern

## 📱 Captures d'Écran

*Captures d'écran à ajouter*

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK 3.8.0 ou supérieur
- Dart SDK
- Firebase Project
- Compte OpenAI (optionnel pour les conseils IA)

### 1. Cloner le Projet
```bash
git clone https://github.com/votre-username/ger-ton-argent.git
cd ger-ton-argent
```

### 2. Installer les Dépendances
```bash
flutter pub get
```

### 3. Configuration Firebase

#### Créer un Projet Firebase
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet
3. Activez Authentication (Email/Password)
4. Créez une base de données Firestore
5. Configurez Cloud Messaging

#### Configurer l'Application
1. Ajoutez votre application Android/iOS dans Firebase
2. Téléchargez le fichier `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS)
3. Placez le fichier dans le dossier approprié :
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Mettre à Jour firebase_options.dart
Remplacez les valeurs mock dans `lib/firebase_options.dart` par vos vraies valeurs Firebase :

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'votre-api-key',
  appId: 'votre-app-id',
  messagingSenderId: 'votre-sender-id',
  projectId: 'votre-project-id',
  authDomain: 'votre-project.firebaseapp.com',
  storageBucket: 'votre-project.appspot.com',
);
```

### 4. Configuration OpenAI (Optionnel)
Pour activer les conseils IA avancés :

1. Créez un compte sur [OpenAI](https://openai.com/)
2. Générez une clé API
3. Remplacez `your-openai-api-key-here` dans `lib/services/ai_service.dart`

```dart
static const String _apiKey = 'sk-votre-vraie-cle-api';
```

### 5. Lancer l'Application

#### Mode Développement
```bash
flutter run
```

#### Build de Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📊 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── firebase_options.dart     # Configuration Firebase
├── models/                   # Modèles de données
│   ├── transaction_model.dart
│   └── user_model.dart
├── screens/                  # Écrans de l'application
│   ├── auth/                # Authentification
│   ├── home/                # Dashboard principal
│   ├── transactions/        # Gestion des transactions
│   └── settings/            # Paramètres
├── services/                # Services métier
│   ├── auth_service.dart    # Authentification Firebase
│   ├── transaction_service.dart # Gestion des transactions
│   ├── ai_service.dart      # Service IA
│   ├── notification_service.dart # Notifications
│   └── connectivity_service.dart # Connectivité
├── widgets/                 # Composants réutilisables
│   ├── balance_card.dart
│   ├── budget_planning_widget.dart
│   ├── spending_insights_widget.dart
│   └── ...
└── utils/                   # Utilitaires
    └── theme.dart           # Thème de l'application
```

## 🔧 Configuration Avancée

### Variables d'Environnement
Créez un fichier `.env` à la racine du projet :

```env
FIREBASE_API_KEY=votre-api-key
FIREBASE_PROJECT_ID=votre-project-id
OPENAI_API_KEY=votre-openai-key
```

### Règles Firestore
Configurez les règles de sécurité Firestore :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 📈 Déploiement

### Firebase Hosting (Web)
```bash
flutter build web
firebase deploy --only hosting
```

### Google Play Store (Android)
```bash
flutter build appbundle --release
# Téléchargez le fichier .aab et uploadez-le sur Google Play Console
```

### App Store (iOS)
```bash
flutter build ios --release
# Ouvrez Xcode et archivez l'application
```

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Contactez l'équipe de développement
- Consultez la documentation Firebase

## 🎯 Roadmap

### Version 1.1
- [ ] Intégration complète GPT API
- [ ] Fonctionnalités sociales
- [ ] Commandes vocales
- [ ] Paiements QR Code

### Version 1.2
- [ ] Gamification
- [ ] Objectifs financiers
- [ ] Rapports avancés
- [ ] Export de données

### Version 2.0
- [ ] IA prédictive
- [ ] Intégration bancaire
- [ ] Multi-devises
- [ ] API publique

---

**Développé avec ❤️ pour la communauté ivoirienne**


