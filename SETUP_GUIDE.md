# Guide de Configuration GèrTonArgent

## 🔧 Problèmes Corrigés

### 1. Erreurs de Syntaxe dans main.dart
- ✅ Ajout du point-virgule manquant après `FlutterLocalNotificationsPlugin()`
- ✅ Import de `firebase_messaging` et `flutter_local_notifications`
- ✅ Configuration complète des notifications Firebase

### 2. Configuration Firebase
- ✅ Fichiers de configuration présents (`google-services.json`, `firebase_options.dart`)
- ✅ Règles Firestore créées pour la sécurité
- ✅ Initialisation correcte de Firebase dans `main.dart`

### 3. Configuration Hive
- ✅ Adaptateurs générés avec `build_runner`
- ✅ Enregistrement des adaptateurs dans `main.dart`
- ✅ Configuration du stockage local

### 4. Service de Transactions
- ✅ Amélioration de la gestion des erreurs
- ✅ Logs de débogage ajoutés
- ✅ Synchronisation offline/online

## 📋 Étapes de Configuration Physique

### Étape 1: Configuration Firebase Console

1. **Accédez à la [Console Firebase](https://console.firebase.google.com/)**
2. **Sélectionnez votre projet `gtonargent-app`**
3. **Activez l'authentification Email/Mot de passe:**
   - Allez dans "Authentication" → "Sign-in method"
   - Activez "Email/Password"
   - Cliquez sur "Save"

4. **Configurez Firestore Database:**
   - Allez dans "Firestore Database"
   - Créez une base de données si elle n'existe pas
   - Choisissez "Start in test mode" pour le développement
   - Sélectionnez une région (Europe-west1 recommandé)

5. **Déployez les règles Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

### Étape 2: Configuration des Notifications

1. **Dans Firebase Console:**
   - Allez dans "Cloud Messaging"
   - Notez votre "Server key" (sera nécessaire pour les notifications push)

2. **Configuration Android:**
   - Le fichier `google-services.json` est déjà présent
   - Les permissions sont configurées dans `AndroidManifest.xml`

### Étape 3: Test de l'Application

1. **Nettoyez et reconstruisez l'application:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Testez l'authentification:**
   - Créez un compte avec email/mot de passe
   - Vérifiez que l'utilisateur apparaît dans Firebase Console

3. **Testez l'ajout de transactions:**
   - Ajoutez une transaction
   - Vérifiez qu'elle apparaît dans Firestore
   - Vérifiez les logs dans la console

## 🔍 Vérification du Fonctionnement

### Vérifiez les Logs
L'application affiche maintenant des logs détaillés:
- `Firebase initialized successfully`
- `Transaction saved to Firestore: [ID]`
- `NotificationService initialized successfully`

### Test de Connectivité
1. **Mode Online:** Les transactions se sauvegardent immédiatement
2. **Mode Offline:** Les transactions sont mises en file d'attente
3. **Reconnexion:** Synchronisation automatique des données

## 🚨 Résolution des Problèmes

### Si les transactions ne se sauvegardent pas:
1. Vérifiez que Firebase est initialisé (logs)
2. Vérifiez la connectivité internet
3. Vérifiez les règles Firestore
4. Vérifiez que l'utilisateur est authentifié

### Si les notifications ne fonctionnent pas:
1. Vérifiez les permissions Android
2. Vérifiez que les canaux sont créés
3. Vérifiez le token FCM dans les logs

### Si Hive ne fonctionne pas:
1. Relancez `flutter packages pub run build_runner build`
2. Vérifiez que les adaptateurs sont enregistrés
3. Nettoyez l'application: `flutter clean`

## 📱 Configuration Recommandée

### Variables d'Environnement
Créez un fichier `.env` (optionnel):
```
FIREBASE_PROJECT_ID=gtonargent-app
FIREBASE_API_KEY=your-api-key
```

### Optimisations
1. **Cache:** L'application utilise Hive pour le cache local
2. **Synchronisation:** Synchronisation automatique offline/online
3. **Notifications:** Canaux configurés pour différents types d'alertes

## ✅ Checklist de Validation

- [ ] Firebase Authentication activé
- [ ] Firestore Database créé
- [ ] Règles Firestore déployées
- [ ] Application compile sans erreurs
- [ ] Authentification fonctionne
- [ ] Transactions se sauvegardent
- [ ] Notifications locales fonctionnent
- [ ] Stockage local Hive fonctionne

## 🆘 Support

Si vous rencontrez des problèmes:
1. Vérifiez les logs dans la console Flutter
2. Vérifiez la console Firebase pour les erreurs
3. Testez avec un compte de test
4. Vérifiez la connectivité réseau
