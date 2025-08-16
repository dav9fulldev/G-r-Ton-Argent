# 🚀 Guide de Configuration Gemini pour GèrTonArgent

## ✅ Configuration Terminée

L'intégration Firebase AI Logic avec Google Gemini a été **complètement implémentée** et testée. Voici comment configurer et utiliser la fonctionnalité :

## 🔧 Configuration Requise

### 1. Obtenir une Clé API Gemini

1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Connectez-vous avec votre compte Google
3. Cliquez sur **"Create API Key"**
4. Copiez la clé API générée

### 2. Configurer la Clé API dans l'Application

Ouvrez le fichier `lib/services/gemini_service.dart` et remplacez :

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // À remplacer par votre clé API
```

Par votre vraie clé API :

```dart
static const String _apiKey = 'AIzaSyC...'; // Votre vraie clé API
```

### 3. Sécurité (Recommandé)

Pour une meilleure sécurité, vous pouvez :

1. **Utiliser des variables d'environnement** :
   ```dart
   static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
   ```

2. **Lancer l'app avec la variable** :
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=votre-cle-api
   ```

## 🧪 Test de l'Intégration

### Test Automatisé
```bash
flutter test test/gemini_service_test.dart
```

### Test Manuel
1. Lancez l'application : `flutter run`
2. Connectez-vous à votre compte
3. Allez dans **Paramètres** → activez **"Conseils IA"**
4. Ajoutez une nouvelle dépense
5. Cliquez sur **"Obtenir un conseil IA"**
6. Vérifiez que les conseils s'affichent

## 🎯 Fonctionnalités Disponibles

### 1. Conseils lors de l'Ajout de Dépense
- **Déclencheur** : Ajout d'une nouvelle dépense
- **Données utilisées** : Budget mensuel, dépenses actuelles, nouvelle dépense
- **Résultat** : 2-3 conseils personnalisés en français

### 2. Conseils du Dashboard
- **Déclencheur** : Chargement du dashboard
- **Données utilisées** : Solde actuel, budget, historique des transactions
- **Résultat** : Conseils généraux adaptés à la situation

### 3. Gestion Conditionnelle
- **Switch dans les paramètres** : Active/désactive les conseils IA
- **Fallback automatique** : Conseils locaux si IA désactivée ou erreur
- **Persistance** : Sauvegarde du choix dans Firestore

## 🔒 Sécurité et Performance

### Sécurité
- ✅ **Validation des entrées** avant envoi à Gemini
- ✅ **Gestion d'erreurs** robuste avec fallback
- ✅ **Limitation des tokens** (400 max par requête)
- ⚠️ **Clé API exposée** : Utilisez des variables d'environnement en production

### Performance
- ✅ **Requêtes optimisées** (400 tokens max)
- ✅ **Cache local** des conseils
- ✅ **Fallback local** en cas d'erreur
- ✅ **Gestion des timeouts**

## 📊 Coûts Estimés

- **Gemini 1.5 Flash** : ~$0.000075 / 1K tokens input, ~$0.0003 / 1K tokens output
- **Conseil moyen** : ~$0.001 par conseil
- **Recommandation** : Limiter à 10 conseils/utilisateur/jour

## 🐛 Dépannage

### Erreurs Courantes

1. **"Clé API Gemini non configurée"**
   - Vérifiez que vous avez remplacé `YOUR_GEMINI_API_KEY` par votre vraie clé
   - Redémarrez l'application après modification

2. **"Erreur API: 400"**
   - Vérifiez que votre clé API est valide
   - Vérifiez votre quota Gemini

3. **"Erreur API: 403"**
   - Vérifiez les permissions de votre clé API
   - Activez l'API Gemini dans Google Cloud Console

4. **Conseils par défaut s'affichent**
   - Normal si IA désactivée ou erreur réseau
   - Vérifiez la connexion internet
   - Vérifiez les logs pour plus de détails

### Logs de Débogage

Activez les logs détaillés dans `lib/services/gemini_service.dart` :

```dart
if (kDebugMode) {
  print('Appel Gemini avec prompt: $prompt');
  print('Réponse Gemini: $response');
}
```

## 🔄 Mise à Jour

### Modifier les Prompts
Éditez les méthodes `_buildPrompt()` dans `lib/services/gemini_service.dart`

### Changer le Modèle
Modifiez `_baseUrl` dans `lib/services/gemini_service.dart` :
```dart
static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
```

### Ajuster les Paramètres
Modifiez `generationConfig` dans `_callGemini()` :
```dart
'generationConfig': {
  'temperature': 0.8,    // Créativité (0.0-1.0)
  'topK': 50,           // Diversité
  'topP': 0.9,          // Cohérence
  'maxOutputTokens': 400, // Longueur max
},
```

## 📞 Support

Pour toute question ou problème :

1. **Vérifiez les logs** de l'application
2. **Testez avec les conseils par défaut** (désactivez IA temporairement)
3. **Consultez la documentation Gemini** : [Google AI Studio](https://makersuite.google.com/)
4. **Vérifiez votre quota** dans Google Cloud Console

## 🎉 Résultat Final

Une fois configurée, votre application "GèrTonArgent" fournira des **conseils financiers intelligents et personnalisés** en français, adaptés au contexte ivoirien, avec une gestion robuste des erreurs et un fallback vers des conseils locaux.

---

**Status** : ✅ **INTÉGRATION TERMINÉE ET FONCTIONNELLE**
