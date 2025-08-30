# 🚀 GitHub Actions Workflows - GèrTonArgent

## 📋 Vue d'ensemble

Ce projet utilise GitHub Actions pour automatiser le déploiement Firebase et la validation du code Flutter. Les workflows sont configurés pour :

- ✅ **Tests automatiques** sur chaque push/PR
- ✅ **Déploiement automatique** sur merge vers master/main
- ✅ **Prévisualisation** sur Pull Requests
- ✅ **Déploiement manuel** avec choix d'environnement

## 🔧 Workflows Configurés

### 1. **firebase-hosting-merge.yml**
**Déclencheur :** Push sur `master` ou `main`
**Actions :**
- Installation de Flutter 3.19.0
- Récupération des dépendances
- Génération des adaptateurs Hive
- Build de l'application web
- Déploiement sur Firebase Hosting (production)

### 2. **firebase-hosting-pull-request.yml**
**Déclencheur :** Pull Request
**Actions :**
- Installation de Flutter 3.19.0
- Récupération des dépendances
- Génération des adaptateurs Hive
- Build de l'application web
- Déploiement sur Firebase Hosting (preview)

### 3. **flutter-test.yml**
**Déclencheur :** Push/PR sur `master`, `main`, `develop`
**Actions :**
- **Tests :** Analyse, tests unitaires, build web/Android
- **Lint :** Vérification du code avec `flutter analyze`
- **Format :** Vérification du formatage avec `dart format`

### 4. **manual-deploy.yml**
**Déclencheur :** Déclenchement manuel
**Actions :**
- Tests complets
- Build de l'application
- Déploiement Firebase (staging ou production)
- Déploiement des règles Firestore

## 🔑 Secrets Requis

Configurez ces secrets dans votre repository GitHub :

### **FIREBASE_SERVICE_ACCOUNT_GTONARGENT_APP**
```json
{
  "type": "service_account",
  "project_id": "gtonargent-app",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-...@gtonargent-app.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

### **FIREBASE_TOKEN** (optionnel)
Token Firebase CLI pour le déploiement des règles Firestore.

## 🛠️ Configuration des Secrets

### 1. **Générer la clé de service Firebase**
```bash
# Dans Firebase Console
1. Allez dans Project Settings > Service Accounts
2. Cliquez sur "Generate new private key"
3. Téléchargez le fichier JSON
```

### 2. **Configurer dans GitHub**
```bash
# Dans votre repository GitHub
1. Settings > Secrets and variables > Actions
2. Cliquez sur "New repository secret"
3. Nom: FIREBASE_SERVICE_ACCOUNT_GTONARGENT_APP
4. Valeur: Contenu du fichier JSON téléchargé
```

## 🚀 Utilisation

### **Déploiement Automatique**
- Push sur `master` → Déploiement automatique en production
- Pull Request → Prévisualisation automatique

### **Déploiement Manuel**
1. Allez dans **Actions** > **Manual Deploy to Firebase**
2. Cliquez sur **Run workflow**
3. Choisissez l'environnement (staging/production)
4. Cliquez sur **Run workflow**

### **Tests Automatiques**
- Chaque push/PR déclenche automatiquement les tests
- Vérification du code, formatage, et builds

## 📊 Monitoring

### **Statuts des Workflows**
- ✅ **Succès** : Déploiement réussi
- ❌ **Échec** : Erreur dans le processus
- ⏳ **En cours** : Workflow en cours d'exécution

### **Logs de Débogage**
Les workflows incluent des logs détaillés pour :
- Installation de Flutter
- Récupération des dépendances
- Génération des adaptateurs Hive
- Build de l'application
- Déploiement Firebase

## 🔧 Personnalisation

### **Modifier la version Flutter**
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.19.0'  # Changez ici
    channel: 'stable'
```

### **Ajouter des étapes personnalisées**
```yaml
- name: Custom step
  run: |
    echo "Votre commande personnalisée"
    # Autres commandes...
```

### **Modifier les branches déclencheuses**
```yaml
on:
  push:
    branches: [ master, main, develop, feature/* ]  # Ajoutez vos branches
```

## 🚨 Dépannage

### **Erreurs Communes**

#### **1. Flutter non trouvé**
```bash
# Solution : Vérifiez la version Flutter
flutter-version: '3.19.0'  # Doit correspondre à votre projet
```

#### **2. Dépendances manquantes**
```bash
# Solution : Vérifiez pubspec.yaml
flutter pub get  # Doit s'exécuter sans erreur
```

#### **3. Erreur de build Hive**
```bash
# Solution : Régénérez les adaptateurs
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### **4. Erreur Firebase**
```bash
# Solution : Vérifiez les secrets
- FIREBASE_SERVICE_ACCOUNT_GTONARGENT_APP
- projectId: gtonargent-app
```

### **Logs de Débogage**
```bash
# Dans GitHub Actions
1. Cliquez sur le workflow en échec
2. Cliquez sur le job en échec
3. Cliquez sur l'étape en échec
4. Consultez les logs détaillés
```

## 📱 Résultats

### **URLs de Déploiement**
- **Production :** https://gtonargent-app.web.app
- **Preview :** https://gtonargent-app--pr-[number].web.app
- **Staging :** https://gtonargent-app--staging.web.app

### **Statuts**
- ✅ **Tests** : Automatiques sur chaque commit
- ✅ **Déploiement** : Automatique sur merge
- ✅ **Sécurité** : Règles Firestore déployées
- ✅ **Performance** : Build optimisé pour production

## 🎯 Avantages

1. **Automatisation complète** du déploiement
2. **Tests de qualité** avant déploiement
3. **Prévisualisation** sur Pull Requests
4. **Déploiement manuel** flexible
5. **Monitoring** en temps réel
6. **Sécurité** avec secrets chiffrés

## 🔄 Mise à Jour

Pour mettre à jour les workflows :
1. Modifiez les fichiers `.yml` dans `.github/workflows/`
2. Committez et poussez les changements
3. Les nouveaux workflows se déclencheront automatiquement

---

**🎉 Vos workflows GitHub Actions sont maintenant configurés pour un déploiement automatique et sécurisé !**
