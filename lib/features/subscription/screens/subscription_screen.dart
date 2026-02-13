import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/subscription/widgets/tier_comparison_card.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load subscription tier from provider
    const currentTier = 'Free';

    final tiers = [
      {
        'name': 'Free',
        'price': '\$0',
        'period': '/month',
        'isCurrent': currentTier == 'Free',
        'isPopular': false,
        'features': [
          '1 story per day',
          '10 favorites',
          '3 basic voices',
          'Standard content library',
        ],
      },
      {
        'name': 'Premium',
        'price': '\$9.99',
        'period': '/month',
        'isCurrent': currentTier == 'Premium',
        'isPopular': true,
        'features': [
          '5 stories per day',
          '50 favorites',
          'All voices',
          'Background music',
          'Ad-free experience',
          'Priority generation',
        ],
      },
      {
        'name': 'Unlimited',
        'price': '\$19.99',
        'period': '/month',
        'isCurrent': currentTier == 'Unlimited',
        'isPopular': false,
        'features': [
          'Unlimited stories',
          'Unlimited favorites',
          'All voices & accents',
          'Premium background music',
          'Offline downloads',
          'Priority generation',
          'Family sharing (5 kids)',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Unlock More Dreams'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tier cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tiers.map((tier) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TierComparisonCard(
                        name: tier['name'] as String,
                        price: tier['price'] as String,
                        period: tier['period'] as String,
                        isCurrent: tier['isCurrent'] as bool,
                        isPopular: tier['isPopular'] as bool,
                        features:
                            List<String>.from(tier['features'] as List),
                        onUpgrade: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Upgrading to ${tier['name']}...',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Feature comparison table
              _buildFeatureComparison(context),

              const SizedBox(height: 32),

              // FAQ section
              _buildFAQSection(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparison(BuildContext context) {
    final features = [
      'Stories per day',
      'Favorites',
      'Voice options',
      'Background music',
      'Offline downloads',
      'Priority generation',
      'Family sharing',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature Comparison',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: features.map((feature) {
              return _buildComparisonRow(feature);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _buildCheckmark(false),
          ),
          Expanded(
            child: _buildCheckmark(true),
          ),
          Expanded(
            child: _buildCheckmark(true),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckmark(bool included) {
    return Center(
      child: Icon(
        included ? Icons.check_circle : Icons.cancel,
        color: included ? Colors.green : Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': 'Can I change my plan anytime?',
        'answer': 'Yes! You can upgrade or downgrade your plan at any time.',
      },
      {
        'question': 'Is there a free trial?',
        'answer': 'Yes, Premium plans include a 7-day free trial.',
      },
      {
        'question': 'What payment methods do you accept?',
        'answer':
            'We accept all major credit cards, Apple Pay, and Google Pay.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Column(
          children: faqs.map((faq) {
            return ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(color: Colors.white),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['answer']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
