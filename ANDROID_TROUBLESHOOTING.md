# Guide de résolution des problèmes Android - GerTonArgent

## Problèmes courants et solutions

### 1. Android toolchain crash
**Symptôme**: `flutter doctor` échoue avec "Android toolchain - develop for Android devices (the doctor check crashed)"

**Solutions**:
```bash
# Nettoyage complet
flutter clean
flutter pub get

# Vérification des licences Android
flutter doctor --android-licenses

# Redémarrage du daemon Gradle
cd android
./gradlew --stop
cd ..
```

### 2. Problèmes de mémoire Gradle
**Symptôme**: Build échoue avec des erreurs de mémoire

**Solutions**:
- Augmentation de la mémoire dans `android/gradle.properties`
- Utilisation du script `fix_android_issues.bat`

### 3. Problèmes de réseau
**Symptôme**: Timeout sur pub.dev ou maven.google.com

**Solutions**:
```bash
# Vérification de la connexion
ping pub.dev
ping maven.google.com

# Utilisation d'un proxy si nécessaire
# Configuration dans gradle.properties
```

### 4. Problèmes de compilation Kotlin
**Symptôme**: Erreurs de compilation Kotlin

**Solutions**:
- Vérification de la version JDK (recommandé: JDK 17)
- Nettoyage du cache Kotlin
- Mise à jour des plugins Kotlin

### 5. API obsolètes détectées et corrigées
**Symptôme**: Utilisation d'API dépréciées dans le code

**API corrigées**:
- ✅ `Priority.high` → `Importance.high`
- ✅ `AndroidNotificationImportance.high` → `Importance.high`
- ✅ `AndroidNotificationImportance.max` → `Importance.max`
- ✅ Méthode `@deprecated currentMonthBalance` supprimée
- ✅ `minSdk` mis à jour vers 24 (Android 7.0+)

**Vérification**:
```bash
# Exécuter le script de vérification
dart check_deprecated_apis.dart
```

## Configuration optimisée

### Fichiers modifiés:
1. `android/gradle.properties` - Optimisations mémoire et performance
2. `android/build.gradle.kts` - Configuration des repositories
3. `android/app/build.gradle.kts` - Configuration de l'application
4. `lib/services/notification_service.dart` - API de notifications modernisées
5. `lib/services/transaction_service.dart` - Méthodes dépréciées supprimées

### Variables d'environnement requises:
```bash
ANDROID_HOME=C:\Users\[USERNAME]\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT=C:\Users\[USERNAME]\AppData\Local\Android\Sdk
JAVA_HOME=C:\Program Files\Java\jdk-17
```

## Scripts de diagnostic

### Script automatique:
```bash
# Exécuter le script de diagnostic
fix_android_issues.bat
```

### Script de vérification des API obsolètes:
```bash
# Vérifier les API obsolètes
dart check_deprecated_apis.dart
```

### Commandes manuelles:
```bash
# Diagnostic complet
flutter doctor -v

# Nettoyage et reconstruction
flutter clean
flutter pub get
flutter build apk --debug

# Vérification des licences
flutter doctor --android-licenses
```

## Vérifications préventives

### Avant chaque build:
1. Vérifier la connexion internet
2. S'assurer que Android Studio est à jour
3. Vérifier que les SDK Android sont installés
4. Contrôler l'espace disque disponible

### Maintenance régulière:
1. Nettoyer le cache Gradle: `cd android && ./gradlew clean`
2. Mettre à jour Flutter: `flutter upgrade`
3. Mettre à jour les dépendances: `flutter pub upgrade`
4. Vérifier les licences Android: `flutter doctor --android-licenses`
5. Vérifier les API obsolètes: `dart check_deprecated_apis.dart`

## Support

En cas de problème persistant:
1. Consulter les logs dans `flutter_01.log`
2. Vérifier la configuration dans les fichiers gradle
3. Redémarrer l'IDE et le terminal
4. Réinstaller les plugins Android Studio si nécessaire
5. Exécuter le script de vérification des API obsolètes
