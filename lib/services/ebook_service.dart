import '../config/api_config.dart';
import 'api_service.dart';

class EbookService {
  // Liste des ebooks
  static Future<Map<String, dynamic>> getEbooks() async {
    try {
      final response = await ApiService.get('${ApiConfig.ebooksEndpoint}');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des ebooks: $e');
    }
  }

  // Afficher un ebook spécifique
  static Future<Map<String, dynamic>> getEbook(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.ebooksEndpoint}/$id');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'ebook: $e');
    }
  }

  // Télécharger un ebook
  static Future<Map<String, dynamic>> downloadEbook(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.ebooksEndpoint}/$id/download');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'ebook: $e');
    }
  }
  
  // Consulter un ebook en ligne
  static Future<Map<String, dynamic>> viewEbook(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.ebooksEndpoint}/$id/view');
      return response;
    } catch (e) {
      throw Exception('Erreur lors de la consultation de l\'ebook: $e');
    }
  }

  // Acheter un ebook
  static Future<Map<String, dynamic>> purchaseEbook(String id) async {
    try {
      final response = await ApiService.post('${ApiConfig.ebooksEndpoint}/$id/purchase', {});
      return response;
    } catch (e) {
      throw Exception('Erreur lors de l\'achat de l\'ebook: $e');
    }
  }
}