import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';

class DebugInfoWidget extends StatefulWidget {
  const DebugInfoWidget({super.key});

  @override
  State<DebugInfoWidget> createState() => _DebugInfoWidgetState();
}

class _DebugInfoWidgetState extends State<DebugInfoWidget> {
  bool _showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, TransactionService>(
      builder: (context, authService, transactionService, child) {
        if (authService.currentUser == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Debug toggle button
            Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showDebugInfo = !_showDebugInfo;
                  });
                },
                icon: Icon(_showDebugInfo ? Icons.visibility_off : Icons.visibility),
                label: Text(_showDebugInfo ? 'Masquer Debug' : 'Afficher Debug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // Debug information
            if (_showDebugInfo)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Informations de Débogage',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // User info
                    Text('👤 Utilisateur: ${authService.currentUser!.name}'),
                    Text('🆔 UID: ${authService.currentUser!.uid}'),
                    Text('💰 Budget: ${authService.currentUser!.monthlyBudget.toStringAsFixed(0)} FCFA'),
                    
                    const SizedBox(height: 8),
                    
                    // Transaction info
                    Text('📊 Transactions locales: ${transactionService.transactions.length}'),
                    Text('📱 Mode hors ligne: ${!transactionService.isOnline ? "Oui" : "Non"}'),
                    Text('💸 Total dépenses: ${transactionService.totalExpenses.toStringAsFixed(0)} FCFA'),
                    Text('💰 Total revenus: ${transactionService.totalIncome.toStringAsFixed(0)} FCFA'),
                    
                    const SizedBox(height: 8),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await transactionService.forceRefresh(authService.currentUser!.uid);
                              await transactionService.debugDataConsistency(authService.currentUser!.uid);
                              if (mounted) setState(() {});
                            },
                            child: const Text('🔄 Forcer Sync'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await transactionService.debugDataConsistency(authService.currentUser!.uid);
                            },
                            child: const Text('🔍 Vérifier'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Recent transactions
                    if (transactionService.transactions.isNotEmpty) ...[
                      Text(
                        '📋 Transactions récentes:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...transactionService.transactions.take(3).map((transaction) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '  • ${transaction.amount.toStringAsFixed(0)} FCFA - ${transaction.type.name} - ${transaction.category.name}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
