import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import '../config/constants.dart';
import 'api_service.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.user,
    this.token,
    this.errorMessage,
  });
}

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  // Connexion
  static Future<AuthResult> login(String email, String password) async {
    print(
      'AuthService: Envoi de la requête de connexion à ${ApiConfig.authEndpoint}/login',
    );
    print('AuthService: Données envoyées - email: $email, password: $password');

    try {
      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/login',
        {'email': email, 'password': password},
      );

      print('AuthService: Réponse reçue - $response');

      if (response['success'] == true) {
        // Vérifier que la réponse contient les données utilisateur
        if (response['user'] == null) {
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Données utilisateur manquantes dans la réponse',
          );
        }

        final user = User.fromJson(response['user']);
        final token = response['token'];
        print(
          'AuthService: Connexion réussie, utilisateur: ${user.email}, token: $token',
        );

        await ApiService.saveAuthToken(token);
        await _saveUserData(user);
        _currentUser = user;

        return AuthResult(isSuccess: true, user: user, token: token);
      }

      print(
        'AuthService: Échec de la connexion, message: ${response['message']}',
      );
      return AuthResult(
        isSuccess: false,
        errorMessage: response['message'] ?? 'Échec de la connexion',
      );
    } catch (e, stackTrace) {
      print('AuthService: Erreur lors de la connexion: $e');
      print('AuthService: StackTrace: $stackTrace');
      return AuthResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Inscription
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? promoCode,
  }) async {
    try {
      final response =
          await ApiService.post('${ApiConfig.authEndpoint}/register', {
            'name': name,
            'email': email,
            'password': password,
            'password_confirmation': password,
            'promo_code': promoCode,
          });

      if (response['success'] == true) {
        // Vérifier que la réponse contient les données utilisateur
        if (response['user'] == null) {
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Données utilisateur manquantes dans la réponse',
          );
        }

        final user = User.fromJson(response['user']);
        final token = response['token'];

        await ApiService.saveAuthToken(token);
        await _saveUserData(user);
        _currentUser = user;

        return AuthResult(isSuccess: true, user: user, token: token);
      }

      return AuthResult(
        isSuccess: false,
        errorMessage: response['message'] ?? 'Échec de l\'inscription',
      );
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    try {
      await ApiService.post('${ApiConfig.authEndpoint}/logout', {});
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      await ApiService.clearAuthToken();
      await _clearUserData();
      _currentUser = null;
    }
  }

  // Vérifier la session
  static Future<bool> checkSession() async {
    try {
      final token = await ApiService.getAuthToken();
      if (token == null) return false;

      final response = await ApiService.get('${ApiConfig.authEndpoint}/me');
      if (response['user'] != null) {
        final user = User.fromJson(response['user']);
        _currentUser = user;
        await _saveUserData(user);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Réinitialiser le mot de passe
  static Future<bool> resetPassword(String email) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/forgot-password',
        {'email': email},
      );

      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le profil
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put(
        '${ApiConfig.authEndpoint}/profile',
        data,
      );

      if (response['success'] == true && response['user'] != null) {
        final user = User.fromJson(response['user']);
        _currentUser = user;
        await _saveUserData(user);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtenir l'utilisateur actuel
  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userDataKey);

    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      return _currentUser;
    }

    return null;
  }

  // Obtenir le token
  static Future<String?> getToken() async {
    return await ApiService.getAuthToken();
  }

  // Sauvegarder les données utilisateur
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  // Effacer les données utilisateur
  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
  }
}
