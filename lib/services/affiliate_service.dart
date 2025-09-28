import '../config/api_config.dart';
import 'api_service.dart';

class AffiliateService {
  // Dashboard principal d'affiliation
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await ApiService.get('${ApiConfig.affiliateEndpoint}/dashboard');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement du dashboard d\'affiliation: $e');
    }
  }

  // Liste des affiliés avec pagination
  static Future<Map<String, dynamic>> getAffiliates({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.affiliateEndpoint}/list?page=$page&limit=$limit',
      );
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des affiliés: $e');
    }
  }

  // Statistiques détaillées
  static Future<Map<String, dynamic>> getDetailedStats() async {
    try {
      final response = await ApiService.get('${ApiConfig.affiliateEndpoint}/stats');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques détaillées: $e');
    }
  }

  // Générer un nouveau lien d'affiliation
  static Future<Map<String, dynamic>> generateLink({String? campaign}) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.affiliateEndpoint}/generate-link',
        {'campaign': campaign},
      );
      return response;
    } catch (e) {
      throw Exception('Erreur lors de la génération du lien d\'affiliation: $e');
    }
  }

  // Bannières promotionnelles
  static Future<Map<String, dynamic>> getBanners() async {
    try {
      final response = await ApiService.get('${ApiConfig.affiliateEndpoint}/banners');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des bannières: $e');
    }
  }

  // Télécharger une bannière
  static Future<Map<String, dynamic>> downloadBanner(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.affiliateEndpoint}/banners/$id/download');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la bannière: $e');
    }
  }

  // Historique des commissions
  static Future<Map<String, dynamic>> getCommissions({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.affiliateEndpoint}/commissions?page=$page&limit=$limit',
      );
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des commissions: $e');
    }
  }
}