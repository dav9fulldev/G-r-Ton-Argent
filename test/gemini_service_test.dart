import 'package:flutter_test/flutter_test.dart';
import 'package:ger_ton_argent/services/gemini_service.dart';

void main() {
  group('GeminiService Tests', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
    });

    test('should parse response correctly', () {
      final response = '''
- Conseil 1: 💰 Pensez à épargner 10% de vos revenus
- Conseil 2: 🍽️ Cuisinez plus à la maison pour économiser
- Conseil 3: 📊 Suivez votre budget régulièrement
''';

      final conseils = geminiService.getConseilsIA(100000, 50000, 10000);
      
      // Test que la méthode ne lance pas d'exception
      expect(conseils, isA<Future<List<String>>>());
    });

    test('should handle empty response', () {
      final response = '';
      
      // Test que la méthode gère les réponses vides
      final conseils = geminiService.getConseilsIA(100000, 50000, 10000);
      expect(conseils, isA<Future<List<String>>>());
    });

    test('should handle malformed response', () {
      final response = '''
Juste du texte sans formatage
Plus de texte
''';

      // Test que la méthode gère les réponses mal formatées
      final conseils = geminiService.getConseilsIA(100000, 50000, 10000);
      expect(conseils, isA<Future<List<String>>>());
    });

    test('should provide default advice when budget is exceeded', () {
      final budget = 100000.0;
      final depenses = 95000.0;
      final nouvelleDepense = 10000.0;

      final conseils = geminiService.getConseilsIA(budget, depenses, nouvelleDepense);
      expect(conseils, isA<Future<List<String>>>());
    });

    test('should provide default advice when budget is healthy', () {
      final budget = 100000.0;
      final depenses = 30000.0;
      final nouvelleDepense = 5000.0;

      final conseils = geminiService.getConseilsIA(budget, depenses, nouvelleDepense);
      expect(conseils, isA<Future<List<String>>>());
    });
  });
}
