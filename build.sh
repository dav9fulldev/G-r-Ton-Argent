#!/bin/bash

echo "🚀 GèrTonArgent - Build Script"
echo "================================"

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Build pour Android
echo "🤖 Build Android APK..."
flutter build apk --release

# Build pour Web
echo "🌐 Build Web..."
flutter build web --release

echo "✅ Build terminé !"
echo ""
echo "📱 APK Android: build/app/outputs/flutter-apk/app-release.apk"
echo "🌐 Web: build/web/"
echo ""
echo "Pour tester:"
echo "- Android: flutter install"
echo "- Web: flutter run -d web-server --web-port 3000"
