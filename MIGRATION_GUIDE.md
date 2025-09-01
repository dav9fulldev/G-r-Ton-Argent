# 🚀 Guide de Migration : Firebase → Node.js + MySQL

Ce guide détaille la migration complète de l'application GèrTonArgent de Firebase vers une architecture Node.js + MySQL avec API REST.

## 📋 Résumé de la Migration

### Avant (Firebase)
- **Authentification** : Firebase Auth
- **Base de données** : Firestore (NoSQL)
- **Hébergement** : Firebase Hosting
- **Problèmes** : Persistance des données, coût, complexité

### Après (Node.js + MySQL)
- **Authentification** : JWT + bcrypt
- **Base de données** : MySQL (SQL)
- **API** : REST avec Express.js
- **Avantages** : Contrôle total, persistance garantie, coût réduit

## 🛠️ Architecture Technique

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Node.js API   │    │   MySQL DB      │
│                 │    │                 │    │                 │
│ • UI/UX         │◄──►│ • Express.js    │◄──►│ • Users         │
│ • Hive (local)  │    │ • JWT Auth      │    │ • Transactions  │
│ • HTTP Client   │    │ • Validation    │    │ • Budgets       │
│ • Offline Sync  │    │ • Rate Limiting │    │ • Analytics     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Structure du Projet

```
GerTonArgent/
├── lib/                          # Application Flutter
│   ├── config/
│   │   └── api_config.dart       # Configuration API
│   ├── models/                   # Modèles de données
│   ├── services/
│   │   ├── api_service.dart      # Service API REST
│   │   ├── auth_service.dart     # Authentification
│   │   └── transaction_service.dart
│   └── screens/                  # Écrans de l'application
├── backend/                      # API Node.js
│   ├── config/
│   │   └── database.js           # Configuration MySQL
│   ├── middleware/
│   │   └── auth.js               # Middleware JWT
│   ├── routes/                   # Routes API
│   ├── server.js                 # Serveur principal
│   └── package.json
└── README.md
```

## 🔄 Étapes de Migration

### 1. Préparation de l'Environnement

#### Backend Node.js
```bash
cd backend
npm install
cp env.example .env
# Configurer les variables d'environnement
```

#### Base de Données MySQL
```sql
CREATE DATABASE gertonargent_db;
CREATE USER 'gertonargent_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON gertonargent_db.* TO 'gertonargent_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Migration des Données (Optionnel)

Si vous avez des données existantes dans Firebase :

```javascript
// Script de migration Firebase → MySQL
const admin = require('firebase-admin');
const mysql = require('mysql2/promise');

// 1. Exporter les données Firebase
// 2. Transformer les données
// 3. Importer dans MySQL
```

### 3. Configuration Flutter

#### Mise à jour des dépendances
```yaml
# pubspec.yaml
dependencies:
  http: ^1.2.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  # Supprimer les dépendances Firebase
```

#### Configuration API
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  // Configuration pour production
  // static const String baseUrl = 'https://your-api-domain.com/api';
}
```

### 4. Services Migrés

#### AuthService
- ✅ Firebase Auth → JWT + bcrypt
- ✅ Gestion des tokens locaux
- ✅ Persistance des sessions

#### TransactionService
- ✅ Firestore → MySQL via API REST
- ✅ Synchronisation offline avec Hive
- ✅ Gestion des erreurs réseau

#### ApiService
- ✅ Client HTTP avec Dio
- ✅ Intercepteurs pour JWT
- ✅ Gestion des timeouts

## 🚀 Déploiement

### Backend (API)

#### Option 1 : Render (Recommandé)
1. Connecter le repository GitHub
2. Configurer les variables d'environnement
3. Déployer automatiquement

#### Option 2 : Heroku
```bash
heroku create gertonargent-api
heroku config:set NODE_ENV=production
git push heroku main
```

#### Option 3 : VPS
```bash
# Installer PM2
npm install -g pm2

# Démarrer l'application
pm2 start server.js --name "gertonargent-api"

# Configurer Nginx
sudo nano /etc/nginx/sites-available/gertonargent-api
```

### Frontend (Flutter Web)

#### Option 1 : Vercel
```bash
flutter build web
vercel --prod
```

#### Option 2 : Netlify
```bash
flutter build web
netlify deploy --prod --dir=build/web
```

#### Option 3 : Firebase Hosting (gardé pour le web)
```bash
flutter build web
firebase deploy --only hosting
```

## 🔧 Configuration de Production

### Variables d'Environnement Backend
```env
# Production
NODE_ENV=production
DB_HOST=your-mysql-host
DB_USER=your-mysql-user
DB_PASSWORD=your-mysql-password
DB_NAME=gertonargent_db
JWT_SECRET=your-super-secret-jwt-key
CORS_ORIGIN=https://your-flutter-app.com
```

### Configuration Flutter Production
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com/api';
}
```

## 🧪 Tests et Validation

### Tests Backend
```bash
cd backend
npm test
```

### Tests Flutter
```bash
flutter test
flutter analyze
```

### Tests d'Intégration
```bash
# Tester l'API
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

## 📊 Monitoring et Logs

### Backend
```javascript
// Ajouter Winston pour les logs
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### Flutter
```dart
// Ajouter des logs pour le debugging
import 'package:logging/logging.dart';

final _logger = Logger('ApiService');
_logger.info('API request: ${request.url}');
```

## 🔒 Sécurité

### Backend
- ✅ Helmet.js pour les headers de sécurité
- ✅ Rate limiting pour prévenir les attaques
- ✅ Validation des données avec express-validator
- ✅ Hashage des mots de passe avec bcrypt
- ✅ JWT avec expiration

### Frontend
- ✅ Stockage sécurisé des tokens
- ✅ Validation côté client
- ✅ Gestion des erreurs réseau
- ✅ Mode offline avec Hive

## 📈 Performance

### Optimisations Backend
- ✅ Pool de connexions MySQL
- ✅ Index sur les colonnes fréquemment utilisées
- ✅ Pagination des résultats
- ✅ Cache Redis (optionnel)

### Optimisations Flutter
- ✅ Stockage local avec Hive
- ✅ Synchronisation intelligente
- ✅ Gestion du cache des images
- ✅ Lazy loading des données

## 🐛 Dépannage

### Problèmes Courants

#### 1. Erreur de Connexion à la Base de Données
```bash
# Vérifier MySQL
sudo systemctl status mysql
mysql -u root -p
SHOW DATABASES;
```

#### 2. Erreur CORS
```javascript
// backend/server.js
app.use(cors({
  origin: process.env.CORS_ORIGIN,
  credentials: true
}));
```

#### 3. Token JWT Expiré
```dart
// lib/services/api_service.dart
if (response.statusCode == 401) {
  await _clearToken();
  // Rediriger vers login
}
```

#### 4. Synchronisation Offline
```dart
// Vérifier la connectivité
if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
  // Mode offline
  return await _loadFromLocal();
}
```

## 📚 Ressources

### Documentation
- [Express.js Documentation](https://expressjs.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [JWT Documentation](https://jwt.io/)
- [Flutter HTTP Package](https://pub.dev/packages/http)

### Outils Utiles
- [Postman](https://www.postman.com/) - Tester l'API
- [MySQL Workbench](https://www.mysql.com/products/workbench/) - Gérer la base de données
- [Insomnia](https://insomnia.rest/) - Alternative à Postman

## 🎯 Prochaines Étapes

1. **Tests de Charge** - Vérifier les performances
2. **Monitoring** - Ajouter des métriques
3. **Backup** - Configurer les sauvegardes automatiques
4. **SSL** - Configurer HTTPS
5. **CDN** - Optimiser la livraison de contenu

## 📞 Support

Pour toute question ou problème :
1. Vérifier les logs du serveur
2. Consulter la documentation
3. Ouvrir une issue sur GitHub
4. Contacter l'équipe de développement

---

**Migration terminée ! 🎉**

Votre application GèrTonArgent utilise maintenant une architecture Node.js + MySQL robuste et évolutive.
