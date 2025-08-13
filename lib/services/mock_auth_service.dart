import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class MockAuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Mock user data for testing
  final UserModel _mockUser = UserModel(
    uid: 'mock-user-id',
    email: 'test@example.com',
    name: 'Utilisateur Test',
    monthlyBudget: 50000.0,
    createdAt: DateTime.now(),
  );

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    _currentUser = _mockUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    double monthlyBudget,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful registration
    _currentUser = UserModel(
      uid: 'mock-new-user-id',
      email: email,
      name: name,
      monthlyBudget: monthlyBudget,
      createdAt: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({String? name, double? monthlyBudget}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      monthlyBudget: monthlyBudget ?? _currentUser!.monthlyBudget,
    );
    _isLoading = false;
    notifyListeners();
  }

  // Initialize with mock user for testing
  void initializeWithMockUser() {
    _currentUser = _mockUser;
    notifyListeners();
  }
}
