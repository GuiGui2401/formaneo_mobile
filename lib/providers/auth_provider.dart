import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authToken;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authToken => _authToken;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        _currentUser = userData;
        _isAuthenticated = true;
        _authToken = await AuthService.getToken();
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    print('AuthProvider: Début de la connexion avec email: $email');
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      print(
        'AuthProvider: Résultat de AuthService.login - isSuccess: ${result.isSuccess}, token: ${result.token}, errorMessage: ${result.errorMessage}',
      );

      if (result.isSuccess) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _authToken = result.token;
        print(
          'AuthProvider: Connexion réussie, utilisateur: ${_currentUser?.email}, token: $_authToken',
        );
        notifyListeners();
        return true;
      }
      print(
        'AuthProvider: Échec de la connexion, message: ${result.errorMessage}',
      );
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('AuthProvider: Erreur de connexion: $e');
      }
      if (kDebugMode) {
        print('StackTrace: $stackTrace');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('AuthProvider: Fin de la tentative de connexion');
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? promoCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        promoCode: promoCode,
      );

      if (result.isSuccess) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _authToken = result.token;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _authToken = null;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
