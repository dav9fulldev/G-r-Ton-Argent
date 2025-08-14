import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double monthlyBudget;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final remainingBudget = monthlyBudget - (monthlyBudget - balance);
    final budgetPercentage = monthlyBudget > 0 ? (remainingBudget / monthlyBudget) * 100 : 0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solde du mois',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green[100] : Colors.red[100],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isPositive ? 'Solde positif' : 'Solde négatif',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPositive ? Colors.green[100] : Colors.red[100],
                  ),
                ),
              ],
            ),
            
            if (monthlyBudget > 0) ...[
              const SizedBox(height: 24),
              
              // Budget Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget mensuel',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${budgetPercentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  LinearProgressIndicator(
                    value: budgetPercentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetPercentage > 80 
                          ? Colors.red[100]! 
                          : budgetPercentage > 60 
                              ? Colors.orange[100]! 
                              : Colors.green[100]!,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(remainingBudget)} restant sur ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(monthlyBudget)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
