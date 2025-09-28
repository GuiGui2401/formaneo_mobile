import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/constants.dart';

class ApiService {
  static String? _authToken;
  
  // Obtenir le token stocké
  static Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.userTokenKey);
    return _authToken;
  }
  
  // Sauvegarder le token
  static Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
  }
  
  // Supprimer le token
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
  }
  
  // GET Request
  static Future<dynamic> get(String endpoint) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: token != null 
            ? ApiConfig.getAuthHeaders(token)
            : ApiConfig.headers,
      ).timeout(Duration(seconds: ApiConfig.connectionTimeout));
      
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST Request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: token != null 
            ? ApiConfig.getAuthHeaders(token)
            : ApiConfig.headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: ApiConfig.connectionTimeout));
      
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT Request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: token != null 
            ? ApiConfig.getAuthHeaders(token)
            : ApiConfig.headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: ApiConfig.connectionTimeout));
      
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE Request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: token != null 
            ? ApiConfig.getAuthHeaders(token)
            : ApiConfig.headers,
      ).timeout(Duration(seconds: ApiConfig.connectionTimeout));
      
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Upload File
  static Future<dynamic> uploadFile(String endpoint, String filePath, {Map<String, String>? fields}) async {
    try {
      final token = await getAuthToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);
      
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Process Response
  static dynamic _processResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        clearAuthToken();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      case 403:
        throw Exception('Accès refusé');
      case 404:
        throw Exception('Ressource non trouvée');
      case 422:
        throw Exception(body['message'] ?? 'Données invalides');
      case 500:
        throw Exception('Erreur serveur');
      default:
        throw Exception(body['message'] ?? 'Erreur inconnue');
    }
  }
  
  // Handle Errors
  static String _handleError(dynamic error) {
    print('ApiService: Erreur détaillée - $error');
    if (error.toString().contains('SocketException')) {
      return 'Erreur de connexion. Vérifiez votre internet. Details: ${error.toString()}';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé';
    }
    return error.toString();
  }
}