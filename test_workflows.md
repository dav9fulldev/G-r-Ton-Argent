# 🧪 Test des Workflows GitHub Actions

## ✅ Workflows Configurés

### 1. **firebase-hosting-merge.yml** ✅
- **Déclencheur :** Push sur `master` ou `main`
- **Actions :** Installation Flutter → Dépendances → Build → Déploiement Firebase

### 2. **firebase-hosting-pull-request.yml** ✅
- **Déclencheur :** Pull Request
- **Actions :** Installation Flutter → Dépendances → Build → Preview Firebase

### 3. **flutter-test.yml** ✅
- **Déclencheur :** Push/PR sur `master`, `main`, `develop`
- **Actions :** Tests → Lint → Format → Builds

### 4. **manual-deploy.yml** ✅
- **Déclencheur :** Manuel
- **Actions :** Tests complets → Build → Déploiement → Règles Firestore

## 🔧 Étapes de Test

### **Test 1: Vérification Locale**
```bash
# 1. Vérifiez que Flutter fonctionne
flutter --version

# 2. Vérifiez les dépendances
flutter pub get

# 3. Générez les adaptateurs Hive
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. Analysez le code
flutter analyze

# 5. Testez le build web
flutter build web --release

# 6. Testez le build Android
flutter build apk --release
```

### **Test 2: Configuration GitHub**
1. **Vérifiez les secrets :**
   - `FIREBASE_SERVICE_ACCOUNT_GTONARGENT_APP` ✅
   - `FIREBASE_TOKEN` (optionnel)

2. **Vérifiez les permissions :**
   - Actions activées dans le repository
   - Secrets configurés correctement

### **Test 3: Déclenchement des Workflows**

#### **A. Test Automatique (Push)**
```bash
# 1. Créez une branche de test
git checkout -b test-workflows

# 2. Faites un petit changement
echo "# Test workflow" >> README.md

# 3. Committez et poussez
git add README.md
git commit -m "test: Test workflows GitHub Actions"
git push origin test-workflows

# 4. Créez une Pull Request
# 5. Vérifiez que les workflows se déclenchent
```

#### **B. Test Manuel**
1. Allez dans **Actions** > **Manual Deploy to Firebase**
2. Cliquez sur **Run workflow**
3. Choisissez **staging**
4. Cliquez sur **Run workflow**
5. Surveillez l'exécution

## 📊 Résultats Attendus

### **Workflow de Test (flutter-test.yml)**
```
✅ test: Analyse, tests, builds réussis
✅ lint: Code conforme aux standards
✅ format: Formatage correct
```

### **Workflow de Déploiement (firebase-hosting-merge.yml)**
```
✅ Checkout code
✅ Setup Flutter 3.19.0
✅ Get Flutter dependencies
✅ Generate Hive adapters
✅ Build Flutter web app
✅ Deploy to Firebase Hosting
```

### **Workflow de Preview (firebase-hosting-pull-request.yml)**
```
✅ Checkout code
✅ Setup Flutter 3.19.0
✅ Get Flutter dependencies
✅ Generate Hive adapters
✅ Build Flutter web app
✅ Deploy to Firebase Hosting Preview
```

## 🔍 Logs de Débogage

### **Logs de Succès**
```
✅ Setup Flutter
Flutter 3.19.0 • channel stable • https://github.com/flutter/flutter.git

✅ Get Flutter dependencies
Running "flutter pub get" in /home/runner/work/ger-ton-argent/ger-ton-argent...
Resolving dependencies...

✅ Generate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
Generated build script completed, took 1.2s

✅ Build Flutter web app
flutter build web --release
Compiling lib/main.dart for the Web...

✅ Deploy to Firebase Hosting
Deploying to Firebase Hosting...
✔  Deploy complete!
```

### **Logs d'Erreur Communs**
```
❌ Flutter not found
Solution: Vérifiez flutter-version: '3.19.0'

❌ Dependencies failed
Solution: Vérifiez pubspec.yaml et flutter pub get

❌ Hive adapters failed
Solution: Vérifiez build_runner et les modèles

❌ Firebase deployment failed
Solution: Vérifiez les secrets et projectId
```

## 🚨 Dépannage

### **Problème 1: Flutter non installé**
```yaml
# Solution: Vérifiez la version
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.19.0'  # Doit correspondre à votre projet
```

### **Problème 2: Dépendances manquantes**
```bash
# Solution: Vérifiez pubspec.yaml
flutter pub get
flutter pub deps
```

### **Problème 3: Erreur Hive**
```bash
# Solution: Régénérez les adaptateurs
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **Problème 4: Erreur Firebase**
```bash
# Solution: Vérifiez les secrets
1. FIREBASE_SERVICE_ACCOUNT_GTONARGENT_APP
2. projectId: gtonargent-app
3. Permissions Firebase
```

## 📱 URLs de Test

### **Production**
- **URL :** https://gtonargent-app.web.app
- **Statut :** Déployé automatiquement sur merge

### **Preview**
- **URL :** https://gtonargent-app--pr-[number].web.app
- **Statut :** Déployé automatiquement sur PR

### **Staging**
- **URL :** https://gtonargent-app--staging.web.app
- **Statut :** Déployé manuellement

## 🎯 Checklist de Validation

### **Configuration ✅**
- [ ] Workflows créés dans `.github/workflows/`
- [ ] Secrets configurés dans GitHub
- [ ] Permissions Actions activées
- [ ] Version Flutter correcte (3.19.0)

### **Tests Locaux ✅**
- [ ] `flutter pub get` fonctionne
- [ ] `flutter analyze` sans erreurs
- [ ] `flutter build web` réussit
- [ ] `flutter build apk` réussit

### **Tests GitHub Actions ✅**
- [ ] Workflow de test se déclenche
- [ ] Workflow de déploiement se déclenche
- [ ] Workflow de preview se déclenche
- [ ] Déploiement manuel fonctionne

### **Résultats ✅**
- [ ] Application déployée sur Firebase
- [ ] Tests automatisés fonctionnels
- [ ] Logs de débogage disponibles
- [ ] Monitoring en temps réel

## 🚀 Prochaines Étapes

1. **Testez les workflows** avec un commit de test
2. **Vérifiez les déploiements** sur Firebase
3. **Configurez les notifications** Slack/Email
4. **Optimisez les performances** si nécessaire
5. **Documentez les procédures** pour l'équipe

---

**🎉 Vos workflows GitHub Actions sont prêts pour la production !**
