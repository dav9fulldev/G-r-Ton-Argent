import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';

import '../models/transaction_model.dart';

class FinancialTipsWidget extends StatefulWidget {
  const FinancialTipsWidget({super.key});

  @override
  State<FinancialTipsWidget> createState() => _FinancialTipsWidgetState();
}

class _FinancialTipsWidgetState extends State<FinancialTipsWidget> {
  List<String> _aiTips = [];
  bool _isLoadingTips = false;

  @override
  void initState() {
    super.initState();
    _loadAITips();
  }

  Future<void> _loadAITips() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);

    // Vérifier si les conseils IA sont activés
    if (authService.currentUser?.aiAdviceEnabled != true) {
      setState(() {
        _aiTips = [];
        _isLoadingTips = false;
      });
      return;
    }

    setState(() => _isLoadingTips = true);

    try {
      // Pour l'instant, on utilise les conseils locaux
      // L'intégration IA sera ajoutée plus tard
      setState(() {
        _aiTips = [];
        _isLoadingTips = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTips = [];
          _isLoadingTips = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, transactionService, child) {
        // Utiliser les conseils IA si disponibles, sinon les conseils locaux
        final tips = _aiTips.isNotEmpty 
            ? _convertAITipsToFinancialTips(_aiTips)
            : _generateTips(transactionService);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF1E3A8A),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec icône et titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Conseils Financiers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Conseils
              ...tips.map((tip) => _TipCard(
                icon: tip.icon,
                title: tip.title,
                description: tip.description,
                color: tip.color,
                priority: tip.priority,
              )),
            ],
          ),
        );
      },
    );
  }

  List<FinancialTip> _generateTips(TransactionService service) {
    final tips = <FinancialTip>[];
    final expenses = service.currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final avgExpense = expenses.isNotEmpty ? totalExpenses / expenses.length : 0.0;
    
    // Tip 1: Budget dépassé
    if (totalExpenses > 100000) { // Exemple de seuil
      tips.add(FinancialTip(
        icon: Icons.warning,
        title: 'Alerte Budget',
        description: '🚨 Votre budget est dépassé. Considérez réduire vos dépenses non essentielles ce mois-ci.',
        color: const Color(0xFFEF4444),
        priority: 1,
      ));
    }
    
    // Tip 2: Dépenses en nourriture élevées
    final foodExpenses = expenses
        .where((e) => e.category == TransactionCategory.food)
        .fold(0.0, (sum, e) => sum + e.amount);
    
    if (foodExpenses > totalExpenses * 0.3) {
      tips.add(FinancialTip(
        icon: Icons.restaurant,
        title: 'Dépenses Alimentaires',
        description: '🍽️ Vous dépensez beaucoup en nourriture. Essayez de cuisiner plus à la maison pour économiser.',
        color: const Color(0xFFF59E0B),
        priority: 2,
      ));
    }
    
    // Tip 3: Épargne recommandée
    tips.add(FinancialTip(
      icon: Icons.savings,
      title: 'Conseil Épargne',
      description: '💡 Pensez à épargner au moins 10% de vos revenus pour vos objectifs futurs.',
      color: const Color(0xFF10B981),
      priority: 3,
    ));
    
    // Tip 4: Dépenses moyennes élevées
    if (avgExpense > 50000) {
      tips.add(FinancialTip(
        icon: Icons.trending_up,
        title: 'Analyse Dépenses',
        description: '📊 Vos dépenses moyennes sont élevées. Analysez vos habitudes de consommation.',
        color: const Color(0xFF8B5CF6),
        priority: 4,
      ));
    }

    // Tip 5: Transport optimisé
    final transportExpenses = expenses
        .where((e) => e.category == TransactionCategory.transport)
        .fold(0.0, (sum, e) => sum + e.amount);
    
    if (transportExpenses > totalExpenses * 0.25) {
      tips.add(FinancialTip(
        icon: Icons.directions_bus,
        title: 'Optimisation Transport',
        description: '🚐 Considérez le transport en commun pour réduire vos dépenses de transport.',
        color: const Color(0xFF06B6D4),
        priority: 5,
      ));
    }
    
    // Trier par priorité et limiter à 3 conseils
    tips.sort((a, b) => a.priority.compareTo(b.priority));
    return tips.take(3).toList();
  }

  /// Convertit les conseils IA en format FinancialTip
  List<FinancialTip> _convertAITipsToFinancialTips(List<String> aiTips) {
    final tips = <FinancialTip>[];
    
    for (int i = 0; i < aiTips.length && i < 3; i++) {
      final tip = aiTips[i];
      final icon = _getIconForTip(tip);
      final color = _getColorForTip(tip);
      final title = _getTitleForTip(tip, i + 1);
      
      tips.add(FinancialTip(
        icon: icon,
        title: title,
        description: tip,
        color: color,
        priority: i + 1,
      ));
    }
    
    return tips;
  }

  /// Détermine le titre approprié selon le contenu du conseil
  String _getTitleForTip(String tip, int index) {
    final lowerTip = tip.toLowerCase();
    
    if (lowerTip.contains('budget') || lowerTip.contains('dépassé')) {
      return 'Alerte Budget';
    } else if (lowerTip.contains('nourriture') || lowerTip.contains('🍽️')) {
      return 'Dépenses Alimentaires';
    } else if (lowerTip.contains('épargner') || lowerTip.contains('💡')) {
      return 'Conseil Épargne';
    } else if (lowerTip.contains('excellent') || lowerTip.contains('✅')) {
      return 'Excellent Gestion';
    } else if (lowerTip.contains('attention') || lowerTip.contains('🚨')) {
      return 'Attention Requise';
    } else if (lowerTip.contains('transport') || lowerTip.contains('🚐')) {
      return 'Optimisation Transport';
    } else if (lowerTip.contains('santé') || lowerTip.contains('🏥')) {
      return 'Conseil Santé';
    } else if (lowerTip.contains('divertissement') || lowerTip.contains('🎮')) {
      return 'Loisirs Économiques';
    } else {
      return 'Conseil Personnalisé';
    }
  }

  /// Détermine l'icône appropriée selon le contenu du conseil
  IconData _getIconForTip(String tip) {
    final lowerTip = tip.toLowerCase();
    
    if (lowerTip.contains('budget') || lowerTip.contains('dépassé')) {
      return Icons.warning;
    } else if (lowerTip.contains('nourriture') || lowerTip.contains('🍽️')) {
      return Icons.restaurant;
    } else if (lowerTip.contains('épargner') || lowerTip.contains('💡')) {
      return Icons.savings;
    } else if (lowerTip.contains('excellent') || lowerTip.contains('✅')) {
      return Icons.check_circle;
    } else if (lowerTip.contains('attention') || lowerTip.contains('🚨')) {
      return Icons.error;
    } else {
      return Icons.lightbulb;
    }
  }

  /// Détermine la couleur appropriée selon le contenu du conseil
  Color _getColorForTip(String tip) {
    final lowerTip = tip.toLowerCase();
    
    if (lowerTip.contains('dépassé') || lowerTip.contains('attention') || lowerTip.contains('🚨')) {
      return const Color(0xFFEF4444); // Rouge
    } else if (lowerTip.contains('prudent') || lowerTip.contains('⚠️')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (lowerTip.contains('excellent') || lowerTip.contains('✅')) {
      return const Color(0xFF10B981); // Vert
    } else {
      return const Color(0xFF3B82F6); // Bleu
    }
  }
}

class FinancialTip {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int priority;

  FinancialTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.priority,
  });
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int priority;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône avec badge de priorité
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              if (priority <= 2)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton d'action
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
