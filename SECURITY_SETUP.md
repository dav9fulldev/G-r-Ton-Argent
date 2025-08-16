# 🔒 Guide de Sécurité - Configuration des Clés API

## ⚠️ IMPORTANT : Sécurité des Clés API

Ce projet utilise des clés API sensibles qui ne doivent **JAMAIS** être exposées publiquement.

## 🛡️ Configuration Sécurisée

### 1. Fichiers de Configuration

- **`lib/config/api_keys.dart`** : Contient vos vraies clés API (IGNORÉ par Git)
- **`lib/config/api_keys.example.dart`** : Exemple de structure (COMMITÉ dans Git)

### 2. Configuration Initiale

1. **Copiez le fichier d'exemple** :
   ```bash
   cp lib/config/api_keys.example.dart lib/config/api_keys.dart
   ```

2. **Remplacez les clés par vos vraies clés** :
   ```dart
   static const String geminiApiKey = 'AIzaSyC...'; // Votre vraie clé
   ```

3. **Vérifiez que le fichier est ignoré** :
   ```bash
   git status
   # lib/config/api_keys.dart ne doit PAS apparaître
   ```

### 3. Vérification de Sécurité

Le fichier `api_keys.dart` est automatiquement ignoré par Git grâce au `.gitignore` :

```gitignore
# API Keys and sensitive configuration
lib/config/api_keys.dart
```

## 🔍 Vérification

### Test de Configuration

```bash
# Vérifier que les clés sont configurées
flutter test test/gemini_service_test.dart
```

### Vérification Git

```bash
# Vérifier que les clés ne sont pas commitées
git status
git diff --cached
```

## 🚨 Bonnes Pratiques

### ✅ À FAIRE

- ✅ Utiliser `api_keys.dart` pour les vraies clés
- ✅ Garder `api_keys.example.dart` comme exemple
- ✅ Vérifier que `api_keys.dart` est dans `.gitignore`
- ✅ Utiliser des variables d'environnement en production
- ✅ Régénérer les clés API régulièrement

### ❌ À NE PAS FAIRE

- ❌ Commiter `api_keys.dart` dans Git
- ❌ Partager les clés API publiquement
- ❌ Utiliser les mêmes clés en développement et production
- ❌ Stocker les clés dans le code source
- ❌ Ignorer les alertes de sécurité

## 🔄 Mise à Jour des Clés

### 1. Régénérer une Clé API

1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Supprimez l'ancienne clé
3. Créez une nouvelle clé
4. Mettez à jour `api_keys.dart`

### 2. Rotation des Clés

- Changez les clés tous les 3-6 mois
- Utilisez des clés différentes par environnement
- Surveillez l'utilisation des clés

## 🚀 Déploiement Sécurisé

### Variables d'Environnement (Recommandé)

Pour une sécurité maximale, utilisez des variables d'environnement :

```dart
// Dans api_keys.dart
static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
```

```bash
# Lancement avec variable d'environnement
flutter run --dart-define=GEMINI_API_KEY=votre-cle-api
```

### Firebase Functions (Alternative)

Pour une sécurité encore plus élevée, utilisez Firebase Functions comme proxy :

```dart
// Appel via Firebase Functions au lieu d'appel direct
final response = await FirebaseFunctions.instance
    .httpsCallable('generateAdvice')
    .call({'prompt': prompt});
```

## 📞 Support Sécurité

En cas de compromission de clés API :

1. **Régénérez immédiatement** la clé compromise
2. **Vérifiez les logs** d'utilisation
3. **Mettez à jour** tous les environnements
4. **Contactez le support** si nécessaire

---

**Rappel** : La sécurité de vos clés API est de votre responsabilité. Suivez toujours les bonnes pratiques de sécurité.
