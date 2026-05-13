import 'package:dreamweaver/models/user/subscription_tier.dart';
import 'package:dreamweaver/models/user/user_preferences.dart';

class UserModel {
  final String id;
  final String username;
  final int childAge;
  final SubscriptionTier subscriptionTier;
  final DateTime createdAt;
  final DateTime? subscriptionExpiresAt;
  final List<String> favoriteContentIds;
  final List<String> savedContentIds;
  final UserPreferences preferences;
  final Map<String, int> todayUsage;
  final int storiesGenerated;
  final int daysActive;

  UserModel({
    required this.id,
    required this.username,
    required this.childAge,
    this.subscriptionTier = SubscriptionTier.free,
    required this.createdAt,
    this.subscriptionExpiresAt,
    this.favoriteContentIds = const [],
    this.savedContentIds = const [],
    required this.preferences,
    this.todayUsage = const {},
    this.storiesGenerated = 0,
    this.daysActive = 0,
  });

  UserModel copyWith({
    String? id,
    String? username,
    int? childAge,
    SubscriptionTier? subscriptionTier,
    DateTime? createdAt,
    DateTime? subscriptionExpiresAt,
    List<String>? favoriteContentIds,
    List<String>? savedContentIds,
    UserPreferences? preferences,
    Map<String, int>? todayUsage,
    int? storiesGenerated,
    int? daysActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      childAge: childAge ?? this.childAge,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      favoriteContentIds: favoriteContentIds ?? this.favoriteContentIds,
      savedContentIds: savedContentIds ?? this.savedContentIds,
      preferences: preferences ?? this.preferences,
      todayUsage: todayUsage ?? this.todayUsage,
      storiesGenerated: storiesGenerated ?? this.storiesGenerated,
      daysActive: daysActive ?? this.daysActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'childAge': childAge,
      'subscriptionTier': subscriptionTier.name,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'favoriteContentIds': favoriteContentIds,
      'savedContentIds': savedContentIds,
      'preferences': preferences.toJson(),
      'todayUsage': todayUsage,
      'storiesGenerated': storiesGenerated,
      'daysActive': daysActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      childAge: json['childAge'] as int? ?? 0,
      subscriptionTier: SubscriptionTier.fromString(json['subscriptionTier'] as String? ?? 'free'),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      favoriteContentIds: List<String>.from(json['favoriteContentIds'] as List? ?? []),
      savedContentIds: List<String>.from(json['savedContentIds'] as List? ?? []),
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      todayUsage: Map<String, int>.from(json['todayUsage'] as Map? ?? {}),
      storiesGenerated: json['storiesGenerated'] as int? ?? 0,
      daysActive: json['daysActive'] as int? ?? 0,
    );
  }

  bool get isSubscriptionActive {
    if (subscriptionTier == SubscriptionTier.free) {
      return true;
    }
    if (subscriptionExpiresAt == null) {
      return false;
    }
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  /// Number of stories used today
  int get dailyStoriesUsed => todayUsage['used'] ?? 0;

  /// Daily story limit based on subscription tier
  int get dailyStoriesLimit => subscriptionTier.dailyLimit;

  int get remainingDailyUsage {
    final used = todayUsage['used'] ?? 0;
    final limit = subscriptionTier.dailyLimit;
    return (limit - used).clamp(0, limit);
  }

  /// Number of favorite content items
  int get favoriteCount => favoriteContentIds.length;

  bool get canAddFavorite {
    return favoriteContentIds.length < subscriptionTier.maxFavorites;
  }

  bool get canAddSave {
    return savedContentIds.length < subscriptionTier.maxSaves;
  }
}
