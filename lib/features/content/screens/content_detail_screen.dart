import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/content/widgets/album_art_display.dart';
import 'package:dreamweaver/widgets/common/content_type_badge.dart';
import 'package:dreamweaver/widgets/common/dream_app_bar.dart';

class ContentDetailScreen extends ConsumerWidget {
  final String contentId;
  final String? heroTag;

  const ContentDetailScreen({
    Key? key,
    required this.contentId,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load content from provider
    final content = _getMockContent();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DreamAppBar(
        title: '',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero album art
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(24),
                child: Hero(
                  tag: heroTag ?? contentId,
                  child: AlbumArtDisplay(
                    url: content['imageUrl'] ?? '',
                    contentType: content['type'] ?? 'story',
                    hasGlow: true,
                  ),
                ),
              ),
            ),
          ),

          // Content details
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      content['title'] ?? 'Untitled',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Author
                    Text(
                      'By ${content['author'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Category tags
                    Wrap(
                      spacing: 8,
                      children: [
                        ContentTypeBadge(
                          type: content['type'] ?? 'story',
                        ),
                        ...((content['categories'] as List<String>?) ?? [])
                            .map((category) => Chip(
                              label: Text(category),
                              backgroundColor:
                                  DreamTheme.primary.withOpacity(0.3),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ))
                            .toList(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Age badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: DreamTheme.accent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Suitable for age ${content['minAge'] ?? 2}+',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: DreamTheme.accent,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Like and Save buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          icon: Icons.favorite_border,
                          label: 'Like',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 24),
                        _buildIconButton(
                          icon: Icons.bookmark_border,
                          label: 'Save',
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content['description'] ?? 'No description available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Text preview (if available)
                    if (content['textPreview'] != null) ...[
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content['textPreview'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.6,
                                  ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Read more',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: DreamTheme.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Play button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to player
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DreamTheme.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Play Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customize & Play button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to customization
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: DreamTheme.accent,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Customize & Play',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DreamTheme.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: Colors.white.withOpacity(0.7),
          iconSize: 28,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getMockContent() {
    return {
      'id': contentId,
      'title': 'The Magical Forest',
      'author': 'Sarah Johnson',
      'type': 'story',
      'description':
          'Join Luna on an enchanting adventure through a magical forest filled with friendly creatures and sparkling surprises. A perfect bedtime story for children ages 3-8.',
      'textPreview':
          'Once upon a time, in a forest where the trees sparkled with starlight and the flowers hummed gentle lullabies...',
      'imageUrl': 'https://via.placeholder.com/400x400',
      'categories': ['Fantasy', 'Adventure'],
      'minAge': 3,
    };
  }
}
