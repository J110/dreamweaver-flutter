import 'package:flutter/material.dart';

enum MusicType {
  ambient,
  lullaby,
  nature,
  instrumental,
  classical,
  rain;

  String get displayName {
    switch (this) {
      case MusicType.ambient:
        return 'Ambient';
      case MusicType.lullaby:
        return 'Lullaby';
      case MusicType.nature:
        return 'Nature';
      case MusicType.instrumental:
        return 'Instrumental';
      case MusicType.classical:
        return 'Classical';
      case MusicType.rain:
        return 'Rain';
    }
  }

  static MusicType fromString(String value) {
    return MusicType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MusicType.lullaby,
    );
  }
}

class UserPreferences {
  final String selectedVoiceId;
  final String selectedTone;
  final MusicType backgroundMusicType;
  final bool enableBackgroundMusic;
  final double musicVolume;
  final double speechSpeed;
  final bool enableNotifications;
  final List<String> preferredContentTypes;
  final List<String> preferredCategories;

  UserPreferences({
    required this.selectedVoiceId,
    this.selectedTone = 'calm',
    this.backgroundMusicType = MusicType.lullaby,
    this.enableBackgroundMusic = true,
    this.musicVolume = 0.7,
    this.speechSpeed = 1.0,
    this.enableNotifications = true,
    this.preferredContentTypes = const [],
    this.preferredCategories = const [],
  });

  UserPreferences copyWith({
    String? selectedVoiceId,
    String? selectedTone,
    MusicType? backgroundMusicType,
    bool? enableBackgroundMusic,
    double? musicVolume,
    double? speechSpeed,
    bool? enableNotifications,
    List<String>? preferredContentTypes,
    List<String>? preferredCategories,
  }) {
    return UserPreferences(
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      selectedTone: selectedTone ?? this.selectedTone,
      backgroundMusicType: backgroundMusicType ?? this.backgroundMusicType,
      enableBackgroundMusic: enableBackgroundMusic ?? this.enableBackgroundMusic,
      musicVolume: musicVolume ?? this.musicVolume,
      speechSpeed: speechSpeed ?? this.speechSpeed,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      preferredContentTypes: preferredContentTypes ?? this.preferredContentTypes,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedVoiceId': selectedVoiceId,
      'selectedTone': selectedTone,
      'backgroundMusicType': backgroundMusicType.name,
      'enableBackgroundMusic': enableBackgroundMusic,
      'musicVolume': musicVolume,
      'speechSpeed': speechSpeed,
      'enableNotifications': enableNotifications,
      'preferredContentTypes': preferredContentTypes,
      'preferredCategories': preferredCategories,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      selectedVoiceId: json['selectedVoiceId'] as String? ?? 'luna',
      selectedTone: json['selectedTone'] as String? ?? 'calm',
      backgroundMusicType: MusicType.fromString(json['backgroundMusicType'] as String? ?? 'lullaby'),
      enableBackgroundMusic: json['enableBackgroundMusic'] as bool? ?? true,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.7,
      speechSpeed: (json['speechSpeed'] as num?)?.toDouble() ?? 1.0,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      preferredContentTypes: List<String>.from(json['preferredContentTypes'] as List? ?? []),
      preferredCategories: List<String>.from(json['preferredCategories'] as List? ?? []),
    );
  }

  static UserPreferences defaultPreferences() {
    return UserPreferences(
      selectedVoiceId: 'luna',
      selectedTone: 'calm',
      backgroundMusicType: MusicType.lullaby,
      enableBackgroundMusic: true,
      musicVolume: 0.7,
      speechSpeed: 1.0,
      enableNotifications: true,
      preferredContentTypes: const [],
      preferredCategories: const [],
    );
  }
}
