import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class BackgroundMusicToggle extends StatefulWidget {
  final bool isEnabled;
  final double volume;
  final Function(bool) onToggle;
  final Function(double) onVolumeChanged;

  const BackgroundMusicToggle({
    Key? key,
    required this.isEnabled,
    required this.volume,
    required this.onToggle,
    required this.onVolumeChanged,
  }) : super(key: key);

  @override
  State<BackgroundMusicToggle> createState() => _BackgroundMusicToggleState();
}

class _BackgroundMusicToggleState extends State<BackgroundMusicToggle> {
  bool _showMusicTypes = false;
  String _selectedMusicType = 'Ambient';

  final List<String> _musicTypes = ['Ambient', 'Lullaby', 'Nature', 'Rain'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            Icons.music_note,
            color: widget.isEnabled
                ? DreamTheme.accent
                : Colors.white.withOpacity(0.5),
          ),
          onPressed: () {
            widget.onToggle(!widget.isEnabled);
            if (!widget.isEnabled) {
              setState(() => _showMusicTypes = true);
            }
          },
        ),
        if (widget.isEnabled)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: Slider(
                  value: widget.volume,
                  onChanged: widget.onVolumeChanged,
                  activeColor: DreamTheme.accent,
                  inactiveColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Text(
                '${(widget.volume * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        if (_showMusicTypes && widget.isEnabled)
          const SizedBox(height: 8),
        if (_showMusicTypes && widget.isEnabled)
          Wrap(
            spacing: 8,
            children: _musicTypes.map((type) {
              return FilterChip(
                label: Text(type),
                selected: _selectedMusicType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedMusicType = type);
                  }
                },
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: DreamTheme.accent.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: _selectedMusicType == type
                      ? DreamTheme.accent
                      : Colors.white,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
