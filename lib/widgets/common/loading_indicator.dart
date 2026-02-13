import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatefulWidget {
  final LoadingSize size;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.message,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _moonController;
  late AnimationController _starsController;

  @override
  void initState() {
    super.initState();
    _moonController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _starsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _moonController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  double _getSize() {
    switch (widget.size) {
      case LoadingSize.small:
        return 40;
      case LoadingSize.medium:
        return 80;
      case LoadingSize.large:
        return 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getSize(),
            height: _getSize(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbiting stars
                AnimatedBuilder(
                  animation: _starsController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _starsController.value * 2 * 3.14159,
                      child: CustomPaint(
                        painter: OrbitalStarsPainter(
                          size: _getSize(),
                        ),
                        size: Size(_getSize(), _getSize()),
                      ),
                    );
                  },
                ),

                // Moon
                AnimatedBuilder(
                  animation: _moonController,
                  builder: (context, child) {
                    final offset = (_moonController.value - 0.5).abs() * 20;
                    return Transform.translate(
                      offset: Offset(0, -offset),
                      child: Container(
                        width: _getSize() * 0.4,
                        height: _getSize() * 0.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: DreamTheme.accent.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Weaving your dream...',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

class OrbitalStarsPainter extends CustomPainter {
  final double size;

  OrbitalStarsPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    final radius = canvasSize.width * 0.35;

    const starCount = 4;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..isAntiAlias = true;

    for (int i = 0; i < starCount; i++) {
      final angle = (2 * 3.14159 * i) / starCount;
      final x = centerX + radius * Math.cos(angle);
      final y = centerY + radius * Math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(OrbitalStarsPainter oldDelegate) => true;
}

class Math {
  static double cos(double radians) => math_cos(radians);
  static double sin(double radians) => math_sin(radians);
}

import 'dart:math' as math;

double math_cos(double x) => math.cos(x);
double math_sin(double x) => math.sin(x);
