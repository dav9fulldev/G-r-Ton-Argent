# GèrTonArgent - Gestionnaire de Budget Personnel

Une application mobile et web moderne pour la gestion de budget personnel, spécialement conçue pour les utilisateurs en Côte d'Ivoire.

## 🧩 Problème

En Côte d'Ivoire, de nombreux jeunes (étudiants et jeunes actifs) n'ont pas d'outil structuré pour gérer efficacement leurs finances personnelles. Les dépenses quotidiennes sont réalisées sans visibilité globale, entraînant des dépassements de budget et des difficultés en fin de mois.

## 💡 Solution

GèrTonArgent est une application multiplateforme (Flutter) fonctionnant sur Android, iOS et Web. Elle permet de:
- Créer un compte personnel
- Enregistrer revenus et dépenses
- Visualiser le solde restant en temps réel
- Voir la répartition des dépenses par catégorie (graphique)
- Recevoir des alertes en cas de dépassement de budget

## 🚀 Fonctionnalités

### ✅ Fonctionnalités Implémentées
- **Authentification Firebase** — Connexion sécurisée (email/mot de passe)
- **Gestion des transactions** — Ajout, modification et suppression
- **Solde en temps réel** — Calcul automatique du solde mensuel
- **Répartition des dépenses** — Graphique par catégorie (fl_chart)
- **Historique des transactions** — Liste filtrable par date/catégorie
- **Budget mensuel + alertes** — Alerte FCM en cas de dépassement
- **Stockage hors ligne** — Synchronisation locale via Hive
- **Interface responsive** — Mobile et Web
- **Conseils avant dépense (IA)** — Optionnel (bêta), désactivable dans les paramètres

### 🔄 Fonctionnalités en Développement
- Intégration GPT API complète (Cloud Functions + prompts dynamiques)
- Fonctionnalités sociales
- Commandes vocales
- Paiements QR Code
- Gamification

## 🛠️ Technologies Utilisées

- **Frontend**: Flutter 3.x (mobile + web)
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **Base de données**: Firestore + Hive (hors ligne)
- **Graphiques**: fl_chart
- **Notifications**: Firebase Cloud Messaging (FCM)
- **IA**: Firebase AI Logic avec Google Gemini (conseils financiers intelligents)
- **Gestion d'état**: Provider Pattern

## 🧱 Architecture Technique

- **Frontend**: Flutter rend l'UI et gère l'état et la navigation
- **Services**: Auth, transactions, notifications et IA encapsulés dans `lib/services/`
- **Backend**: Firebase (Auth, Firestore, Cloud Functions pour calculs/IA)
- **Hors ligne**: Hive pour cache et usage offline-first
- **Observabilité**: Logs Firebase (à configurer selon besoin)

## 📦 Modèle de Données (Firestore)

- `users` — données de base utilisateur: `email`, `name`, `monthlyBudget`
- `transactions` — `amount`, `type` (income|expense), `category`, `date`, `userId`

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

### 4. Configuration Firebase AI Logic avec Gemini
Pour activer les conseils IA intelligents :

1. **Activez Firebase AI Logic** dans votre projet Firebase
2. **Configurez Gemini** avec votre clé API
3. **Suivez le guide détaillé** dans `FIREBASE_AI_SETUP.md`

```bash
# Voir la configuration complète
cat FIREBASE_AI_SETUP.md
```

> **Important** : Cette intégration utilise Firebase AI Logic comme proxy sécurisé vers Gemini, évitant d'exposer la clé API dans l'application mobile.

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
├── main.dart                         # Point d'entrée de l'application
├── firebase_options.dart             # Configuration Firebase
├── models/                           # Modèles de données
│   ├── transaction_model.dart
│   ├── transaction_model.g.dart
│   ├── user_model.dart
│   └── user_model.g.dart
├── screens/                          # Écrans de l'application
│   ├── auth/                        # Authentification
│   ├── home/                        # Dashboard principal
│   ├── settings/                    # Paramètres
│   ├── transactions/                # Gestion des transactions
│   └── splash_screen.dart           # Écran de démarrage
├── services/                         # Services métier
│   ├── gemini_service.dart          # Service IA avec Firebase AI Logic
│   ├── auth_service.dart            # Authentification Firebase
│   ├── connectivity_service.dart    # Connectivité
│   ├── notification_service.dart    # Notifications (FCM)
│   ├── transaction_service.dart     # Gestion des transactions
│   ├── mock_auth_service.dart       # Mocks pour tests
│   ├── mock_notification_service.dart
│   └── mock_transaction_service.dart
├── widgets/                          # Composants réutilisables
│   ├── app_logo.dart
│   ├── balance_card.dart
│   ├── budget_planning_widget.dart
│   ├── expense_chart.dart           # Graphique (fl_chart)
│   ├── financial_tips_widget.dart
│   ├── spending_insights_widget.dart
│   ├── splash_screen.dart
│   └── transaction_list_item.dart
└── utils/                            # Utilitaires
    └── theme.dart                   # Thème de l'application
```

Des services « mock » sont fournis pour faciliter les tests sans dépendre des services distants.

## 🔬 Étude Utilisateur (30 répondants)

Fonctionnalités prioritaires attendues:

| Fonctionnalité | % de répondants |
|---|---|
| 🗓️ Planification du budget mensuel | 78% |
| 🔔 Alertes de dépassement | 68% |
| 📊 Répartition des dépenses (graphique) | 58% |
| ⏳ Historique des transactions | 56% |
| 💰 Visualisation du solde en temps réel | 52% |
| 🧠 Conseils avant dépense | 2% |

Ces résultats confirment la pertinence d'un outil clair, visuel et proactif. Les « conseils avant dépense » restent optionnels et désactivables.

## 🗺️ Plan de Développement (Sprints)

- **Sprint 1 — Auth + Base UI**: Accueil, login/register (Firebase Auth), création du modèle `Transaction`
- **Sprint 2 — Saisie**: Formulaire d'entrée, écriture Firestore, affichage historique
- **Sprint 3 — Visualisation**: Dashboard + graphique (fl_chart)
- **Sprint 4 — Budget + Alertes**: Limite mensuelle, notification FCM en dépassement
- **Sprint 5 — Finitions**: Responsive Web, tests Android/iOS/Web, documentation et soutenance

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

## 🤖 IA — Conseils avant dépense (Optionnel/Bêta)

Objectif: fournir un message contextuel au moment de l'enregistrement d'une dépense pour encourager une décision réfléchie.

- **Déclenchement**: Cloud Function lors de la création d'une nouvelle dépense
- **Personnalisation**: basée sur solde restant du mois, % de budget utilisé et catégorie
- **Technologie**: GPT API (OpenAI) via Cloud Functions
- **Affichage**: message dynamique dans l'interface Flutter
- **Confidentialité**: données anonymisées, fonctionnalité désactivable

Exemple de message:

« Votre solde actuel est 12 500 FCFA. Cette dépense de 5 000 FCFA représente 40% de vos fonds mensuels restants. Est-ce essentiel maintenant ? Vous pourriez attendre ou réduire le montant. »

Flux de traitement:

Flutter (Formulaire)
↓
Cloud Function → GPT API
↓
Message IA affiché à l'utilisateur

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

- **Web**: déploiement via Firebase Hosting
- **Android**: APK/AAB pour test et distribution
- **Sauvegarde des données**: Firestore

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
- [ ] Intégration complète GPT API (Cloud Functions)
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


