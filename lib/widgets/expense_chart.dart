import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../utils/category_utils.dart';

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
        color: Color(CategoryUtils.getCategoryColor(category)),
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
    });

    // Si aucune donnée, afficher un message
    if (expensesByCategory.isEmpty || total == 0) {
      return Container(
        height: 200,
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: Color(0xFF64748B),
              ),
              SizedBox(height: 16),
              Text(
                'Aucune donnée disponible',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ajoutez des transactions pour voir\nla répartition de vos dépenses',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
                         children: expensesByCategory.keys.map((c) {
               return _legendItem(context, c, Color(CategoryUtils.getCategoryColor(c)));
             }).toList(),
          )
        ],
      ),
    );
  }



  Widget _legendItem(BuildContext context, TransactionCategory category, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(2)
          )
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            CategoryUtils.getCategoryName(category), 
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


}

