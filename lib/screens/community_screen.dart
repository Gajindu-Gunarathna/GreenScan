import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // ── UI TEAM: Style post composer box ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience or ask a question...',
                    border: InputBorder.none,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: () {},
                      // ── UI TEAM: Style image attach button ──
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Post Experience'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3, // placeholder count
              itemBuilder: (_, index) => _buildPostCard(index),
            ),
          ),
        ],
      ),
    );
  }

  // ── UI TEAM: Replace with ForumPostCard widget from designs ──
  Widget _buildPostCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farmer ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '2 hours ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'My betel leaves are showing yellow spots. What should I do?',
          ),
          const SizedBox(height: 10),
          // AI reply indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_toy, color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'GreenScan AI: Yellow spots may indicate rust disease...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: const Text('Helpful'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
