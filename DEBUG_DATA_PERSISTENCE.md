# 🔍 Guide de Débogage - Persistance des Données

## 🚨 Problème Identifié

L'utilisateur ajoute une dépense de 2500 FCFA, le solde affiche 147500 FCFA, mais après déconnexion/reconnexion, le solde revient à 150000 FCFA (comme si rien n'avait été fait).

## 🔧 Corrections Apportées

### 1. **Logs de Débogage Améliorés**
- ✅ Logs détaillés lors de l'ajout de transaction
- ✅ Vérification de la sauvegarde Firestore
- ✅ Logs de chargement des transactions
- ✅ Calcul des totaux pour débogage

### 2. **Widget de Débogage**
- ✅ `DebugInfoWidget` pour afficher les informations en temps réel
- ✅ Boutons pour forcer la synchronisation
- ✅ Affichage des transactions récentes
- ✅ Informations sur l'état de la connexion

### 3. **Vérification de Sauvegarde**
- ✅ Vérification que la transaction est bien sauvegardée dans Firestore
- ✅ Gestion d'erreur si la sauvegarde échoue
- ✅ Logs de débogage pour tracer le problème

## 🧪 Étapes de Test

### **Test 1: Ajout de Transaction avec Logs**
1. **Connectez-vous** à l'application
2. **Ouvrez la console** (F12 pour le web)
3. **Ajoutez une dépense** de 1000 FCFA
4. **Vérifiez les logs** dans la console :
   ```
   🔄 Adding transaction: [ID] - 1000.0 FCFA - expense - transport
   ✅ Transaction added to local storage
   🌐 Saving to Firestore...
   ✅ Transaction saved to Firestore: [ID]
   ✅ Transaction verified in Firestore
   ```

### **Test 2: Vérification Dashboard**
1. **Allez sur le dashboard**
2. **Cliquez sur "Afficher Debug"** (bouton orange)
3. **Vérifiez les informations** :
   - Nombre de transactions locales
   - Total dépenses
   - Mode hors ligne
4. **Cliquez sur "Forcer Sync"** pour recharger depuis Firestore

### **Test 3: Test de Persistance**
1. **Ajoutez une dépense** de 2000 FCFA
2. **Notez le solde** affiché
3. **Déconnectez-vous**
4. **Reconnectez-vous**
5. **Vérifiez le solde** et les logs de chargement

## 🔍 Logs à Surveiller

### **Lors de l'Ajout de Transaction**
```
🔄 Adding transaction: [ID] - 2000.0 FCFA - expense - transport
✅ Transaction added to local storage
🌐 Saving to Firestore...
✅ Transaction saved to Firestore: [ID]
✅ Transaction verified in Firestore
```

### **Lors du Chargement**
```
🔄 Loading transactions from Firestore for user: [UID]
📊 Found X transactions in Firestore
💰 Total Income: 0 FCFA
💸 Total Expenses: 2000 FCFA
📈 Net: -2000 FCFA
✅ Loaded X transactions from Firestore for user [UID]
```

### **Lors du Débogage**
```
🔍 Debugging data consistency for user: [UID]
📱 Local transactions: X
  - [ID]: 2000 FCFA (expense)
🌐 Firestore transactions: X
  - [ID]: 2000 FCFA (expense)
```

## 🚨 Problèmes Possibles

### **1. Transaction non sauvegardée dans Firestore**
**Symptômes :**
- Logs montrent "❌ Transaction not found in Firestore after save!"
- Solde correct localement mais pas après reconnexion

**Solutions :**
- Vérifiez les règles Firestore
- Vérifiez la connexion internet
- Vérifiez les permissions Firebase

### **2. Erreur de chargement depuis Firestore**
**Symptômes :**
- Logs montrent "❌ Error loading from Firestore"
- Mode hors ligne activé

**Solutions :**
- Vérifiez la connexion internet
- Vérifiez les règles Firestore
- Vérifiez l'ID utilisateur

### **3. Conflit entre données locales et Firestore**
**Symptômes :**
- Nombre différent de transactions locales vs Firestore
- Données incohérentes

**Solutions :**
- Utilisez "Forcer Sync" pour recharger depuis Firestore
- Vérifiez les logs de débogage
- Nettoyez les données locales si nécessaire

## 🛠️ Actions de Débogage

### **1. Vérifier les Règles Firestore**
```javascript
// Dans Firebase Console > Firestore > Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### **2. Vérifier la Connexion Internet**
- Testez la connexion internet
- Vérifiez que Firebase est accessible
- Vérifiez les logs de connexion

### **3. Vérifier les Permissions**
- Vérifiez que l'utilisateur est bien authentifié
- Vérifiez que l'UID correspond
- Vérifiez les permissions Firebase

## 📊 Informations de Débogage

### **Widget Debug Info**
Le widget affiche :
- 👤 Nom de l'utilisateur et UID
- 💰 Budget mensuel
- 📊 Nombre de transactions locales
- 📱 État de la connexion (hors ligne/online)
- 💸 Total dépenses et revenus
- 🔄 Boutons pour forcer la synchronisation

### **Logs Console**
Les logs incluent :
- Ajout de transactions
- Sauvegarde Firestore
- Chargement des données
- Vérification de cohérence
- Calculs des totaux

## 🎯 Résultat Attendu

Après les corrections, vous devriez voir :
1. **Logs détaillés** lors de l'ajout de transactions
2. **Vérification** que les données sont sauvegardées dans Firestore
3. **Persistance** des données après déconnexion/reconnexion
4. **Widget de débogage** pour diagnostiquer les problèmes

## 🚀 Prochaines Étapes

1. **Testez avec les nouveaux logs**
2. **Utilisez le widget de débogage**
3. **Vérifiez les logs dans la console**
4. **Identifiez le point de défaillance**
5. **Appliquez les corrections nécessaires**

---

**🔍 Utilisez ce guide pour diagnostiquer et résoudre le problème de persistance des données !**
