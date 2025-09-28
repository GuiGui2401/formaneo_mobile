import '../../config/api_config.dart';

class Ebook {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String? pdfUrl;
  final String? author;
  final double? price;
  final int? pages;
  final String? category;
  final double? rating;
  final int? downloads;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ebook({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    this.pdfUrl,
    this.author,
    this.price,
    this.pages,
    this.category,
    this.rating,
    this.downloads,
    this.isPurchased = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Méthodes pour obtenir les URLs complètes
  String? get fullCoverImageUrl {
    if (coverImageUrl == null || coverImageUrl!.isEmpty) return null;
    
    // Si l'URL est déjà absolue, la retourner telle quelle
    if (coverImageUrl!.startsWith('http://') || coverImageUrl!.startsWith('https://')) {
      return coverImageUrl;
    }
    
    // Sinon, ajouter le domaine de base
    return '${ApiConfig.baseUrl}$coverImageUrl';
  }
  
  String? get fullPdfUrl {
    if (pdfUrl == null || pdfUrl!.isEmpty) return null;
    
    // Si l'URL est déjà absolue, la retourner telle quelle
    if (pdfUrl!.startsWith('http://') || pdfUrl!.startsWith('https://')) {
      return pdfUrl;
    }
    
    // Sinon, ajouter le domaine de base
    return '${ApiConfig.baseUrl}$pdfUrl';
  }

  factory Ebook.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour convertir en double de manière sécurisée
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Fonction utilitaire pour convertir en int de manière sécurisée
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Ebook(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      coverImageUrl: json['cover_image_url'],
      pdfUrl: json['pdf_url'],
      author: json['author'],
      price: parseDouble(json['price']),
      pages: parseInt(json['pages']),
      category: json['category'],
      rating: parseDouble(json['rating']),
      downloads: parseInt(json['downloads']),
      isPurchased: json['is_purchased'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'pdf_url': pdfUrl,
      'author': author,
      'price': price,
      'pages': pages,
      'category': category,
      'rating': rating,
      'downloads': downloads,
      'is_purchased': isPurchased,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}