import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/transaction_model.dart';
import '../firebase_ai_config.dart';

class GeminiService extends ChangeNotifier {
  final FirebaseAI _firebaseAI = FirebaseAI.instance;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fonction centrale pour obtenir des conseils IA via Gemini
  /// Cette fonction est appelée quand l'utilisateur ajoute une dépense
  Future<List<String>> getConseilsIA(double budget, double depenses, double nouvelleDepense) async {
    _setLoading(true);
    _clearError();

    try {
      // Vérifier si les conseils IA sont activés (sera vérifié dans l'appelant)
      
      // Construire le prompt en français
      final prompt = _buildPrompt(budget, depenses, nouvelleDepense);
      
      // Appeler Gemini via Firebase AI Logic
      final response = await _callGemini(prompt);
      
      // Parser la réponse en liste de conseils
      final conseils = _parseResponse(response);
      
      return conseils;
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      // Retourner des conseils par défaut en cas d'erreur
      return _getDefaultAdvice(budget, depenses, nouvelleDepense);
    } finally {
      _setLoading(false);
    }
  }

  /// Construit le prompt pour Gemini
  String _buildPrompt(double budget, double depenses, double nouvelleDepense) {
    final totalApresDepense = depenses + nouvelleDepense;
    final pourcentageBudget = (totalApresDepense / budget) * 100;
    final resteBudget = budget - totalApresDepense;

    return '''
Tu es un conseiller financier expert spécialisé dans la gestion de budget personnel en Côte d'Ivoire.

Voici la situation financière de l'utilisateur :
- Budget mensuel défini : ${budget.toStringAsFixed(0)} FCFA
- Dépenses actuelles totalisent : ${depenses.toStringAsFixed(0)} FCFA
- Nouvelle dépense à ajouter : ${nouvelleDepense.toStringAsFixed(0)} FCFA
- Total après la nouvelle dépense : ${totalApresDepense.toStringAsFixed(0)} FCFA
- Pourcentage du budget utilisé : ${pourcentageBudget.toStringAsFixed(1)}%
- Reste du budget : ${resteBudget.toStringAsFixed(0)} FCFA

Donne 2 à 3 conseils financiers courts et pratiques pour mieux gérer ses finances.
Sois encourageant mais réaliste, adapté au contexte ivoirien (FCFA).
Utilise des emojis appropriés et un ton bienveillant.

Format de réponse souhaité :
- Conseil 1: [conseil court avec emoji]
- Conseil 2: [conseil court avec emoji]
- Conseil 3: [conseil court avec emoji]
''';
  }

  /// Appelle Gemini via Firebase AI Logic
  Future<String> _callGemini(String prompt) async {
    try {
      // Utiliser Firebase AI Logic avec le modèle Gemini
      final response = await _firebaseAI.generateContent(
        model: FirebaseAIConfig.geminiModel,
        content: [
          Content.text(prompt),
        ],
        generationConfig: FirebaseAIConfig.financialAdviceConfig,
      );

      if (response.text != null) {
        return response.text!;
      } else {
        throw Exception('Réponse vide de Gemini');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel à Gemini: $e');
    }
  }

  /// Parse la réponse de Gemini en liste de conseils
  List<String> _parseResponse(String response) {
    final lines = response.split('\n');
    final conseils = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && 
          (trimmedLine.startsWith('-') || 
           trimmedLine.startsWith('•') || 
           trimmedLine.startsWith('Conseil') ||
           trimmedLine.contains(':'))) {
        
        // Nettoyer le formatage
        String conseil = trimmedLine;
        if (conseil.startsWith('- ')) conseil = conseil.substring(2);
        if (conseil.startsWith('• ')) conseil = conseil.substring(2);
        if (conseil.contains(':')) {
          conseil = conseil.split(':').skip(1).join(':').trim();
        }
        
        if (conseil.isNotEmpty) {
          conseils.add(conseil);
        }
      }
    }
    
    // Si aucun conseil n'a été trouvé, traiter la réponse comme un seul conseil
    if (conseils.isEmpty && response.trim().isNotEmpty) {
      conseils.add(response.trim());
    }
    
    return conseils.take(3).toList(); // Limiter à 3 conseils
  }

  /// Conseils par défaut en cas d'erreur
  List<String> _getDefaultAdvice(double budget, double depenses, double nouvelleDepense) {
    final totalApresDepense = depenses + nouvelleDepense;
    final pourcentageBudget = (totalApresDepense / budget) * 100;
    final resteBudget = budget - totalApresDepense;

    final conseils = <String>[];

    if (pourcentageBudget > 90) {
      conseils.add('🚨 Attention : Vous avez utilisé ${pourcentageBudget.toStringAsFixed(0)}% de votre budget. Considérez reporter cette dépense si possible.');
    } else if (pourcentageBudget > 70) {
      conseils.add('⚠️ Vous avez utilisé ${pourcentageBudget.toStringAsFixed(0)}% de votre budget. Soyez prudent avec vos dépenses restantes.');
    } else {
      conseils.add('✅ Excellente gestion ! Il vous reste ${resteBudget.toStringAsFixed(0)} FCFA ce mois-ci.');
    }

    if (nouvelleDepense > budget * 0.2) {
      conseils.add('💰 Cette dépense représente une part importante de votre budget. Assurez-vous qu\'elle est vraiment nécessaire.');
    }

    if (conseils.length < 2) {
      conseils.add('💡 Pensez à épargner au moins 10% de vos revenus pour vos objectifs futurs.');
    }

    return conseils.take(3).toList();
  }

  /// Conseils pour le dashboard (version simplifiée)
  Future<List<String>> getFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
      final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
      final remainingBudget = monthlyBudget - totalExpenses;

      final prompt = '''
Analyse cette situation financière et donne 3 conseils pratiques :

Solde actuel : ${currentBalance.toStringAsFixed(0)} FCFA
Budget mensuel : ${monthlyBudget.toStringAsFixed(0)} FCFA
Dépenses totales : ${totalExpenses.toStringAsFixed(0)} FCFA
Budget restant : ${remainingBudget.toStringAsFixed(0)} FCFA

Donne 3 conseils courts et pratiques en français, adaptés au contexte ivoirien.
Sois encourageant et utilise des emojis appropriés.

Format :
- Conseil 1: [conseil]
- Conseil 2: [conseil]
- Conseil 3: [conseil]
''';

      final response = await _callGemini(prompt);
      return _parseResponse(response);
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      return _getDefaultFinancialTips(currentBalance, monthlyBudget, transactions);
    } finally {
      _setLoading(false);
    }
  }

  /// Conseils financiers par défaut pour le dashboard
  List<String> _getDefaultFinancialTips(
    double currentBalance,
    double monthlyBudget,
    List<TransactionModel> transactions,
  ) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final remainingBudget = monthlyBudget - totalExpenses;

    final tips = <String>[];

    if (remainingBudget < 0) {
      tips.add('🚨 Votre budget est dépassé. Considérez réduire vos dépenses non essentielles ce mois-ci.');
    } else if (remainingBudget < monthlyBudget * 0.2) {
      tips.add('⚠️ Il vous reste peu de budget. Soyez prudent avec vos dépenses restantes.');
    } else {
      tips.add('✅ Excellent ! Vous gérez bien votre budget. Continuez ainsi !');
    }

    final foodExpenses = expenses.where((e) => e.category == TransactionCategory.food).fold(0.0, (sum, e) => sum + e.amount);
    if (foodExpenses > totalExpenses * 0.4) {
      tips.add('🍽️ Vous dépensez beaucoup en nourriture. Essayez de cuisiner plus à la maison pour économiser.');
    }

    if (tips.length < 3) {
      tips.add('💡 Pensez à épargner au moins 10% de vos revenus pour vos objectifs futurs.');
    }

    return tips.take(3).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
