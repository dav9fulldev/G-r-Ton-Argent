class ApiConfig {
  // Configuration de l'API REST
  static const String baseUrl = 'http://localhost:3000/api'; // Pour le développement local
  // static const String baseUrl = 'https://your-api-domain.com/api'; // Pour la production
  
  // Endpoints d'authentification
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  
  // Endpoints des transactions
  static const String transactionsEndpoint = '/transactions';
  
  // Endpoints du budget
  static const String budgetEndpoint = '/budget';
  
  // Endpoints des analytics
  static const String analyticsEndpoint = '/analytics';
  
  // Timeout pour les requêtes
  static const int requestTimeout = 30000; // 30 secondes
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers avec token d'authentification
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
