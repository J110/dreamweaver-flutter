import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/user/user_model.dart';
import 'package:dreamweaver/models/user/user_preferences.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

/// Current user provider - fetches user profile based on auth state
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  if (authState is AuthStateAuthenticated) {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getUser(authState.userId);
  }
  
  return null;
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
      state = state.copyWith(childAge: age);
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
        enableParentalControls: enableParentalControls,
        preferredVoice: preferredVoice,
        preferredTheme: preferredTheme,
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
    // In production, fetch initial preferences from API
    final initialPreferences = UserPreferences(
      childAge: 5,
      enableNotifications: true,
      enableBackgroundMusic: true,
      enableParentalControls: true,
      preferredVoice: 'default',
      preferredTheme: 'light',
      speechSpeed: 1.0,
    );

    return UserPreferencesNotifier(
      apiClient: apiClient,
      userId: authState.userId,
      initialPreferences: initialPreferences,
    );
  }

  // Return default preferences if not authenticated
  return UserPreferencesNotifier(
    apiClient: apiClient,
    userId: '',
    initialPreferences: UserPreferences(
      childAge: 5,
      enableNotifications: true,
      enableBackgroundMusic: true,
      enableParentalControls: true,
      preferredVoice: 'default',
      preferredTheme: 'light',
      speechSpeed: 1.0,
    ),
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
