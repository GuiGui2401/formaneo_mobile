import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../config/theme.dart';
import '../../services/quiz_service.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;

  const QuizResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _confettiController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _saveResult();
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.result.percentage,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
      curve: Curves.easeIn,
    ));

    // Start animations
    _scoreAnimationController.forward();
    _confettiController.forward();
  }

  Future<void> _saveResult() async {
    try {
      await QuizService.saveQuizResult(
        quizId: widget.result.quizId,
        score: widget.result.percentage,
        totalQuestions: widget.result.totalQuestions,
        correctAnswers: widget.result.correctAnswers,
        timeTaken: widget.result.timeTaken,
        subject: widget.result.subject,
      );
    } catch (e) {
      print('Erreur lors de l\'enregistrement du résultat: $e');
    }
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Résultats du Quiz'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildScoreCard(),
              SizedBox(height: AppSpacing.lg),
              _buildPerformanceSummary(),
              SizedBox(height: AppSpacing.lg),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.result.passed 
                  ? AppTheme.accentColor 
                  : Colors.orange,
              widget.result.passed 
                  ? AppTheme.accentColor.withOpacity(0.8) 
                  : Colors.orange.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Column(
          children: [
            Icon(
              widget.result.passed ? Icons.check_circle : Icons.warning,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              widget.result.passed ? 'Félicitations !' : 'Continuez à pratiquer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Text(
                  '${_scoreAnimation.value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Score obtenu',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de votre performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _buildStatRow(
              'Questions totales',
              '${widget.result.totalQuestions}',
              Icons.question_answer,
            ),
            _buildStatRow(
              'Réponses correctes',
              '${widget.result.correctAnswers}',
              Icons.check_circle,
              isCorrect: true,
            ),
            _buildStatRow(
              'Temps écoulé',
              '${widget.result.timeTaken} secondes',
              Icons.timer,
            ),
            _buildStatRow(
              'Sujet',
              widget.result.subject,
              Icons.subject,
            ),
            SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: widget.result.percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.result.passed ? AppTheme.accentColor : Colors.orange,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.result.correctAnswers}/${widget.result.totalQuestions} bonnes réponses',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {bool isCorrect = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isCorrect ? AppTheme.accentColor : AppTheme.textSecondary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isCorrect ? AppTheme.accentColor : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: Text('Revoir les questions'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: Text('Retour à l\'accueil'),
          ),
        ),
      ],
    );
  }
}