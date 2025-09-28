import '../../config/api_config.dart';

class Formation {
  final String id;
  final String packId;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final int order;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> modules;
  final Map<String, dynamic>? userProgress;

  Formation({
    required this.id,
    required this.packId,
    required this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.order,
    required this.isActive,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.modules = const [],
    this.userProgress,
  });

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

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'].toString(),
      packId: json['pack_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'] ?? json['duration_minutes'] ?? 0,
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      modules: json['modules'] is List ? json['modules'] : [],
      userProgress: json['user_progress'] is Map ? json['user_progress'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pack_id': packId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'order': order,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'modules': modules,
      'user_progress': userProgress,
    };
  }
}