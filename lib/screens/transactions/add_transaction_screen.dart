import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/expense_chatbot_widget.dart';

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
  bool _isLoadingAdvice = false;
  String? _chatbotResponse;
  List<String> _conversationHistory = [];
  int _conversationStep = 0;

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

    setState(() {
      _showAIAdvice = true;
      _isLoadingAdvice = false;
    });
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
                if (_showAIAdvice) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // Hauteur fixe pour le chatbot
                    child: ExpenseChatbotWidget(
                      amount: double.tryParse(_amountController.text) ?? 0,
                      category: _category,
                      description: _descriptionController.text,
                      onClose: () {
                                  setState(() {
                                    _showAIAdvice = false;
                                  });
                                },
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

