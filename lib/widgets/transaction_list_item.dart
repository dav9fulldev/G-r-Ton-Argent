import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../utils/category_utils.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(CategoryUtils.getCategoryColor(transaction.category)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            CategoryUtils.getCategoryIcon(transaction.category),
            style: TextStyle(
              fontSize: 24,
              color: Color(CategoryUtils.getCategoryColor(transaction.category)),
            ),
          ),
        ),
        title: Text(
          transaction.description.isNotEmpty 
              ? transaction.description 
              : CategoryUtils.getCategoryName(transaction.category),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CategoryUtils.getCategoryName(transaction.category),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            Text(
              isIncome ? 'Revenu' : 'Dépense',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: amountColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
