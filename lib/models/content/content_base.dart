enum ContentType {
  story,
  poem,
  song;

  String get displayName {
    switch (this) {
      case ContentType.story:
        return 'Story';
      case ContentType.poem:
        return 'Poem';
      case ContentType.song:
        return 'Song';
    }
  }

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ContentType.story,
    );
  }
}

abstract class ContentBase {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final int targetAge;
  final Duration duration;
  final String authorId;
  final DateTime createdAt;
  final String audioUrl;
  final String albumArtUrl;
  final int likeCount;
  final int viewCount;
  final int saveCount;
  final List<String> categories;
  final String theme;
  final bool isGenerated;

  ContentBase({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetAge,
    required this.duration,
    required this.authorId,
    required this.createdAt,
    required this.audioUrl,
    required this.albumArtUrl,
    this.likeCount = 0,
    this.viewCount = 0,
    this.saveCount = 0,
    this.categories = const [],
    this.theme = 'default',
    this.isGenerated = false,
  });

  Map<String, dynamic> baseToJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'targetAge': targetAge,
      'duration': duration.inSeconds,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'audioUrl': audioUrl,
      'albumArtUrl': albumArtUrl,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'saveCount': saveCount,
      'categories': categories,
      'theme': theme,
      'isGenerated': isGenerated,
    };
  }

  static Map<String, dynamic> parseBaseJson(Map<String, dynamic> json) {
    return {
      'id': json['id'] as String? ?? '',
      'title': json['title'] as String? ?? '',
      'description': json['description'] as String? ?? '',
      'type': ContentType.fromString(json['type'] as String? ?? 'story'),
      'targetAge': json['targetAge'] as int? ?? 0,
      'duration': Duration(seconds: json['duration'] as int? ?? 0),
      'authorId': json['authorId'] as String? ?? '',
      'createdAt': DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      'audioUrl': json['audioUrl'] as String? ?? '',
      'albumArtUrl': json['albumArtUrl'] as String? ?? '',
      'likeCount': json['likeCount'] as int? ?? 0,
      'viewCount': json['viewCount'] as int? ?? 0,
      'saveCount': json['saveCount'] as int? ?? 0,
      'categories': List<String>.from(json['categories'] as List? ?? []),
      'theme': json['theme'] as String? ?? 'default',
      'isGenerated': json['isGenerated'] as bool? ?? false,
    };
  }

  Map<String, dynamic> toJson();

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  bool get isAgeAppropriate {
    return targetAge > 0;
  }
}
