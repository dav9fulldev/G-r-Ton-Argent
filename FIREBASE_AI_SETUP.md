# Configuration Firebase AI Logic avec Gemini

## 🚀 Vue d'ensemble

Cette application utilise **Firebase AI Logic** pour intégrer **Google Gemini** et fournir des conseils financiers intelligents aux utilisateurs.

## 📋 Prérequis

1. **Projet Firebase** configuré
2. **Firebase AI Logic** activé dans votre projet
3. **Clé API Gemini** configurée dans Firebase

## ⚙️ Configuration Firebase AI Logic

### 1. Activer Firebase AI Logic

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Dans le menu de gauche, cliquez sur **"AI"** (ou **"Extensions"** → **"AI"**)
4. Cliquez sur **"Get started"** ou **"Activer"**

### 2. Configurer Gemini

1. Dans la section AI, sélectionnez **"Gemini"**
2. Cliquez sur **"Configure"**
3. Entrez votre **clé API Gemini** :
   - Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Créez une nouvelle clé API
   - Copiez la clé et collez-la dans Firebase

### 3. Modèles disponibles

L'application utilise le modèle `gemini-1.5-flash` qui est :
- ✅ Rapide et efficace
- ✅ Adapté pour les conseils financiers
- ✅ Supporte le français
- ✅ Limite de tokens appropriée

## 🔧 Configuration dans l'Application

### Variables d'environnement (optionnel)

Pour une configuration plus sécurisée, vous pouvez utiliser des variables d'environnement :

```bash
# .env
FIREBASE_AI_PROJECT_ID=votre-project-id
GEMINI_API_KEY=votre-gemini-api-key
```

### Configuration Firebase

Assurez-vous que votre `firebase_options.dart` contient les bonnes valeurs :

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'votre-api-key',
  appId: 'votre-app-id',
  messagingSenderId: 'votre-sender-id',
  projectId: 'votre-project-id',
  // ... autres configurations
);
```

## 🧪 Test de l'Intégration

### Test manuel

1. Lancez l'application
2. Allez dans **Paramètres** → activez **"Conseils IA"**
3. Ajoutez une nouvelle dépense
4. Cliquez sur **"Obtenir un conseil IA"**
5. Vérifiez que les conseils s'affichent

### Test automatisé

```bash
# Lancer les tests
flutter test test/gemini_service_test.dart
```

## 📊 Monitoring et Logs

### Firebase Console

1. Allez dans **"AI"** → **"Usage"**
2. Surveillez :
   - Nombre de requêtes
   - Tokens utilisés
   - Erreurs éventuelles

### Logs de l'Application

Les logs sont disponibles dans la console de développement :

```dart
// Exemple de log
print('Gemini API appelée avec succès');
print('Conseils générés: ${conseils.length}');
```

## 🔒 Sécurité

### Bonnes pratiques

1. **Ne jamais exposer la clé API** dans le code client
2. **Utiliser Firebase AI Logic** comme proxy sécurisé
3. **Limiter les requêtes** par utilisateur
4. **Valider les entrées** avant envoi à Gemini

### Rate Limiting

L'application inclut une gestion des limites de taux :

```dart
// Exemple de gestion d'erreur
try {
  final conseils = await geminiService.getConseilsIA(budget, depenses, nouvelleDepense);
} catch (e) {
  if (e.toString().contains('rate limit')) {
    // Afficher un message d'erreur approprié
  }
}
```

## 🐛 Dépannage

### Erreurs courantes

1. **"Firebase AI not configured"**
   - Vérifiez que Firebase AI Logic est activé
   - Vérifiez la clé API Gemini

2. **"Model not found"**
   - Vérifiez que le modèle `gemini-1.5-flash` est disponible
   - Vérifiez les permissions Firebase

3. **"Rate limit exceeded"**
   - Attendez quelques minutes
   - Vérifiez votre quota Gemini

### Logs de débogage

Activez les logs détaillés :

```dart
// Dans main.dart
if (kDebugMode) {
  print('Firebase AI configuré avec succès');
}
```

## 📈 Optimisation

### Performance

1. **Cache des conseils** : Les conseils sont mis en cache localement
2. **Requêtes optimisées** : Limitation à 300 tokens par réponse
3. **Fallback local** : Conseils par défaut en cas d'erreur

### Coûts

- **Gemini 1.5 Flash** : ~$0.000075 / 1K tokens input, ~$0.0003 / 1K tokens output
- **Estimation** : ~$0.001 par conseil financier
- **Recommandation** : Limiter à 10 conseils par utilisateur par jour

## 🔄 Mise à jour

### Mise à jour du modèle

Pour changer de modèle Gemini :

1. Modifiez `FirebaseAIConfig.geminiModel`
2. Testez avec le nouveau modèle
3. Mettez à jour la documentation

### Mise à jour des prompts

Les prompts sont dans `lib/firebase_ai_config.dart` :

```dart
static const String financialAdvisorSystemPrompt = '''
// Votre nouveau prompt ici
''';
```

## 📞 Support

Pour toute question ou problème :

1. Vérifiez les logs Firebase Console
2. Consultez la [documentation Firebase AI](https://firebase.google.com/docs/ai)
3. Consultez la [documentation Gemini](https://ai.google.dev/docs)

---

**Note** : Cette configuration utilise Firebase AI Logic comme proxy sécurisé vers Gemini, évitant ainsi d'exposer directement la clé API dans l'application mobile.
