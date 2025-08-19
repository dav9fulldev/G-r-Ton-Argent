import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class SpendingInsightsWidget extends StatefulWidget {
  const SpendingInsightsWidget({super.key});

  @override
  State<SpendingInsightsWidget> createState() => _SpendingInsightsWidgetState();
}

class _SpendingInsightsWidgetState extends State<SpendingInsightsWidget> {
  String _selectedPeriod = 'Ce mois';

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, transactionService, child) {
        final transactions = _getTransactionsForPeriod(transactionService);
        final insights = _calculateInsights(transactions);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Fond plus doux
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyses de Dépenses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: _PeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Key Metrics
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 150,
                    child: _InsightCard(
                      title: 'Dépense Moyenne',
                      value: insights.averageDailySpending.toDouble(),
                      subtitle: 'par jour',
                      color: Colors.blue,
                      icon: Icons.trending_up,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _InsightCard(
                      title: 'Plus Grande Dépense',
                      value: insights.largestExpense.toDouble(),
                      subtitle: insights.largestExpenseCategory,
                      color: Colors.red,
                      icon: Icons.warning,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _InsightCard(
                      title: 'Économies',
                      value: insights.savings,
                      subtitle: 'vs mois précédent',
                      color: insights.savings >= 0 ? Colors.green : Colors.red,
                      icon: insights.savings >= 0 ? Icons.savings : Icons.trending_down,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _InsightCard(
                      title: 'Jours Restants',
                      value: insights.daysLeftInMonth.toDouble(),
                      subtitle: 'jours restants',
                      color: Colors.orange,
                      icon: Icons.calendar_today,
                      isCurrency: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Spending Patterns
              if (insights.topCategories.isNotEmpty) ...[
                Text(
                  'Catégories les Plus Dépensées',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.topCategories.map((category) => _CategoryInsightCard(
                  category: category,
                  totalSpent: insights.categoryTotals[category] ?? 0,
                  percentage: insights.categoryPercentages[category] ?? 0,
                )),
              ],

              const SizedBox(height: 20),

              // Recommendations
              if (insights.recommendations.isNotEmpty) ...[
                Text(
                  'Recommandations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.recommendations.map((recommendation) => _RecommendationCard(
                  recommendation: recommendation,
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  List<TransactionModel> _getTransactionsForPeriod(TransactionService service) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Ce mois':
        return service.currentMonthTransactions;
      case 'Mois dernier':
        final lastMonth = DateTime(now.year, now.month - 1);
        return service.getTransactionsForDateRange(
          DateTime(lastMonth.year, lastMonth.month, 1),
          DateTime(lastMonth.year, lastMonth.month + 1, 0),
        );
      case '3 derniers mois':
        final threeMonthsAgo = DateTime(now.year, now.month - 3);
        return service.getTransactionsForDateRange(
          threeMonthsAgo,
          now,
        );
      default:
        return service.currentMonthTransactions;
    }
  }

  SpendingInsights _calculateInsights(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    
    // Calculate average daily spending
    final daysInPeriod = _getDaysInPeriod();
    final averageDailySpending = daysInPeriod > 0 ? totalExpenses / daysInPeriod : 0.0;

    // Find largest expense
    final largestExpense = expenses.isNotEmpty ? expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b) : 0.0;
    final largestExpenseTransaction = expenses.where((e) => e.amount == largestExpense).firstOrNull;
    final largestExpenseCategory = largestExpenseTransaction?.category.name ?? '';

    // Calculate category totals and percentages
    final categoryTotals = <TransactionCategory, double>{};
    final categoryPercentages = <TransactionCategory, double>{};
    
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    for (final entry in categoryTotals.entries) {
      categoryPercentages[entry.key] = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;
    }

    // Get top categories
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).map((e) => e.key).toList();

    // Calculate savings (simplified - compare with previous period)
    final savings = _calculateSavings(transactions);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      totalExpenses,
      averageDailySpending.toDouble(),
      categoryTotals,
      largestExpense.toDouble(),
    );

    return SpendingInsights(
      averageDailySpending: averageDailySpending,
      largestExpense: largestExpense,
      largestExpenseCategory: largestExpenseCategory,
      savings: savings,
      daysLeftInMonth: _getDaysLeftInMonth(),
      topCategories: topCategories,
      categoryTotals: categoryTotals,
      categoryPercentages: categoryPercentages,
      recommendations: recommendations,
    );
  }

  double _calculateSavings(List<TransactionModel> transactions) {
    // Simplified savings calculation
    // In a real app, you'd compare with previous periods
    return 0.0;
  }

  List<String> _generateRecommendations(
    double totalExpenses,
    double averageDailySpending,
    Map<TransactionCategory, double> categoryTotals,
    double largestExpense,
  ) {
    final recommendations = <String>[];

    if (averageDailySpending > 5000) {
      recommendations.add('Votre dépense quotidienne moyenne est élevée. Considérez réduire vos dépenses non essentielles.');
    }

    if (largestExpense > 10000) {
      recommendations.add('Votre plus grande dépense représente une part importante de votre budget. Planifiez mieux vos gros achats.');
    }

    final foodExpenses = categoryTotals[TransactionCategory.food] ?? 0;
    if (foodExpenses > totalExpenses * 0.4) {
      recommendations.add('Vous dépensez beaucoup en nourriture. Essayez de cuisiner plus à la maison.');
    }

    final entertainmentExpenses = categoryTotals[TransactionCategory.entertainment] ?? 0;
    if (entertainmentExpenses > totalExpenses * 0.3) {
      recommendations.add('Les loisirs représentent une grande part de vos dépenses. Cherchez des activités gratuites.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Excellent! Vos dépenses semblent bien équilibrées. Continuez ainsi!');
    }

    return recommendations;
  }

  int _getDaysInPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Ce mois':
        return now.day;
      case 'Mois dernier':
        return DateTime(now.year, now.month, 0).day;
      case '3 derniers mois':
        return 90;
      default:
        return now.day;
    }
  }

  int _getDaysLeftInMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final totalDaysInMonth = lastDayOfMonth.day;
    final currentDay = now.day;
    return totalDaysInMonth - currentDay;
  }
}

class SpendingInsights {
  final double averageDailySpending;
  final double largestExpense;
  final String largestExpenseCategory;
  final double savings;
  final int daysLeftInMonth;
  final List<TransactionCategory> topCategories;
  final Map<TransactionCategory, double> categoryTotals;
  final Map<TransactionCategory, double> categoryPercentages;
  final List<String> recommendations;

  SpendingInsights({
    required this.averageDailySpending,
    required this.largestExpense,
    required this.largestExpenseCategory,
    required this.savings,
    required this.daysLeftInMonth,
    required this.topCategories,
    required this.categoryTotals,
    required this.categoryPercentages,
    required this.recommendations,
  });
}

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedPeriod,
        onChanged: (value) => onPeriodChanged(value!),
        dropdownColor: const Color(0xFF3B82F6),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: ['Ce mois', 'Mois dernier', '3 derniers mois'].map((period) {
          return DropdownMenuItem(
            value: period,
            child: Text(period),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final double value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isCurrency;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCurrency 
                ? NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(value)
                : value.toInt().toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryInsightCard extends StatelessWidget {
  final TransactionCategory category;
  final double totalSpent;
  final double percentage;

  const _CategoryInsightCard({
    required this.category,
    required this.totalSpent,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryName(category),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% du total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(totalSpent),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Colors.orange;
      case TransactionCategory.transport:
        return Colors.blue;
      case TransactionCategory.entertainment:
        return Colors.purple;
      case TransactionCategory.shopping:
        return Colors.pink;
      case TransactionCategory.health:
        return Colors.red;
      case TransactionCategory.education:
        return Colors.indigo;
      case TransactionCategory.utilities:
        return Colors.teal;
      case TransactionCategory.salary:
        return Colors.green;
      case TransactionCategory.freelance:
        return Colors.amber;
      case TransactionCategory.investment:
        return Colors.cyan;
      case TransactionCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.health:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.utilities:
        return Icons.electric_bolt;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.freelance:
        return Icons.computer;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Nourriture';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.entertainment:
        return 'Loisirs';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.utilities:
        return 'Factures';
      case TransactionCategory.salary:
        return 'Salaire';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investissement';
      case TransactionCategory.other:
        return 'Autre';
    }
  }
}

class _RecommendationCard extends StatelessWidget {
  final String recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
