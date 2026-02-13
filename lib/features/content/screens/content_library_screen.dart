import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/content/widgets/album_art_display.dart';
import 'package:dreamweaver/widgets/common/dream_app_bar.dart';
import 'package:dreamweaver/widgets/common/empty_state.dart';
import 'package:dreamweaver/widgets/common/loading_indicator.dart';

class ContentLibraryScreen extends ConsumerStatefulWidget {
  const ContentLibraryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContentLibraryScreen> createState() =>
      _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends ConsumerState<ContentLibraryScreen> {
  late ScrollController _scrollController;
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  int _currentPage = 0;

  final List<String> _filters = ['All', 'Stories', 'Poems', 'Songs'];
  final List<String> _sortOptions = ['Newest', 'Most Popular', 'Duration'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load next page
      setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Load content from provider
    final contentList = _getMockContentList();

    return Scaffold(
      appBar: DreamAppBar(
        title: 'Dream Library',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search stories, poems, songs...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedFilter = filter);
                                }
                              },
                              backgroundColor:
                                  Colors.white.withOpacity(0.1),
                              selectedColor:
                                  DreamTheme.primary.withOpacity(0.3),
                              labelStyle: TextStyle(
                                color: _selectedFilter == filter
                                    ? DreamTheme.accent
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Sort dropdown
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.sort,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onSelected: (value) {
                      setState(() => _selectedSort = value);
                    },
                    itemBuilder: (BuildContext context) {
                      return _sortOptions.map((option) {
                        return PopupMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content grid
            Expanded(
              child: contentList.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No Content Found',
                      description: 'Try adjusting your filters or search terms',
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: contentList.length,
                      itemBuilder: (context, index) {
                        final content = contentList[index];
                        return _buildContentCard(context, content);
                      },
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
      12,
      (index) => {
        'id': 'content_$index',
        'title': 'The Magical Forest ${index + 1}',
        'author': 'Story Author ${index + 1}',
        'type': ['story', 'poem', 'song'][index % 3],
        'imageUrl': 'https://via.placeholder.com/300x300',
      },
    );
  }
}
