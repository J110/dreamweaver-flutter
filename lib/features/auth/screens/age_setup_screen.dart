import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/user_provider.dart';
import 'package:dreamweaver/features/auth/widgets/magic_button.dart';
import 'package:dreamweaver/routing/route_constants.dart';

class AgeSetupScreen extends ConsumerStatefulWidget {
  const AgeSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AgeSetupScreen> createState() => _AgeSetupScreenState();
}

class _AgeSetupScreenState extends ConsumerState<AgeSetupScreen> {
  late int _selectedAge = 5;
  bool _isLoading = false;

  String _getAgeGroupEmoji(int age) {
    if (age >= 0 && age <= 2) return '👶';
    if (age >= 3 && age <= 7) return '👧';
    return '👦';
  }

  String _getAgeGroupLabel(int age) {
    if (age >= 0 && age <= 2) return 'Baby Dreamer';
    if (age >= 3 && age <= 7) return 'Little Dreamer';
    return 'Young Dreamer';
  }

  Future<void> _saveAge() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(userProvider.notifier).updateChildAge(_selectedAge);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Age saved! Let\'s start dreaming!'),
            backgroundColor: DreamTheme.primaryPurple,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DreamTheme.deepNight,
              const Color(0xFF1a0f2e),
              const Color(0xFF2d1b4e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _isLoading ? null : () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: DreamTheme.moonGlow,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        'How old is your\nlittle dreamer?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: DreamTheme.moonGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Age helps us create perfect stories',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color:
                                      DreamTheme.starYellow.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                      ),
                      const SizedBox(height: 60),
                      // Age emoji and label
                      Column(
                        children: [
                          Text(
                            _getAgeGroupEmoji(_selectedAge),
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getAgeGroupLabel(_selectedAge),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: DreamTheme.primaryPink,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Age display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DreamTheme.primaryPurple.withOpacity(0.3),
                              DreamTheme.primaryPink.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DreamTheme.moonGlow.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _selectedAge.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: DreamTheme.starYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 72,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'year${_selectedAge != 1 ? 's' : ''} old',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: DreamTheme.moonGlow
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Slider
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape: RoundSliderThumbShape(
                                elevation: 4,
                                enabledThumbRadius: 14,
                              ),
                              activeTrackColor: DreamTheme.primaryPurple,
                              inactiveTrackColor:
                                  DreamTheme.moonGlow.withOpacity(0.2),
                              thumbColor: DreamTheme.starYellow,
                            ),
                            child: Slider(
                              value: _selectedAge.toDouble(),
                              min: 0,
                              max: 14,
                              divisions: 14,
                              onChanged: _isLoading
                                  ? null
                                  : (value) =>
                                      setState(() => _selectedAge = value.toInt()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: DreamTheme.moonGlow
                                            .withOpacity(0.5),
                                      ),
                                ),
                                Text(
                                  '14',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: DreamTheme.moonGlow
                                            .withOpacity(0.5),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              // Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: MagicButton(
                    onPressed: _saveAge,
                    text: 'Start Dreaming',
                    isLoading: _isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
