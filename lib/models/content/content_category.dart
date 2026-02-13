import 'package:flutter/material.dart';

class ContentCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  ContentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  ContentCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? description,
  }) {
    return ContentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'colorValue': color.value,
      'description': description,
    };
  }

  factory ContentCategory.fromJson(Map<String, dynamic> json) {
    return ContentCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: IconData(
        json['codePoint'] as int? ?? 0,
        fontFamily: json['fontFamily'] as String?,
      ),
      color: Color(json['colorValue'] as int? ?? 0xFF000000),
      description: json['description'] as String? ?? '',
    );
  }

  static List<ContentCategory> defaultCategories() {
    return [
      ContentCategory(
        id: 'fairy-tales',
        name: 'Fairy Tales',
        icon: Icons.auto_stories,
        color: const Color(0xFFFF69B4),
        description: 'Classic fairy tales and magical stories',
      ),
      ContentCategory(
        id: 'animals',
        name: 'Animals',
        icon: Icons.pets,
        color: const Color(0xFF8B4513),
        description: 'Stories featuring animal characters',
      ),
      ContentCategory(
        id: 'adventure',
        name: 'Adventure',
        icon: Icons.explore,
        color: const Color(0xFF4CAF50),
        description: 'Exciting adventures and quests',
      ),
      ContentCategory(
        id: 'learning',
        name: 'Learning',
        icon: Icons.school,
        color: const Color(0xFF2196F3),
        description: 'Educational stories and content',
      ),
      ContentCategory(
        id: 'friendship',
        name: 'Friendship',
        icon: Icons.people,
        color: const Color(0xFFFFD700),
        description: 'Stories about friendship and cooperation',
      ),
      ContentCategory(
        id: 'nature',
        name: 'Nature',
        icon: Icons.eco,
        color: const Color(0xFF00AA00),
        description: 'Stories set in nature',
      ),
    ];
  }
}
