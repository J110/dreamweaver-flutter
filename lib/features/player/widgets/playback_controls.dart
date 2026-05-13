import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class PlaybackControls extends StatefulWidget {
  final bool isPlaying;
  final bool hasPlaylist;
  final VoidCallback onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final int repeatMode; // 0: off, 1: all, 2: one
  final Function(int) onRepeatChanged;

  const PlaybackControls({
    Key? key,
    required this.isPlaying,
    required this.hasPlaylist,
    required this.onPlayPause,
    this.onNext,
    this.onPrevious,
    required this.repeatMode,
    required this.onRepeatChanged,
  }) : super(key: key);

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PlaybackControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous button
        if (widget.hasPlaylist)
          _buildControlButton(
            icon: Icons.skip_previous,
            onPressed: widget.onPrevious,
          )
        else
          SizedBox(width: 56),

        // Skip backward 15s
        _buildSmallControlButton(
          icon: Icons.replay_10,
          onPressed: () {},
          size: 40,
        ),

        // Play/Pause button (large center)
        _buildPlayPauseButton(),

        // Skip forward 15s
        _buildSmallControlButton(
          icon: Icons.forward_10,
          onPressed: () {},
          size: 40,
        ),

        // Next button
        if (widget.hasPlaylist)
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: widget.onNext,
          )
        else
          SizedBox(width: 56),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: widget.onPlayPause,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              DreamTheme.primary,
              DreamTheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: DreamTheme.primary.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            key: ValueKey(widget.isPlaying),
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.white.withOpacity(0.8),
      iconSize: 32,
      onPressed: onPressed,
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: size,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
