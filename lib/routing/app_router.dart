import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dreamweaver/features/auth/screens/splash_screen.dart';
import 'package:dreamweaver/features/auth/screens/login_screen.dart';
import 'package:dreamweaver/features/auth/screens/signup_screen.dart';
import 'package:dreamweaver/features/auth/screens/age_setup_screen.dart';
import 'package:dreamweaver/features/home/screens/home_screen.dart';
import 'package:dreamweaver/features/content/screens/content_detail_screen.dart';
import 'package:dreamweaver/features/content/screens/content_library_screen.dart';
import 'package:dreamweaver/features/content/screens/category_browse_screen.dart';
import 'package:dreamweaver/features/customization/screens/story_customization_screen.dart';
import 'package:dreamweaver/features/customization/screens/voice_selection_screen.dart';
import 'package:dreamweaver/features/player/screens/player_screen.dart';
import 'package:dreamweaver/features/subscription/screens/subscription_screen.dart';
import 'package:dreamweaver/features/search/screens/search_screen.dart';
import 'package:dreamweaver/features/settings/screens/settings_screen.dart';
import 'package:dreamweaver/routing/route_constants.dart';

/// App-wide router provider using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnSplash = state.uri.path == Routes.splash;

      // Allow splash screen always
      if (isOnSplash) return null;

      // No auth required — app is open like the web version
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: Routes.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: Routes.ageSetup,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AgeSetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Main app routes
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Content detail
      GoRoute(
        path: Routes.contentDetail,
        pageBuilder: (context, state) {
          final contentId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ContentDetailScreen(contentId: contentId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),

      // Content library
      GoRoute(
        path: Routes.contentLibrary,
        builder: (context, state) => const ContentLibraryScreen(),
      ),

      // Category browse
      GoRoute(
        path: Routes.categoryBrowse,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return CategoryBrowseScreen(categoryName: categoryId);
        },
      ),

      // Customization
      GoRoute(
        path: Routes.customize,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoryCustomizationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: Routes.voiceSelection,
        builder: (context, state) => const VoiceSelectionScreen(),
      ),

      // Player (full screen overlay)
      GoRoute(
        path: Routes.player,
        pageBuilder: (context, state) {
          final contentId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: PlayerScreen(contentId: contentId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Subscription
      GoRoute(
        path: Routes.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),

      // Search
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),

      // Settings
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0D0B2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF6B4CE6),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! This dream path doesn\'t exist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
