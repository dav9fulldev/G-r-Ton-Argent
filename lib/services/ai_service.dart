import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';
import '../utils/category_utils.dart';

class AIService extends ChangeNotifier {
  // Replace with your actual OpenAI API key
  static const String _apiKey = 'your-openai-api-key-here';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Enhanced spending advice with real GPT integration
  Future<String> getSpendingAdvice({
    required double expenseAmount,
    required double currentBalance,
    required double monthlyBudget,
    required TransactionCategory category,
    required List<TransactionModel> recentTransactions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // If no API key is configured, use local advice
      if (_apiKey == 'your-openai-api-key-here') {
        return await _getLocalAdvice(
          expenseAmount: expenseAmount,
          currentBalance: currentBalance,
          monthlyBudget: monthlyBudget,
          category: category,
          recentTransactions: recentTransactions,
        );
      }

      // Use real GPT API
      return await _getGPTAdvice(
        expenseAmount: expenseAmount,
        currentBalance: currentBalance,
        monthlyBudget: monthlyBudget,
        category: category,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      // Fallback to local advice
      return await _getLocalAdvice(
        expenseAmount: expenseAmount,
        currentBalance: currentBalance,
        monthlyBudget: monthlyBudget,
        category: category,
        recentTransactions: recentTransactions,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _getGPTAdvice({
    required double expenseAmount,
    required double currentBalance,
    required double monthlyBudget,
    required TransactionCategory category,
    required List<TransactionModel> recentTransactions,
  }) async {
    final prompt = _buildPrompt(
      expenseAmount: expenseAmount,
      currentBalance: currentBalance,
      monthlyBudget: monthlyBudget,
      category: category,
      recentTransactions: recentTransactions,
    );

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un conseiller financier expert spécialisé dans la gestion de budget personnel. Tu donnes des conseils pratiques et encourageants en français, adaptés au contexte ivoirien (FCFA).',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 300,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.trim();
    } else {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }

  String _buildPrompt({
    required double expenseAmount,
    required double currentBalance,
    required double monthlyBudget,
    required TransactionCategory category,
    required List<TransactionModel> recentTransactions,
  }) {
    final categoryName = CategoryUtils.getCategoryName(category);
    final recentExpenses = recentTransactions
        .where((t) => t.type == TransactionType.expense)
        .take(5)
        .map((t) => '${CategoryUtils.getCategoryName(t.category)}: ${t.amount} FCFA')
        .join(', ');

    return '''
Analyse cette dépense et donne un conseil financier personnalisé:

Montant de la dépense: $expenseAmount FCFA
Catégorie: $categoryName
Solde actuel: $currentBalance FCFA
Budget mensuel: $monthlyBudget FCFA
Dépenses récentes: $recentExpenses

Donne un conseil court (2-3 phrases) en français, adapté au contexte ivoirien. Sois encourageant mais réaliste. Utilise des emojis appropriés.
''';
  }

  Future<String> _getLocalAdvice({
    required double expenseAmount,
    required double currentBalance,
    required double monthlyBudget,
    required TransactionCategory category,
    required List<TransactionModel> recentTransactions,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final percentageOfBalance = (expenseAmount / currentBalance) * 100;
    final percentageOfBudget = (expenseAmount / monthlyBudget) * 100;
    final daysLeftInMonth = _getDaysLeftInMonth();
    final averageDailySpending = _calculateAverageDailySpending(recentTransactions);

    String advice = '';

    // Check if this is a large expense
    if (percentageOfBalance > 50) {
      advice += '⚠️ Cette dépense représente ${percentageOfBalance.toStringAsFixed(0)}% de votre solde actuel. ';
      advice += 'C\'est une dépense importante qui pourrait impacter vos finances. ';
    }

    // Check budget utilization
    if (percentageOfBudget > 20) {
      advice += '📊 Cette dépense représente ${percentageOfBudget.toStringAsFixed(0)}% de votre budget mensuel. ';
    }

    // Category-specific advice
    switch (category) {
      case TransactionCategory.food:
        if (expenseAmount > 5000) {
          advice += '🍽️ Pour la nourriture, considérez si vous pouvez réduire ce montant en cuisinant à la maison. ';
        }
        break;
      case TransactionCategory.entertainment:
        if (percentageOfBalance > 30) {
          advice += '🎬 Cette dépense de loisirs est importante. Assurez-vous qu\'elle en vaut vraiment la peine. ';
        }
        break;
      case TransactionCategory.shopping:
        advice += '🛍️ Avant d\'acheter, demandez-vous si cet article est vraiment nécessaire. ';
        break;
      case TransactionCategory.transport:
        if (expenseAmount > 3000) {
          advice += '🚗 Considérez les alternatives moins chères comme le transport en commun. ';
        }
        break;
      default:
        break;
    }

    // Check if user is spending too much daily
    if (averageDailySpending > (monthlyBudget / 30) * 1.2) {
      advice += '📈 Votre dépense quotidienne moyenne est élevée. ';
      advice += 'Il vous reste $daysLeftInMonth jours ce mois-ci. ';
    }

    // Positive reinforcement for good spending
    if (percentageOfBalance < 10 && currentBalance > monthlyBudget * 0.3) {
      advice += '✅ Excellente gestion! Cette dépense est raisonnable par rapport à votre solde. ';
    }

    // Final recommendation
    if (currentBalance - expenseAmount < monthlyBudget * 0.1) {
      advice += '🚨 ATTENTION: Après cette dépense, il vous restera très peu pour le reste du mois. ';
      advice += 'Considérez reporter cette dépense si possible.';
    } else if (advice.isEmpty) {
      advice = '✅ Cette dépense semble raisonnable. Continuez votre bonne gestion financière!';
    }

    return advice;
  }

  // Get financial tips for dashboard
  Future<List<String>> getFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiKey == 'your-openai-api-key-here') {
        return _getLocalFinancialTips(
          currentBalance: currentBalance,
          monthlyBudget: monthlyBudget,
          transactions: transactions,
        );
      }

      return await _getGPTFinancialTips(
        currentBalance: currentBalance,
        monthlyBudget: monthlyBudget,
        transactions: transactions,
      );
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      return _getLocalFinancialTips(
        currentBalance: currentBalance,
        monthlyBudget: monthlyBudget,
        transactions: transactions,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> _getGPTFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) async {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final categoryBreakdown = <String, double>{};
    
    for (final expense in expenses) {
      final categoryName = CategoryUtils.getCategoryName(expense.category);
      categoryBreakdown[categoryName] = (categoryBreakdown[categoryName] ?? 0) + expense.amount;
    }

    final prompt = '''
Analyse cette situation financière et donne 3 conseils pratiques:

Solde actuel: $currentBalance FCFA
Budget mensuel: $monthlyBudget FCFA
Dépenses totales: $totalExpenses FCFA
Répartition par catégorie: ${categoryBreakdown.entries.map((e) => '${e.key}: ${e.value} FCFA').join(', ')}

Donne 3 conseils courts et pratiques en français, adaptés au contexte ivoirien. Sois encourageant et utilise des emojis.
''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un conseiller financier expert. Donne des conseils pratiques et encourageants.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 400,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.split('\n').where((line) => line.trim().isNotEmpty).take(3).toList();
    } else {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }

  List<String> _getLocalFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) {
    final tips = <String>[];
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final remainingBudget = monthlyBudget - totalExpenses;

    if (remainingBudget < 0) {
      tips.add('🚨 Votre budget est dépassé. Considérez réduire vos dépenses non essentielles ce mois-ci.');
    } else if (remainingBudget < monthlyBudget * 0.2) {
      tips.add('⚠️ Il vous reste peu de budget. Soyez prudent avec vos dépenses restantes.');
    } else {
      tips.add('✅ Excellent! Vous gérez bien votre budget. Continuez ainsi!');
    }

    final foodExpenses = expenses.where((e) => e.category == TransactionCategory.food).fold(0.0, (sum, e) => sum + e.amount);
    if (foodExpenses > totalExpenses * 0.4) {
      tips.add('🍽️ Vous dépensez beaucoup en nourriture. Essayez de cuisiner plus à la maison pour économiser.');
    }

    final entertainmentExpenses = expenses.where((e) => e.category == TransactionCategory.entertainment).fold(0.0, (sum, e) => sum + e.amount);
    if (entertainmentExpenses > totalExpenses * 0.3) {
      tips.add('🎬 Les loisirs représentent une grande part de vos dépenses. Cherchez des activités gratuites.');
    }

    if (tips.length < 3) {
      tips.add('💡 Pensez à épargner au moins 10% de vos revenus pour vos objectifs futurs.');
    }

    return tips.take(3).toList();
  }

  int _getDaysLeftInMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays;
  }

  double _calculateAverageDailySpending(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final monthlyExpenses = transactions
        .where((t) => t.type == TransactionType.expense && t.date.isAfter(startOfMonth))
        .toList();

    if (monthlyExpenses.isEmpty) return 0;

    final totalExpenses = monthlyExpenses.fold(0.0, (sum, t) => sum + t.amount);
    return totalExpenses / now.day;
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
