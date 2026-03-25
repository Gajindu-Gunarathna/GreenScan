import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/active_plan_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final planProvider = context.read<ActivePlanProvider>();
      final userId = auth.currentUser?.id ?? 'temp_user_id';
      final district = auth.currentUser?.district ?? 'Colombo';

      await planProvider.loadActivePlan(userId);
      await planProvider.loadDistrictAlert(district);
      if (mounted) {
        await _triggerSmartNotifications(
          userId: userId,
          planProvider: planProvider,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<ActivePlanProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final userId = authProvider.currentUser?.id ?? 'temp_user_id';
    final userName = authProvider.currentUser?.name ?? 'Farmer';

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
        actions: [
          IconButton(
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: AppColors.primary),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        notificationProvider.unreadCount > 9
                            ? '9+'
                            : '${notificationProvider.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner, color: AppColors.primary),
            onPressed: () => context.go('/camera'),
            tooltip: 'Scan new leaf',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final district = authProvider.currentUser?.district ?? 'Colombo';
          await planProvider.loadActivePlan(userId);
          await planProvider.loadDistrictAlert(district);
          await _triggerSmartNotifications(
            userId: userId,
            planProvider: planProvider,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hello, $userName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here\'s your farm health summary',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // ── District alert ──────────────────────────────
              if (planProvider.districtAlert != null)
                _buildDistrictAlert(planProvider.districtAlert!),

              const SizedBox(height: 16),

              // ── Active plan ─────────────────────────────────
              if (planProvider.state == ActivePlanState.loading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),

              if (planProvider.activePlan != null)
                _buildActivePlanCard(context, planProvider, userId)
              else if (planProvider.state == ActivePlanState.loaded)
                _buildNoPlanCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictAlert(Map<String, dynamic> alert) {
    final cases = (alert['totalCases'] ?? 0) as int;
    final riskText = _riskLabel(cases);
    final riskColor = _riskColor(cases);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(76)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert — ${alert['district']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withAlpha(35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        riskText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                    ),
                    Text(
                      '$cases cases',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${alert['diseaseName']} is currently the most reported disease in your district. Check your leaves and scan early.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(
    BuildContext context,
    ActivePlanProvider planProvider,
    String userId,
  ) {
    final plan = planProvider.activePlan!;
    final percent = plan.progressPercent;
    final pendingSteps = plan.steps.where((s) => !s.isDone).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Treatment Plan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/roadmap'),
              child: const Text(
                'View all',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Plan summary card
        GestureDetector(
          onTap: () => context.push('/roadmap'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        plan.scanImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.background,
                          child: const Icon(
                            Icons.eco,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.diseaseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${plan.doneCount}/${plan.totalCount} steps done',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percent >= 0.8
                          ? AppColors.success
                          : percent >= 0.4
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(percent * 100).toInt()}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Today's pending steps (max 3)
        if (pendingSteps.isNotEmpty) ...[
          const Text(
            'What to do next',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...pendingSteps.map(
            (step) => GestureDetector(
              onTap: () =>
                  planProvider.toggleStep(userId: userId, stepId: step.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (plan.steps.where((s) => !s.isDone).length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${plan.steps.where((s) => !s.isDone).length - 3} more steps in roadmap',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],

        if (plan.isCompleted)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All treatment steps completed! 🎉 Scan again to monitor recovery.',
                    style: TextStyle(color: AppColors.success, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  String _riskLabel(int cases) {
    if (cases >= 50) return 'High risk';
    if (cases >= 20) return 'Medium risk';
    return 'Early warning';
  }

  Color _riskColor(int cases) {
    if (cases >= 50) return AppColors.error;
    if (cases >= 20) return AppColors.warning;
    return AppColors.primary;
  }

  Future<void> _triggerSmartNotifications({
    required String userId,
    required ActivePlanProvider planProvider,
  }) async {
    final notificationProvider = context.read<NotificationProvider>();
    final alert = planProvider.districtAlert;
    final plan = planProvider.activePlan;

    if (alert != null) {
      final signature =
          '${alert['district']}_${alert['diseaseName']}_${alert['totalCases']}';
      final last = LocalStorageService.getString(
        AppConstants.userBox,
        'last_alert_$userId',
      );
      if (last != signature) {
        notificationProvider.addNotification(
          'District Alert',
          '${alert['diseaseName']} is increasing in ${alert['district']} (${alert['totalCases']} cases).',
        );
        await LocalStorageService.saveString(
          AppConstants.userBox,
          'last_alert_$userId',
          signature,
        );
      }
    }

    if (plan != null && !plan.isCompleted) {
      final pending = plan.steps.where((s) => !s.isDone).length;
      if (pending > 0) {
        final today = DateTime.now().toIso8601String().split('T').first;
        final reminderKey = '${plan.id}_$today';
        final lastReminder = LocalStorageService.getString(
          AppConstants.userBox,
          'last_plan_reminder_$userId',
        );
        if (lastReminder != reminderKey) {
          notificationProvider.addNotification(
            'Treatment Reminder',
            'You still have $pending pending step${pending > 1 ? 's' : ''} in your treatment plan.',
          );
          await LocalStorageService.saveString(
            AppConstants.userBox,
            'last_plan_reminder_$userId',
            reminderKey,
          );
        }
      }
    }

    if (plan != null && plan.isCompleted) {
      final lastCompleted = LocalStorageService.getString(
        AppConstants.userBox,
        'last_completed_plan_$userId',
      );
      if (lastCompleted != plan.id) {
        notificationProvider.addNotification(
          'Plan Completed',
          'Great job! You completed your ${plan.diseaseName} treatment plan.',
        );
        await LocalStorageService.saveString(
          AppConstants.userBox,
          'last_completed_plan_$userId',
          plan.id,
        );
      }
    }
  }

  void _showNotifications(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final items = List<Map<String, dynamic>>.from(notificationProvider.notifications);
    notificationProvider.markAllRead();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        if (items.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (_, i) {
              final n = items[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications, color: AppColors.primary),
                title: Text(
                  n['title']?.toString() ?? 'Notification',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(n['body']?.toString() ?? ''),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoPlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 56,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 12),
          const Text(
            'No active treatment plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan a betel leaf to detect diseases and start a personalized treatment plan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/camera'),
            icon: const Icon(Icons.document_scanner),
            label: const Text('Scan a Leaf Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ActivePlanProvider planProvider,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Treatment Plan?'),
        content: const Text(
          'This will delete your current plan and all progress. '
          'You can create a new one after scanning a leaf.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // dialog — fine
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog — fine
              await planProvider.deletePlan(userId);
              if (context.mounted) {
                await planProvider.loadActivePlan(userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Plan deleted. Scan a new leaf to start fresh.',
                    ),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
