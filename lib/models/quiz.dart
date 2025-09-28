import 'dart:convert';

class Quiz {
  final String id;
  final String title;
  final String? description;
  final List<dynamic> questions;
  final String? difficulty;
  final String subject;
  final int questionsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    this.difficulty,
    required this.subject,
    required this.questionsCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      questions: json['questions'] is String 
        ? (json['questions'] as String).isNotEmpty 
          ? (jsonDecode(json['questions']) as List<dynamic>) 
          : []
        : json['questions'] is List 
          ? json['questions'] 
          : [],
      difficulty: json['difficulty'],
      subject: json['subject'] ?? '',
      questionsCount: json['questions_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions,
      'difficulty': difficulty,
      'subject': subject,
      'questions_count': questionsCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTaken;
  final String subject;
  final double percentage;
  final bool passed;
  final DateTime createdAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.subject,
    required this.percentage,
    required this.passed,
    required this.createdAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      quizId: json['quiz_id'].toString(),
      score: double.parse(json['score']?.toString() ?? '0'),
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      subject: json['subject'] ?? '',
      percentage: double.parse(json['percentage']?.toString() ?? '0'),
      passed: json['passed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_taken': timeTaken,
      'subject': subject,
      'percentage': percentage,
      'passed': passed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}