import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/models/content_model.dart';
import 'package:dreamweaver/routing/route_constants.dart';

class TrendingCarousel extends StatefulWidget {
  final List<Content> trendingItems;

  const TrendingCarousel({
    Key? key,
    required this.trendingItems,
  }) : super(key: key);

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page?.round() ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.trendingItems.length,
            itemBuilder: (context, index) {
              final content = widget.trendingItems[index];
              return GestureDetector(
                onTap: () {
                  context.push(Routes.contentDetailPath(content.id));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: DreamTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image or gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                DreamTheme.primaryPurple.withOpacity(0.6),
                                DreamTheme.primaryPink.withOpacity(0.4),
                              ],
                            ),
                          ),
                          child: content.albumArtUrl.isNotEmpty
                              ? Image.network(
                                  content.albumArtUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                        ),
                        // Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                content.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: DreamTheme.starYellow
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      content.displayLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: DreamTheme.deepNight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${content.duration} min',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dot indicators
        SizedBox(
          height: 8,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.trendingItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? DreamTheme.starYellow
                    : DreamTheme.moonGlow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Trending header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Now',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: DreamTheme.moonGlow,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              GestureDetector(
                onTap: () => context.push(Routes.contentLibrary),
                child: Text(
                  'See All',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: DreamTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
