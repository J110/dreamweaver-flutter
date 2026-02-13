import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

/// User likes notifier - manages liked content IDs
class UserLikesNotifier extends StateNotifier<Set<String>> {
  final ApiClient _apiClient;
  final String _userId;

  UserLikesNotifier({
    required ApiClient apiClient,
    required String userId,
    required Set<String> initialLikes,
  })  : _apiClient = apiClient,
        _userId = userId,
        super(initialLikes);

  /// Toggle like status for content
  Future<void> toggleLike(String contentId) async {
    try {
      final isLiked = state.contains(contentId);

      if (isLiked) {
        // Unlike
        await _apiClient.unlikeContent(
          userId: _userId,
          contentId: contentId,
        );
        state = {...state}..remove(contentId);
      } else {
        // Like
        await _apiClient.likeContent(
          userId: _userId,
          contentId: contentId,
        );
        state = {...state, contentId};
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Check if content is liked
  bool isLiked(String contentId) {
    return state.contains(contentId);
  }

  /// Load likes from API
  Future<void> loadLikes() async {
    try {
      final likes = await _apiClient.getUserLikes(userId: _userId);
      state = likes.toSet();
    } catch (e) {
      throw Exception('Failed to load likes: $e');
    }
  }
}

/// User likes provider
final userLikesProvider = StateNotifierProvider<UserLikesNotifier, Set<String>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    final apiClient = ref.watch(apiClientProvider);

    if (authState is AuthStateAuthenticated) {
      final notifier = UserLikesNotifier(
        apiClient: apiClient,
        userId: authState.userId,
        initialLikes: {},
      );

      // Load likes from API on initialization
      notifier.loadLikes();

      return notifier;
    }

    return UserLikesNotifier(
      apiClient: apiClient,
      userId: '',
      initialLikes: {},
    );
  },
);

/// User saves notifier - manages saved content IDs
class UserSavesNotifier extends StateNotifier<Set<String>> {
  final ApiClient _apiClient;
  final String _userId;

  UserSavesNotifier({
    required ApiClient apiClient,
    required String userId,
    required Set<String> initialSaves,
  })  : _apiClient = apiClient,
        _userId = userId,
        super(initialSaves);

  /// Toggle save status for content
  Future<void> toggleSave(String contentId) async {
    try {
      final isSaved = state.contains(contentId);

      if (isSaved) {
        // Unsave
        await _apiClient.unsaveContent(
          userId: _userId,
          contentId: contentId,
        );
        state = {...state}..remove(contentId);
      } else {
        // Save
        await _apiClient.saveContent(
          userId: _userId,
          contentId: contentId,
        );
        state = {...state, contentId};
      }
    } catch (e) {
      throw Exception('Failed to toggle save: $e');
    }
  }

  /// Check if content is saved
  bool isSaved(String contentId) {
    return state.contains(contentId);
  }

  /// Load saves from API
  Future<void> loadSaves() async {
    try {
      final saves = await _apiClient.getUserSaves(userId: _userId);
      state = saves.toSet();
    } catch (e) {
      throw Exception('Failed to load saves: $e');
    }
  }
}

/// User saves provider
final userSavesProvider = StateNotifierProvider<UserSavesNotifier, Set<String>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    final apiClient = ref.watch(apiClientProvider);

    if (authState is AuthStateAuthenticated) {
      final notifier = UserSavesNotifier(
        apiClient: apiClient,
        userId: authState.userId,
        initialSaves: {},
      );

      // Load saves from API on initialization
      notifier.loadSaves();

      return notifier;
    }

    return UserSavesNotifier(
      apiClient: apiClient,
      userId: '',
      initialSaves: {},
    );
  },
);

/// Provider to check if content is liked
final isContentLikedProvider =
    Provider.family<bool, String>((ref, contentId) {
  final likes = ref.watch(userLikesProvider);
  return likes.contains(contentId);
});

/// Provider to check if content is saved
final isContentSavedProvider =
    Provider.family<bool, String>((ref, contentId) {
  final saves = ref.watch(userSavesProvider);
  return saves.contains(contentId);
});
