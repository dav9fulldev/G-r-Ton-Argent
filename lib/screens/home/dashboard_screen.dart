import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removed mock service imports; using real services below
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_details_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/expense_chart.dart';
import '../../widgets/transaction_list_item.dart';
import '../../widgets/financial_tips_widget.dart';
import '../../widgets/budget_planning_widget.dart';
import '../../widgets/spending_insights_widget.dart';
import '../../widgets/app_logo.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Bleu royal
              Color(0xFF3B82F6), // Bleu plus clair
            ],
          ),
        ),
        child: Column(
          children: [
            // AppBar personnalisé
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GèrTonArgent',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // TODO: Ouvrir les notifications
                    },
                  ),
          IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
            ),
            // Contenu principal
            Expanded(
              child: Consumer2<AuthService, TransactionService>(
        builder: (context, authService, transactionService, child) {
          if (authService.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

                  // Handle different tabs
                  if (_selectedIndex == 1) {
                    return const TransactionListScreen();
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
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Voici un aperçu de vos finances',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Balance Card
                  BalanceCard(
                            balance: transactionService.currentMonthBalance,
                            monthlyBudget: 100000.0, // You might want to get this from user settings
                  ),

                  const SizedBox(height: 24),

                          // Quick Actions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Actions rapides',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const AddTransactionScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Ajouter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF1E3A8A),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                      Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const TransactionListScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.list),
                                        label: const Text('Voir tout'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                        ),
                      ),
                    ],
                                ),
                              ],
                            ),
                  ),

                  const SizedBox(height: 24),

                  // Expense Chart
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                    Text(
                      'Répartition des dépenses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: ExpenseChart(
                                    expensesByCategory: transactionService.expensesByCategory,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    const SizedBox(height: 24),

                  // Recent Transactions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions récentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const TransactionListScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Voir tout',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                                ...transactionService.currentMonthTransactions.take(3).map((transaction) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: TransactionListItem(
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
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                                            const SizedBox(height: 24),

                  // Budget Planning Widget
                  const BudgetPlanningWidget(),

                  const SizedBox(height: 24),

                  // Spending Insights Widget
                  const SpendingInsightsWidget(),

                  const SizedBox(height: 24),

                  // Financial Tips
                  const FinancialTipsWidget(),

                          const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}
