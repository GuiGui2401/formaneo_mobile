import 'formation.dart';
import '../../config/api_config.dart';

class FormationPack {
  final String id;
  final String name;
  final String slug;
  final String author;
  final String? description;
  final String? thumbnailUrl;
  final double price;
  final int totalDuration;
  final double rating;
  final int studentsCount;
  final int formationsCount;
  final bool isFeatured;
  final bool isActive;
  final int order;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Formation> formations;
  bool isPurchased;
  final double completion_percentage;
  final int completedFormationsCount;
  final Map<String, double>? progress; // Ajout de la propriété progress

  FormationPack({
    required this.id,
    required this.name,
    required this.slug,
    required this.author,
    this.description,
    this.thumbnailUrl,
    required this.price,
    required this.totalDuration,
    required this.rating,
    required this.studentsCount,
    required this.formationsCount,
    required this.isFeatured,
    required this.isActive,
    required this.order,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.formations = const [],
    this.isPurchased = false,
    this.completion_percentage = 0.0,
    this.completedFormationsCount = 0,
    this.progress, // Ajout du paramètre progress
  });

  // Getter pour completionPercentage (alias de completion_percentage)
  double get completionPercentage => completion_percentage;
  
  // Méthode pour obtenir l'URL complète de la miniature
  String? get fullThumbnailUrl {
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) return null;
    
    // Si l'URL est déjà absolue, la retourner telle quelle
    if (thumbnailUrl!.startsWith('http://') || thumbnailUrl!.startsWith('https://')) {
      return thumbnailUrl;
    }
    
    // Sinon, ajouter le domaine de base
    return '${ApiConfig.baseUrl}$thumbnailUrl';
  }

  factory FormationPack.fromJson(Map<String, dynamic> json) {
    List<Formation> formationsList = [];
    if (json['formations'] != null) {
      if (json['formations'] is List) {
        formationsList = (json['formations'] as List)
            .map((formation) => Formation.fromJson(formation))
            .toList();
      } else if (json['formations'] is Map) {
        // Si formations est un objet avec des clés numériques
        formationsList = (json['formations'].values as Iterable)
            .map((formation) => Formation.fromJson(formation))
            .toList();
      }
    }

    // Récupérer la progression si disponible
    Map<String, double>? progressMap;
    if (json['progress'] != null && json['progress'] is Map) {
      progressMap = {};
      (json['progress'] as Map).forEach((key, value) {
        // Convertir la valeur en double de manière sécurisée
        if (value is num) {
          progressMap![key.toString()] = value.toDouble();
        } else if (value is String) {
          progressMap![key.toString()] = double.tryParse(value) ?? 0.0;
        } else {
          progressMap![key.toString()] = 0.0;
        }
      });
    }

    // Calculer la progression si les données utilisateur sont disponibles
    bool isPurchased = json['is_purchased'] ?? false;
    double completion_percentage = 0.0;
    int completedFormationsCount = 0;
    
    // Ces valeurs peuvent venir des données utilisateur
    if (json['completion_percentage'] != null) {
      if (json['completion_percentage'] is num) {
        completion_percentage = json['completion_percentage'].toDouble();
      } else if (json['completion_percentage'] is String) {
        completion_percentage = double.tryParse(json['completion_percentage']) ?? 0.0;
      }
    }
    
    if (json['completed_formations_count'] != null) {
      if (json['completed_formations_count'] is int) {
        completedFormationsCount = json['completed_formations_count'];
      } else if (json['completed_formations_count'] is String) {
        completedFormationsCount = int.tryParse(json['completed_formations_count']) ?? 0;
      }
    }

    return FormationPack(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      description: json['description']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      price: json['price'] is num 
          ? json['price'].toDouble() 
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      totalDuration: json['total_duration'] is int 
          ? json['total_duration'] 
          : (int.tryParse(json['total_duration']?.toString() ?? '0') ?? 0),
      rating: json['rating'] is num 
          ? json['rating'].toDouble() 
          : (double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0),
      studentsCount: json['students_count'] is int 
          ? json['students_count'] 
          : (int.tryParse(json['students_count']?.toString() ?? '0') ?? 0),
      formationsCount: json['formations_count'] is int 
          ? json['formations_count'] 
          : (int.tryParse(json['formations_count']?.toString() ?? '0') ?? 0),
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      order: json['order'] is int 
          ? json['order'] 
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
      metadata: json['metadata'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
      formations: formationsList,
      isPurchased: isPurchased,
      completion_percentage: completion_percentage,
      completedFormationsCount: completedFormationsCount,
      progress: progressMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'author': author,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'total_duration': totalDuration,
      'rating': rating,
      'students_count': studentsCount,
      'formations_count': formationsCount,
      'is_featured': isFeatured,
      'is_active': isActive,
      'order': order,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'formations': formations.map((formation) => formation.toJson()).toList(),
      'is_purchased': isPurchased,
      'completion_percentage': completionPercentage,
      'completed_formations_count': completedFormationsCount,
      'progress': progress, // Ajout de la propriété progress
    };
  }
}