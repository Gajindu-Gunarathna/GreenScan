import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/scan_provider.dart';
import 'providers/map_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/forum_provider.dart';
import 'providers/notification_provider.dart';
import 'services/local_storage_service.dart';
import 'services/connectivity_service.dart';
import 'utils/app_colors.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const GreenScanApp());
}

class GreenScanApp extends StatelessWidget {
  const GreenScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        Provider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'GreenScan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
