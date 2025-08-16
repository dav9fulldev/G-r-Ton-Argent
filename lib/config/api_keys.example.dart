/// Exemple de configuration des clés API
/// ⚠️ Ce fichier est un exemple - ne pas utiliser en production
/// 
/// Pour configurer vos clés API :
/// 1. Copiez ce fichier et renommez-le en api_keys.dart
/// 2. Remplacez les valeurs par vos vraies clés API
/// 3. Assurez-vous que api_keys.dart est dans .gitignore

class ApiKeys {
  /// Clé API Google Gemini
  /// Obtenez votre clé sur : https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  /// Autres clés API (si nécessaire)
  // static const String openAiApiKey = 'your-openai-key';
  // static const String otherApiKey = 'your-other-key';
  
  /// Vérification que les clés sont configurées
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY';
  
  /// Méthode pour valider toutes les clés
  static List<String> getMissingKeys() {
    final missing = <String>[];
    
    if (!isGeminiConfigured) {
      missing.add('Gemini API Key');
    }
    
    return missing;
  }
}
