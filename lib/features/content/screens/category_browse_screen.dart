import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/content/widgets/album_art_display.dart';
import 'package:dreamweaver/widgets/common/dream_app_bar.dart';

class CategoryBrowseScreen extends ConsumerWidget {
  final String categoryName;
  final String? categoryDescription;

  const CategoryBrowseScreen({
    Key? key,
    required this.categoryName,
    this.categoryDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load filtered content from provider
    final contentList = _getMockContentList();

    return Scaffold(
      appBar: DreamAppBar(
        title: categoryName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Category description
            if (categoryDescription != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    categoryDescription!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.6,
                        ),
                  ),
                ),
              ),

            // Content grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final content = contentList[index];
                    return _buildContentCard(context, content);
                  },
                  childCount: contentList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, Map<String, dynamic> content) {
    return GestureDetector(
      onTap: () {
        // Navigate to content detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AlbumArtDisplay(
              url: content['imageUrl'] ?? '',
              contentType: content['type'] ?? 'story',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content['title'] ?? 'Untitled',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            content['author'] ?? 'Unknown',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockContentList() {
    return List.generate(
      8,
      (index) => {
        'id': 'content_$index',
        'title': '$categoryName Story ${index + 1}',
        'author': 'Story Author ${index + 1}',
        'type': 'story',
        'imageUrl': 'https://via.placeholder.com/300x300',
      },
    );
  }
}
