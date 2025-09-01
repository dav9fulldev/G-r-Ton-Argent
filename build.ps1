# GèrTonArgent - Build Script (Windows PowerShell)
Write-Host "🚀 GèrTonArgent - Build Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Nettoyer le projet
Write-Host "🧹 Nettoyage du projet..." -ForegroundColor Yellow
flutter clean

# Récupérer les dépendances
Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
flutter pub get

# Build pour Android
Write-Host "🤖 Build Android APK..." -ForegroundColor Yellow
flutter build apk --release

# Build pour Web
Write-Host "🌐 Build Web..." -ForegroundColor Yellow
flutter build web --release

Write-Host "✅ Build terminé !" -ForegroundColor Green
Write-Host ""
Write-Host "📱 APK Android: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
Write-Host "🌐 Web: build/web/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour tester:" -ForegroundColor White
Write-Host "- Android: flutter install" -ForegroundColor Gray
Write-Host "- Web: flutter run -d web-server --web-port 3000" -ForegroundColor Gray
