import 'package:flutter/foundation.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  List<Quiz> _availableQuizzes = [];
  bool _isLoading = false;
  String? _error;
  int _freeQuizzesLeft = 5;

  List<Quiz> get availableQuizzes => _availableQuizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get freeQuizzesLeft => _freeQuizzesLeft;

  Future<void> loadAvailableQuizzes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await QuizService.getAvailableQuizzes();
      _availableQuizzes = (data['quizzes'] as List)
          .map((quizData) => Quiz.fromJson(quizData))
          .toList();
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des quiz disponibles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFreeQuizCount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await QuizService.getFreeQuizCount();
      _freeQuizzesLeft = data['free_quizzes_left'] ?? 5;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement du nombre de quiz gratuits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> saveQuizResult({
    required String quizId,
    required double score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeTaken,
    required String subject,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await QuizService.saveQuizResult(
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        timeTaken: timeTaken,
        subject: subject,
      );

      // Mettre à jour le nombre de quiz gratuits restants
      if (result.containsKey('free_quizzes_left')) {
        _freeQuizzesLeft = result['free_quizzes_left'];
      }

      return result;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de la sauvegarde du résultat du quiz: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getQuizHistory({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await QuizService.getQuizHistory(page: page, limit: limit);
      return result;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement de l\'historique des quiz: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getQuizStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await QuizService.getQuizStats();
      return result;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des statistiques des quiz: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}