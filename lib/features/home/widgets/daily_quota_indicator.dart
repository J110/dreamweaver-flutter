import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class DailyQuotaIndicator extends StatelessWidget {
  final int used;
  final int total;

  const DailyQuotaIndicator({
    Key? key,
    required this.used,
    required this.total,
  }) : super(key: key);

  Color _getColorForQuota() {
    final percentage = (used / total) * 100;
    if (percentage >= 100) {
      return Colors.red.shade400;
    } else if (percentage >= 80) {
      return Colors.amber.shade400;
    } else {
      return DreamTheme.primaryPurple;
    }
  }

  bool _isQuotaExhausted() => used >= total;

  @override
  Widget build(BuildContext context) {
    final color = _getColorForQuota();
    final isExhausted = _isQuotaExhausted();
    final percentage = used / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Stories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DreamTheme.moonGlow.withOpacity(0.7),
                  ),
            ),
            Text(
              '$used/$total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DreamTheme.moonGlow.withOpacity(0.1),
                ),
              ),
              // Progress circle
              CircularProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$used',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'of $total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DreamTheme.moonGlow.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isExhausted)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Upgrade to generate more stories!'),
                    backgroundColor: DreamTheme.primaryPurple,
                    action: SnackBarAction(
                      label: 'Learn More',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/upgrade');
                      },
                    ),
                  ),
                );
              },
              child: Text(
                'Upgrade for more stories',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.orange.shade300,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
