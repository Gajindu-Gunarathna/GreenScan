import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';
import '../utils/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  static final AdminService _adminService = AdminService();

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/community')) return 1;
    if (location.startsWith('/camera')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/support')) return 4;
    return 0;
  }

  bool _isCommunityArea(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith('/community');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    return FutureBuilder<bool>(
      future: _adminService.isAdmin(userId),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data == true;

        if (isAdmin && !_isCommunityArea(context)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/community');
          });
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: isAdmin
              ? Container(
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE6E6E6)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: TextButton.icon(
                      onPressed: () => context.go('/community'),
                      icon: const Icon(Icons.forum, color: AppColors.primary),
                      label: const Text(
                        'Community',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : BottomNavigationBar(
                  currentIndex: _currentIndex(context),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Colors.white,
                  elevation: 8,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go('/home');
                        break;
                      case 1:
                        context.go('/community');
                        break;
                      case 2:
                        context.go('/camera');
                        break;
                      case 3:
                        context.go('/profile');
                        break;
                      case 4:
                        context.go('/support');
                        break;
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.forum_outlined),
                      activeIcon: Icon(Icons.forum),
                      label: 'Community',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.document_scanner_outlined),
                      activeIcon: Icon(Icons.document_scanner),
                      label: 'Scan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.help_outline),
                      activeIcon: Icon(Icons.help),
                      label: 'Support',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
