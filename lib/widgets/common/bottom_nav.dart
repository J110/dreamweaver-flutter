import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[widget.currentIndex].forward();
      for (int i = 0; i < _controllers.length; i++) {
        if (i != widget.currentIndex) {
          _controllers[i].reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      {'label': 'Home', 'icon': Icons.home},
      {'label': 'Explore', 'icon': Icons.explore},
      {'label': 'Favorites', 'icon': Icons.favorite},
      {'label': 'Profile', 'icon': Icons.person},
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: DreamTheme.primaryDark.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: DreamTheme.accent.withOpacity(0.2),
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: widget.currentIndex,
            onTap: widget.onTap,
            type: BottomNavigationBarType.fixed,
            items: List.generate(
              items.length,
              (index) {
                final item = items[index];
                final isActive = index == widget.currentIndex;

                return BottomNavigationBarItem(
                  icon: AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (_controllers[index].value * 0.1),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: isActive
                              ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: DreamTheme.accent.withOpacity(0.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DreamTheme.accent
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                )
                              : null,
                          child: Icon(
                            item['icon'] as IconData,
                            color: isActive
                                ? DreamTheme.accent
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                  label: item['label'] as String,
                );
              },
            ),
            selectedItemColor: DreamTheme.accent,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
