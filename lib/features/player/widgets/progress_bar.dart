import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class ProgressBar extends StatefulWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration bufferedPosition;
  final Function(Duration) onSeek;

  const ProgressBar({
    Key? key,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    required this.onSeek,
  }) : super(key: key);

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late Duration _draggedPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _draggedPosition = widget.currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalDuration.inMilliseconds > 0
        ? widget.currentPosition.inMilliseconds /
            widget.totalDuration.inMilliseconds
        : 0.0;

    final buffered = widget.totalDuration.inMilliseconds > 0
        ? widget.bufferedPosition.inMilliseconds /
            widget.totalDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 4,
            ),
            thumbColor: DreamTheme.accent,
            activeTrackColor: DreamTheme.primary,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            overlayColor: DreamTheme.accent.withOpacity(0.3),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16,
            ),
          ),
          child: Stack(
            children: [
              // Buffered position indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: buffered,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              // Main slider
              Slider(
                value: _isDragging
                    ? _draggedPosition.inMilliseconds.toDouble()
                    : progress * widget.totalDuration.inMilliseconds,
                max: widget.totalDuration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _isDragging = true;
                    _draggedPosition =
                        Duration(milliseconds: value.toInt());
                  });
                },
                onChangeEnd: (value) {
                  widget.onSeek(_draggedPosition);
                  setState(() => _isDragging = false);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(
                  _isDragging
                      ? _draggedPosition
                      : widget.currentPosition,
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
              Text(
                _formatDuration(widget.totalDuration),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours == 0) {
      return '$minutes:$seconds';
    }
    return '$hours:$minutes:$seconds';
  }
}
