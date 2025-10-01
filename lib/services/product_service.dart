import '../config/api_config.dart';
import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> getProducts() async {
    try {
      final response = await ApiService.get(ApiConfig.productsEndpoint);
      if (response.containsKey('products') && response['products'] is List) {
        return (response['products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  static Future<Product> getProduct(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.productsEndpoint}/$id');
      if (response.containsKey('product')) {
        return Product.fromJson(response['product']);
      }
      throw Exception('Product not found');
    } catch (e) {
      print('Error fetching product $id: $e');
      rethrow;
    }
  }
}
