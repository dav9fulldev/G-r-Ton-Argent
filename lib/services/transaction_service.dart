import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService extends ChangeNotifier {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final ApiService _apiService = ApiService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Calculer le solde actuel
  double get currentBalance {
    double balance = 0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  // Obtenir les transactions du mois actuel
  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions.where((transaction) {
      return transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Obtenir les dépenses du mois actuel
  List<TransactionModel> get currentMonthExpenses {
    return currentMonthTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .toList();
  }

  // Obtenir les revenus du mois actuel
  List<TransactionModel> get currentMonthIncomes {
    return currentMonthTransactions
        .where((transaction) => transaction.type == TransactionType.income)
        .toList();
  }

  // Charger les transactions
  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      // Essayer de charger depuis l'API
      if (_apiService.isAuthenticated) {
        final apiTransactions = await _apiService.getTransactions();
        _transactions = apiTransactions;
        
        // Sauvegarder en local
        await _saveTransactionsLocally(apiTransactions);
        
        _setOnline(true);
      } else {
        // Charger depuis le stockage local
        await _loadTransactionsFromLocal();
        _setOnline(false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading transactions: $e');
      }
      
      // En cas d'erreur API, charger depuis le local
      await _loadTransactionsFromLocal();
      _setOnline(false);
      _setError('Mode hors ligne - données locales');
    } finally {
      _setLoading(false);
    }
  }

  // Charger depuis le stockage local
  Future<void> _loadTransactionsFromLocal() async {
    try {
      final transactionBox = await Hive.openBox<TransactionModel>('transactions');
      _transactions = transactionBox.values.toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading transactions from local: $e');
      }
      _transactions = [];
    }
  }

  // Sauvegarder en local
  Future<void> _saveTransactionsLocally(List<TransactionModel> transactions) async {
    try {
      final transactionBox = await Hive.openBox<TransactionModel>('transactions');
      await transactionBox.clear();
      await transactionBox.addAll(transactions);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving transactions locally: $e');
      }
    }
  }

  // Ajouter une transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      TransactionModel newTransaction;
      
      if (_apiService.isAuthenticated) {
        // Ajouter via l'API
        newTransaction = await _apiService.createTransaction(transaction);
        _setOnline(true);
      } else {
        // Ajouter en local seulement
        newTransaction = transaction;
        _setOnline(false);
      }

      _transactions.add(newTransaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      // Sauvegarder en local
      await _saveTransactionsLocally(_transactions);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour une transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      TransactionModel updatedTransaction;
      
      if (_apiService.isAuthenticated) {
        // Mettre à jour via l'API
        updatedTransaction = await _apiService.updateTransaction(transaction);
        _setOnline(true);
      } else {
        // Mettre à jour en local seulement
        updatedTransaction = transaction;
        _setOnline(false);
      }

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        
        // Sauvegarder en local
        await _saveTransactionsLocally(_transactions);
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer une transaction
  Future<bool> deleteTransaction(String transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiService.isAuthenticated) {
        // Supprimer via l'API
        await _apiService.deleteTransaction(transactionId);
        _setOnline(true);
      } else {
        _setOnline(false);
      }

      _transactions.removeWhere((t) => t.id == transactionId);
      
      // Sauvegarder en local
      await _saveTransactionsLocally(_transactions);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forcer le rechargement depuis l'API
  Future<void> forceRefresh() async {
    if (_apiService.isAuthenticated) {
      await loadTransactions();
    }
  }

  // Synchroniser les données locales avec l'API
  Future<void> syncWithServer() async {
    if (!_apiService.isAuthenticated) return;

    try {
      final apiTransactions = await _apiService.getTransactions();
      _transactions = apiTransactions;
      await _saveTransactionsLocally(apiTransactions);
      _setOnline(true);
      notifyListeners();
        } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing with server: $e');
      }
      _setOnline(false);
    }
  }

  // Gestion des états
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

  void _setOnline(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  // Effacer l'erreur manuellement
  void clearError() {
    _clearError();
  }

  // Debug: vérifier la cohérence des données
  Future<void> debugDataConsistency() async {
    if (kDebugMode) {
      print('🔍 Debug: Transaction count - Local: ${_transactions.length}');
      
      if (_apiService.isAuthenticated) {
        try {
          final apiTransactions = await _apiService.getTransactions();
          print('🔍 Debug: Transaction count - API: ${apiTransactions.length}');
        } catch (e) {
          print('🔍 Debug: Could not fetch API transactions: $e');
        }
      }
    }
  }
}
