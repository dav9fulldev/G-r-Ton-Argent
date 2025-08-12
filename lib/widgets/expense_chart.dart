import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class ExpenseChart extends StatelessWidget {
  final Map<TransactionCategory, double> expensesByCategory;

  const ExpenseChart({super.key, required this.expensesByCategory});

  @override
  Widget build(BuildContext context) {
    final total = expensesByCategory.values.fold<double>(0, (s, v) => s + v);
    final sections = <PieChartSectionData>[];
    expensesByCategory.forEach((category, value) {
      final percentage = total == 0 ? 0.0 : (value / total) * 100;
      sections.add(PieChartSectionData(
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: _getCategoryColor(category),
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: expensesByCategory.keys.map((c) {
                return _legendItem(context, c, _getCategoryColor(c));
              }).toList(),
            )
          ],
        ),
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

  Widget _legendItem(BuildContext context, TransactionCategory category, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(_categoryName(category), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Nourriture';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.entertainment:
        return 'Divertissement';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.utilities:
        return 'Services';
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

