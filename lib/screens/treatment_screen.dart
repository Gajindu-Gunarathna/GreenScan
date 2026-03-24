import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/plan_provider.dart';
import '../utils/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/active_plan_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Treatments',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: plan.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : plan.currentTreatment == null
          ? const Center(child: Text('No treatment data available'))
          : _buildContent(context, plan),
    );
  }

  // --- REPLACED _buildContent METHOD ---
  Widget _buildContent(BuildContext context, PlanProvider plan) {
    final treatment = plan.currentTreatment!;

    // 3. INITIALIZE PROVIDERS: Grab the instances needed for saving the plan
    final scanProvider = context.read<ScanProvider>();
    final activePlanProvider = context.read<ActivePlanProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentScan = scanProvider.currentScan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4. SAVE BUTTON LOGIC
          // This block checks if a scan exists and if it's NOT already the active plan
          if (currentScan != null &&
              activePlanProvider.activePlan?.diseaseName !=
                  currentScan.diseaseName)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final userId = authProvider.currentUser?.id ?? 'temp_user_id';

                  // Logic to handle existing plans (Replace vs Keep)
                  if (activePlanProvider.hasPlan) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Replace existing plan?'),
                        content: Text(
                          'You already have an active plan for '
                          '"${activePlanProvider.activePlan!.diseaseName}". '
                          'Do you want to replace it with this new plan?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Keep existing'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Replace'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    await activePlanProvider.deletePlan(userId);
                  }

                  // Actually create the plan in the database/provider
                  await activePlanProvider.createPlan(
                    userId: userId,
                    scan: currentScan,
                    treatment: treatment,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Treatment plan saved! Track it on your home screen.',
                      ),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add),
                label: const Text(
                  'Save as My Treatment Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // 5. ROADMAP BUTTON
          // Only shows if the user has ALREADY saved this specific disease plan
          if (activePlanProvider.activePlan?.diseaseName ==
              currentScan?.diseaseName)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/roadmap'),
                icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                label: const Text(
                  'View My Treatment Roadmap',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // 6. ORIGINAL CONTENT (Short term, Chemical, Long term)
          _sectionCard(
            icon: '🌿',
            iconColor: AppColors.success,
            title: 'Short-Term Solutions',
            subtitle: 'Prevention Tips',
            subtitleColor: AppColors.success,
            child: Column(
              children: treatment.shortTermSteps
                  .asMap()
                  .entries
                  .map((e) => _numberedItem(e.key + 1, e.value))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Immediate Chemical Action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: treatment.chemicalTreatments
                  .asMap()
                  .entries
                  .map((e) => _chemicalItem(e.key + 1, e.value))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            icon: '🌱',
            iconColor: AppColors.primaryLight,
            title: 'Long-Term Solutions',
            child: Column(
              children: treatment.longTermSteps
                  .asMap()
                  .entries
                  .map((e) => _numberedItem(e.key + 1, e.value))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Feedback button remains at the bottom
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Feedback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _numberedItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chemicalItem(int number, chemical) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ${chemical.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use: ${chemical.use}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Where to buy:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          ...chemical.whereToBuy.map(
            (place) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                '• $place',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (chemical.youtubeUrl != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _launchUrl(chemical.youtubeUrl!),
              child: const Row(
                children: [
                  Icon(Icons.play_circle_filled, color: Colors.red, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'How to use this chemical',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
