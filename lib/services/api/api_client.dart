import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dreamweaver/config/env.dart';
import 'package:dreamweaver/models/content_model.dart';
import 'package:dreamweaver/models/content/story_model.dart';
import 'package:dreamweaver/models/user/user_model.dart';
import 'package:dreamweaver/models/user/subscription_tier.dart';
import 'package:dreamweaver/services/api/endpoints.dart';

/// Custom exception for DreamWeaver API errors
class DreamWeaverApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  DreamWeaverApiException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'DreamWeaverApiException: $message (StatusCode: $statusCode)';
}

/// Main API Client for DreamWeaver Backend
/// 
/// Handles all HTTP requests to the backend with:
/// - Automatic token injection
/// - Request/response logging
/// - Error handling and transformation
/// - Interceptor pipeline
class DreamWeaverApiClient {
  late Dio _dio;
  String? _authToken;

  /// Constructor initializes Dio with configuration
  /// 
  /// Parameters:
  /// - [baseUrl]: Base URL for API (e.g., 'https://api.dreamweaver.app')
  /// - [authToken]: Optional JWT token for authenticated requests
  /// - [connectTimeout]: Connection timeout in milliseconds (default: 30s)
  /// - [receiveTimeout]: Response timeout in milliseconds (default: 30s)
  DreamWeaverApiClient({
    required String baseUrl,
    String? authToken,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) : _authToken = authToken {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _setupInterceptors();
  }

  /// Setup all interceptors for request/response pipeline
  void _setupInterceptors() {
    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
      ),
    );

    // Logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint(
              'API Request: ${options.method} ${options.path}',
            );
            if (options.data != null) {
              debugPrint('Request Body: ${options.data}');
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              'API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              'API Error: ${error.message} - ${error.response?.statusCode}',
            );
            return handler.next(error);
          },
        ),
      );
    }

    // Error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = _handleError(error);
          return handler.reject(error.copyWith(error: exception));
        },
      ),
    );
  }

  /// Process DIO errors into DreamWeaverApiException
  DreamWeaverApiException _handleError(DioException error) {
    String message = 'An error occurred';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        // Handle HTTP error responses
        final response = error.response;
        if (response != null) {
          statusCode = response.statusCode;
          if (response.data is Map) {
            message = response.data['message'] ?? 'Server error';
          } else {
            message = 'HTTP ${response.statusCode}: ${response.statusMessage}';
          }
        }
        break;
      case DioExceptionType.badCertificate:
        message = 'SSL certificate error.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'Unknown error';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
    }

    return DreamWeaverApiException(
      message: message,
      statusCode: statusCode,
      originalError: error.error,
      stackTrace: error.stackTrace,
    );
  }

  /// Update the authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// ===== AUTH ENDPOINTS =====

  /// Sign up new user
  /// 
  /// Parameters:
  /// - [username]: User's desired username
  /// - [password]: User's password
  /// - [childAge]: Age of the child using the app
  /// 
  /// Returns: Map with user data and tokens
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required int childAge,
  }) async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.signUp,
        data: {
          'username': username,
          'password': password,
          'childAge': childAge,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign in existing user
  /// 
  /// Parameters:
  /// - [username]: User's username
  /// - [password]: User's password
  /// 
  /// Returns: Map with user data and tokens
  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.signIn,
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh authentication token
  /// 
  /// Returns: Map with new token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.refreshToken,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ===== USER ENDPOINTS =====

  /// Get user profile
  /// 
  /// Returns: Map with user profile data
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.userProfile,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  /// 
  /// Parameters:
  /// - [data]: Map of profile fields to update
  /// 
  /// Returns: Updated profile data
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        DreamWeaverEndpoints.updateProfile,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user preferences
  /// 
  /// Parameters:
  /// - [preferences]: Map of preferences to update
  /// 
  /// Returns: Updated preferences data
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final response = await _dio.put(
        DreamWeaverEndpoints.updatePreferences,
        data: preferences,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get daily content quota
  /// 
  /// Returns: Map with quota information
  Future<Map<String, dynamic>> getDailyQuota() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.dailyQuota,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ===== CONTENT ENDPOINTS =====

  /// Get list of content with optional filters
  /// 
  /// Parameters:
  /// - [filters]: Map of filter criteria (e.g., {'category': 'adventure', 'page': 1})
  /// 
  /// Returns: List of content items
  Future<Map<String, dynamic>> getContentList(Map<String, dynamic>? filters) async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.contentList,
        queryParameters: filters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific content by ID
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// 
  /// Returns: Content item data
  Future<Map<String, dynamic>> getContentById(String id) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.contentDetail,
        'id',
        id,
      );
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate new content
  /// 
  /// Parameters:
  /// - [params]: Generation parameters (theme, duration, ageGroup, etc.)
  /// 
  /// Returns: Generated content data
  Future<Map<String, dynamic>> generateContent(Map<String, dynamic> params) async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.generateContent,
        data: params,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search content by query
  /// 
  /// Parameters:
  /// - [query]: Search query string
  /// 
  /// Returns: List of matching content items
  Future<Map<String, dynamic>> searchContent(String query) async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.searchContent,
        queryParameters: {'q': query},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ===== TRENDING ENDPOINTS =====

  /// Get trending content with pagination
  /// 
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// 
  /// Returns: List of trending content
  Future<Map<String, dynamic>> getTrending({int page = 1}) async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.trending,
        queryParameters: {'page': page},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get trending content by category
  /// 
  /// Parameters:
  /// - [category]: Content category
  /// 
  /// Returns: List of trending content in category
  Future<Map<String, dynamic>> getTrendingByCategory(String category) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.trendingByCategory,
        'category',
        category,
      );
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get weekly trending content
  /// 
  /// Returns: List of trending content for the week
  Future<Map<String, dynamic>> getWeeklyTrending() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.weeklyTrending,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ===== INTERACTION ENDPOINTS =====

  /// Like a content item
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// 
  /// Returns: Updated interaction data
  Future<Map<String, dynamic>> likeContent(String id) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.likeContent,
        'id',
        id,
      );
      final response = await _dio.post(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unlike a content item
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// 
  /// Returns: Updated interaction data
  Future<Map<String, dynamic>> unlikeContent(String id) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.unlikeContent,
        'id',
        id,
      );
      final response = await _dio.post(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Save a content item
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// 
  /// Returns: Updated interaction data
  Future<Map<String, dynamic>> saveContent(String id) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.saveContent,
        'id',
        id,
      );
      final response = await _dio.post(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unsave a content item
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// 
  /// Returns: Updated interaction data
  Future<Map<String, dynamic>> unsaveContent(String id) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.unsaveContent,
        'id',
        id,
      );
      final response = await _dio.post(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's liked content
  /// 
  /// Returns: List of liked content IDs
  Future<Map<String, dynamic>> getUserLikes() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.userLikes,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's saved content
  /// 
  /// Returns: List of saved content IDs
  Future<Map<String, dynamic>> getUserSaves() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.userSaves,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ===== AUDIO ENDPOINTS =====

  /// Get audio URL for content
  /// 
  /// Parameters:
  /// - [contentId]: Content ID
  /// 
  /// Returns: Map with audio URL and metadata
  Future<Map<String, dynamic>> getAudioUrl(String contentId) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.audioUrl,
        'contentId',
        contentId,
      );
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get available voices for audio generation
  Future<Map<String, dynamic>> getVoices() async {
    try {
      final response = await _dio.get(DreamWeaverEndpoints.voices);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get available narration tone presets
  Future<Map<String, dynamic>> getTones() async {
    try {
      final response = await _dio.get(DreamWeaverEndpoints.tones);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get TTS engine info (chatterbox or edge-tts)
  Future<Map<String, dynamic>> getEngineInfo() async {
    try {
      final response = await _dio.get(DreamWeaverEndpoints.engineInfo);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit text for TTS synthesis (returns task_id for polling)
  Future<Map<String, dynamic>> generateTTS({
    required String text,
    String voiceId = 'luna',
    String contentType = 'story',
    String tone = 'calm',
    double? exaggeration,
    double? cfgWeight,
  }) async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.tts,
        data: {
          'text': text,
          'voice_id': voiceId,
          'content_type': contentType,
          'tone': tone,
          if (exaggeration != null) 'exaggeration': exaggeration,
          if (cfgWeight != null) 'cfg_weight': cfgWeight,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Poll TTS synthesis status
  Future<Map<String, dynamic>> getTTSStatus(String taskId) async {
    try {
      final endpoint = DreamWeaverEndpoints.replacePathParam(
        DreamWeaverEndpoints.ttsStatus, 'taskId', taskId,
      );
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get the full URL for a voice preview audio clip
  String getVoicePreviewUrl(String voiceId, {String tone = 'calm'}) {
    final path = DreamWeaverEndpoints.replacePathParam(
      DreamWeaverEndpoints.ttsPreview, 'voiceId', voiceId,
    );
    return '${_dio.options.baseUrl}$path?tone=$tone';
  }

  /// Get the full URL for a completed TTS result
  String getTTSResultUrl(String taskId) {
    final path = DreamWeaverEndpoints.replacePathParam(
      DreamWeaverEndpoints.ttsResult, 'taskId', taskId,
    );
    return '${_dio.options.baseUrl}$path';
  }

  /// ===== SUBSCRIPTION ENDPOINTS =====

  /// Get available subscription tiers
  /// 
  /// Returns: List of subscription tiers with pricing
  Future<Map<String, dynamic>> getTiers() async {
    try {
      final response = await _dio.get(
        DreamWeaverEndpoints.subscriptionTiers,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upgrade subscription to a tier
  /// 
  /// Parameters:
  /// - [tier]: Tier ID to upgrade to
  /// 
  /// Returns: Updated subscription data
  Future<Map<String, dynamic>> upgradeToTier(String tier) async {
    try {
      final response = await _dio.post(
        DreamWeaverEndpoints.upgradeSubscription,
        data: {'tier': tier},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cleanup and dispose resources
  void dispose() {
    _dio.close();
  }
}

/// High-level API Client used by providers.
///
/// Wraps [DreamWeaverApiClient] and provides typed methods that return
/// domain model objects (UserModel, Content, etc.) instead of raw Maps.
class ApiClient {
  late final DreamWeaverApiClient _raw;

  ApiClient() : _raw = DreamWeaverApiClient(baseUrl: Env.apiBaseUrl);

  ApiClient.withRaw(DreamWeaverApiClient raw) : _raw = raw;

  /// Access the underlying raw client (for voice_provider, etc.)
  DreamWeaverApiClient get raw => _raw;

  /// Set auth token on the underlying client
  void setAuthToken(String token) => _raw.setAuthToken(token);

  /// Clear auth token
  void clearAuthToken() => _raw.clearAuthToken();

  // ===== AUTH =====

  /// Register a new user on the backend after Firebase auth
  Future<void> registerUser({
    required String userId,
    required String username,
    required int childAge,
  }) async {
    await _raw.signUp(
      username: username,
      password: userId, // userId used as identifier; real password handled by Firebase
      childAge: childAge,
    );
  }

  /// Fetch the username for a given userId
  Future<String> getUserUsername(String userId) async {
    final data = await _raw.getProfile();
    return data['username'] as String? ?? '';
  }

  // ===== USER =====

  /// Get full user model
  Future<UserModel> getUser(String userId) async {
    final data = await _raw.getProfile();
    return UserModel.fromJson(data);
  }

  /// Update user preferences on the backend
  Future<void> updateUserPreferences({
    required String userId,
    int? childAge,
    bool? enableNotifications,
    bool? enableBackgroundMusic,
    bool? enableParentalControls,
    String? preferredVoice,
    String? preferredTheme,
    double? speechSpeed,
  }) async {
    final prefs = <String, dynamic>{};
    if (childAge != null) prefs['childAge'] = childAge;
    if (enableNotifications != null) prefs['enableNotifications'] = enableNotifications;
    if (enableBackgroundMusic != null) prefs['enableBackgroundMusic'] = enableBackgroundMusic;
    if (enableParentalControls != null) prefs['enableParentalControls'] = enableParentalControls;
    if (preferredVoice != null) prefs['preferredVoice'] = preferredVoice;
    if (preferredTheme != null) prefs['preferredTheme'] = preferredTheme;
    if (speechSpeed != null) prefs['speechSpeed'] = speechSpeed;
    await _raw.updatePreferences(prefs);
  }

  /// Get remaining daily quota for a user
  Future<int> getDailyQuota(String userId) async {
    final data = await _raw.getDailyQuota();
    return data['remaining'] as int? ?? 0;
  }

  // ===== CONTENT =====

  /// Get filtered content list
  Future<List<Content>> getContentList({
    String? type,
    String? category,
    int? ageMin,
    int? ageMax,
    int page = 1,
    int pageSize = 20,
  }) async {
    final filters = <String, dynamic>{
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (ageMin != null) 'ageMin': ageMin,
      if (ageMax != null) 'ageMax': ageMax,
      'page': page,
      'pageSize': pageSize,
    };
    final data = await _raw.getContentList(filters);
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get single content detail by ID
  Future<Content> getContentDetail(String contentId) async {
    final data = await _raw.getContentById(contentId);
    return Story.fromJson(data);
  }

  /// Generate new content
  Future<Content> generateContent({
    required String userId,
    required String contentType,
    required int childAge,
    String? theme,
    String? length,
    bool includeMusic = false,
    bool includeSongs = false,
    bool includePoems = false,
    String? voiceId,
    String? musicType,
  }) async {
    final params = <String, dynamic>{
      'userId': userId,
      'contentType': contentType,
      'childAge': childAge,
      if (theme != null) 'theme': theme,
      if (length != null) 'length': length,
      'includeMusic': includeMusic,
      'includeSongs': includeSongs,
      'includePoems': includePoems,
      if (voiceId != null) 'voiceId': voiceId,
      if (musicType != null) 'musicType': musicType,
    };
    final data = await _raw.generateContent(params);
    return Story.fromJson(data);
  }

  /// Search content by query
  Future<List<Content>> searchContent(String query) async {
    final data = await _raw.searchContent(query);
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ===== TRENDING =====

  /// Get trending content
  Future<List<Content>> getTrendingContent({int page = 1}) async {
    final data = await _raw.getTrending(page: page);
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get trending content by category
  Future<List<Content>> getTrendingByCategory(String category) async {
    final data = await _raw.getTrendingByCategory(category);
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get weekly trending content
  Future<List<Content>> getWeeklyTrending() async {
    final data = await _raw.getWeeklyTrending();
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get trending content by age group
  Future<List<Content>> getTrendingByAge(int childAge) async {
    final data = await _raw.getTrending(page: 1);
    final items = data['items'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ===== INTERACTIONS =====

  /// Like content
  Future<void> likeContent({
    required String userId,
    required String contentId,
  }) async {
    await _raw.likeContent(contentId);
  }

  /// Unlike content
  Future<void> unlikeContent({
    required String userId,
    required String contentId,
  }) async {
    await _raw.unlikeContent(contentId);
  }

  /// Save content
  Future<void> saveContent({
    required String userId,
    required String contentId,
  }) async {
    await _raw.saveContent(contentId);
  }

  /// Unsave content
  Future<void> unsaveContent({
    required String userId,
    required String contentId,
  }) async {
    await _raw.unsaveContent(contentId);
  }

  /// Get user's liked content IDs
  Future<List<String>> getUserLikes({required String userId}) async {
    final data = await _raw.getUserLikes();
    final items = data['items'] as List? ?? [];
    return items.cast<String>();
  }

  /// Get user's saved content IDs
  Future<List<String>> getUserSaves({required String userId}) async {
    final data = await _raw.getUserSaves();
    final items = data['items'] as List? ?? [];
    return items.cast<String>();
  }

  /// Get user's liked content as full Content objects
  Future<List<Content>> getLikedContent({required String userId}) async {
    final data = await _raw.getUserLikes();
    final items = data['content'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get user's saved content as full Content objects
  Future<List<Content>> getSavedContent({required String userId}) async {
    final data = await _raw.getUserSaves();
    final items = data['content'] as List? ?? [];
    return items
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ===== SUBSCRIPTIONS =====

  /// Get available subscription tiers
  Future<List<SubscriptionTier>> getSubscriptionTiers() async {
    final data = await _raw.getTiers();
    final items = data['tiers'] as List? ?? [];
    return items
        .map((item) => SubscriptionTier.fromString(item as String? ?? 'free'))
        .toList();
  }

  /// Upgrade subscription tier
  Future<void> upgradeTier({
    required String userId,
    required SubscriptionTier tier,
  }) async {
    await _raw.upgradeToTier(tier.name);
  }

  /// Cancel subscription
  Future<void> cancelSubscription({required String userId}) async {
    await _raw.upgradeToTier('free');
  }

  // ===== AUDIO (delegated to raw client) =====

  /// Get voices
  Future<Map<String, dynamic>> getVoices() => _raw.getVoices();

  /// Get tones
  Future<Map<String, dynamic>> getTones() => _raw.getTones();

  /// Get engine info
  Future<Map<String, dynamic>> getEngineInfo() => _raw.getEngineInfo();

  /// Get voice preview URL
  String getVoicePreviewUrl(String voiceId, {String tone = 'calm'}) =>
      _raw.getVoicePreviewUrl(voiceId, tone: tone);

  /// Cleanup
  void dispose() => _raw.dispose();
}
