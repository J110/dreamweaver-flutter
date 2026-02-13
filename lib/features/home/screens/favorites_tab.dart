import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/favorites_provider.dart';
import 'package:dreamweaver/features/home/widgets/content_card.dart';

class FavoritesTab extends ConsumerStatefulWidget {
  const FavoritesTab({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends ConsumerState<FavoritesTab> {
  bool _showLiked = true;

  @override
  Widget build(BuildContext context) {
    final favoritesAsyncValue = _showLiked
        ? ref.watch(likedContentProvider)
        : ref.watch(savedContentProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Favorites',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: DreamTheme.moonGlow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showLiked = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _showLiked
                                ? DreamTheme.primaryPurple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Liked',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _showLiked
                                    ? DreamTheme.primaryPurple
                                    : DreamTheme.moonGlow.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showLiked = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !_showLiked
                                ? DreamTheme.primaryPurple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Saved',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: !_showLiked
                                    ? DreamTheme.primaryPurple
                                    : DreamTheme.moonGlow.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content grid
          Expanded(
            child: favoritesAsyncValue.when(
              data: (content) => content.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showLiked
                                ? Icons.favorite_outline
                                : Icons.bookmark_outline,
                            size: 64,
                            color: DreamTheme.moonGlow.withOpacity(0.4),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No ${_showLiked ? 'liked' : 'saved'} content yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      DreamTheme.moonGlow.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Explore and find stories you love!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      DreamTheme.starYellow.withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: content.length,
                      itemBuilder: (context, index) => ContentCard(
                        content: content[index],
                      ),
                    ),
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DreamTheme.primaryPurple,
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load favorites',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DreamTheme.moonGlow.withOpacity(0.7),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
