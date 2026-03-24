import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user data from AuthProvider
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'GreenScan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── UI TEAM: Replace with profile image upload widget ──
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.textSecondary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () {}, child: const Text('Add Profile')),
            const SizedBox(height: 20),

            // ── UI TEAM: Style info tiles to match Figma ──
            ...[
              (user?.name ?? 'No name', Icons.person_outline),
              (user?.phone ?? 'No phone', Icons.phone_outlined),
              (user?.email ?? 'No email', Icons.email_outlined),
              (user?.address ?? 'No address', Icons.location_on_outlined),
              (user?.city ?? 'No city', Icons.location_city_outlined),
              (user?.district ?? 'No district', Icons.map_outlined),
            ].map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(item.$2, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(item.$1),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Edit Details'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
