import '../config/api_config.dart';
import 'api_service.dart';
import '../models/product.dart';
import 'product_service.dart';

class StoreService {
  // Obtenir tous les produits de la boutique
  static Future<List<Product>> getStoreItems() async {
    try {
      return await ProductService.getProducts();
    } catch (e) {
      print('❌ Error in getStoreItems: $e');
      throw Exception('Erreur lors du chargement des produits de la boutique: $e');
    }
  }

  // Obtenir les détails d'un produit spécifique
  static Future<Product> getProductDetails(String productId) async {
    try {
      return await ProductService.getProduct(productId);
    } catch (e) {
      print('❌ Error in getProductDetails: $e');
      throw Exception('Erreur lors du chargement des détails du produit: $e');
    }
  }

  // Obtenir les catégories de produits
  static List<Map<String, dynamic>> getCategories() {
    return [
      {'id': 'all', 'name': 'Tout', 'icon': 'apps'},
      {'id': 'formation_pack', 'name': 'Formations', 'icon': 'school'},
      {'id': 'ebook', 'name': 'Ebooks', 'icon': 'menu_book'},
      {'id': 'tool', 'name': 'Outils', 'icon': 'build'},
      {'id': 'template', 'name': 'Modèles', 'icon': 'copy_all'},
      // Ajoutez d'autres catégories si nécessaire
    ];
  }

  // Cette méthode n'est plus nécessaire si les formations sont gérées comme des produits
  // et que le détail du pack est obtenu via getProductDetails
  static Future<List<Map<String, dynamic>>> getPackFormations(String packId) async {
    // Cette logique devrait être gérée par la récupération du produit de type 'formation_pack'
    // et l'extraction des formations de son metadata si nécessaire.
    // Pour l'instant, on peut laisser une implémentation simple ou la supprimer si non utilisée.
    return [];
  }
}