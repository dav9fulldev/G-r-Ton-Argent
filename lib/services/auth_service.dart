import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class AuthService extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(fb_auth.User? fbUser) async {
    if (fbUser != null) {
      await _loadOrCreateUser(fbUser);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Une erreur inattendue s\'est produite');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String email, 
    required String password, 
    required String name
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        monthlyBudget: 0,
        createdAt: DateTime.now(),
        aiAdviceEnabled: true,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      _currentUser = user;
      notifyListeners();
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Une erreur inattendue s\'est produite');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      // Clear local data before signing out
      await _clearLocalData();
      
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la déconnexion');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _clearLocalData() async {
    try {
      // Clear transactions from local storage
      final transactionBox = Hive.box<TransactionModel>('transactions');
      await transactionBox.clear();
      
      // Clear offline queue
      final offlineQueueBox = Hive.box('offline_queue');
      await offlineQueueBox.clear();
      
      print('✅ Local data cleared successfully');
    } catch (e) {
      print('⚠️ Error clearing local data: $e');
    }
  }

  Future<void> updateUserBudget(double amount) async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = _currentUser!.copyWith(monthlyBudget: amount);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'monthlyBudget': amount,
      });
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour du budget');
    }
  }

  Future<void> updateAiAdviceSetting(bool enabled) async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = _currentUser!.copyWith(aiAdviceEnabled: enabled);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'aiAdviceEnabled': enabled,
      });
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour des paramètres IA');
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = _currentUser!.copyWith(profilePhotoUrl: photoUrl);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'profilePhotoUrl': photoUrl,
      });
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la photo de profil');
    }
  }

  Future<void> updateLanguage(String language) async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = _currentUser!.copyWith(language: language);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'language': language,
      });
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la langue');
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Une erreur inattendue s\'est produite');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadOrCreateUser(fb_auth.User fbUser) async {
    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        print('✅ User loaded from Firestore: ${_currentUser!.name} (Budget: ${_currentUser!.monthlyBudget})');
      } else {
        final user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? (fbUser.email?.split('@').first ?? 'Utilisateur'),
          monthlyBudget: 0,
          createdAt: DateTime.now(),
          aiAdviceEnabled: true,
        );
        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        _currentUser = user;
        print('✅ New user created: ${_currentUser!.name}');
      }
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement du profil utilisateur');
      print('❌ Error loading user: $e');
    }
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

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return 'Erreur d\'authentification';
    }
  }
}


