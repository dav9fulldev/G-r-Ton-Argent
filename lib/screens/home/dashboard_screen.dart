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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Bleu royal foncé
              Color(0xFF3B82F6), // Bleu moyen
              Color(0xFF60A5FA), // Bleu clair
              Color(0xFF93C5FD), // Bleu très clair
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // AppBar personnalisé
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF374151), // Même couleur que le pied de page
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GèrTonArgent',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, // Texte blanc pour contraste
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
                    'Bonjour, ${authService.currentUser!.name}', // TODO: Add welcome message to translations
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Voici un aperçu de vos finances', // TODO: Add subtitle to translations
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                    balance: transactionService.getCurrentMonthBalance(authService.currentUser?.monthlyBudget ?? 0),
                    monthlyBudget: authService.currentUser?.monthlyBudget ?? 0,
                  ),

                  const SizedBox(height: 24),

                          // Quick Actions
                          Container(
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
                                Text(
                                  'Actions rapides',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF1E293B),
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
                                          backgroundColor: const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
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
                                          backgroundColor: const Color(0xFF64748B),
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
                  ExpenseChart(
                    expensesByCategory: transactionService.expensesByCategory,
                  ),

                    const SizedBox(height: 24),

                  // Recent Transactions
                          Container(
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
                          'Transactions récentes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const TransactionListScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Voir tout',
                                        style: TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                                if (transactionService.currentMonthTransactions.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.receipt_long_outlined,
                                            size: 48,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Aucune transaction',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Commencez par ajouter\ndes transactions',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1E3A8A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF9CA3AF),
          elevation: 0,
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
      ),
    );
  }
}
