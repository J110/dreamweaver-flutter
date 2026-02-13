import 'package:dreamweaver/models/content/content_base.dart';

class Song extends ContentBase {
  final String lyrics;
  final String musicGenre;
  final List<String> instruments;

  Song({
    required String id,
    required String title,
    required String description,
    required int targetAge,
    required Duration duration,
    required String authorId,
    required DateTime createdAt,
    required String audioUrl,
    required String albumArtUrl,
    required this.lyrics,
    required this.musicGenre,
    required this.instruments,
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
    type: ContentType.song,
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

  Song copyWith({
    String? id,
    String? title,
    String? description,
    int? targetAge,
    Duration? duration,
    String? authorId,
    DateTime? createdAt,
    String? audioUrl,
    String? albumArtUrl,
    String? lyrics,
    String? musicGenre,
    List<String>? instruments,
    int? likeCount,
    int? viewCount,
    int? saveCount,
    List<String>? categories,
    String? theme,
    bool? isGenerated,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAge: targetAge ?? this.targetAge,
      duration: duration ?? this.duration,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      audioUrl: audioUrl ?? this.audioUrl,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      lyrics: lyrics ?? this.lyrics,
      musicGenre: musicGenre ?? this.musicGenre,
      instruments: instruments ?? this.instruments,
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
      'lyrics': lyrics,
      'musicGenre': musicGenre,
      'instruments': instruments,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    final baseData = ContentBase.parseBaseJson(json);
    return Song(
      id: baseData['id'],
      title: baseData['title'],
      description: baseData['description'],
      targetAge: baseData['targetAge'],
      duration: baseData['duration'],
      authorId: baseData['authorId'],
      createdAt: baseData['createdAt'],
      audioUrl: baseData['audioUrl'],
      albumArtUrl: baseData['albumArtUrl'],
      lyrics: json['lyrics'] as String? ?? '',
      musicGenre: json['musicGenre'] as String? ?? '',
      instruments: List<String>.from(json['instruments'] as List? ?? []),
      likeCount: baseData['likeCount'],
      viewCount: baseData['viewCount'],
      saveCount: baseData['saveCount'],
      categories: baseData['categories'],
      theme: baseData['theme'],
      isGenerated: baseData['isGenerated'],
    );
  }

  int get verseCount {
    return lyrics.split(RegExp(r'\n\n+')).length;
  }

  int get wordCount {
    return lyrics.split(RegExp(r'\s+')).length;
  }
}
