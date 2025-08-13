import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class MockTransactionService extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Mock data for testing
  final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: '1',
      userId: 'mock-user-id',
      amount: 25000.0,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Salaire du mois',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TransactionModel(
      id: '2',
      userId: 'mock-user-id',
      amount: 5000.0,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Courses alimentaires',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: '3',
      userId: 'mock-user-id',
      amount: 3000.0,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Transport en commun',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: '4',
      userId: 'mock-user-id',
      amount: 8000.0,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Achats vêtements',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: '5',
      userId: 'mock-user-id',
      amount: 2000.0,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      date: DateTime.now(),
      description: 'Cinéma',
      createdAt: DateTime.now(),
    ),
  ];

  // Get transactions for current month
  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions.where((transaction) {
      return transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Calculate current month balance
  double get currentMonthBalance {
    double income = 0;
    double expenses = 0;
    
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }
    
    return income - expenses;
  }

  // Get expenses by category for current month
  Map<TransactionCategory, double> get expensesByCategory {
    final Map<TransactionCategory, double> categoryExpenses = {};
    
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryExpenses[transaction.category] = 
            (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return categoryExpenses;
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Load mock data
    _transactions = List.from(_mockTransactions);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required String userId,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
    required String description,
  }) async {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      userId: userId,
      amount: amount,
      type: type,
      category: category,
      date: date,
      description: description,
      createdAt: DateTime.now(),
    );

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Add to local list
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Update in local list
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }

    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Remove from local list
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }

  // Get transactions for a specific date range
  List<TransactionModel> getTransactionsForDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total income for a period
  double getTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total expenses for a period
  double getTotalExpenses(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Initialize with mock data for testing
  void initializeWithMockData() {
    _transactions = List.from(_mockTransactions);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }
}
