import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class AgeSelector extends StatefulWidget {
  final int currentAge;
  final ValueChanged<int> onChanged;

  const AgeSelector({
    Key? key,
    required this.currentAge,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  late int _displayAge;

  @override
  void initState() {
    super.initState();
    _displayAge = widget.currentAge;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Large age display with glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DreamTheme.primaryLight.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: DreamTheme.accentPurple.withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            // Number circle background
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DreamTheme.accentPurple.withOpacity(0.3),
                    DreamTheme.accentPurple.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: DreamTheme.primaryLight.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            // Age number
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _displayAge.toString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: DreamTheme.primaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 100,
                      ),
                ),
                Text(
                  'years old',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DreamTheme.primaryLight.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 60),
        // Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8.0,
                  activeTrackColor: DreamTheme.primaryLight.withOpacity(0.8),
                  inactiveTrackColor: DreamTheme.darkBlue.withOpacity(0.5),
                  thumbColor: DreamTheme.primaryLight,
                  overlayColor: DreamTheme.primaryLight.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    elevation: 4.0,
                    enabledThumbRadius: 14.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 28.0,
                  ),
                ),
                child: Slider(
                  value: _displayAge.toDouble(),
                  min: 0,
                  max: 14,
                  divisions: 14,
                  onChanged: (value) {
                    setState(() {
                      _displayAge = value.toInt();
                    });
                    widget.onChanged(_displayAge);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Age range labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    Text(
                      '7',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    Text(
                      '14',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
