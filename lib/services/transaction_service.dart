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
  String? _error;
  bool _isOnline = true;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

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

  // Calculate current month balance (corrected formula)
  // solde = budgetInitial + totalRevenus - totalDepenses
  double getCurrentMonthBalance(double budgetInitial) {
    double income = 0;
    double expenses = 0;
    
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }
    
    return budgetInitial + income - expenses;
  }

  // Calculate remaining budget (corrected formula)
  // restant = budgetInitial - totalDepenses + totalRevenus
  double getRemainingBudget(double budgetInitial) {
    double income = 0;
    double expenses = 0;
    
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }
    
    return budgetInitial - expenses + income;
  }

  // Calculate budget progression percentage
  // progression = (restant / budgetInitial) * 100
  double getBudgetProgressionPercentage(double budgetInitial) {
    if (budgetInitial <= 0) return 0;
    final restant = getRemainingBudget(budgetInitial);
    return (restant / budgetInitial) * 100;
  }

  // Legacy method for backward compatibility (deprecated)
  @deprecated
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

  // Get total income for current month
  double get totalIncome {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total expenses for current month
  double get totalExpenses {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> loadTransactions(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load from local storage first
      await _loadFromLocal(userId);
      
      // Then sync with Firestore if online
      if (_isOnline) {
        await _loadFromFirestore(userId);
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des transactions: $e');
      _setLoading(false);
    }
  }

  Future<void> _loadFromLocal(String userId) async {
    try {
      final box = Hive.box<TransactionModel>('transactions');
      final localTransactions = box.values
          .where((transaction) => transaction.userId == userId)
          .toList();
      
      _transactions = localTransactions;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
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
      _isOnline = false;
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
      // Add to local list immediately for responsive UI
      _transactions.insert(0, transaction);
      await _saveToLocal();
      notifyListeners();

      // Add to Firestore if online
      if (_isOnline) {
        await _firestore
            .collection('transactions')
            .doc(transaction.id)
            .set(transaction.toMap());
        print('Transaction saved to Firestore: ${transaction.id}');
      } else {
        // Queue for later sync
        await _addToOfflineQueue(transaction);
        print('Transaction queued for offline sync: ${transaction.id}');
      }
    } catch (e) {
      // Remove from local list if Firestore fails
      _transactions.removeAt(0);
      await _saveToLocal();
      notifyListeners();
      _setError('Erreur lors de l\'ajout de la transaction: $e');
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Update in local list immediately
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await _saveToLocal();
        notifyListeners();
      }

      // Update in Firestore if online
      if (_isOnline) {
        await _firestore
            .collection('transactions')
            .doc(transaction.id)
            .update(transaction.toMap());
      } else {
        // Queue for later sync
        await _addToOfflineQueue(transaction, isUpdate: true);
      }
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Remove from local list immediately
      _transactions.removeWhere((t) => t.id == transactionId);
      await _saveToLocal();
      notifyListeners();

      // Delete from Firestore if online
      if (_isOnline) {
        await _firestore
            .collection('transactions')
            .doc(transactionId)
            .delete();
      } else {
        // Queue for later sync
        await _addToOfflineQueue(null, transactionId: transactionId, isDelete: true);
      }
    } catch (e) {
      _setError('Erreur lors de la suppression de la transaction: $e');
      rethrow;
    }
  }

  Future<void> _addToOfflineQueue(
    TransactionModel? transaction, {
    String? transactionId,
    bool isUpdate = false,
    bool isDelete = false,
  }) async {
    try {
      final box = Hive.box('offline_queue');
      final queueItem = {
        'action': isDelete ? 'delete' : (isUpdate ? 'update' : 'add'),
        'transaction': transaction?.toMap(),
        'transactionId': transactionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await box.add(queueItem);
    } catch (e) {
      print('Error adding to offline queue: $e');
    }
  }

  Future<void> syncOfflineQueue() async {
    if (!_isOnline) return;

    try {
      final box = Hive.box('offline_queue');
      final queue = box.values.toList();
      
      for (final item in queue) {
        try {
          switch (item['action']) {
            case 'add':
              final transaction = TransactionModel.fromMap(item['transaction']);
              await _firestore
                  .collection('transactions')
                  .doc(transaction.id)
                  .set(transaction.toMap());
              break;
            case 'update':
              final transaction = TransactionModel.fromMap(item['transaction']);
              await _firestore
                  .collection('transactions')
                  .doc(transaction.id)
                  .update(transaction.toMap());
              break;
            case 'delete':
              await _firestore
                  .collection('transactions')
                  .doc(item['transactionId'])
                  .delete();
              break;
          }
        } catch (e) {
          print('Error syncing queue item: $e');
        }
      }
      
      await box.clear();
    } catch (e) {
      print('Error syncing offline queue: $e');
    }
  }

  // Get transactions for a specific date range
  List<TransactionModel> getTransactionsForDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    if (online) {
      syncOfflineQueue();
    }
  }
}
