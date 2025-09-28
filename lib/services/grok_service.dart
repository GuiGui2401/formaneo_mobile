import 'dart:convert';
import 'package:http/http.dart' as http;

class GrokService {
  static const String _apiKey = 'xai-ZzsccvfpmQZgYgEedDmlRkluUJ4AsfJwGChmYqd2EIulhPCDAGsybalUWATzKQ3mTQRYGDrbgzSDkS0e';
  static const String _baseUrl = 'https://api.x.ai/v1';

  // Assistant IA pour les formations
  static Future<String> getFormationAssistantResponse({
    required String formationTitle,
    required String userMessage,
    required List<String> conversationHistory,
  }) async {
    try {
      final messages = [
        {
          "role": "system",
          "content": "Tu es un assistant pédagogique expert pour la formation '$formationTitle' sur la plateforme Formaneo. Tu dois :"
              "- Répondre uniquement aux questions liées à cette formation"
              "- Être pédagogique et encourageant"
              "- Donner des conseils pratiques"
              "- Utiliser un ton professionnel mais accessible"
              "- Encourager la pratique et l'application des concepts"
              "- Ne pas répondre aux questions hors sujet"
        },
        ...conversationHistory.map((msg) => {
          "role": msg.startsWith("Assistant:") ? "assistant" : "user",
          "content": msg.replaceFirst(RegExp(r'^(Assistant:|User:)\s*'), '')
        }),
        {
          "role": "user",
          "content": userMessage
        }
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'grok-beta',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      return "Désolé, je ne peux pas répondre pour le moment. Veuillez réessayer plus tard.";
    }
  }

  // Générateur de quiz adaptatif
  static Future<Map<String, dynamic>> generateQuiz({
    required String subject,
    required int numberOfQuestions,
    String difficulty = "bac",
  }) async {
    try {
      final prompt = """
Génère un quiz de $numberOfQuestions questions sur le sujet: $subject.
Niveau de difficulté: $difficulty (niveau baccalauréat).

Retourne UNIQUEMENT un JSON valide avec cette structure exacte:
{
  "quiz": {
    "title": "Quiz sur $subject",
    "questions": [
      {
        "question": "Question 1",
        "options": ["Option A", "Option B", "Option C", "Option D"],
        "correctAnswer": 0,
        "explanation": "Explication de la réponse"
      }
    ]
  }
}

Les sujets peuvent inclure: culture générale, mathématiques, physique, informatique.
Questions adaptées au niveau baccalauréat français.
""";

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'grok-beta',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Nettoyer la réponse pour extraire le JSON
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          return json.decode(jsonMatch.group(0)!);
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      // Lancer l'exception pour que le gestionnaire d'erreur du QuizScreen puisse la capturer
      throw Exception('Erreur lors de la génération du quiz: $e');
    }
  }
}