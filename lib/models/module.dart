class Module {
  final String id;
  final String formationId;
  final String title;
  final String? content;
  final String? videoUrl;
  final int duration;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Module({
    required this.id,
    required this.formationId,
    required this.title,
    this.content,
    this.videoUrl,
    required this.duration,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'].toString(),
      formationId: json['formation_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      videoUrl: json['video_url'],
      duration: json['duration'] ?? json['duration_minutes'] ?? 0,
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formation_id': formationId,
      'title': title,
      'content': content,
      'video_url': videoUrl,
      'duration': duration,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}