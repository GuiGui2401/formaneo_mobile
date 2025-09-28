import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class ScreenRecorderBlocker {
  static const MethodChannel _channel = MethodChannel('formaneo/screen_security');
  
  // Activer la protection contre l'enregistrement d'écran
  static Future<void> enableSecureMode() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableSecureMode');
      } else if (Platform.isIOS) {
        // iOS nécessite une approche différente
        await _channel.invokeMethod('enableScreenRecordingProtection');
      }
    } catch (e) {
      print('Erreur lors de l\'activation de la protection d\'écran: $e');
    }
  }
  
  // Désactiver la protection (pour certains écrans si nécessaire)
  static Future<void> disableSecureMode() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureMode');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableScreenRecordingProtection');
      }
    } catch (e) {
      print('Erreur lors de la désactivation de la protection d\'écran: $e');
    }
  }
  
  // Vérifier si l'enregistrement d'écran est actif (iOS uniquement)
  static Future<bool> isScreenRecording() async {
    try {
      if (Platform.isIOS) {
        final bool isRecording = await _channel.invokeMethod('isScreenRecording');
        return isRecording;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification de l\'enregistrement: $e');
      return false;
    }
  }
  
  // Activer la protection pour les vidéos de formation
  static Future<void> protectVideoContent() async {
    try {
      await _channel.invokeMethod('protectVideoContent');
    } catch (e) {
      print('Erreur lors de la protection du contenu vidéo: $e');
    }
  }
}
