import 'package:dreamweaver/models/content/content_base.dart';

enum PoemStyle {
  rhyming,
  freeverse,
  nursery,
  haiku;

  String get displayName {
    switch (this) {
      case PoemStyle.rhyming:
        return 'Rhyming';
      case PoemStyle.freeverse:
        return 'Free Verse';
      case PoemStyle.nursery:
        return 'Nursery Rhyme';
      case PoemStyle.haiku:
        return 'Haiku';
    }
  }

  static PoemStyle fromString(String value) {
    return PoemStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => PoemStyle.rhyming,
    );
  }
}

class Poem extends ContentBase {
  final String poemText;
  final PoemStyle style;

  Poem({
    required String id,
    required String title,
    required String description,
    required int targetAge,
    required Duration duration,
    required String authorId,
    required DateTime createdAt,
    required String audioUrl,
    required String albumArtUrl,
    required this.poemText,
    this.style = PoemStyle.rhyming,
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
    type: ContentType.poem,
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

  Poem copyWith({
    String? id,
    String? title,
    String? description,
    int? targetAge,
    Duration? duration,
    String? authorId,
    DateTime? createdAt,
    String? audioUrl,
    String? albumArtUrl,
    String? poemText,
    PoemStyle? style,
    int? likeCount,
    int? viewCount,
    int? saveCount,
    List<String>? categories,
    String? theme,
    bool? isGenerated,
  }) {
    return Poem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAge: targetAge ?? this.targetAge,
      duration: duration ?? this.duration,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      audioUrl: audioUrl ?? this.audioUrl,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      poemText: poemText ?? this.poemText,
      style: style ?? this.style,
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
      'poemText': poemText,
      'style': style.name,
    };
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    final baseData = ContentBase.parseBaseJson(json);
    return Poem(
      id: baseData['id'],
      title: baseData['title'],
      description: baseData['description'],
      targetAge: baseData['targetAge'],
      duration: baseData['duration'],
      authorId: baseData['authorId'],
      createdAt: baseData['createdAt'],
      audioUrl: baseData['audioUrl'],
      albumArtUrl: baseData['albumArtUrl'],
      poemText: json['poemText'] as String? ?? '',
      style: PoemStyle.fromString(json['style'] as String? ?? 'rhyming'),
      likeCount: baseData['likeCount'],
      viewCount: baseData['viewCount'],
      saveCount: baseData['saveCount'],
      categories: baseData['categories'],
      theme: baseData['theme'],
      isGenerated: baseData['isGenerated'],
    );
  }

  int get lineCount {
    return poemText.split('\n').length;
  }

  int get wordCount {
    return poemText.split(RegExp(r'\s+')).length;
  }
}
