import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  
  // Contrôleurs pour chaque élément éducatif
  late List<AnimationController> _elementControllers;
  late List<AnimationController> _rotationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  
  int currentElementIndex = -1;
  bool allElementsLoaded = false;

  // Liste des éléments éducatifs avec leurs icônes
  final List<Map<String, dynamic>> educationalElements = [
    {'icon': Icons.school, 'name': 'École', 'color': Colors.white},
    {'icon': Icons.menu_book, 'name': 'Cours', 'color': Colors.white},
    {'icon': Icons.psychology, 'name': 'Apprentissage', 'color': Colors.white},
    {'icon': Icons.quiz, 'name': 'Quiz', 'color': Colors.white},
    {'icon': Icons.trending_up, 'name': 'Progression', 'color': Colors.white},
    {'icon': Icons.star, 'name': 'Évaluation', 'color': Colors.white},
    {'icon': Icons.emoji_events, 'name': 'Certificats', 'color': Colors.white},
    {'icon': Icons.monetization_on, 'name': 'Récompenses', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Animation du logo principal
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Initialiser les contrôleurs pour chaque élément
    _elementControllers = List.generate(
      educationalElements.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      ),
    );
    
    _rotationControllers = List.generate(
      educationalElements.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500),
        vsync: this,
      ),
    );

    // Créer les animations d'échelle et de rotation
    _scaleAnimations = _elementControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
    
    _rotationAnimations = _rotationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 4 * math.pi, // 2 tours complets
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  void _startLoadingSequence() async {
    // Afficher le logo d'abord
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      _logoController.forward();
    }

    // Attendre un peu puis commencer la séquence des éléments
    await Future.delayed(Duration(milliseconds: 800));
    
    // Animer chaque élément un par un
    for (int i = 0; i < educationalElements.length; i++) {
      if (mounted) {
        setState(() {
          currentElementIndex = i;
        });
        
        // Démarrer l'animation de l'élément actuel
        _elementControllers[i].forward();
        _rotationControllers[i].repeat(); // Rotation continue
        
        // Attendre avant le prochain élément
        await Future.delayed(Duration(milliseconds: 600));
        
        // Arrêter la rotation de l'élément précédent
        if (i > 0) {
          _rotationControllers[i - 1].stop();
        }
      }
    }
    
    // Arrêter la rotation du dernier élément
    if (mounted && _rotationControllers.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 400));
      _rotationControllers.last.stop();
      
      setState(() {
        allElementsLoaded = true;
      });
      
      // Naviguer vers la page suivante
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    try {
      // Vérifier si l'utilisateur est déjà connecté
      final isLoggedIn = await AuthService.checkSession();
      
      // Attendre un peu pour voir l'animation complète
      await Future.delayed(Duration(milliseconds: 1000));
      
      if (mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Logo principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  ScaleTransition(
                    scale: _logoScale,
                    child: Column(
                      children: [
                        Text(
                          'FORMANEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Apprenez et Gagnez',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Zone des éléments éducatifs (en bas)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: _buildEducationalElementsSection(),
            ),
            
            // Indicateur de progression
            if (!allElementsLoaded)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: _buildLoadingIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalElementsSection() {
    return Container(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(educationalElements.length, (index) {
            final isActive = index <= currentElementIndex;
            final isCurrent = index == currentElementIndex;
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimations[index],
                  _rotationAnimations[index],
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive ? _scaleAnimations[index].value : 0.0,
                    child: Transform.rotate(
                      angle: isCurrent ? _rotationAnimations[index].value : 0.0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 7.5,
                              offset: Offset(0, 8),
                            ),
                            if (isCurrent)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 12.5,
                                offset: Offset(0, 0),
                              ),
                          ],
                        ),
                        child: Icon(
                          educationalElements[index]['icon'],
                          size: 17.5,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          Text(
            currentElementIndex >= 0 && currentElementIndex < educationalElements.length
                ? 'Chargement ${educationalElements[currentElementIndex]['name']}...'
                : 'Initialisation...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentElementIndex + 1) / educationalElements.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      AppTheme.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (var controller in _elementControllers) {
      controller.dispose();
    }
    for (var controller in _rotationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}