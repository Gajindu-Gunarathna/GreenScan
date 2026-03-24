import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/community_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/support_screen.dart';
import '../screens/result_screen.dart';
import '../screens/treatment_screen.dart';
import '../screens/hotlines_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      // If logged in and trying to go to auth screens → send to home
      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/result', builder: (_, __) => const ResultScreen()),
      GoRoute(path: '/treatment', builder: (_, __) => const TreatmentScreen()),
      GoRoute(path: '/hotlines', builder: (_, __) => const HotlinesScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/community',
            builder: (_, __) => const CommunityScreen(),
          ),
          GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
        ],
      ),
    ],
  );
}
