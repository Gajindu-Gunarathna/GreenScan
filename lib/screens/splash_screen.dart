import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── UI TEAM: Replace with GreenScan logo SVG/image ──
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            // ── UI TEAM: Replace with styled app name text ──
            const Text(
              'GREENSCAN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PRECISION HEALTH TECHNOLOGY',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
