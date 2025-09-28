import 'package:intl/intl.dart';

class Formatters {
  // Formateur de nombres avec séparateurs de milliers
  static final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'fr_FR');
  
  // Formater un montant en FCFA avec décimales
  static String formatAmount(double amount) {
    return '${_numberFormat.format(amount)} FCFA';
  }
  
  // Formater un nombre avec décimales
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }
  
  // Formater une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // Formater une date et heure
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // Formater une durée en heures et minutes
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h${mins > 0 ? ' ${mins}min' : ''}';
    }
    return '${mins}min';
  }
  
  // Formater un pourcentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  // Formater un code promo
  static String formatPromoCode(String code) {
    return code.toUpperCase();
  }
  
  // Formater un numéro de téléphone
  static String formatPhoneNumber(String phone) {
    if (phone.length >= 9) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }
}