/// API Endpoint Constants for DreamWeaver Backend
/// 
/// This file contains all API endpoint paths as static constants.
/// The base URL is configured in the API client.

class DreamWeaverEndpoints {
  // Base path for all API endpoints
  static const String baseApi = '/api';

  // ===== AUTH ENDPOINTS =====
  static const String signUp = '$baseApi/auth/signup';
  static const String signIn = '$baseApi/auth/signin';
  static const String refreshToken = '$baseApi/auth/refresh-token';

  // ===== USER ENDPOINTS =====
  static const String userProfile = '$baseApi/users/profile';
  static const String updateProfile = '$baseApi/users/profile';
  static const String updatePreferences = '$baseApi/users/preferences';
  static const String dailyQuota = '$baseApi/users/quota/daily';

  // ===== CONTENT ENDPOINTS =====
  static const String contentList = '$baseApi/content';
  static const String contentDetail = '$baseApi/content/:id';
  static const String generateContent = '$baseApi/content/generate';
  static const String searchContent = '$baseApi/content/search';

  // ===== TRENDING ENDPOINTS =====
  static const String trending = '$baseApi/trending';
  static const String trendingByCategory = '$baseApi/trending/category/:category';
  static const String weeklyTrending = '$baseApi/trending/weekly';

  // ===== INTERACTION ENDPOINTS =====
  static const String likeContent = '$baseApi/interactions/like/:id';
  static const String unlikeContent = '$baseApi/interactions/unlike/:id';
  static const String saveContent = '$baseApi/interactions/save/:id';
  static const String unsaveContent = '$baseApi/interactions/unsave/:id';
  static const String userLikes = '$baseApi/interactions/likes';
  static const String userSaves = '$baseApi/interactions/saves';

  // ===== AUDIO ENDPOINTS =====
  static const String audioUrl = '$baseApi/audio/:contentId';
  static const String voices = '$baseApi/audio/voices';
  static const String tones = '$baseApi/audio/tones';
  static const String tts = '$baseApi/audio/tts';
  static const String ttsStatus = '$baseApi/audio/tts/status/:taskId';
  static const String ttsResult = '$baseApi/audio/tts/result/:taskId';
  static const String ttsPreview = '$baseApi/audio/tts/preview/:voiceId';
  static const String engineInfo = '$baseApi/audio/engine';

  // ===== SUBSCRIPTION ENDPOINTS =====
  static const String subscriptionTiers = '$baseApi/subscriptions/tiers';
  static const String upgradeSubscription = '$baseApi/subscriptions/upgrade';

  /// Helper method to replace path parameters
  /// Example: replacePathParam('/content/:id', 'id', '123') => '/content/123'
  static String replacePathParam(String endpoint, String param, String value) {
    return endpoint.replaceAll(':$param', value);
  }
}
