# 🧪 Test avec les Émulateurs Firebase

## 🎯 Objectif

Tester l'application GèrTonArgent localement avec les émulateurs Firebase pour diagnostiquer le problème de persistance des données.

## 🚀 Configuration des Émulateurs

### **Émulateurs Configurés :**
- ✅ **Firestore Emulator** : Port 8080
- ✅ **Hosting Emulator** : Port 5000
- ✅ **Emulator UI** : Port 4000

## 🔧 Lancement des Émulateurs

### **Étape 1: Démarrer les Émulateurs**
```bash
firebase emulators:start
```

### **Étape 2: Vérifier les Émulateurs**
- **Emulator UI** : http://localhost:4000
- **Firestore** : http://localhost:8080
- **Hosting** : http://localhost:5000

## 🧪 Test de l'Application

### **Étape 1: Lancer l'Application Flutter**
```bash
flutter run -d chrome --web-port 3000
```

### **Étape 2: Test de Persistance**
1. **Connectez-vous** à l'application
2. **Ajoutez une dépense** de 1000 FCFA
3. **Vérifiez les logs** dans la console (F12)
4. **Actualisez la page** (F5)
5. **Vérifiez** que la transaction persiste

## 🔍 Logs à Surveiller

### **Lors du Démarrage :**
```
✅ Connected to Firestore emulator on localhost:8080
✅ Firebase initialized successfully
```

### **Lors de l'Ajout de Transaction :**
```
🔄 Adding transaction: [ID] - 1000.0 FCFA - expense - transport
✅ Transaction added to local storage
🌐 Saving to Firestore...
✅ Transaction saved to Firestore: [ID]
✅ Transaction verified in Firestore
```

### **Lors de l'Actualisation :**
```
🔄 Loading data for user: [Nom]
🔄 Force refreshing transactions for user [UID]
🔄 Loading transactions from Firestore for user: [UID]
📊 Found 1 transactions in Firestore
✅ Loaded 1 transactions from Firestore for user [UID]
```

## 📊 Vérification dans l'Emulator UI

### **Accéder à l'Emulator UI :**
1. **Ouvrez** http://localhost:4000
2. **Allez dans** "Firestore"
3. **Vérifiez** la collection `transactions`
4. **Vérifiez** que vos transactions apparaissent

### **Vérifier les Données :**
- **Collection `users`** : Votre utilisateur connecté
- **Collection `transactions`** : Vos transactions ajoutées
- **Vérifiez** que le `userId` correspond

## 🛠️ Diagnostic des Problèmes

### **Problème 1: Émulateur non connecté**
```
⚠️ Failed to connect to Firestore emulator: [erreur]
```

**Solution :**
- Vérifiez que les émulateurs sont démarrés
- Vérifiez le port 8080
- Redémarrez les émulateurs

### **Problème 2: Transaction non sauvegardée**
```
❌ Transaction not found in Firestore after save!
```

**Solution :**
- Vérifiez les règles Firestore dans l'émulateur
- Vérifiez que l'utilisateur est authentifié
- Vérifiez les logs de l'émulateur

### **Problème 3: Données non persistantes**
```
📊 Found 0 transactions in Firestore
```

**Solution :**
- Vérifiez que les transactions sont bien créées
- Vérifiez les permissions
- Vérifiez les logs de l'émulateur

## 🔧 Configuration des Règles Émulateur

### **Règles par Défaut (Test Mode) :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### **Règles de Production :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /transactions/{transactionId} {
      allow read, write, create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## 📈 Avantages des Émulateurs

### **1. Test Local Rapide**
- Pas de latence réseau
- Tests instantanés
- Développement plus rapide

### **2. Données Isolées**
- Pas de pollution des données de production
- Tests sécurisés
- Reset facile des données

### **3. Debugging Avancé**
- Logs détaillés
- Interface de visualisation
- Traçabilité complète

## 🎯 Résultat Attendu

Avec les émulateurs, vous devriez voir :
- ✅ **Connexion réussie** à l'émulateur Firestore
- ✅ **Sauvegarde des transactions** dans l'émulateur
- ✅ **Persistance des données** après actualisation
- ✅ **Logs détaillés** pour le debugging

## 🚀 Prochaines Étapes

1. **Testez avec les émulateurs**
2. **Identifiez le point de défaillance**
3. **Corrigez le problème**
4. **Testez en production**

---

**🧪 Utilisez les émulateurs pour diagnostiquer et résoudre le problème de persistance !**
