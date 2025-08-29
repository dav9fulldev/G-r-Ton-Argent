import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/gemini_service.dart';
import '../../models/transaction_model.dart';
import '../../utils/category_utils.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _type = TransactionType.expense;
  TransactionCategory? _category;
  bool _isSubmitting = false;
  bool _showAIAdvice = false;
  Map<String, dynamic>? _chatbotResponse;
  bool _isLoadingAdvice = false;
  List<Map<String, dynamic>> _conversationHistory = [];
  int _conversationStep = 0; // Limiter la conversation à 3 étapes maximum

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getAIAdvice() async {
    if (_amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final auth = context.read<AuthService>();
    final tx = context.read<TransactionService>();
    final gemini = context.read<GeminiService>();
    
    if (auth.currentUser == null) return;

    // Vérifier si les conseils IA sont activés
    if (!auth.currentUser!.aiAdviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les conseils IA sont désactivés dans les paramètres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingAdvice = true);
    
    try {
      // Récupérer les données nécessaires depuis Firestore
      final budget = auth.currentUser!.monthlyBudget;
      final depenses = tx.totalExpenses; // Dépenses actuelles du mois
      
             // Appeler la fonction d'analyse conversationnelle
       final analyse = await gemini.analyserDepense(budget, depenses, amount, category: _category);
      
       if (mounted) {
                 setState(() {
          _chatbotResponse = analyse;
          _conversationHistory = [analyse]; // Initialiser l'historique
          _conversationStep = 1; // Première étape
          _showAIAdvice = true;
          _isLoadingAdvice = false;
        });
       }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAdvice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du conseil: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleChatbotOption(String option) async {
    // Si c'est un choix avec prix spécifique, permettre l'enregistrement direct
    if (option.contains('(') && option.contains('FCFA')) {
      // L'utilisateur peut enregistrer directement avec cette option
      final priceMatch = RegExp(r'\((\d+)\s*FCFA\)').firstMatch(option);
      if (priceMatch != null) {
        final price = int.parse(priceMatch.group(1)!);
        _amountController.text = price.toString();
        _submit();
        return;
      }
    }
    
    // Vérifier si on a atteint la limite de conversation
    if (_conversationStep >= 3) {
      _showFinalOptions(option);
      return;
    }

    setState(() => _isLoadingAdvice = true);

    try {
      final auth = context.read<AuthService>();
      final gemini = context.read<GeminiService>();
      final tx = context.read<TransactionService>();

      if (auth.currentUser == null) return;

      final budget = auth.currentUser!.monthlyBudget;
      final depenses = tx.totalExpenses;
      final amount = double.parse(_amountController.text);

      // Appeler l'IA avec le choix de l'utilisateur
      final response = await gemini.analyserDepense(
        budget, 
        depenses, 
        amount, 
        category: _category,
        userChoice: option,
      );
      
      if (mounted) {
        setState(() {
          _chatbotResponse = response;
          _conversationHistory.add(response);
          _conversationStep++; // Incrémenter l'étape
          _isLoadingAdvice = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAdvice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'analyse: ${e.toString()}')),
        );
      }
    }
  }

  void _showFinalOptions(String lastChoice) {
    final auth = context.read<AuthService>();
    final budget = auth.currentUser?.monthlyBudget ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final categoryName = _category != null ? CategoryUtils.getCategoryName(_category!) : 'cette dépense';

    String message = '';
    List<String> options = [];

    // Vérifier si c'est un choix avec prix spécifique
    final priceMatch = RegExp(r'\((\d+)\s*FCFA\)').firstMatch(lastChoice);
    
    if (priceMatch != null) {
      // Choix avec prix spécifique
      final price = int.parse(priceMatch.group(1)!);
      final economie = amount - price;
      
      if (lastChoice.contains('gbaka') || lastChoice.contains('Gbaka')) {
        message = '🚐 Super choix ! Le Gbaka à $price FCFA est économique et efficace. Tu as économisé ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('bus') || lastChoice.contains('Bus')) {
        message = '🚌 Parfait ! Le bus à $price FCFA est un excellent choix. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('woro') || lastChoice.contains('Woro')) {
        message = '🚐 Excellente décision ! Le Woroworo à $price FCFA est une option viable. Tu as économisé ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('taxi') || lastChoice.contains('Taxi')) {
        message = '🚕 Confortable ! Le taxi à $price FCFA est pratique. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('marche') || lastChoice.contains('Marche') || lastChoice.contains('0 FCFA')) {
        message = '🚶‍♂️ Sage choix ! Marcher est gratuit et bon pour la santé. Tu économiseras ${amount.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('street') || lastChoice.contains('Street')) {
        message = '🍜 Excellente idée ! La street food à $price FCFA est délicieuse et économique. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('cantine') || lastChoice.contains('Cantine')) {
        message = '🍽️ Parfait ! La cantine populaire à $price FCFA offre un bon rapport qualité-prix. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('marché') || lastChoice.contains('Marché') || lastChoice.contains('local')) {
        message = '🥬 Sage choix ! Le marché local à $price FCFA est frais et économique. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else if (lastChoice.contains('cuisine') || lastChoice.contains('Cuisine') || lastChoice.contains('maison')) {
        message = '👨‍🍳 Brillant ! Cuisiner à la maison à $price FCFA est sain et économique. Tu économiseras ${economie.toStringAsFixed(0)} FCFA !';
      } else {
        message = '💡 Excellente décision ! Tu économiseras ${economie.toStringAsFixed(0)} FCFA avec ce choix !';
      }
      
      options = ['Enregistrer ($price FCFA)', 'Modifier le montant', 'Fermer'];
    } else {
      // Choix générique
      switch (lastChoice) {
        case 'Continuer':
        case 'Finaliser le choix':
          message = '✅ Parfait ! Tu as fait un bon choix pour $categoryName. Tu économiseras ${(amount * 0.3).toStringAsFixed(0)} FCFA ! 💰';
          options = ['Enregistrer la transaction', 'Modifier le montant', 'Fermer'];
          break;
        case 'Reporter':
        case 'Attendre les soldes':
          message = '⏰ Bonne décision ! Tu économiseras ${amount.toStringAsFixed(0)} FCFA en reportant cet achat.';
          options = ['Annuler la transaction', 'Programmer un rappel', 'Fermer'];
          break;
        default:
          message = '💡 Merci pour cette conversation ! Tu as pris une décision éclairée pour ton budget.';
          options = ['Enregistrer la transaction', 'Modifier le montant', 'Fermer'];
      }
    }

    final finalResponse = {
      'message': message,
      'options': options,
      'isFinal': true,
    };

    setState(() {
      _chatbotResponse = finalResponse;
      _conversationHistory.add(finalResponse);
      _isLoadingAdvice = false;
    });
  }

  void _handleFinalOption(String option) {
    if (option == 'Enregistrer la transaction') {
      _submit();
    } else if (option == 'Enregistrer (300 FCFA)') {
      _amountController.text = '300';
      _submit();
    } else if (option.startsWith('Enregistrer (') && option.endsWith(' FCFA)')) {
      // Extraire le montant du texte "Enregistrer (X FCFA)"
      final amountText = option.substring(13, option.length - 6); // Enlever "Enregistrer (" et " FCFA)"
      final amount = double.tryParse(amountText) ?? 0;
      _amountController.text = amount.toStringAsFixed(0);
      _submit();
    } else if (option == 'Modifier le montant') {
      // L'utilisateur peut modifier le montant manuellement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💡 Modifiez le montant dans le champ ci-dessus'),
          backgroundColor: Colors.blue,
        ),
      );
    } else if (option == 'Annuler la transaction') {
      Navigator.of(context).pop();
    } else if (option == 'Programmer un rappel') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Rappel programmé pour plus tard !'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } else if (option == 'Fermer') {
      // Mettre à jour le montant selon le dernier choix avec prix spécifique
      _updateAmountFromLastChoice();
      
      setState(() {
        _showAIAdvice = false;
        _conversationHistory.clear();
        _conversationStep = 0;
      });
    }
  }

  /// Met à jour le montant selon le dernier choix avec prix spécifique
  void _updateAmountFromLastChoice() {
    if (_conversationHistory.isNotEmpty) {
      final lastResponse = _conversationHistory.last;
      final options = lastResponse['options'] as List<String>?;
      
      if (options != null) {
        // Chercher une option "Enregistrer (X FCFA)" dans les dernières options
        for (final option in options) {
          if (option.startsWith('Enregistrer (') && option.endsWith(' FCFA)')) {
            final amountText = option.substring(13, option.length - 6);
            final amount = double.tryParse(amountText);
            if (amount != null) {
              _amountController.text = amount.toStringAsFixed(0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('💰 Montant mis à jour : ${amount.toStringAsFixed(0)} FCFA'),
                  backgroundColor: Colors.green,
                ),
              );
              return;
            }
          }
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final auth = context.read<AuthService>();
    final tx = context.read<TransactionService>();
    final notification = context.read<NotificationService>();
    if (auth.currentUser == null) return;

    final amount = double.parse(_amountController.text);
    final isExpense = _type == TransactionType.expense;

    setState(() => _isSubmitting = true);
    try {
      await tx.addTransaction(
        userId: auth.currentUser!.uid,
        amount: amount,
        type: _type,
        category: _category!,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
      );

      // Show budget alerts for expenses
      if (isExpense) {
        final budgetInitial = auth.currentUser!.monthlyBudget;
        final currentBalance = tx.getCurrentMonthBalance(budgetInitial);
        final newBalance = currentBalance - amount;
        await notification.showBudgetOverrunAlert(
          currentBalance: newBalance,
          monthlyBudget: budgetInitial,
          expenseAmount: amount,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, icon: Icon(Icons.remove), label: Text('Dépense')),
                  ButtonSegment(value: TransactionType.income, icon: Icon(Icons.add), label: Text('Revenu')),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  setState(() {
                    _type = s.first;
                    // Réinitialiser la catégorie quand le type change
                    _category = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                onChanged: (v) => setState(() => _category = v),
                items: (_type == TransactionType.expense 
                    ? CategoryUtils.getExpenseCategories() 
                    : CategoryUtils.getIncomeCategories()).map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Text(CategoryUtils.getCategoryIcon(c)),
                        const SizedBox(width: 8),
                        Text(CategoryUtils.getCategoryName(c)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Entrez un montant valide';
                  return null;
                },
                onChanged: (value) {
                  // Clear AI advice when amount changes
                                     if (_showAIAdvice) {
                     setState(() {
                       _showAIAdvice = false;
                       _chatbotResponse = null;
                       _conversationHistory.clear();
                       _conversationStep = 0;
                     });
                   }
                },
              ),
              const SizedBox(height: 16),
              if (_type == TransactionType.expense) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingAdvice ? null : _getAIAdvice,
                        icon: _isLoadingAdvice 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.psychology),
                                                 label: Text(_isLoadingAdvice ? 'Analyse...' : 'Analyser cette dépense'),
                      ),
                    ),
                  ],
                ),
                if (_showAIAdvice && _conversationHistory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Conseiller IA',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            // Indicateur de progrès de conversation
                            Text(
                              'Étape $_conversationStep/3',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_conversationHistory.length > 1)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _conversationHistory.clear();
                                    _showAIAdvice = false;
                                    _conversationStep = 0;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 20),
                                tooltip: 'Fermer la conversation',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Afficher seulement le dernier message de conversation
                        if (_conversationHistory.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _conversationHistory.last['message'] as String,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (_conversationHistory.last['options'] as List<String>).map((option) {
                              final isFinal = _conversationHistory.last['isFinal'] == true;
                              return ElevatedButton(
                                onPressed: _isLoadingAdvice ? null : () {
                                  if (isFinal) {
                                    _handleFinalOption(option);
                                  } else {
                                    _handleChatbotOption(option);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  backgroundColor: isFinal 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  foregroundColor: isFinal 
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                child: Text(option),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optionnel)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.toLocal().toString().substring(0, 16)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = TimeOfDay.fromDateTime(_selectedDate);
                        setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
                      }
                    },
                    child: const Text('Choisir la date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

