import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class LengthSlider extends StatefulWidget {
  final String selectedLength;
  final Function(String) onChanged;

  const LengthSlider({
    Key? key,
    required this.selectedLength,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LengthSlider> createState() => _LengthSliderState();
}

class _LengthSliderState extends State<LengthSlider> {
  late int _currentValue;

  final List<String> _lengths = ['Short', 'Medium', 'Long'];
  final List<String> _durations = ['2-3 min', '5-7 min', '10-15 min'];
  final List<IconData> _moonPhases = [
    Icons.circle_outlined,
    Icons.circle,
    Icons.circle,
  ];

  @override
  void initState() {
    super.initState();
    _currentValue = _lengths.indexOf(widget.selectedLength);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
            ),
            thumbColor: DreamTheme.accent,
            activeTrackColor: DreamTheme.primary,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            overlayColor: DreamTheme.accent.withOpacity(0.3),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16,
            ),
          ),
          child: Slider(
            value: _currentValue.toDouble(),
            min: 0,
            max: 2,
            divisions: 2,
            onChanged: (value) {
              setState(() {
                _currentValue = value.toInt();
                widget.onChanged(_lengths[_currentValue]);
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final isSelected = index == _currentValue;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentValue = index;
                  widget.onChanged(_lengths[_currentValue]);
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? DreamTheme.primary.withOpacity(0.3)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? DreamTheme.accent
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _moonPhases[index],
                          size: 24,
                          color: isSelected
                              ? DreamTheme.accent
                              : Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lengths[index],
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isSelected
                                    ? DreamTheme.accent
                                    : Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _durations[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
