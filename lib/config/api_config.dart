class ApiConfig {
  // URL de base de l'API (à remplacer par votre domaine en production)
  static const String baseUrl = 'http://admin.cleanestuaire.com';
  //static const String baseUrl = 'http://192.168.1.135:8001'; // Pour le développement

  static const String apiVersion = '/api/v1';

  // Endpoints principaux
  static const String authEndpoint = '$apiVersion/auth';
  static const String formationsEndpoint = '$apiVersion/formations';
  static const String packsEndpoint = '$apiVersion/packs';
  static const String quizEndpoint = '$apiVersion/quiz';
  static const String affiliateEndpoint = '$apiVersion/affiliate';
  static const String walletEndpoint = '$apiVersion/wallet';
  static const String transactionsEndpoint = '$apiVersion/transactions';
  static const String settingsEndpoint = '$apiVersion/settings';
  static const String ebooksEndpoint = '$apiVersion/ebooks';
  static const String productsEndpoint = '$apiVersion/products';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  // Timeouts
  static const int connectionTimeout = 30; // secondes
  static const int receiveTimeout = 30; // secondes

  // Mega Storage Configuration
  static const String megaApiUrl = 'https://g.api.mega.co.nz';
  static const String megaStorageFolder = '/Formaneo';
}