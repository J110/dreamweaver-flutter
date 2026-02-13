import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/user_provider.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  void _showAgeEditDialog(BuildContext context, WidgetRef ref, int currentAge) {
    int tempAge = currentAge;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: DreamTheme.deepNight,
          title: Text(
            'Edit Child Age',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DreamTheme.moonGlow,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempAge.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: DreamTheme.starYellow,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    onPressed: tempAge > 0
                        ? () => setState(() => tempAge--)
                        : null,
                    backgroundColor: DreamTheme.primaryPurple,
                    child: const Icon(Icons.remove),
                  ),
                  FloatingActionButton.small(
                    onPressed: tempAge < 14
                        ? () => setState(() => tempAge++)
                        : null,
                    backgroundColor: DreamTheme.primaryPink,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: DreamTheme.moonGlow,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(userProvider.notifier).updateChildAge(tempAge);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: DreamTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            userAsyncValue.when(
              data: (user) => Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DreamTheme.primaryPurple,
                          DreamTheme.primaryPink,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DreamTheme.primaryPurple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.username.characters.first.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Username
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: DreamTheme.moonGlow,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Subscription badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DreamTheme.primaryPurple.withOpacity(0.3),
                          DreamTheme.primaryPink.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DreamTheme.starYellow.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: DreamTheme.starYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.subscriptionTier,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: DreamTheme.starYellow,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Child age section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DreamTheme.moonGlow.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DreamTheme.moonGlow.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Little Dreamer',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: DreamTheme.moonGlow
                                        .withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.childAge} years old',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: DreamTheme.starYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showAgeEditDialog(context, ref, user.childAge),
                          child: Icon(
                            Icons.edit_rounded,
                            color: DreamTheme.primaryPurple,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Stats section
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.auto_stories_rounded,
                          title: 'Stories',
                          value: user.storiesGenerated.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite_rounded,
                          title: 'Favorites',
                          value: user.favoriteCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today_rounded,
                          title: 'Active Days',
                          value: user.daysActive.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Settings button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Settings coming soon!'),
                            backgroundColor: DreamTheme.primaryPurple,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: DreamTheme.moonGlow.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: DreamTheme.moonGlow,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushReplacementNamed('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red.shade600.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DreamTheme.primaryPurple,
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DreamTheme.moonGlow.withOpacity(0.7),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DreamTheme.moonGlow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DreamTheme.moonGlow.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: DreamTheme.primaryPurple,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: DreamTheme.starYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: DreamTheme.moonGlow.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}
