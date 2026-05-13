import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/content_provider.dart';
import 'package:dreamweaver/providers/trending_provider.dart';
import 'package:dreamweaver/providers/user_provider.dart';
import 'package:dreamweaver/features/home/widgets/trending_carousel.dart';
import 'package:dreamweaver/features/home/widgets/daily_quota_indicator.dart';
import 'package:dreamweaver/features/home/widgets/content_card.dart';

class TrendingTab extends ConsumerWidget {
  const TrendingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);
    final trendingContentAsyncValue = ref.watch(trendingContentProvider);
    final currentHour = DateTime.now().hour;
    final greeting = currentHour < 12
        ? 'Good Morning'
        : currentHour < 18
            ? 'Good Afternoon'
            : 'Good Evening';

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(trendingContentProvider);
      },
      backgroundColor: DreamTheme.primaryPurple,
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Greeting
                    userAsyncValue.when(
                      data: (user) => Text(
                        '$greeting, ${user.username}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: DreamTheme.moonGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                      ),
                      loading: () => Text(
                        '$greeting, Dreamer!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: DreamTheme.moonGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                      ),
                      error: (_, __) => Text(
                        '$greeting, Dreamer!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: DreamTheme.moonGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Daily quota
                    userAsyncValue.when(
                      data: (user) => DailyQuotaIndicator(
                        used: user.dailyStoriesUsed,
                        total: user.dailyStoriesLimit,
                      ),
                      loading: () => const DailyQuotaIndicator(used: 0, total: 5),
                      error: (_, __) =>
                          const DailyQuotaIndicator(used: 0, total: 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Trending carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: trendingContentAsyncValue.when(
                data: (content) => TrendingCarousel(trendingItems: content),
                loading: () => const SizedBox(
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'Failed to load trending',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DreamTheme.moonGlow.withOpacity(0.7),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Categories section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: DreamTheme.moonGlow,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Fantasy',
                        'Adventure',
                        'Fairy Tales',
                        'Magic',
                        'Bedtime',
                      ]
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(category),
                                backgroundColor:
                                    DreamTheme.primaryPurple.withOpacity(0.3),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: DreamTheme.starYellow,
                                    ),
                                side: BorderSide(
                                  color: DreamTheme.primaryPurple
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            sliver: trendingContentAsyncValue.when(
              data: (content) => SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ContentCard(
                    content: content[index],
                  ),
                  childCount: content.length,
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DreamTheme.primaryPurple,
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      'Failed to load content',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DreamTheme.moonGlow.withOpacity(0.7),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}
