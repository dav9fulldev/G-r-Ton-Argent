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
- **Authentification JWT (API REST)** — Connexion sécurisée (email/mot de passe)
- **Gestion des transactions** — Ajout, modification et suppression
- **Solde en temps réel** — Calcul automatique du solde mensuel
- **Répartition des dépenses** — Graphique par catégorie (fl_chart)
- **Historique des transactions** — Liste filtrable par date/catégorie
- **Budget mensuel + alertes** — Alertes locales (sans FCM)
- **Stockage hors ligne** — Synchronisation locale via Hive
- **Interface responsive** — Mobile et Web
- **Conseils avant dépense (IA)** — Optionnel (bêta), désactivable dans les paramètres

### 🔄 Fonctionnalités en Développement
- Intégration complète API Node.js (transactions, budget, analytics)
- Fonctionnalités sociales
- Commandes vocales
- Paiements QR Code
- Gamification

## 🛠️ Technologies Utilisées

- **Frontend**: Flutter 3.x (mobile + web)
- **Backend**: API Node.js + Express (séparé, repo distinct)
- **Base de données**: MySQL (backend) + Hive (hors ligne côté app)
- **Graphiques**: fl_chart
- **Notifications**: Notifications locales (Flutter Local Notifications)
- **IA**: Firebase AI Logic avec Google Gemini (conseils financiers intelligents)
- **Gestion d'état**: Provider Pattern

## 🧱 Architecture Technique

- **Frontend**: Flutter rend l'UI et gère l'état et la navigation
- **Services**: Auth, transactions, notifications et IA encapsulés dans `lib/services/`
- **Backend**: API REST (Node.js) hébergée séparément (voir repo backend)
- **Hors ligne**: Hive pour cache et usage offline-first
- **Observabilité**: Logs applicatifs

## 📦 Modèle de Données (API REST)

- Endpoints principaux:
- `POST /auth/register`, `POST /auth/login`, `GET/POST /transactions`, `GET/PUT /budget`, `GET /analytics`

## 📱 Captures d'Écran

*Captures d'écran à ajouter*

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK 3.8.0 ou supérieur
- Dart SDK
- Backend Node.js + MySQL (repo séparé)

### 1. Cloner le Projet
```bash
git clone https://github.com/votre-username/ger-ton-argent.git
cd ger-ton-argent
```

### 2. Installer les Dépendances
```bash
flutter pub get
```

### 3. Configuration de l'API Backend
Le backend (Node.js + MySQL) est maintenant dans un repo séparé.
Configurez l'URL de l'API dans `lib/config/api_config.dart`.

<!-- Ancienne section Firebase supprimée après migration vers API REST -->

### 4. IA Gemini (optionnel)
L'IA utilise directement l'API Gemini via `lib/services/gemini_service.dart`.
Ajoutez votre clé API si nécessaire.

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
│   ├── gemini_service.dart          # Service IA (API Gemini)
│   ├── auth_service.dart            # Authentification via API REST (JWT)
│   ├── connectivity_service.dart    # Connectivité
│   ├── notification_service.dart    # Notifications locales
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


