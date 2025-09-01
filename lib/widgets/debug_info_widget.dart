import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class DebugInfoWidget extends StatefulWidget {
  const DebugInfoWidget({super.key});

  @override
  State<DebugInfoWidget> createState() => _DebugInfoWidgetState();
}

class _DebugInfoWidgetState extends State<DebugInfoWidget> {
  List<String> _debugLogs = [];
  bool _showLogs = false;

  void _addLog(String message) {
    setState(() {
      _debugLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_debugLogs.length > 20) {
        _debugLogs.removeAt(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _addLog('DebugInfoWidget initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, TransactionService>(
      builder: (context, authService, transactionService, child) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🔧 Debug Info',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_showLogs ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _showLogs = !_showLogs;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _addLog('Manual refresh triggered');
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // User Info
                Text('👤 User: ${authService.currentUser?.name ?? 'Not logged in'}'),
                Text('🆔 UID: ${authService.currentUser?.uid ?? 'N/A'}'),
                Text('💰 Budget: ${authService.currentUser?.monthlyBudget ?? 0} FCFA'),
                Text('🔐 Auth Status: ${authService.isAuthenticated ? 'Authenticated' : 'Not authenticated'}'),
                
                const SizedBox(height: 8),
                
                // Transaction Info
                Text('📊 Local Transactions: ${transactionService.transactions.length}'),
                Text('📡 Offline Mode: ${transactionService.isOffline ? 'Yes' : 'No'}'),
                Text('💵 Solde actuel: ${transactionService.currentBalance} FCFA'),
                
                const SizedBox(height: 8),
                
                // Action Buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _addLog('Force sync triggered');
                        transactionService.forceRefresh();
                      },
                      child: const Text('Forcer Sync'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _addLog('Data consistency check triggered');
                        transactionService.debugDataConsistency();
                      },
                      child: const Text('Vérifier'),
                    ),
                  ],
                ),
                
                // Debug Logs
                if (_showLogs) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '📝 Debug Logs:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _debugLogs.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _debugLogs[index],
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        );
                      },
                    ),
                  ),
                ],
                
                // Recent Transactions
                const SizedBox(height: 16),
                const Text(
                  '🕒 Recent Transactions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...transactionService.transactions.take(3).map((transaction) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${transaction.category.name}: ${transaction.amount} FCFA (${transaction.type.name})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
