import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_transaction_service.dart';

class FinancialTipsWidget extends StatefulWidget {
  const FinancialTipsWidget({super.key});

  @override
  State<FinancialTipsWidget> createState() => _FinancialTipsWidgetState();
}

class _FinancialTipsWidgetState extends State<FinancialTipsWidget> {
  List<String> _tips = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    
    try {
             final authService = Provider.of<MockAuthService>(context, listen: false);
       final transactionService = Provider.of<MockTransactionService>(context, listen: false);
      final aiService = Provider.of<AIService>(context, listen: false);
      
      if (authService.currentUser != null) {
        final tips = await aiService.getFinancialTips(
          currentBalance: transactionService.currentMonthBalance,
          monthlyBudget: authService.currentUser!.monthlyBudget,
          transactions: transactionService.currentMonthTransactions,
        );
        
        if (mounted) {
          setState(() {
            _tips = tips;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text(
                'Analyse de vos finances...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_tips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conseils financiers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: _loadTips,
                  tooltip: 'Actualiser les conseils',
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
