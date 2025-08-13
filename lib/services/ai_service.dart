import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class AIService extends ChangeNotifier {
  // This is a simulated AI service that can be replaced with actual GPT API integration
  // For now, it provides intelligent advice based on user's financial situation

  Future<String> getSpendingAdvice({
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
    final daysPassed = now.difference(startOfMonth).inDays + 1;
    
    return totalExpenses / daysPassed;
  }

  // Method to get personalized financial tips
  Future<List<String>> getFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) async {
    final tips = <String>[];

    // Analyze spending patterns
    final expensesByCategory = <TransactionCategory, double>{};
    for (final transaction in transactions.where((t) => t.type == TransactionType.expense)) {
      expensesByCategory[transaction.category] = 
          (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
    }

    // Find highest spending category
    if (expensesByCategory.isNotEmpty) {
      final highestCategory = expensesByCategory.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      tips.add('💡 Votre plus grande dépense est dans ${_getCategoryName(highestCategory.key)}. '
          'Considérez réduire ce poste de dépenses.');
    }

    // Budget utilization advice
    final budgetUtilization = ((monthlyBudget - currentBalance) / monthlyBudget) * 100;
    if (budgetUtilization > 80) {
      tips.add('⚠️ Vous avez utilisé ${budgetUtilization.toStringAsFixed(0)}% de votre budget. '
          'Soyez prudent avec vos dépenses restantes.');
    } else if (budgetUtilization < 50) {
      tips.add('✅ Excellente gestion! Vous n\'avez utilisé que ${budgetUtilization.toStringAsFixed(0)}% '
          'de votre budget. Continuez ainsi!');
    }

    // Savings advice
    if (currentBalance > monthlyBudget * 0.2) {
      tips.add('💰 Considérez mettre de côté une partie de votre solde pour les urgences.');
    }

    return tips;
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'l\'alimentation';
      case TransactionCategory.transport:
        return 'le transport';
      case TransactionCategory.entertainment:
        return 'les loisirs';
      case TransactionCategory.shopping:
        return 'les achats';
      case TransactionCategory.health:
        return 'la santé';
      case TransactionCategory.education:
        return 'l\'éducation';
      case TransactionCategory.utilities:
        return 'les factures';
      case TransactionCategory.salary:
        return 'le salaire';
      case TransactionCategory.freelance:
        return 'le freelance';
      case TransactionCategory.investment:
        return 'l\'investissement';
      case TransactionCategory.other:
        return 'autres';
    }
  }
}
