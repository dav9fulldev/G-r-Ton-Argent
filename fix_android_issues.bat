@echo off
echo ========================================
echo Diagnostic et reparation Android Flutter
echo ========================================
echo.

echo [1/6] Nettoyage du projet Flutter...
flutter clean
if %errorlevel% neq 0 (
    echo ERREUR: Echec du nettoyage Flutter
    pause
    exit /b 1
)

echo.
echo [2/6] Recuperation des dependances...
flutter pub get
if %errorlevel% neq 0 (
    echo ERREUR: Echec de la recuperation des dependances
    pause
    exit /b 1
)

echo.
echo [3/6] Nettoyage du cache Gradle...
cd android
if exist .gradle rmdir /s /q .gradle
if exist build rmdir /s /q build
cd ..

echo.
echo [4/6] Verification de la configuration Android...
flutter doctor --android-licenses
if %errorlevel% neq 0 (
    echo ATTENTION: Probleme avec les licences Android
)

echo.
echo [5/6] Test de compilation Android...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERREUR: Echec de la compilation Android
    echo.
    echo Solutions possibles:
    echo 1. Verifiez que Android SDK est correctement installe
    echo 2. Verifiez que les variables d'environnement sont configurees
    echo 3. Redemarrez Android Studio
    pause
    exit /b 1
)

echo.
echo [6/6] Verification finale...
flutter doctor
if %errorlevel% neq 0 (
    echo ATTENTION: Probleme detecte dans flutter doctor
)

echo.
echo ========================================
echo Diagnostic termine!
echo ========================================
echo.
echo Si des erreurs persistent:
echo 1. Redemarrez votre IDE
echo 2. Verifiez votre connexion internet
echo 3. Mettez a jour Flutter: flutter upgrade
echo 4. Reinstallez les plugins Android Studio
echo.
pause
