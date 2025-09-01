import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _apiService.isAuthenticated;

  // Callback pour notifier quand l'utilisateur est chargé
  Function()? _onUserLoaded;

  void setOnUserLoadedCallback(Function() callback) {
    _onUserLoaded = callback;
  }

  // Initialiser le service
  Future<void> initialize() async {
    try {
      await _apiService.initialize();
      
      // Vérifier si un token existe et charger l'utilisateur
      if (_apiService.isAuthenticated) {
        await _loadCurrentUser();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AuthService: $e');
      }
    }
  }

  // Charger l'utilisateur actuel depuis l'API
  Future<void> _loadCurrentUser() async {
    try {
      // Pour l'instant, on va utiliser les données locales
      // TODO: Ajouter un endpoint /auth/me pour récupérer les infos utilisateur
      final userBox = await Hive.openBox<UserModel>('users');
      if (userBox.isNotEmpty) {
        _currentUser = userBox.values.first;
        notifyListeners();
        _onUserLoaded?.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading current user: $e');
      }
    }
  }

  // Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = user;
      
      // Sauvegarder en local
      await _saveUserLocally(user);
      
      notifyListeners();
      _onUserLoaded?.call();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.login(
        email: email,
        password: password,
      );

      _currentUser = user;
      
      // Sauvegarder en local
      await _saveUserLocally(user);
      
      notifyListeners();
      _onUserLoaded?.call();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _apiService.logout();
      await _clearLocalData();
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during sign out: $e');
      }
    }
  }

  // Sauvegarder l'utilisateur en local
  Future<void> _saveUserLocally(UserModel user) async {
    try {
      final userBox = await Hive.openBox<UserModel>('users');
      await userBox.clear();
      await userBox.add(user);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving user locally: $e');
      }
    }
  }

  // Effacer les données locales
  Future<void> _clearLocalData() async {
    try {
      final userBox = await Hive.openBox<UserModel>('users');
      await userBox.clear();
      
      final transactionBox = await Hive.openBox('transactions');
      await transactionBox.clear();
      
      final budgetBox = await Hive.openBox('budgets');
      await budgetBox.clear();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing local data: $e');
      }
    }
  }

  // Mettre à jour l'utilisateur
  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserLocally(updatedUser);
    notifyListeners();
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

  // Effacer l'erreur manuellement
  void clearError() {
    _clearError();
  }
}


