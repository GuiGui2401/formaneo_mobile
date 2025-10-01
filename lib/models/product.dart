import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final double price;
  final double? promotionPrice;
  final bool isOnPromotion;
  final String category;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.price,
    this.promotionPrice,
    this.isOnPromotion = false,
    required this.category,
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  double get currentPrice => (isOnPromotion && promotionPrice != null) ? promotionPrice! : price;

  factory Product.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      price: parseDouble(json['price']) ?? 0.0,
      promotionPrice: parseDouble(json['promotion_price']),
      isOnPromotion: json['is_on_promotion'] ?? false,
      category: json['category'] ?? 'other',
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'promotion_price': promotionPrice,
      'is_on_promotion': isOnPromotion,
      'category': category,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
