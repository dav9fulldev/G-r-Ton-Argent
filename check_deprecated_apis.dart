import 'dart:io';
import 'dart:convert';

/// Script de vérification des API obsolètes pour GerTonArgent
/// Usage: dart check_deprecated_apis.dart

void main() async {
  print('🔍 Vérification des API obsolètes dans GerTonArgent...\n');
  
  final results = <String, List<String>>{};
  
  // Vérifier les fichiers Dart
  await checkDartFiles(results);
  
  // Vérifier les fichiers de configuration Android
  await checkAndroidFiles(results);
  
  // Afficher le rapport
  printReport(results);
}

Future<void> checkDartFiles(Map<String, List<String>> results) async {
  print('📱 Vérification des fichiers Dart...');
  
  final dartFiles = await findDartFiles();
  final deprecatedPatterns = [
    '@deprecated',
    'Priority.high',
    'Priority.low',
    'Importance.high',
    'Importance.low',
    'Importance.max',
    'Importance.min',
    'Importance.none',
    'Importance.default',
  ];
  
  for (final file in dartFiles) {
    final content = await File(file).readAsString();
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final pattern in deprecatedPatterns) {
        if (line.contains(pattern)) {
          results.putIfAbsent(file, () => []).add('Ligne ${i + 1}: $pattern');
        }
      }
    }
  }
}

Future<void> checkAndroidFiles(Map<String, List<String>> results) async {
  print('🤖 Vérification des fichiers Android...');
  
  final androidFiles = [
    'android/app/build.gradle.kts',
    'android/build.gradle.kts',
    'android/gradle.properties',
  ];
  
  final deprecatedPatterns = [
    'compileSdkVersion',
    'targetSdkVersion',
    'minSdkVersion',
    'android.enableJetifier=true',
  ];
  
  for (final file in androidFiles) {
    if (await File(file).exists()) {
      final content = await File(file).readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final pattern in deprecatedPatterns) {
          if (line.contains(pattern)) {
            results.putIfAbsent(file, () => []).add('Ligne ${i + 1}: $pattern');
          }
        }
      }
    }
  }
}

Future<List<String>> findDartFiles() async {
  final dartFiles = <String>[];
  final libDir = Directory('lib');
  
  if (await libDir.exists()) {
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        dartFiles.add(entity.path);
      }
    }
  }
  
  return dartFiles;
}

void printReport(Map<String, List<String>> results) {
  print('\n📊 RAPPORT DE VÉRIFICATION DES API OBSOLÈTES\n');
  print('=' * 60);
  
  if (results.isEmpty) {
    print('✅ Aucune API obsolète détectée !');
    print('🎉 Votre projet est à jour avec les dernières recommandations.');
  } else {
    print('⚠️  API obsolètes détectées :\n');
    
    results.forEach((file, issues) {
      print('📁 $file');
      for (final issue in issues) {
        print('   • $issue');
      }
      print('');
    });
    
    print('💡 Recommandations :');
    print('   1. Mettez à jour les API obsolètes vers les nouvelles versions');
    print('   2. Testez votre application après les modifications');
    print('   3. Consultez la documentation officielle pour les alternatives');
  }
  
  print('\n' + '=' * 60);
  print('✅ Vérification terminée !');
}
