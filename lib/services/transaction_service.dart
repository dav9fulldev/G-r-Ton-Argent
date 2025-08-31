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
  bool get isOffline => !_isOnline; // Ajout de la propriété isOffline

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

  // Removed deprecated method - use getCurrentMonthBalance() instead

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
      // Clear any existing transactions first
      _transactions.clear();
      
      // Load from Firestore first (source of truth)
      if (_isOnline) {
        await _loadFromFirestore(userId);
      } else {
        // Only load from local if offline
        await _loadFromLocal(userId);
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
      print('🔄 Loading transactions from Firestore for user: $userId');
      
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final firestoreTransactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();

      print('📊 Found ${firestoreTransactions.length} transactions in Firestore');

      // Use Firestore as source of truth (no merge with local data)
      _transactions = firestoreTransactions;
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      // Calculate totals for debugging
      double totalIncome = 0;
      double totalExpenses = 0;
      for (final transaction in _transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      }
      
      print('💰 Total Income: ${totalIncome.toStringAsFixed(0)} FCFA');
      print('💸 Total Expenses: ${totalExpenses.toStringAsFixed(0)} FCFA');
      print('📈 Net: ${(totalIncome - totalExpenses).toStringAsFixed(0)} FCFA');

      // Save to local storage for offline access
      await _saveToLocal();
      
      print('✅ Loaded ${_transactions.length} transactions from Firestore for user $userId');
    } catch (e) {
      print('❌ Error loading from Firestore: $e');
      _isOnline = false;
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final box = Hive.box<TransactionModel>('transactions');
      await box.clear();
      await box.addAll(_transactions);
      print('✅ Saved ${_transactions.length} transactions to local storage');
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

    print('🔄 Adding transaction: ${transaction.id} - ${transaction.amount} FCFA - ${transaction.type} - ${transaction.category}');

    try {
      // Add to local list immediately for responsive UI
      _transactions.insert(0, transaction);
      await _saveToLocal();
      notifyListeners();
      print('✅ Transaction added to local storage');

      // Add to Firestore if online
      if (_isOnline) {
        print('🌐 Saving to Firestore...');
        await _firestore
            .collection('transactions')
            .doc(transaction.id)
            .set(transaction.toMap());
        print('✅ Transaction saved to Firestore: ${transaction.id}');
        
        // Verify the transaction was saved
        final savedDoc = await _firestore
            .collection('transactions')
            .doc(transaction.id)
            .get();
        
        if (savedDoc.exists) {
          print('✅ Transaction verified in Firestore');
        } else {
          print('❌ Transaction not found in Firestore after save!');
          throw Exception('Transaction not saved to Firestore');
        }
      } else {
        // Queue for later sync
        await _addToOfflineQueue(transaction);
        print('📱 Transaction queued for offline sync: ${transaction.id}');
      }
    } catch (e) {
      // Remove from local list if Firestore fails
      _transactions.removeAt(0);
      await _saveToLocal();
      notifyListeners();
      _setError('Erreur lors de l\'ajout de la transaction: $e');
      print('❌ Error adding transaction: $e');
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

  // Force refresh from Firestore (useful after login)
  Future<void> forceRefresh(String userId) async {
    print('🔄 Force refreshing transactions for user $userId');
    _isOnline = true;
    
    try {
      // Clear local data first
      _transactions.clear();
      await _saveToLocal();
      
      // Force reload from Firestore
      await _loadFromFirestore(userId);
      
      print('✅ Force refresh completed for user $userId');
    } catch (e) {
      print('❌ Error during force refresh: $e');
      // Fallback to local data if Firestore fails
      await _loadFromLocal(userId);
    }
  }

  // Debug method to check data consistency
  Future<void> debugDataConsistency(String userId) async {
    print('🔍 Debugging data consistency for user: $userId');
    
    // Check local data
    print('📱 Local transactions: ${_transactions.length}');
    for (final transaction in _transactions.take(5)) {
      print('  - ${transaction.id}: ${transaction.amount} FCFA (${transaction.type})');
    }
    
    // Check Firestore data
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();
      
      print('🌐 Firestore transactions: ${snapshot.docs.length}');
      for (final doc in snapshot.docs.take(5)) {
        final data = doc.data();
        print('  - ${doc.id}: ${data['amount']} FCFA (${data['type']})');
      }
    } catch (e) {
      print('❌ Error checking Firestore: $e');
    }
  }
}
