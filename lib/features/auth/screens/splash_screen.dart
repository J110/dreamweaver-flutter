import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Auto-navigate after 2.5 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        authState.when(
          loading: () {},
          authenticated: (_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          unauthenticated: () {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          error: (error) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        );
      });
    });

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
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Crescent moon icon
                  Icon(
                    Icons.nights_stay_rounded,
                    size: 80,
                    color: DreamTheme.moonGlow,
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: const Duration(milliseconds: 2000),
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                      )
                      .then()
                      .scale(
                        duration: const Duration(milliseconds: 2000),
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(0.9, 0.9),
                      ),
                  const SizedBox(height: 24),
                  // App name with glow
                  Text(
                    'DreamWeaver',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: DreamTheme.moonGlow,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                          letterSpacing: 2,
                        ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(
                        duration: const Duration(milliseconds: 1500),
                      )
                      .then()
                      .fadeOut(
                        duration: const Duration(milliseconds: 1500),
                      ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    'Where dreams come alive',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: DreamTheme.starYellow.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 500)),
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
                  ),
                ],
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
