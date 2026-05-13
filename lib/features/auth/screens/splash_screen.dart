import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/routing/route_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Show splash for minimum 2.5s, then navigate based on auth state
    Future.delayed(const Duration(milliseconds: 2500), () {
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    // No login required — go straight to home, just like the web app
    context.go(Routes.home);
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
              DreamTheme.deepNight.withOpacity(0.8),
              const Color(0xFF2d1b4e),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated star particles
            Positioned.fill(
              child: CustomPaint(
                painter: StarParticlesPainter(),
              ),
            ),
            // Center content — matches web app onboarding step 0
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo image (same as web app onboarding)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: DreamTheme.primaryPurple.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: const Duration(milliseconds: 3000),
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.05, 1.05),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: const Duration(milliseconds: 3000),
                          begin: const Offset(1.05, 1.05),
                          end: const Offset(0.95, 0.95),
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 32),
                    // Subtitle — matches web app
                    Text(
                      'Where magical bedtime stories come alive',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: DreamTheme.starYellow.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            fontSize: 18,
                          ),
                    )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 800),
                        ),
                    const SizedBox(height: 16),
                    // Description — matches web app
                    Text(
                      'Beautiful stories, poems & songs to help your little ones drift off to dreamland',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DreamTheme.moonGlow.withOpacity(0.5),
                            fontSize: 14,
                            height: 1.6,
                          ),
                    )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 800),
                        ),
                    const SizedBox(height: 60),
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          DreamTheme.primaryPurple,
                        ),
                        strokeWidth: 3,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 1200),
                          duration: const Duration(milliseconds: 600),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = DreamTheme.starYellow.withOpacity(0.6);

    // Draw random stars
    final random = DateTime.now().millisecond;
    for (int i = 0; i < 50; i++) {
      final x = (random * 31 + i * 17) % size.width;
      final y = (random * 37 + i * 19) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(StarParticlesPainter oldDelegate) => true;
}
