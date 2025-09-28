import 'dart:convert';
import '../config/api_config.dart';
import 'api_service.dart';

class QuizService {
  // Obtenir les quiz disponibles
  static Future<Map<String, dynamic>> getAvailableQuizzes() async {
    try {
      final response = await ApiService.get('${ApiConfig.quizEndpoint}/available');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des quiz disponibles: $e');
    }
  }

  // Obtenir le nombre de quiz gratuits restants
  static Future<Map<String, dynamic>> getFreeQuizCount() async {
    try {
      final response = await ApiService.get('${ApiConfig.quizEndpoint}/free-count');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement du nombre de quiz gratuits: $e');
    }
  }

  // Sauvegarder le résultat d'un quiz
  static Future<Map<String, dynamic>> saveQuizResult({
    required String quizId,
    required double score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeTaken,
    required String subject,
  }) async {
    try {
      final response = await ApiService.post('${ApiConfig.quizEndpoint}/results', {
        'quiz_id': quizId,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'time_taken': timeTaken,
        'subject': subject,
      });
      return response;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du résultat du quiz: $e');
    }
  }

  // Obtenir l'historique des quiz
  static Future<Map<String, dynamic>> getQuizHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.quizEndpoint}/history?page=$page&limit=$limit',
      );
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'historique des quiz: $e');
    }
  }

  // Obtenir les statistiques des quiz
  static Future<Map<String, dynamic>> getQuizStats() async {
    try {
      final response = await ApiService.get('${ApiConfig.quizEndpoint}/stats');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques des quiz: $e');
    }
  }
}