import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/user/user_model.dart';
import 'package:dreamweaver/models/user/user_preferences.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

/// User state notifier that supports async loading and mutations like updateChildAge.
class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final ApiClient _apiClient;
  final String _userId;

  UserNotifier({
    required ApiClient apiClient,
    required String userId,
  })  : _apiClient = apiClient,
        _userId = userId,
        super(const AsyncValue.loading()) {
    if (_userId.isNotEmpty) {
      _loadUser();
    } else {
      state = AsyncValue.data(UserModel(
        id: '',
        username: 'Guest',
        childAge: 5,
        createdAt: DateTime.now(),
        preferences: UserPreferences.defaultPreferences(),
      ));
    }
  }

  Future<void> _loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _apiClient.getUser(_userId);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reload user data from the backend
  Future<void> refresh() async {
    await _loadUser();
  }

  /// Update the child's age
  Future<void> updateChildAge(int age) async {
    try {
      await _apiClient.updateUserPreferences(
        userId: _userId,
        childAge: age,
      );
      // Optimistically update the local state
      final currentUser = state.valueOrNull;
      if (currentUser != null) {
        state = AsyncValue.data(currentUser.copyWith(childAge: age));
      }
    } catch (e, st) {
      throw Exception('Failed to update child age: $e');
    }
  }
}

/// Primary user provider used by screens.
///
/// Screens use:
///   ref.watch(userProvider) -- returns AsyncValue<UserModel>
///   ref.read(userProvider.notifier).updateChildAge(age)
final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (authState is AuthStateAuthenticated) {
    return UserNotifier(
      apiClient: apiClient,
      userId: authState.userId,
    );
  }

  return UserNotifier(
    apiClient: apiClient,
    userId: '',
  );
});

/// Alias for providers that reference currentUserProvider
final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.when(
    data: (user) => user,
    loading: () => throw Exception('User still loading'),
    error: (e, st) => throw e,
  );
});

/// User preferences notifier
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final ApiClient _apiClient;
  final String _userId;

  UserPreferencesNotifier({
    required ApiClient apiClient,
    required String userId,
    required UserPreferences initialPreferences,
  })  : _apiClient = apiClient,
        _userId = userId,
        super(initialPreferences);

  /// Update child age preference
  Future<void> updateChildAge(int age) async {
    try {
      await _apiClient.updateUserPreferences(
        userId: _userId,
        childAge: age,
      );
    } catch (e) {
      throw Exception('Failed to update child age: $e');
    }
  }

  /// Update general preferences
  Future<void> updatePreferences({
    bool? enableNotifications,
    bool? enableBackgroundMusic,
    bool? enableParentalControls,
    String? preferredVoice,
    String? preferredTheme,
    double? speechSpeed,
  }) async {
    try {
      await _apiClient.updateUserPreferences(
        userId: _userId,
        enableNotifications: enableNotifications,
        enableBackgroundMusic: enableBackgroundMusic,
        enableParentalControls: enableParentalControls,
        preferredVoice: preferredVoice,
        preferredTheme: preferredTheme,
        speechSpeed: speechSpeed,
      );

      state = state.copyWith(
        enableNotifications: enableNotifications,
        enableBackgroundMusic: enableBackgroundMusic,
        selectedVoiceId: preferredVoice,
        speechSpeed: speechSpeed,
      );
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }
}

/// User preferences provider
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final authState = ref.watch(authStateProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (authState is AuthStateAuthenticated) {
    return UserPreferencesNotifier(
      apiClient: apiClient,
      userId: authState.userId,
      initialPreferences: UserPreferences.defaultPreferences(),
    );
  }

  // Return default preferences if not authenticated
  return UserPreferencesNotifier(
    apiClient: apiClient,
    userId: '',
    initialPreferences: UserPreferences.defaultPreferences(),
  );
});

/// Daily quota provider - checks how much content can be generated today
final dailyQuotaProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (authState is AuthStateAuthenticated) {
    return await apiClient.getDailyQuota(authState.userId);
  }

  return 0;
});
