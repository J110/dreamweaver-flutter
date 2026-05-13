import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/models/content_model.dart';
import 'package:dreamweaver/routing/route_constants.dart';

class ContentCard extends StatefulWidget {
  final Content content;

  const ContentCard({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.contentDetailPath(widget.content.id));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
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
                child: widget.content.albumArtUrl.isNotEmpty
                    ? Image.network(
                        widget.content.albumArtUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
              // Content overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content details
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section - badge
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DreamTheme.primaryPurple.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.content.displayLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Bottom section - title and metadata
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.content.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.content.duration} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: DreamTheme.starYellow
                                          .withOpacity(0.8),
                                    ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _isLiked = !_isLiked),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_outline_rounded,
                                      color: _isLiked
                                          ? Colors.red
                                          : DreamTheme.moonGlow
                                              .withOpacity(0.6),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.content.likeCount.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: DreamTheme.moonGlow
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
