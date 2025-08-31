import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../models/transaction_model.dart';
import 'transaction_details_screen.dart';
import 'add_transaction_screen.dart';
import '../../widgets/transaction_list_item.dart';
import '../../utils/category_utils.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _filterType;
  TransactionCategory? _filterCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    
    if (authService.currentUser != null) {
      await transactionService.loadTransactions(authService.currentUser!.uid);
    }
    
    setState(() => _isLoading = false);
  }

  List<TransactionModel> get _filteredTransactions {
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    List<TransactionModel> transactions = transactionService.transactions;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      transactions = transactions.where((transaction) {
        return transaction.description.toLowerCase().contains(searchTerm) ||
               CategoryUtils.getCategoryName(transaction.category).toLowerCase().contains(searchTerm) ||
               transaction.amount.toString().contains(searchTerm);
      }).toList();
    }

    // Apply type filter
    if (_filterType != null) {
      transactions = transactions.where((transaction) => transaction.type == _filterType).toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      transactions = transactions.where((transaction) => transaction.category == _filterCategory).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      transactions = transactions.where((transaction) => transaction.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      transactions = transactions.where((transaction) => transaction.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    return transactions;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterType = null;
      _filterCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 20,
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.width > 600 ? 48 : 56,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: MediaQuery.of(context).size.width > 600 ? 20 : 24,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 1200 ? 1200 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 12 : 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
          ),

          // Filter chips
          if (_filterType != null || _filterCategory != null || _startDate != null || _endDate != null)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width > 1200 ? 1200 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_filterType != null)
                                Chip(
                                  label: Text(_filterType == TransactionType.income ? 'Revenus' : 'Dépenses'),
                                  onDeleted: () => setState(() => _filterType = null),
                                ),
                              if (_filterCategory != null)
                                Chip(
                                  label: Text(CategoryUtils.getCategoryName(_filterCategory!)),
                                  onDeleted: () => setState(() => _filterCategory = null),
                                ),
                              if (_startDate != null)
                                Chip(
                                  label: Text('À partir de ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                                  onDeleted: () => setState(() => _startDate = null),
                                ),
                              if (_endDate != null)
                                Chip(
                                  label: Text('Jusqu\'à ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                                  onDeleted: () => setState(() => _startDate = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Transaction list
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width > 1200 ? 1200 : double.infinity,
                ),
                child: Consumer<TransactionService>(
                  builder: (context, transactionService, child) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final transactions = _filteredTransactions;

                    if (transactions.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
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
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (result == true) {
            _loadTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction trouvée',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou ajoutez une nouvelle transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les transactions'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type filter
              DropdownButtonFormField<TransactionType?>(
                value: _filterType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous')),
                  const DropdownMenuItem(value: TransactionType.income, child: Text('Revenus')),
                  const DropdownMenuItem(value: TransactionType.expense, child: Text('Dépenses')),
                ],
                onChanged: (value) => setState(() => _filterType = value),
              ),
              const SizedBox(height: 16),
              
              // Category filter
              DropdownButtonFormField<TransactionCategory?>(
                value: _filterCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Toutes')),
                  ...TransactionCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(CategoryUtils.getCategoryIcon(category)),
                        const SizedBox(width: 8),
                        Text(CategoryUtils.getCategoryName(category)),
                      ],
                    ),
                  )),
                ],
                onChanged: (value) => setState(() => _filterCategory = value),
              ),
              const SizedBox(height: 16),
              
              // Date range
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      child: Text(_startDate == null 
                          ? 'Date de début' 
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                    ),
                  ),
                  const Text('à'),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: Text(_endDate == null 
                          ? 'Date de fin' 
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              this.setState(() {});
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}
