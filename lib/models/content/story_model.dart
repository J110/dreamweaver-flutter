import 'package:dreamweaver/models/content/content_base.dart';

enum StoryTheme {
  adventure,
  fantasy,
  educational,
  fairy,
  animals,
  friendship,
  courage,
  nature,
  mystery;

  String get displayName {
    switch (this) {
      case StoryTheme.adventure:
        return 'Adventure';
      case StoryTheme.fantasy:
        return 'Fantasy';
      case StoryTheme.educational:
        return 'Educational';
      case StoryTheme.fairy:
        return 'Fairy Tale';
      case StoryTheme.animals:
        return 'Animals';
      case StoryTheme.friendship:
        return 'Friendship';
      case StoryTheme.courage:
        return 'Courage';
      case StoryTheme.nature:
        return 'Nature';
      case StoryTheme.mystery:
        return 'Mystery';
    }
  }

  static StoryTheme fromString(String value) {
    return StoryTheme.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => StoryTheme.adventure,
    );
  }
}

enum StoryLength {
  short,
  medium,
  long;

  int get minWordCount {
    switch (this) {
      case StoryLength.short:
        return 500;
      case StoryLength.medium:
        return 1500;
      case StoryLength.long:
        return 3000;
    }
  }

  int get maxWordCount {
    switch (this) {
      case StoryLength.short:
        return 1500;
      case StoryLength.medium:
        return 3000;
      case StoryLength.long:
        return 10000;
    }
  }

  String get displayName {
    switch (this) {
      case StoryLength.short:
        return 'Short (5-15 min)';
      case StoryLength.medium:
        return 'Medium (15-30 min)';
      case StoryLength.long:
        return 'Long (30+ min)';
    }
  }

  static StoryLength fromString(String value) {
    return StoryLength.values.firstWhere(
      (length) => length.name == value,
      orElse: () => StoryLength.medium,
    );
  }
}

class Story extends ContentBase {
  final String storyText;
  final StoryTheme storyTheme;
  final List<String> morals;
  final bool hasQandA;
  final bool hasGames;

  Story({
    required String id,
    required String title,
    required String description,
    required int targetAge,
    required Duration duration,
    required String authorId,
    required DateTime createdAt,
    required String audioUrl,
    required String albumArtUrl,
    required this.storyText,
    this.storyTheme = StoryTheme.adventure,
    this.morals = const [],
    this.hasQandA = false,
    this.hasGames = false,
    int likeCount = 0,
    int viewCount = 0,
    int saveCount = 0,
    List<String> categories = const [],
    String theme = 'default',
    bool isGenerated = false,
  }) : super(
    id: id,
    title: title,
    description: description,
    type: ContentType.story,
    targetAge: targetAge,
    duration: duration,
    authorId: authorId,
    createdAt: createdAt,
    audioUrl: audioUrl,
    albumArtUrl: albumArtUrl,
    likeCount: likeCount,
    viewCount: viewCount,
    saveCount: saveCount,
    categories: categories,
    theme: theme,
    isGenerated: isGenerated,
  );

  Story copyWith({
    String? id,
    String? title,
    String? description,
    int? targetAge,
    Duration? duration,
    String? authorId,
    DateTime? createdAt,
    String? audioUrl,
    String? albumArtUrl,
    String? storyText,
    StoryTheme? storyTheme,
    List<String>? morals,
    bool? hasQandA,
    bool? hasGames,
    int? likeCount,
    int? viewCount,
    int? saveCount,
    List<String>? categories,
    String? theme,
    bool? isGenerated,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAge: targetAge ?? this.targetAge,
      duration: duration ?? this.duration,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      audioUrl: audioUrl ?? this.audioUrl,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      storyText: storyText ?? this.storyText,
      storyTheme: storyTheme ?? this.storyTheme,
      morals: morals ?? this.morals,
      hasQandA: hasQandA ?? this.hasQandA,
      hasGames: hasGames ?? this.hasGames,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      saveCount: saveCount ?? this.saveCount,
      categories: categories ?? this.categories,
      theme: theme ?? this.theme,
      isGenerated: isGenerated ?? this.isGenerated,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = baseToJson();
    return {
      ...baseJson,
      'storyText': storyText,
      'storyTheme': storyTheme.name,
      'morals': morals,
      'hasQandA': hasQandA,
      'hasGames': hasGames,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    final baseData = ContentBase.parseBaseJson(json);
    return Story(
      id: baseData['id'],
      title: baseData['title'],
      description: baseData['description'],
      targetAge: baseData['targetAge'],
      duration: baseData['duration'],
      authorId: baseData['authorId'],
      createdAt: baseData['createdAt'],
      audioUrl: baseData['audioUrl'],
      albumArtUrl: baseData['albumArtUrl'],
      storyText: json['storyText'] as String? ?? '',
      storyTheme: StoryTheme.fromString(json['storyTheme'] as String? ?? 'adventure'),
      morals: List<String>.from(json['morals'] as List? ?? []),
      hasQandA: json['hasQandA'] as bool? ?? false,
      hasGames: json['hasGames'] as bool? ?? false,
      likeCount: baseData['likeCount'],
      viewCount: baseData['viewCount'],
      saveCount: baseData['saveCount'],
      categories: baseData['categories'],
      theme: baseData['theme'],
      isGenerated: baseData['isGenerated'],
    );
  }

  int get wordCount {
    return storyText.split(RegExp(r'\s+')).length;
  }

  StoryLength get length {
    final count = wordCount;
    if (count < 1500) {
      return StoryLength.short;
    } else if (count < 3000) {
      return StoryLength.medium;
    } else {
      return StoryLength.long;
    }
  }
}
