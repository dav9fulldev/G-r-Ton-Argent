import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../models/transaction_model.dart';

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
  TransactionCategory _category = TransactionCategory.food;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final tx = context.read<TransactionService>();
    if (auth.currentUser == null) return;

    setState(() => _isSubmitting = true);
    try {
      await tx.addTransaction(
        userId: auth.currentUser!.uid,
        amount: double.parse(_amountController.text),
        type: _type,
        category: _category,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
      );
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
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                onChanged: (v) => setState(() => _category = v ?? _category),
                items: TransactionCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
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
              ),
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

