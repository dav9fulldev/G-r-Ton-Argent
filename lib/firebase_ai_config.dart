import 'package:firebase_ai/firebase_ai.dart';

/// Configuration pour Firebase AI Logic avec Gemini
class FirebaseAIConfig {
  static const String _geminiModel = 'gemini-1.5-flash';
  
  /// Configuration par défaut pour la génération de contenu
  static GenerationConfig get defaultConfig => const GenerationConfig(
    temperature: 0.7,
    topK: 40,
    topP: 0.95,
    maxOutputTokens: 300,
  );

  /// Configuration pour les conseils financiers (plus créatif)
  static GenerationConfig get financialAdviceConfig => const GenerationConfig(
    temperature: 0.8,
    topK: 50,
    topP: 0.9,
    maxOutputTokens: 400,
  );

  /// Configuration pour les conseils urgents (plus direct)
  static GenerationConfig get urgentAdviceConfig => const GenerationConfig(
    temperature: 0.6,
    topK: 30,
    topP: 0.8,
    maxOutputTokens: 200,
  );

  /// Modèle Gemini à utiliser
  static String get geminiModel => _geminiModel;

  /// Instructions système pour les conseils financiers
  static const String financialAdvisorSystemPrompt = '''
Tu es un conseiller financier expert spécialisé dans la gestion de budget personnel en Côte d'Ivoire.
Tu donnes des conseils pratiques, encourageants et réalistes adaptés au contexte local (FCFA).
Utilise un ton bienveillant et des emojis appropriés pour rendre tes conseils plus accessibles.
Sois précis, concis et toujours constructif.
''';

  /// Instructions système pour l'analyse de dépenses
  static const String spendingAnalysisSystemPrompt = '''
Tu es un analyste financier spécialisé dans l'analyse de dépenses personnelles.
Tu analyses les habitudes de dépenses et donnes des conseils pour optimiser le budget.
Sois objectif, factuel et propose des solutions concrètes.
Adapte tes conseils au contexte ivoirien et aux réalités économiques locales.
''';
}
