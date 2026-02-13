import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class TierComparisonCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final bool isCurrent;
  final bool isPopular;
  final List<String> features;
  final VoidCallback onUpgrade;

  const TierComparisonCard({
    Key? key,
    required this.name,
    required this.price,
    required this.period,
    required this.isCurrent,
    required this.isPopular,
    required this.features,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? DreamTheme.accent
              : isCurrent
                  ? DreamTheme.primary
                  : Colors.white.withOpacity(0.2),
          width: isPopular || isCurrent ? 2 : 1,
        ),
        color: isPopular
            ? DreamTheme.primary.withOpacity(0.2)
            : isCurrent
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.02),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: DreamTheme.accent.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular badge
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DreamTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Current plan badge
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DreamTheme.primary.withOpacity(0.3),
                border: Border.all(color: DreamTheme.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Current Plan',
                style: TextStyle(
                  color: DreamTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Tier name
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          // Price
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: DreamTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(
                  text: period,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrent ? Colors.white.withOpacity(0.1) : DreamTheme.accent,
                foregroundColor: isCurrent ? Colors.white : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isCurrent ? 'Current Plan' : 'Upgrade Now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Features
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: DreamTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
