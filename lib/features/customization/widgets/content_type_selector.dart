import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class ContentTypeSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const ContentTypeSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  final List<Map<String, dynamic>> _contentTypes = const [
    {
      'name': 'Story',
      'icon': Icons.book,
      'description': 'Full narrative tale',
    },
    {
      'name': 'Poem',
      'icon': Icons.feather_pen_outlined,
      'description': 'Lyrical poem',
    },
    {
      'name': 'Song',
      'icon': Icons.music_note,
      'description': 'Musical piece',
    },
    {
      'name': 'Mixed',
      'icon': Icons.auto_awesome,
      'description': 'Everything combined',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _contentTypes.map((type) {
        final isSelected = selected == type['name'];
        return GestureDetector(
          onTap: () => onChanged(type['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? DreamTheme.accent
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? DreamTheme.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: DreamTheme.accent.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'],
                  size: 28,
                  color: isSelected ? DreamTheme.accent : Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  type['name'],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? DreamTheme.accent : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  type['description'],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 9,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
