import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../models/transaction_model.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_details_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/expense_chart.dart';
import '../../widgets/transaction_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    
    if (authService.currentUser != null) {
      await transactionService.loadTransactions(authService.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('GèrTonArgent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthService, TransactionService>(
        builder: (context, authService, transactionService, child) {
          if (authService.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  Text(
                    'Bonjour, ${authService.currentUser!.name}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Voici un aperçu de vos finances',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Balance Card
                  BalanceCard(
                    balance: transactionService.currentMonthBalance,
                    monthlyBudget: authService.currentUser!.monthlyBudget,
                  ),

                  const SizedBox(height: 24),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Revenus',
                          transactionService.getTotalIncome(transactionService.currentMonthTransactions),
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Dépenses',
                          transactionService.getTotalExpenses(transactionService.currentMonthTransactions),
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Expense Chart
                  if (transactionService.expensesByCategory.isNotEmpty) ...[
                    Text(
                      'Répartition des dépenses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseChart(
                      expensesByCategory: transactionService.expensesByCategory,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions récentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Transaction List
                  if (transactionService.transactions.isEmpty)
                    _buildEmptyState()
                  else
                    ...transactionService.transactions
                        .take(5)
                        .map((transaction) => TransactionListItem(
                              transaction: transaction,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransactionDetailsScreen(
                                      transaction: transaction,
                                    ),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajouter',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(amount)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre première transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
