import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class BudgetPlanningWidget extends StatefulWidget {
  const BudgetPlanningWidget({super.key});

  @override
  State<BudgetPlanningWidget> createState() => _BudgetPlanningWidgetState();
}

class _BudgetPlanningWidgetState extends State<BudgetPlanningWidget> {
  final _budgetController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _loadCurrentBudget() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _budgetController.text = authService.currentUser!.monthlyBudget.toString();
    }
  }

  Future<void> _updateBudget() async {
    final amount = double.tryParse(_budgetController.text);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateUserBudget(amount);
      
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, TransactionService>(
      builder: (context, authService, transactionService, child) {
        final user = authService.currentUser;
        if (user == null) return const SizedBox.shrink();

        final budgetInitial = user.monthlyBudget;
        final totalRevenus = transactionService.totalIncome;
        final totalDepenses = transactionService.totalExpenses;
        
        // Calcul correct du solde et du restant selon la formule demandée
        final solde = budgetInitial + totalRevenus - totalDepenses;
        final restant = budgetInitial - totalDepenses + totalRevenus;
        
        // Calcul du pourcentage de progression
        final progression = budgetInitial > 0 ? (restant / budgetInitial) * 100 : 0;
        final isOverBudget = restant < 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                             Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: const Color(0xFF3B82F6).withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Icon(
                           Icons.account_balance_wallet,
                           color: Color(0xFF3B82F6),
                           size: 20,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Text(
                           'Planification du Budget',
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             color: const Color(0xFF1E293B),
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   Align(
                     alignment: Alignment.centerRight,
                     child: Container(
                       decoration: BoxDecoration(
                         color: const Color(0xFF3B82F6),
                         borderRadius: BorderRadius.circular(8),
                         boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF3B82F6).withOpacity(0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ),
                       child: IconButton(
                         onPressed: () {
                           setState(() {
                             _isEditing = !_isEditing;
                             if (!_isEditing) {
                               _loadCurrentBudget();
                             }
                           });
                         },
                         icon: Icon(
                           _isEditing ? Icons.close : Icons.edit,
                           color: Colors.white,
                           size: 20,
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
              const SizedBox(height: 16),

              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                                                 style: const TextStyle(color: Color(0xFF1E293B)),
                         decoration: InputDecoration(
                           hintText: 'Budget mensuel (FCFA)',
                           hintStyle: const TextStyle(color: Color(0xFF64748B)),
                           filled: true,
                           fillColor: const Color(0xFFF1F5F9),
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                           ),
                           enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                           ),
                           focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                           ),
                         ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                                                 : Container(
                             decoration: BoxDecoration(
                               gradient: const LinearGradient(
                                 colors: [
                                   Color(0xFF3B82F6),
                                   Color(0xFF1E3A8A),
                                 ],
                               ),
                               borderRadius: BorderRadius.circular(12),
                               boxShadow: [
                                 BoxShadow(
                                   color: const Color(0xFF3B82F6).withOpacity(0.3),
                                   blurRadius: 8,
                                   offset: const Offset(0, 2),
                                 ),
                               ],
                             ),
                             child: ElevatedButton(
                               onPressed: _updateBudget,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.transparent,
                                 foregroundColor: Colors.white,
                                 elevation: 0,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                               ),
                               child: const Text('Sauvegarder'),
                             ),
                           ),
                  ],
                ),
              ] else ...[
                // Budget Overview
                                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: const Color(0xFFF1F5F9),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: const Color(0xFFE2E8F0)),
                   ),
                   child: Column(
                     children: [
                       Row(
                         children: [
                           Expanded(
                             child: _BudgetInfoCard(
                               title: 'Budget Initial',
                               amount: budgetInitial,
                               color: const Color(0xFF3B82F6),
                               icon: Icons.account_balance_wallet,
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: _BudgetInfoCard(
                               title: 'Solde Actuel',
                               amount: solde,
                               color: solde >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                               icon: Icons.account_balance,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 12),
                       Row(
                         children: [
                           Expanded(
                             child: _BudgetInfoCard(
                               title: 'Revenus',
                               amount: totalRevenus,
                               color: const Color(0xFF10B981),
                               icon: Icons.trending_up,
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: _BudgetInfoCard(
                               title: 'Dépenses',
                               amount: totalDepenses,
                               color: const Color(0xFFEF4444),
                               icon: Icons.shopping_cart,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 12),
                       _BudgetInfoCard(
                         title: 'Restant',
                         amount: restant,
                         color: restant >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                         icon: Icons.savings,
                       ),
                     ],
                   ),
                 ),
                const SizedBox(height: 20),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(
                               Icons.trending_up,
                               color: const Color(0xFF3B82F6),
                               size: 16,
                             ),
                             const SizedBox(width: 6),
                             Expanded(
                               child: Text(
                                 'Progression du Budget',
                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                   color: const Color(0xFF1E293B),
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 8),
                         Center(
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: const Color(0xFF3B82F6).withOpacity(0.1),
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                             ),
                             child: Text(
                               restant < 0 ? 'Solde négatif' : '${progression.toStringAsFixed(1)}%',
                               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                 color: const Color(0xFF3B82F6),
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                    const SizedBox(height: 8),
                                         Container(
                       height: 12,
                       decoration: BoxDecoration(
                         color: const Color(0xFFE2E8F0),
                         borderRadius: BorderRadius.circular(6),
                       ),
                       child: ClipRRect(
                         borderRadius: BorderRadius.circular(6),
                         child: LinearProgressIndicator(
                           value: restant < 0 ? 1.0 : (progression / 100).clamp(0.0, 1.0),
                           backgroundColor: Colors.transparent,
                           valueColor: AlwaysStoppedAnimation<Color>(
                             restant < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                           ),
                           minHeight: 12,
                         ),
                       ),
                     ),
                    const SizedBox(height: 8),
                    if (restant < 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              color: const Color(0xFFDC2626),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Solde négatif de ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(restant.abs())}',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BudgetInfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _BudgetInfoCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                                 child: Text(
                   title,
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: const Color(0xFF64748B),
                     fontWeight: FontWeight.w500,
                   ),
                   overflow: TextOverflow.ellipsis,
                 ),
              ),
            ],
          ),
          const SizedBox(height: 4),
                     Text(
             NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(amount),
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: const Color(0xFF1E293B),
               fontWeight: FontWeight.bold,
             ),
           ),
        ],
      ),
    );
  }
}
