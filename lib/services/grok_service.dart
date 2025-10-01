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
      ).timeout(Duration(seconds: 30)); // Ajouter un timeout

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
        print('Erreur API Grok (${response.statusCode}): ${response.body}');
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la génération du quiz via Grok: $e');
      // Utiliser un quiz de fallback
      return _getFallbackQuiz(subject, numberOfQuestions);
    }
  }

  // Quiz de fallback en cas d'erreur de l'API
  static Map<String, dynamic> _getFallbackQuiz(String subject, int numberOfQuestions) {
    final quizzes = {
      'Culture générale': {
        'quiz': {
          'title': 'Quiz sur Culture générale',
          'questions': [
            {
              'question': 'Quelle est la capitale de la France ?',
              'options': ['Paris', 'Londres', 'Berlin', 'Madrid'],
              'correctAnswer': 0,
              'explanation': 'Paris est la capitale de la France.'
            },
            {
              'question': 'Combien de continents y a-t-il sur Terre ?',
              'options': ['5', '6', '7', '8'],
              'correctAnswer': 2,
              'explanation': 'Il y a 7 continents : Afrique, Amérique du Nord, Amérique du Sud, Antarctique, Asie, Europe et Océanie.'
            },
            {
              'question': 'Qui a peint la Joconde ?',
              'options': ['Pablo Picasso', 'Leonardo da Vinci', 'Vincent van Gogh', 'Claude Monet'],
              'correctAnswer': 1,
              'explanation': 'La Joconde a été peinte par Leonardo da Vinci au début du XVIe siècle.'
            },
            {
              'question': 'Quel est le plus grand océan du monde ?',
              'options': ['Océan Atlantique', 'Océan Indien', 'Océan Pacifique', 'Océan Arctique'],
              'correctAnswer': 2,
              'explanation': 'L\'océan Pacifique est le plus grand océan du monde.'
            },
            {
              'question': 'En quelle année l\'homme a-t-il marché sur la Lune pour la première fois ?',
              'options': ['1965', '1969', '1972', '1975'],
              'correctAnswer': 1,
              'explanation': 'Neil Armstrong a marché sur la Lune le 21 juillet 1969.'
            },
          ]
        }
      },
      'Mathématiques': {
        'quiz': {
          'title': 'Quiz sur Mathématiques',
          'questions': [
            {
              'question': 'Combien fait 15 × 8 ?',
              'options': ['110', '120', '130', '140'],
              'correctAnswer': 1,
              'explanation': '15 × 8 = 120'
            },
            {
              'question': 'Quelle est la racine carrée de 144 ?',
              'options': ['10', '11', '12', '13'],
              'correctAnswer': 2,
              'explanation': '√144 = 12 car 12 × 12 = 144'
            },
            {
              'question': 'Combien de degrés y a-t-il dans un triangle ?',
              'options': ['90°', '180°', '270°', '360°'],
              'correctAnswer': 1,
              'explanation': 'La somme des angles d\'un triangle est toujours 180°.'
            },
            {
              'question': 'Quelle est la formule de l\'aire d\'un cercle ?',
              'options': ['πr', 'πr²', '2πr', 'πd'],
              'correctAnswer': 1,
              'explanation': 'L\'aire d\'un cercle est A = πr² où r est le rayon.'
            },
            {
              'question': 'Combien fait 2³ ?',
              'options': ['6', '8', '9', '12'],
              'correctAnswer': 1,
              'explanation': '2³ = 2 × 2 × 2 = 8'
            },
          ]
        }
      },
    };

    // Retourner le quiz correspondant au sujet, ou le quiz de culture générale par défaut
    final quiz = quizzes[subject] ?? quizzes['Culture générale']!;
    final questions = quiz['quiz']?['questions'] as List;

    // Limiter le nombre de questions demandées
    final limitedQuestions = questions.take(numberOfQuestions).toList();

    return {
      'quiz': {
        'title': quiz['quiz']?['title'],
        'questions': limitedQuestions,
      }
    };
  }
}