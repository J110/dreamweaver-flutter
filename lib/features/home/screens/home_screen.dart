import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/home/screens/trending_tab.dart';
import 'package:dreamweaver/features/home/screens/favorites_tab.dart';
import 'package:dreamweaver/features/home/screens/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

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
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            TrendingTab(),
            Placeholder(), // Explore tab - to be implemented
            FavoritesTab(),
            ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: DreamTheme.deepNight.withOpacity(0.9),
        selectedItemColor: DreamTheme.primaryPurple,
        unselectedItemColor: DreamTheme.moonGlow.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nights_stay_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Create Story feature coming soon!'),
              backgroundColor: DreamTheme.primaryPurple,
            ),
          );
        },
        backgroundColor: DreamTheme.primaryPurple,
        elevation: 8,
        child: Icon(
          Icons.add_rounded,
          color: DreamTheme.starYellow,
          size: 28,
        ),
      ),
    );
  }
}
