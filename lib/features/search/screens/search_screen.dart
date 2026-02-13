import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/content/widgets/album_art_display.dart';
import 'package:dreamweaver/widgets/common/content_type_badge.dart';
import 'package:dreamweaver/widgets/common/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  List<String> _recentSearches = ['Magical forest', 'Dinosaurs', 'Ocean'];
  String _selectedTypeFilter = 'All';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }

    // TODO: Perform actual search from provider
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _searchResults = _getMockSearchResults(query);
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search for stories, poems, and songs',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                            setState(() {});
                          },
                        )
                      : null,
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

            // Type filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Stories', 'Poems', 'Songs']
                      .map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type),
                            selected: _selectedTypeFilter == type,
                            onSelected: (selected) {
                              setState(() => _selectedTypeFilter = type);
                            },
                            backgroundColor:
                                Colors.white.withOpacity(0.1),
                            selectedColor:
                                DreamTheme.primary.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: _selectedTypeFilter == type
                                  ? DreamTheme.accent
                                  : Colors.white,
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content area
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentSearches(context)
                  : _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DreamTheme.accent,
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off,
                              title: 'No Results Found',
                              description:
                                  'Try different keywords or check your filters',
                            )
                          : _buildSearchResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: DreamTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final content = _searchResults[index];
        return _buildContentCard(context, content);
      },
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
            child: Stack(
              children: [
                AlbumArtDisplay(
                  url: content['imageUrl'] ?? '',
                  contentType: content['type'] ?? 'story',
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ContentTypeBadge(
                    type: content['type'] ?? 'story',
                  ),
                ),
              ],
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

  List<Map<String, dynamic>> _getMockSearchResults(String query) {
    return List.generate(
      6,
      (index) => {
        'id': 'search_result_$index',
        'title': '$query Story ${index + 1}',
        'author': 'Story Author ${index + 1}',
        'type': ['story', 'poem', 'song'][index % 3],
        'imageUrl': 'https://via.placeholder.com/300x300',
      },
    );
  }
}
