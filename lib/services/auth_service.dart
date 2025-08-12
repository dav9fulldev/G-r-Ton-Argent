import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _loadOrCreateUser(credential.user!);
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
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
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserBudget(double amount) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(monthlyBudget: amount);
    await _firestore.collection('users').doc(_currentUser!.uid).update({
      'monthlyBudget': amount,
    });
    notifyListeners();
  }

  Future<void> updateAiAdviceSetting(bool enabled) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(aiAdviceEnabled: enabled);
    await _firestore.collection('users').doc(_currentUser!.uid).update({
      'aiAdviceEnabled': enabled,
    });
    notifyListeners();
  }

  Future<void> _loadOrCreateUser(fb_auth.User fbUser) async {
    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data()!);
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
    }
    notifyListeners();
  }
}


