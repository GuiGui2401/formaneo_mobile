class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }
  
  // Validation mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    if (value.length > 128) {
      return 'Le mot de passe est trop long';
    }
    
    return null;
  }
  
  // Validation nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return 'Le nom est trop long';
    }
    
    return null;
  }
  
  // Validation numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Champ optionnel
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  // Validation code promo
  static String? validatePromoCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Champ optionnel
    }
    
    if (value.length < 3 || value.length > 10) {
      return 'Code promo invalide';
    }
    
    return null;
  }
  
  // Validation montant
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }
    
    if (min != null && amount < min) {
      return 'Le montant minimum est ${min.toStringAsFixed(2)} FCFA';
    }
    
    if (max != null && amount > max) {
      return 'Le montant maximum est ${max.toStringAsFixed(2)} FCFA';
    }
    
    return null;
  }
  
  // Validation confirmation mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  // Validation URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Champ optionnel
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL invalide';
    }
    
    return null;
  }
  
  // Validation carte bancaire (basique)
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de carte est requis';
    }
    
    final cardNumber = value.replaceAll(' ', '');
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Numéro de carte invalide';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cardNumber)) {
      return 'Le numéro de carte ne doit contenir que des chiffres';
    }
    
    return null;
  }
  
  // Validation date d'expiration
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La date d\'expiration est requise';
    }
    
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format invalide (MM/AA)';
    }
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'Date invalide';
    }
    
    if (month < 1 || month > 12) {
      return 'Mois invalide';
    }
    
    final currentYear = DateTime.now().year % 100;
    if (year < currentYear) {
      return 'Carte expirée';
    }
    
    return null;
  }
  
  // Validation CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le CVV est requis';
    }
    
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV invalide';
    }
    
    return null;
  }
}