import '../config/api_config.dart';
import 'api_service.dart';

class FormationService {
  // Liste des packs de formations
  static Future<Map<String, dynamic>> getFormationPacks() async {
    try {
      final response = await ApiService.get(ApiConfig.packsEndpoint);
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des packs de formations: $e');
    }
  }

  // Obtenir un pack de formations spécifique
  static Future<Map<String, dynamic>> getFormationPack(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.packsEndpoint}/$id');
      
      // Vérifier que la réponse contient bien la clé 'pack'
      if (response.containsKey('pack') && response['pack'] is Map<String, dynamic>) {
        return response;
      } else {
        // Si la réponse ne contient pas 'pack', la reformater
        return {
          'pack': response,
        };
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du pack de formations: $e');
    }
  }

  // Acheter un pack
  static Future<Map<String, dynamic>> purchaseFormationPack(String id) async {
    try {
      final response = await ApiService.post('${ApiConfig.packsEndpoint}/$id/purchase', {});
      return response;
    } catch (e) {
      throw Exception("Erreur lors de l'achat du pack de formations: $e");
    }
  }

  // Obtenir les formations d'un pack
  static Future<Map<String, dynamic>> getFormationsForPack(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.packsEndpoint}/$id/formations');
      
      // Vérifier que la réponse contient bien la clé 'formations'
      if (response.containsKey('formations') && response['formations'] is List) {
        return response;
      } else {
        // Si la réponse ne contient pas 'formations', la reformater
        return {
          'formations': response is List ? response : [],
        };
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des formations du pack: $e');
    }
  }
}