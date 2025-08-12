import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class TransactionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

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

    try {
      // Load from local storage first
      await _loadFromLocal(userId);
      
      // Then sync with Firestore
      await _loadFromFirestore(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading transactions: $e');
    }
  }

  Future<void> _loadFromLocal(String userId) async {
    try {
      final box = Hive.box<TransactionModel>('transactions');
      final localTransactions = box.values
          .where((transaction) => transaction.userId == userId)
          .toList();
      
      _transactions = localTransactions;
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  Future<void> _loadFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final firestoreTransactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();

      // Merge with local data
      final Map<String, TransactionModel> mergedTransactions = {};
      
      // Add local transactions
      for (final transaction in _transactions) {
        mergedTransactions[transaction.id] = transaction;
      }
      
      // Add/update Firestore transactions
      for (final transaction in firestoreTransactions) {
        mergedTransactions[transaction.id] = transaction;
      }

      _transactions = mergedTransactions.values.toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      // Save to local storage
      await _saveToLocal();
    } catch (e) {
      print('Error loading from Firestore: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final box = Hive.box<TransactionModel>('transactions');
      await box.clear();
      await box.addAll(_transactions);
    } catch (e) {
      print('Error saving to local storage: $e');
    }
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

    try {
      // Add to Firestore
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());

      // Add to local list
      _transactions.insert(0, transaction);
      
      // Save to local storage
      await _saveToLocal();

      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());

      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
      
      // Save to local storage
      await _saveToLocal();

      notifyListeners();
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .delete();

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);
      
      // Save to local storage
      await _saveToLocal();

      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
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
}
