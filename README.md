# GèrTonArgent - Gestionnaire de Finances Personnelles

Une application Flutter moderne pour la gestion des finances personnelles, optimisée pour Android et Web, avec un backend Node.js et une base de données MySQL.

## 🚀 Fonctionnalités

- **Gestion des transactions** : Ajout, modification et suppression de revenus et dépenses
- **Suivi du budget** : Définition et suivi du budget mensuel par catégorie
- **Tableau de bord** : Visualisation des finances avec graphiques et statistiques
- **Conseils IA** : Assistant financier intelligent avec Google Gemini API
- **Mode hors ligne** : Stockage local avec synchronisation automatique
- **Interface responsive** : Optimisée pour mobile et web

## 🛠️ Architecture Technique

### Frontend (Flutter)
- **Framework** : Flutter 3.x
- **Langage** : Dart
- **Gestion d'état** : Provider Pattern
- **Stockage local** : Hive (base de données NoSQL)
- **Graphiques** : fl_chart
- **HTTP Client** : Dio
- **IA** : Google Gemini API

### Backend (Node.js)
- **Runtime** : Node.js
- **Framework** : Express.js
- **Base de données** : MySQL
- **Authentification** : JWT (JSON Web Tokens)
- **Sécurité** : bcrypt, helmet, rate limiting
- **Validation** : express-validator

## 📦 Installation

### Prérequis
- Flutter SDK 3.8.0 ou supérieur
- Node.js 18+ (pour le backend)
- MySQL 8.0+ (pour la base de données)
- Android Studio (pour le développement Android)

### 1. Cloner le Projet
```bash
git clone https://github.com/dav9fulldev/G-r-Ton-Argent.git
cd G-r-Ton-Argent
```

### 2. Configuration du Backend
Le backend est dans un repository séparé. Suivez les instructions dans le dossier `backend/` pour :
- Installer les dépendances Node.js
- Configurer la base de données MySQL
- Lancer le serveur API

### 3. Configuration du Frontend
```bash
# Installer les dépendances Flutter
flutter pub get

# Configurer l'URL de l'API
# Modifier lib/config/api_config.dart selon votre environnement
```

### 4. Lancer l'Application

#### Mode Développement
```bash
# Frontend
flutter run -d web-server --web-port 3000

# Backend (dans un autre terminal)
cd backend
npm start
```

#### Build de Production
```bash
# Android
flutter build apk --release

# Web
flutter build web --release
```

## 📊 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── config/
│   └── api_config.dart         # Configuration de l'API
├── models/                     # Modèles de données
│   ├── user_model.dart
│   ├── transaction_model.dart
│   └── budget_model.dart
├── services/                   # Services métier
│   ├── api_service.dart        # Service API REST
│   ├── auth_service.dart       # Authentification
│   ├── transaction_service.dart # Gestion des transactions
│   └── gemini_service.dart     # Service IA
├── screens/                    # Écrans de l'application
│   ├── auth/                   # Authentification
│   ├── home/                   # Tableau de bord
│   ├── transactions/           # Gestion des transactions
│   └── settings/               # Paramètres
└── widgets/                    # Composants réutilisables
    ├── charts/                 # Graphiques
    ├── forms/                  # Formulaires
    └── common/                 # Composants communs
```

## 🔧 Configuration

### Variables d'Environnement Backend
```env
# Base de données
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=votre_mot_de_passe
DB_NAME=gertonargent_db
DB_PORT=3306

# JWT
JWT_SECRET=votre_secret_jwt
JWT_EXPIRES_IN=7d

# Serveur
PORT=3001
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000
```

### Configuration Frontend
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3001/api';
  // Pour la production : 'https://votre-api.com/api'
}
```

## 🧪 Tests

```bash
# Tests Flutter
flutter test

# Tests Backend
cd backend
npm test
```

## 📱 Captures d'Écran

*Captures d'écran à ajouter*

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation du backend
- Vérifier les logs de l'application

## 🔄 Changelog

### Version 2.0.0
- Migration de Firebase vers Node.js + MySQL
- Nouvelle architecture backend REST
- Amélioration des performances
- Support complet hors ligne

### Version 1.0.0
- Version initiale avec Firebase
- Fonctionnalités de base
- Interface utilisateur