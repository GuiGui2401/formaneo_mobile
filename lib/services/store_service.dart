import '../config/api_config.dart';
import 'api_service.dart';

class StoreService {
  // Obtenir tous les produits de la boutique (packs de formations)
  static Future<List<Map<String, dynamic>>> getStoreItems() async {
    try {
      final response = await ApiService.get(ApiConfig.packsEndpoint);
      print('🔍 API Response: $response');
      
      if (response.containsKey('packs') && response['packs'] is List) {
        List<Map<String, dynamic>> packs = List<Map<String, dynamic>>.from(response['packs']);
        print('📚 Found ${packs.length} packs from API');
        
        // Convertir les packs API en format store
        final storeItems = packs.map((pack) {
          print('📦 Converting pack: ${pack['name']} - Promo: ${pack['is_on_promotion']} - PromoPrice: ${pack['promotion_price']}');
          return _convertPackToStoreItem(pack);
        }).toList();
        
        return storeItems;
      }
      
      return [];
    } catch (e) {
      print('❌ Error in getStoreItems: $e');
      throw Exception('Erreur lors du chargement des produits de la boutique: $e');
    }
  }

  // Convertir un pack API en item store
  static Map<String, dynamic> _convertPackToStoreItem(Map<String, dynamic> pack) {
    final originalPrice = (pack['price'] ?? 0.0).toDouble();
    final isOnPromotion = pack['is_on_promotion'] ?? false;
    final promotionPrice = pack['promotion_price']?.toDouble();
    
    return {
      'id': pack['id'].toString(),
      'name': pack['name'] ?? '',
      'category': 'formations', // Tous les packs sont des formations
      'price': isOnPromotion && promotionPrice != null ? promotionPrice : originalPrice,
      'original_price': originalPrice,
      'is_on_promotion': isOnPromotion,
      'promotion_price': promotionPrice,
      'current_price': (pack['current_price'] ?? originalPrice).toDouble(),
      'description': pack['description'] ?? '',
      'icon': 'school', // Icône par défaut pour les formations
      'color': 'purple', // Couleur par défaut
      'badge': _getBadge(pack),
      'thumbnail_url': pack['thumbnail_url'],
      'rating': pack['rating'] ?? 0.0,
      'students_count': pack['students_count'] ?? 0,
      'formations_count': pack['formations_count'] ?? 0,
      'is_featured': pack['is_featured'] ?? false,
      'formations': pack['formations'] ?? [], // Ajouter les formations du pack
    };
  }

  // Obtenir le badge approprié pour un pack
  static String? _getBadge(Map<String, dynamic> pack) {
    if (pack['is_on_promotion'] == true) {
      // Calculer le pourcentage de réduction
      double originalPrice = (pack['price'] ?? 0.0).toDouble();
      double promoPrice = (pack['promotion_price'] ?? originalPrice).toDouble();
      
      if (originalPrice > 0 && promoPrice < originalPrice) {
        int discount = ((originalPrice - promoPrice) / originalPrice * 100).round();
        return '-$discount%';
      }
      return 'PROMO';
    }
    
    if (pack['is_featured'] == true) {
      return 'Best Seller';
    }
    
    return null;
  }

  // Obtenir les formations d'un pack spécifique
  static Future<Map<String, dynamic>> getPackDetails(String packId) async {
    try {
      final response = await ApiService.get('${ApiConfig.packsEndpoint}/$packId');
      print('🔍 Pack Details Response: $response');
      
      if (response.containsKey('pack')) {
        final pack = response['pack'];
        return _convertPackToStoreItem(pack);
      }
      
      throw Exception('Pack non trouvé');
    } catch (e) {
      print('❌ Error in getPackDetails: $e');
      throw Exception('Erreur lors du chargement des détails du pack: $e');
    }
  }

  // Obtenir les formations d'un pack acheté
  static Future<List<Map<String, dynamic>>> getPackFormations(String packId) async {
    try {
      final response = await ApiService.get('${ApiConfig.packsEndpoint}/$packId/formations');
      print('🔍 Pack Formations Response: $response');
      
      if (response.containsKey('formations') && response['formations'] is List) {
        List<Map<String, dynamic>> formations = List<Map<String, dynamic>>.from(response['formations']);
        return formations.map((formation) => _convertFormationToStoreItem(formation)).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error in getPackFormations: $e');
      throw Exception('Erreur lors du chargement des formations du pack: $e');
    }
  }

  // Convertir une formation en item store
  static Map<String, dynamic> _convertFormationToStoreItem(Map<String, dynamic> formation) {
    return {
      'id': formation['id'].toString(),
      'name': formation['title'] ?? formation['name'] ?? '',
      'description': formation['description'] ?? '',
      'thumbnail_url': formation['thumbnail_url'],
      'duration': formation['duration'] ?? 0,
      'modules_count': formation['modules_count'] ?? formation['modules']?.length ?? 0,
      'progress': formation['progress'] ?? 0,
      'is_completed': formation['is_completed'] ?? false,
      'modules': formation['modules'] ?? [],
    };
  }

  // Obtenir les catégories de produits
  static List<Map<String, dynamic>> getCategories() {
    return [
      {'id': 'all', 'name': 'Tout', 'icon': 'apps'},
      {'id': 'formations', 'name': 'Formations', 'icon': 'school'},
      // Autres catégories verrouillées pour le moment
      {'id': 'quiz', 'name': 'Quiz', 'icon': 'quiz', 'locked': true},
      {'id': 'ebooks', 'name': 'Ebooks', 'icon': 'menu_book', 'locked': true},
      {'id': 'tools', 'name': 'Outils', 'icon': 'build', 'locked': true},
    ];
  }
}