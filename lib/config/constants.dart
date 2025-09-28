class AppConstants {
  // URLs et endpoints
  static const String baseUrl = 'http://admin.cleanestuaire.com';
  static const String apiVersion = 'v1';
  static const String websiteUrl = 'http://cleanestuaire.com';
  static const String supportEmail = 'support@formaneo.com';

  // Affiliation (anciennement Parrainage)
  static const String affiliateBaseUrl = 'http://cleanestuaire.com/invite/';
  static const double level1CommissionBasic =
      2000.0; // FCFA pour 0-100 affiliés
  static const double level1CommissionPremium =
      2500.0; // FCFA pour >100 affiliés
  static const double welcomeBonus = 1000.0; // FCFA
  static const int affiliateThreshold = 100; // Seuil pour commission premium

  // Quiz
  static const int freeQuizzesPerUser = 5;
  static const int rewardPerCorrectAnswer = 20; // FCFA
  static const int minPassingScore = 60; // Pourcentage
  static const int defaultQuizQuestions = 5;

  // Formations
  static const double formationCashbackRate =
      0.15; // 15% à la fin de la formation
  static const int maxFormationDuration = 1440; // minutes (24h)

  // Limites et validations
  static const double minWithdrawalAmount = 1000.00; // FCFA
  static const double maxWithdrawalAmount = 1000000.00; // FCFA
  static const double minDepositAmount = 500.00; // FCFA
  static const int maxNameLength = 50;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  // Clés de stockage local
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Messages d'erreur
  static const String networkError =
      'Erreur de connexion. Vérifiez votre internet.';
  static const String serverError =
      'Erreur serveur. Veuillez réessayer plus tard.';
  static const String unauthorizedError =
      'Session expirée. Veuillez vous reconnecter.';
  static const String validationError =
      'Données invalides. Vérifiez vos informations.';

  // Messages de succès
  static const String loginSuccess = 'Connexion réussie !';
  static const String registerSuccess = 'Inscription réussie !';
  static const String profileUpdateSuccess = 'Profil mis à jour avec succès !';
  static const String passwordResetSent = 'Email de réinitialisation envoyé !';
  static const String withdrawalSuccess = 'Retrait effectué avec succès !';

  // Formats et patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String promoCodePattern = r'^[A-Z]{2}\d{3}$';

  // Durées et timeouts
  static const int networkTimeout = 30; // secondes
  static const int splashDuration = 3; // secondes
  static const int animationDuration = 300; // millisecondes
  static const int notificationRotationDuration =
      3; // secondes pour la rotation des notifications

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheValidityHours = 24;
  static const int maxCacheSize = 50; // MB
}

class AssetPaths {
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String welcomeImage = 'assets/images/welcome.png';
  static const String successImage = 'assets/images/success.png';
  static const String errorImage = 'assets/images/error.png';

  // Icons académiques et financiers pour le splash screen
  static const String academicIcon1 = 'assets/icons/graduation-cap.svg';
  static const String academicIcon2 = 'assets/icons/book.svg';
  static const String academicIcon3 = 'assets/icons/certificate.svg';
  static const String financialIcon1 = 'assets/icons/wallet.svg';
  static const String financialIcon2 = 'assets/icons/money.svg';
  static const String financialIcon3 = 'assets/icons/chart.svg';

  // Bannières promotionnelles
  static const String promoBanner1 = 'assets/images/promo_banner_1.jpg';
  static const String promoBanner2 = 'assets/images/promo_banner_2.jpg';
  static const String promoBanner3 = 'assets/images/promo_banner_3.jpg';

  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String confettiAnimation = 'assets/animations/confetti.json';
}

class AppStrings {
  // Titres des écrans
  static const String homeTitle = 'Accueil';
  static const String formationsTitle = 'Formations';
  static const String quizTitle = 'Quiz';
  static const String affiliateTitle = 'Affiliation';
  static const String walletTitle = 'Portefeuille';
  static const String storeTitle = 'Boutique';
  static const String profileTitle = 'Profil';
  static const String settingsTitle = 'Paramètres';

  // Onboarding
  static const String onboardingTitle1 = 'Apprenez à votre rythme';
  static const String onboardingDesc1 =
      'Accédez à des packs de formations de qualité depuis votre mobile';
  static const String onboardingTitle2 = 'Testez vos connaissances';
  static const String onboardingDesc2 =
      'Participez à des quiz et gagnez des récompenses';
  static const String onboardingTitle3 = 'Programme d\'affiliation';
  static const String onboardingDesc3 =
      'Invitez vos amis et gagnez des commissions attractives';

  // Boutons communs
  static const String continueButton = 'Continuer';
  static const String cancelButton = 'Annuler';
  static const String confirmButton = 'Confirmer';
  static const String saveButton = 'Enregistrer';
  static const String editButton = 'Modifier';
  static const String deleteButton = 'Supprimer';
  static const String shareButton = 'Partager';
  static const String retryButton = 'Réessayer';
  static const String withdrawButton = 'Retirer';

  // Messages de validation
  static const String fieldRequired = 'Ce champ est requis';
  static const String invalidEmail = 'Email invalide';
  static const String passwordTooShort =
      'Mot de passe trop court (min 6 caractères)';
  static const String passwordsNotMatch =
      'Les mots de passe ne correspondent pas';
  static const String invalidPromoCode = 'Code promo invalide';
  static const String nameMinLength =
      'Le nom doit contenir au moins 2 caractères';
  static const String insufficientBalance =
      'Solde insuffisant pour effectuer cette opération';
}

// Données fictives pour les notifications de l'accueil
class FictiveNotifications {
  static const List<Map<String, String>> notifications = [
    {
      'name': 'Marie K.',
      'action': 'vient de gagner',
      'amount': '100.00 FCFA',
      'source': 'aux Quiz',
    },
    {
      'name': 'Paul B.',
      'action': 'a gagné',
      'amount': '3000.00 FCFA',
      'source': 'en affiliation',
    },
    {
      'name': 'Sophie L.',
      'action': 'vient de terminer',
      'amount': '',
      'source': 'le pack Dropskills',
    },
    {
      'name': 'Jean M.',
      'action': 'a reçu',
      'amount': '2500.00 FCFA',
      'source': 'de commission',
    },
    {
      'name': 'Alice D.',
      'action': 'vient de réussir',
      'amount': '200.00 FCFA',
      'source': 'le quiz de maths',
    },
    {
      'name': 'Thomas R.',
      'action': 'a parrainé',
      'amount': '',
      'source': '5 nouveaux utilisateurs',
    },
    {
      'name': 'Emma C.',
      'action': 'vient de débloquer',
      'amount': '1500.00 FCFA',
      'source': 'de cashback',
    },
    {
      'name': 'Lucas F.',
      'action': 'a atteint',
      'amount': '',
      'source': '100 affiliés ce mois',
    },
    {
      'name': 'Sarah N.',
      'action': 'vient de gagner',
      'amount': '500.00 FCFA',
      'source': 'au défi quotidien',
    },
    {
      'name': 'Pierre V.',
      'action': 'a complété',
      'amount': '',
      'source': '3 formations aujourd\'hui',
    },
  ];
}
