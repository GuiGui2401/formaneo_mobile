import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/grok_service.dart';
import '../../models/quiz.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int freeQuizzesLeft = 5;
  bool isLoadingQuiz = false;
  Quiz? currentQuiz;
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int score = 0;
  bool showResult = false;
  List<int> userAnswers = [];

  final List<String> subjects = [
    'Culture générale',
    'Mathématiques',
    'Physique',
    'Informatique',
    'Histoire',
    'Géographie',
    'Sciences',
    'Littérature',
  ];

  @override
  Widget build(BuildContext context) {
    if (currentQuiz != null && !showResult) {
      return _buildQuizInterface();
    } else if (showResult) {
      return _buildResultScreen();
    } else {
      return _buildQuizSelection();
    }
  }

  Widget _buildQuizSelection() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Quiz Éducatifs'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFreeQuizCard(),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Choisissez votre domaine',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Tous nos quiz sont adaptés au niveau baccalauréat et proposent des questions aléatoires pour tester vos connaissances.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildSubjectGrid(),
            SizedBox(height: AppSpacing.lg),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeQuizCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.white, size: 32),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Quiz Gratuits Disponibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Il vous reste $freeQuizzesLeft quiz gratuits',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: freeQuizzesLeft / 5,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Gagnez des FCFA à chaque quiz réussi !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(String subject) {
    final icons = {
      'Culture générale': Icons.public,
      'Mathématiques': Icons.calculate,
      'Physique': Icons.science,
      'Informatique': Icons.computer,
      'Histoire': Icons.history_edu,
      'Géographie': Icons.map,
      'Sciences': Icons.biotech,
      'Littérature': Icons.menu_book,
    };

    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.secondaryColor,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
    ];

    final color = colors[subjects.indexOf(subject) % colors.length];

    return Card(
      child: InkWell(
        onTap: freeQuizzesLeft > 0 ? () => _startQuiz(subject) : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: freeQuizzesLeft > 0 ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  icons[subject] ?? Icons.quiz,
                  color: freeQuizzesLeft > 0 ? color : Colors.grey,
                  size: 24,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                subject,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: freeQuizzesLeft > 0 ? AppTheme.textPrimary : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (freeQuizzesLeft == 0) ...[
                SizedBox(height: AppSpacing.sm),
                Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos Statistiques',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Quiz complétés', '0', Icons.quiz),
              ),
              Expanded(
                child: _buildStatItem('Score moyen', '0%', Icons.star),
              ),
              Expanded(
                child: _buildStatItem('FCFA gagnés', '0', Icons.monetization_on),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuizInterface() {
    final question = currentQuiz!.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / currentQuiz!.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Quiz ${currentQuestionIndex + 1}/${currentQuiz!.questions.length}'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _exitQuiz(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            color: Colors.white,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Score: $score/${currentQuestionIndex}',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionCard(index, question.options[index]);
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedAnswer != null ? _nextQuestion : null,
                      child: Text(
                        currentQuestionIndex == currentQuiz!.questions.length - 1
                            ? 'Terminer le Quiz'
                            : 'Question Suivante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String option) {
    final isSelected = selectedAnswer == index;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: InkWell(
          onTap: () {
            setState(() {
              selectedAnswer = index;
            });
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (score / currentQuiz!.questions.length * 100).round();
    final isSuccess = percentage >= 60;
    final reward = isSuccess ? (score * 20) : 0; // 20 FCFA par bonne réponse

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Résultats du Quiz'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isSuccess ? AppTheme.accentColor : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.emoji_events : Icons.thumb_up,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    isSuccess ? 'Félicitations !' : 'Bien joué !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Votre score : $score/${currentQuiz!.questions.length} ($percentage%)',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (isSuccess) ...[
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on, color: AppTheme.accentColor),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Vous avez gagné $reward FCFA !',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuiz = null;
                        showResult = false;
                        currentQuestionIndex = 0;
                        selectedAnswer = null;
                        score = 0;
                        userAnswers.clear();
                      });
                    },
                    child: Text('Nouveau Quiz'),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Retour à l\'accueil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(String subject) async {
    if (freeQuizzesLeft <= 0) return;

    setState(() {
      isLoadingQuiz = true;
    });

    // Afficher un dialog de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Génération du quiz en cours...'),
          ],
        ),
      ),
    );

    try {
      final quizData = await GrokService.generateQuiz(
        subject: subject,
        numberOfQuestions: 5,
        difficulty: "bac",
      );

      Navigator.pop(context); // Fermer le dialog de chargement

      setState(() {
        currentQuiz = Quiz.fromJson(quizData['quiz']);
        isLoadingQuiz = false;
        freeQuizzesLeft--;
        currentQuestionIndex = 0;
        selectedAnswer = null;
        score = 0;
        userAnswers.clear();
      });
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog de chargement
      
      setState(() {
        isLoadingQuiz = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du quiz. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    // Vérifier la réponse
    final question = currentQuiz!.questions[currentQuestionIndex];
    userAnswers.add(selectedAnswer!);
    
    if (selectedAnswer == question.correctAnswer) {
      score++;
    }

    if (currentQuestionIndex == currentQuiz!.questions.length - 1) {
      // Quiz terminé
      setState(() {
        showResult = true;
      });
    } else {
      // Question suivante
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    }
  }

  void _exitQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quitter le quiz'),
        content: Text('Êtes-vous sûr de vouloir quitter ? Votre progression sera perdue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuiz = null;
                currentQuestionIndex = 0;
                selectedAnswer = null;
                score = 0;
                userAnswers.clear();
                freeQuizzesLeft++; // Rendre le quiz gratuit
              });
            },
            child: Text('Quitter'),
          ),
        ],
      ),
    );
  }
}