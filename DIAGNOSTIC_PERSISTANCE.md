# 🔍 Diagnostic - Problème de Persistance des Données

## 🚨 Problème Actuel

L'utilisateur ajoute une dépense (solde passe de 150 000 à 135 000 FCFA), mais après actualisation de la page, le solde revient à 150 000 FCFA.

## 🧪 Étapes de Diagnostic

### **Étape 1: Utiliser le Widget de Débogage**

1. **Ouvrez l'application** dans le navigateur
2. **Connectez-vous** avec votre compte
3. **Allez sur le dashboard**
4. **Cliquez sur "Afficher Debug"** (bouton orange)
5. **Notez les informations affichées** :
   - Nombre de transactions locales
   - Total dépenses
   - Mode hors ligne (Oui/Non)

### **Étape 2: Ajouter une Transaction de Test**

1. **Ouvrez la console** (F12 → Console)
2. **Ajoutez une dépense** de 1000 FCFA
3. **Surveillez les logs** dans la console
4. **Vérifiez le widget de débogage** après l'ajout

### **Étape 3: Actualiser la Page**

1. **Actualisez la page** (F5 ou Ctrl+R)
2. **Surveillez les logs** de chargement
3. **Vérifiez le widget de débogage** après actualisation
4. **Comparez** les données avant/après

## 🔍 Logs à Surveiller

### **Lors de l'Ajout de Transaction**
```
🔄 Adding transaction: [ID] - 1000.0 FCFA - expense - transport
✅ Transaction added to local storage
🌐 Saving to Firestore...
✅ Transaction saved to Firestore: [ID]
✅ Transaction verified in Firestore
```

### **Lors de l'Actualisation**
```
🔄 Loading data for user: [Nom]
🔄 Force refreshing transactions for user [UID]
🔄 Loading transactions from Firestore for user: [UID]
📊 Found X transactions in Firestore
💰 Total Income: 0 FCFA
💸 Total Expenses: 1000 FCFA
📈 Net: -1000 FCFA
✅ Loaded X transactions from Firestore for user [UID]
```

### **Lors du Débogage**
```
🔍 Debugging data consistency for user: [UID]
📱 Local transactions: X
  - [ID]: 1000 FCFA (expense)
🌐 Firestore transactions: X
  - [ID]: 1000 FCFA (expense)
```

## 🚨 Problèmes Possibles

### **1. Transaction non sauvegardée dans Firestore**
**Symptômes :**
- Logs montrent "❌ Transaction not found in Firestore after save!"
- Widget de débogage : 0 transactions locales après actualisation

**Cause :**
- Problème de permissions Firestore
- Problème de connexion internet
- Erreur dans les règles Firestore

### **2. Erreur de chargement depuis Firestore**
**Symptômes :**
- Logs montrent "❌ Error loading from Firestore"
- Widget de débogage : Mode hors ligne = Oui

**Cause :**
- Problème de connexion internet
- Problème de permissions Firestore
- Erreur dans l'ID utilisateur

### **3. Conflit entre données locales et Firestore**
**Symptômes :**
- Nombre différent de transactions locales vs Firestore
- Données incohérentes dans le widget de débogage

**Cause :**
- Données locales obsolètes
- Problème de synchronisation

## 🛠️ Actions de Diagnostic

### **Action 1: Vérifier les Règles Firestore**
```javascript
// Dans Firebase Console > Firestore > Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

### **Action 2: Utiliser "Forcer Sync"**
1. **Cliquez sur "Forcer Sync"** dans le widget de débogage
2. **Surveillez les logs** de synchronisation
3. **Vérifiez** si les données se mettent à jour

### **Action 3: Utiliser "Vérifier"**
1. **Cliquez sur "Vérifier"** dans le widget de débogage
2. **Comparez** les transactions locales vs Firestore
3. **Identifiez** les incohérences

## 📊 Informations du Widget de Débogage

### **Informations Utilisateur**
- 👤 **Nom** : Nom de l'utilisateur connecté
- 🆔 **UID** : Identifiant unique de l'utilisateur
- 💰 **Budget** : Budget mensuel actuel

### **Informations Transactions**
- 📊 **Transactions locales** : Nombre de transactions en mémoire
- 📱 **Mode hors ligne** : État de la connexion
- 💸 **Total dépenses** : Somme des dépenses
- 💰 **Total revenus** : Somme des revenus

### **Actions Disponibles**
- 🔄 **Forcer Sync** : Recharge depuis Firestore
- 🔍 **Vérifier** : Compare local vs Firestore

## 🎯 Résultat Attendu

Après diagnostic, vous devriez voir :
1. **Logs détaillés** dans la console
2. **Informations cohérentes** dans le widget de débogage
3. **Persistance des données** après actualisation
4. **Synchronisation correcte** entre local et Firestore

## 🚀 Prochaines Étapes

1. **Suivez les étapes de diagnostic**
2. **Notez les logs et informations** du widget de débogage
3. **Identifiez le point de défaillance**
4. **Appliquez les corrections nécessaires**

---

**🔍 Utilisez ce guide pour diagnostiquer et résoudre le problème de persistance des données !**
