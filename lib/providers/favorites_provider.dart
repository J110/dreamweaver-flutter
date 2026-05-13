import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/content_model.dart' show Content;
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

/// Provider that fetches the user's liked content as full Content objects.
///
/// Used by favorites_tab.dart to display the "Liked" tab.
final likedContentProvider = FutureProvider.autoDispose<List<Content>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final apiClient = ref.watch(apiClientProvider);

    if (authState is AuthStateAuthenticated) {
      return await apiClient.getLikedContent(userId: authState.userId);
    }

    return [];
  },
);

/// Provider that fetches the user's saved content as full Content objects.
///
/// Used by favorites_tab.dart to display the "Saved" tab.
final savedContentProvider = FutureProvider.autoDispose<List<Content>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final apiClient = ref.watch(apiClientProvider);

    if (authState is AuthStateAuthenticated) {
      return await apiClient.getSavedContent(userId: authState.userId);
    }

    return [];
  },
);
