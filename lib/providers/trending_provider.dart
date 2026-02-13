import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/content_model.dart' show Content;
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';
import 'package:dreamweaver/providers/user_provider.dart';

/// Trending content provider with auto-dispose
final trendingContentProvider = FutureProvider.autoDispose<List<Content>>(
  (ref) async {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getTrendingContent();
  },
);

/// Trending content by category provider
final trendingByCategoryProvider =
    FutureProvider.family.autoDispose<List<Content>, String>(
  (ref, category) async {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getTrendingByCategory(category);
  },
);

/// Weekly trending content provider - shows trending content from past week
final weeklyTrendingProvider = FutureProvider.autoDispose<List<Content>>(
  (ref) async {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getWeeklyTrending();
  },
);

/// Popular content by age group provider
final trendingByAgeProvider = FutureProvider.family.autoDispose<List<Content>, int>(
  (ref, childAge) async {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getTrendingByAge(childAge);
  },
);
