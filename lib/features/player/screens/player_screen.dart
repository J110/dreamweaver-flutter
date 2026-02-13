import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/audio_player_provider.dart';
import 'package:dreamweaver/features/player/widgets/playback_controls.dart';
import 'package:dreamweaver/features/player/widgets/progress_bar.dart';
import 'package:dreamweaver/features/player/widgets/background_music_toggle.dart';
import 'package:dreamweaver/widgets/common/loading_indicator.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String contentId;
  final String? textContent;

  const PlayerScreen({
    Key? key,
    required this.contentId,
    this.textContent,
  }) : super(key: key);

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _starfieldController;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _starfieldController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _starfieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);

    return audioState.when(
      data: (player) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: Navigator.of(context).pop,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: player.isFavorite
                      ? DreamTheme.accent
                      : Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  // Toggle favorite
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Animated starfield background
              _buildStarfield(),

              // Night sky gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DreamTheme.primaryDark.withOpacity(0.8),
                      DreamTheme.primary.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Now Playing header
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Now Playing',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),

                    // Album art with glow
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 32,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: DreamTheme.primary.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: DreamTheme.secondary.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: player.contentImageUrl ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      DreamTheme.primary,
                                      DreamTheme.secondary,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            player.contentTitle ?? 'Unknown Title',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            player.contentType.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: DreamTheme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ProgressBar(
                        currentPosition: player.position,
                        totalDuration: player.duration,
                        bufferedPosition: player.bufferedPosition,
                        onSeek: (position) {
                          // Seek audio
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Playback controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: PlaybackControls(
                        isPlaying: player.isPlaying,
                        hasPlaylist: player.hasPlaylist,
                        onPlayPause: () {
                          if (player.isPlaying) {
                            // Pause
                          } else {
                            // Play
                          }
                        },
                        onNext: player.hasPlaylist ? () {} : null,
                        onPrevious: player.hasPlaylist ? () {} : null,
                        repeatMode: player.repeatMode,
                        onRepeatChanged: (mode) {
                          // Change repeat mode
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Background music & voice controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BackgroundMusicToggle(
                            isEnabled: player.backgroundMusicEnabled,
                            volume: player.backgroundMusicVolume,
                            onToggle: (enabled) {},
                            onVolumeChanged: (volume) {},
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.speed),
                                color: Colors.white.withOpacity(0.7),
                                onPressed: () {
                                  // Show speed selector
                                },
                              ),
                              Text(
                                '${player.speechSpeed.toStringAsFixed(1)}x',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                color: Colors.white.withOpacity(0.7),
                                onPressed: () {
                                  // Show volume slider
                                },
                              ),
                              SizedBox(
                                width: 40,
                                height: 20,
                                child: Slider(
                                  value: player.volume,
                                  onChanged: (value) {},
                                  activeColor: DreamTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Text content toggle (if available)
                    if (widget.textContent != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _showText = !_showText);
                          },
                          icon: Icon(_showText
                              ? Icons.unfold_less
                              : Icons.unfold_more),
                          label: Text(_showText ? 'Hide Text' : 'Show Text'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DreamTheme.secondary
                                .withOpacity(0.3),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Text content overlay
              if (_showText && widget.textContent != null)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _showText = false);
                          },
                        ),
                        title: const Text('Story Text'),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.textContent!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  height: 1.6,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DreamTheme.primaryDark,
                DreamTheme.primary,
              ],
            ),
          ),
          child: const Center(
            child: LoadingIndicator(size: LoadingSize.large),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildStarfield() {
    return AnimatedBuilder(
      animation: _starfieldController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(
            progress: _starfieldController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double progress;

  StarfieldPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5;

    // Create a pseudo-random starfield
    final random = List.generate(50, (index) {
      return (
        x: (index * 37 % 100) / 100 * size.width,
        y: (index * 73 % 100) / 100 * size.height,
        opacity: ((index * 11) % 100) / 100,
      );
    });

    for (final star in random) {
      final opacity = (star.opacity + progress) % 1.0;
      canvas.drawCircle(
        Offset(star.x, star.y),
        2 + (opacity * 1.5),
        paint..color = Colors.white.withOpacity(opacity * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}
