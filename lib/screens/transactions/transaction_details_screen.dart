import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../utils/category_utils.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+' : '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(isIncome ? Icons.trending_up : Icons.trending_down,
                  color: isIncome ? Colors.green : Colors.red),
              title: Text(transaction.description.isEmpty ? CategoryUtils.getCategoryName(transaction.category) : transaction.description),
              subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(transaction.date)),
              trailing: Text(
                '$amountPrefix${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}',
                style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text('Catégorie: ${CategoryUtils.getCategoryName(transaction.category)}'),
            const SizedBox(height: 8),
            Text('Créée le: ${DateFormat('dd MMM yyyy, HH:mm').format(transaction.createdAt)}'),
          ],
        ),
      ),
    );
  }


}

