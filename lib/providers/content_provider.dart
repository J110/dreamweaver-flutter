import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/content_model.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';
import 'package:dreamweaver/providers/user_provider.dart';

/// Content filter class for filtering content
class ContentFilter {
  final String? type; // 'story', 'poem', 'song', etc.
  final String? category; // 'adventure', 'educational', etc.
  final int? ageMin;
  final int? ageMax;
  final int page;
  final int pageSize;

  ContentFilter({
    this.type,
    this.category,
    this.ageMin,
    this.ageMax,
    this.page = 1,
    this.pageSize = 20,
  });
}

/// Generation parameters for content creation
class GenerationParams {
  final String contentType; // 'story', 'poem', 'song'
  final int childAge;
  final String? theme; // 'adventure', 'educational', 'fantasy', etc.
  final String? length; // 'short', 'medium', 'long'
  final bool includeMusic;
  final bool includeSongs;
  final bool includePoems;
  final String? voiceId;
  final String? musicType; // 'calm', 'upbeat', 'nature', etc.

  GenerationParams({
    required this.contentType,
    required this.childAge,
    this.theme,
    this.length,
    this.includeMusic = false,
    this.includeSongs = false,
    this.includePoems = false,
    this.voiceId,
    this.musicType,
  });
}

/// Content list provider with filtering options
final contentListProvider = FutureProvider.family<List<Content>, ContentFilter>(
  (ref, filter) async {
    final apiClient = ref.watch(apiClientProvider);

    return await apiClient.getContentList(
      type: filter.type,
      category: filter.category,
      ageMin: filter.ageMin,
      ageMax: filter.ageMax,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  },
);

/// Content detail provider - fetch single content by ID
final contentDetailProvider = FutureProvider.family<Content, String>(
  (ref, contentId) async {
    final apiClient = ref.watch(apiClientProvider);
    return await apiClient.getContentDetail(contentId);
  },
);

/// Generate new content provider
final generateContentProvider =
    FutureProvider.family<Content, GenerationParams>(
  (ref, params) async {
    final authState = ref.watch(authStateProvider);
    final apiClient = ref.watch(apiClientProvider);

    if (authState is! AuthStateAuthenticated) {
      throw Exception('User must be authenticated to generate content');
    }

    return await apiClient.generateContent(
      userId: authState.userId,
      contentType: params.contentType,
      childAge: params.childAge,
      theme: params.theme,
      length: params.length,
      includeMusic: params.includeMusic,
      includeSongs: params.includeSongs,
      includePoems: params.includePoems,
      voiceId: params.voiceId,
      musicType: params.musicType,
    );
  },
);

/// Search content provider
final searchContentProvider = FutureProvider.family<List<Content>, String>(
  (ref, query) async {
    final apiClient = ref.watch(apiClientProvider);

    if (query.isEmpty) {
      return [];
    }

    return await apiClient.searchContent(query);
  },
);
