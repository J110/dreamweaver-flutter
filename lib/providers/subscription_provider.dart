import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/subscription_model.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';
import 'package:dreamweaver/providers/user_provider.dart';

/// Subscription tier provider - reads from current user
final subscriptionTierProvider = FutureProvider<SubscriptionTier?>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  return currentUser?.subscriptionTier;
});

/// Can generate content provider - checks daily quota against tier limits
final canGenerateContentProvider = FutureProvider<bool>((ref) async {
  final quota = await ref.watch(dailyQuotaProvider.future);
  final tier = await ref.watch(subscriptionTierProvider.future);

  if (tier == null) return false;

  // Check if user has remaining quota for their tier
  return quota > 0;
});

/// Subscription tiers info provider - fetches comparison data from API
final subscriptionTiersInfoProvider =
    FutureProvider<List<SubscriptionTierInfo>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return await apiClient.getSubscriptionTiers();
});

/// Subscription notifier for managing tier upgrades
class SubscriptionNotifier extends StateNotifier<SubscriptionTier?> {
  final ApiClient _apiClient;
  final String _userId;

  SubscriptionNotifier({
    required ApiClient apiClient,
    required String userId,
    required SubscriptionTier? initialTier,
  })  : _apiClient = apiClient,
        _userId = userId,
        super(initialTier);

  /// Upgrade to a new subscription tier
  Future<void> upgradeToTier(SubscriptionTier tier) async {
    try {
      await _apiClient.upgradeTier(userId: _userId, tier: tier);
      state = tier;
    } catch (e) {
      throw Exception('Failed to upgrade subscription tier: $e');
    }
  }

  /// Cancel subscription and revert to free tier
  Future<void> cancelSubscription() async {
    try {
      await _apiClient.cancelSubscription(userId: _userId);
      state = SubscriptionTier.free;
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }
}

/// Subscription notifier provider
final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionTier?>((ref) {
  final authState = ref.watch(authStateProvider);
  final apiClient = ref.watch(apiClientProvider);
  final tierAsync = ref.watch(subscriptionTierProvider);

  if (authState is AuthStateAuthenticated) {
    return SubscriptionNotifier(
      apiClient: apiClient,
      userId: authState.userId,
      initialTier: tierAsync.value,
    );
  }

  return SubscriptionNotifier(
    apiClient: apiClient,
    userId: '',
    initialTier: null,
  );
});
