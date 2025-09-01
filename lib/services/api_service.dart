// import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: Duration(milliseconds: ApiConfig.requestTimeout),
    receiveTimeout: Duration(milliseconds: ApiConfig.requestTimeout),
    headers: ApiConfig.defaultHeaders,
  ));

  String? _authToken;

  // Initialiser le token depuis le stockage local
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Supprimer le token
  Future<void> _clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _dio.options.headers.remove('Authorization');
  }

  // Gestion des erreurs
  void _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      // Token expiré ou invalide
      _clearToken();
    }
    throw Exception(e.response?.data?['message'] ?? e.message);
  }

  // ===== AUTHENTIFICATION =====

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final userData = response.data['user'];
      final token = response.data['token'];
      
      await _saveToken(token);
      
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final userData = response.data['user'];
      final token = response.data['token'];
      
      await _saveToken(token);
      
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // ===== TRANSACTIONS =====

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get(ApiConfig.transactionsEndpoint);
      
      final List<dynamic> transactionsData = response.data['transactions'];
      return transactionsData
          .map((json) => TransactionModel.fromMap(json))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _dio.post(
        ApiConfig.transactionsEndpoint,
        data: transaction.toJson(),
      );
      
      return TransactionModel.fromMap(response.data['transaction']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.transactionsEndpoint}/${transaction.id}',
        data: transaction.toJson(),
      );
      
      return TransactionModel.fromMap(response.data['transaction']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _dio.delete('${ApiConfig.transactionsEndpoint}/$transactionId');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ===== BUDGET =====

  Future<BudgetModel> getBudget() async {
    try {
      final response = await _dio.get(ApiConfig.budgetEndpoint);
      return BudgetModel.fromJson(response.data['budget']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    try {
      final response = await _dio.put(
        ApiConfig.budgetEndpoint,
        data: budget.toJson(),
      );
      
      return BudgetModel.fromJson(response.data['budget']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ===== ANALYTICS =====

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _dio.get(ApiConfig.analyticsEndpoint);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ===== UTILITAIRES =====

  bool get isAuthenticated => _authToken != null;
  
  String? get authToken => _authToken;
}
