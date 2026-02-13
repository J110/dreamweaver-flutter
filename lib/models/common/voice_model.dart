enum VoiceGender {
  male,
  female,
  neutral;

  String get displayName {
    switch (this) {
      case VoiceGender.male:
        return 'Male';
      case VoiceGender.female:
        return 'Female';
      case VoiceGender.neutral:
        return 'Neutral';
    }
  }

  static VoiceGender fromString(String value) {
    return VoiceGender.values.firstWhere(
      (gender) => gender.name == value,
      orElse: () => VoiceGender.neutral,
    );
  }
}

class Voice {
  final String id;
  final String name;
  final VoiceGender gender;
  final String description;
  final String descriptionHi;
  final List<String> emotions;
  final List<String> recommendedFor;
  final String ageGroup;
  final String language;
  final String sampleUrl;

  Voice({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
    this.descriptionHi = '',
    this.emotions = const [],
    this.recommendedFor = const [],
    this.ageGroup = 'general',
    this.language = 'en-US',
    this.sampleUrl = '',
  });

  Voice copyWith({
    String? id,
    String? name,
    VoiceGender? gender,
    String? description,
    String? descriptionHi,
    List<String>? emotions,
    List<String>? recommendedFor,
    String? ageGroup,
    String? language,
    String? sampleUrl,
  }) {
    return Voice(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      emotions: emotions ?? this.emotions,
      recommendedFor: recommendedFor ?? this.recommendedFor,
      ageGroup: ageGroup ?? this.ageGroup,
      language: language ?? this.language,
      sampleUrl: sampleUrl ?? this.sampleUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender.name,
      'description': description,
      'description_hi': descriptionHi,
      'emotions': emotions,
      'recommended_for': recommendedFor,
      'age_group': ageGroup,
      'language': language,
      'sample_url': sampleUrl,
    };
  }

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gender: VoiceGender.fromString(json['gender'] as String? ?? 'neutral'),
      description: json['description'] as String? ?? '',
      descriptionHi: json['description_hi'] as String? ?? '',
      emotions: List<String>.from(json['emotions'] as List? ?? []),
      recommendedFor: List<String>.from(json['recommended_for'] as List? ?? []),
      ageGroup: json['age_group'] as String? ?? 'general',
      language: json['language'] as String? ?? 'en-US',
      sampleUrl: json['sample_url'] as String? ?? '',
    );
  }

  static Voice defaultVoice() {
    return Voice(
      id: 'luna',
      name: 'Luna',
      gender: VoiceGender.female,
      description: 'Gentle and soothing — perfect for bedtime stories',
      emotions: const ['calm', 'gentle', 'soothing', 'sleepy'],
      recommendedFor: const ['story', 'poem'],
    );
  }
}

class TonePreset {
  final String name;
  final String description;
  final String descriptionHi;
  final String icon;

  TonePreset({
    required this.name,
    required this.description,
    this.descriptionHi = '',
    this.icon = 'moon',
  });

  factory TonePreset.fromJson(Map<String, dynamic> json) {
    return TonePreset(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionHi: json['description_hi'] as String? ?? '',
      icon: json['icon'] as String? ?? 'moon',
    );
  }
}
