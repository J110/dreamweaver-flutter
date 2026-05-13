import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class ContentTypeBadge extends StatelessWidget {
  final String type;

  const ContentTypeBadge({
    Key? key,
    required this.type,
  }) : super(key: key);

  Map<String, dynamic> _getTypeConfig() {
    switch (type.toLowerCase()) {
      case 'poem':
        return {
          'label': 'Poem',
          'icon': Icons.edit_outlined,
          'color': Colors.pink,
        };
      case 'song':
        return {
          'label': 'Song',
          'icon': Icons.music_note,
          'color': Colors.teal,
        };
      case 'story':
      default:
        return {
          'label': 'Story',
          'icon': Icons.book,
          'color': DreamTheme.primary,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig();
    final color = config['color'] as Color;
    final icon = config['icon'] as IconData;
    final label = config['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
