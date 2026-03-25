import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/auth_provider.dart';
import '../providers/forum_provider.dart';
import '../services/ai_service.dart';
import '../services/admin_service.dart';
import '../utils/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  final _aiQuestionController = TextEditingController();
  final _aiService = AiService();
  final _tts = FlutterTts();
  final _adminService = AdminService();
  bool _isAdmin = false;

  String? _aiAnswer;
  bool _askingAi = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id ?? '';
      _adminService.isAdmin(userId).then((v) {
        if (mounted) setState(() => _isAdmin = v);
      });
      context.read<ForumProvider>().loadPosts();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _postController.dispose();
    _aiQuestionController.dispose();
    super.dispose();
  }

  Future<void> _askAi() async {
    final q = _aiQuestionController.text.trim();
    if (q.isEmpty || _askingAi) return;

    setState(() {
      _askingAi = true;
      _aiAnswer = null;
      _speaking = false;
    });
    await _tts.stop();

    try {
      final ans = await _aiService.askBetelAssistant(question: q);
      if (!mounted) return;
      setState(() => _aiAnswer = ans);
    } finally {
      if (mounted) setState(() => _askingAi = false);
    }
  }

  Future<void> _postToCommunity({required String content, String? aiAnswer}) async {
    final auth = context.read<AuthProvider>();
    final forum = context.read<ForumProvider>();

    final userId = auth.currentUser?.id ?? 'temp_user_id';
    final userName = auth.currentUser?.name ?? 'Farmer';

    if (aiAnswer != null && aiAnswer.trim().isNotEmpty) {
      final post = await forum.createPostWithAiAnswer(
        userId: userId,
        userName: userName,
        question: content,
        aiAnswer: aiAnswer,
      );
      if (!mounted) return;
      if (post != null) {
        _aiQuestionController.clear();
        setState(() => _aiAnswer = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted to community.')),
        );
        context.push('/community/post/${post.id}');
      }
      return;
    }

    final post = await forum.createPost(
      userId: userId,
      userName: userName,
      content: content,
    );
    if (!mounted) return;
    if (post != null) {
      _postController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted.')),
      );
      context.push('/community/post/${post.id}');
    }
  }

  Future<void> _toggleSpeak() async {
    final text = _aiAnswer?.trim() ?? '';
    if (text.isEmpty) return;

    if (_speaking) {
      await _tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    setState(() => _speaking = true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to log out now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;

    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Community',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const Material(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Ask AI'),
                  Tab(text: 'Community'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAskAiTab(),
                  _buildCommunityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskAiTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask GreenScan AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _aiQuestionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ask about betel diseases, prevention, soil, watering…',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _askingAi ? null : _askAi,
                      icon: _askingAi
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.smart_toy),
                      label: const Text('Get AI Answer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_aiAnswer != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.smart_toy, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'AI Answer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _aiAnswer!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _toggleSpeak,
                    icon: Icon(_speaking ? Icons.stop : Icons.volume_up),
                    label: Text(_speaking ? 'Stop' : 'Listen'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _aiAnswer = null);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Ask again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _postToCommunity(
                          content: _aiQuestionController.text.trim(),
                          aiAnswer: _aiAnswer,
                        ),
                        icon: const Icon(Icons.forum),
                        label: const Text('Ask Community'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'If you are not satisfied, post this to the community so others can reply.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommunityTab() {
    final forum = context.watch<ForumProvider>();
    return RefreshIndicator(
      onRefresh: () => context.read<ForumProvider>().loadPosts(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post a question',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ask the community about a disease, treatment, or farming issue…',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: forum.isPosting
                        ? null
                        : () => _postToCommunity(content: _postController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: forum.isPosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (forum.state == ForumState.loading)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (forum.state == ForumState.error)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                forum.errorMessage,
                style: const TextStyle(color: AppColors.error),
              ),
            )
          else if (forum.posts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'No posts yet. Ask a question to start the community.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...forum.posts
                .map((p) => _PostCard(postId: p.id, isAdmin: _isAdmin)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String postId;
  final bool isAdmin;
  const _PostCard({required this.postId, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumProvider>();
    final post = forum.posts.firstWhere((p) => p.id == postId);

    final aiReply = post.replies.where((r) => r.isAiReply).toList();
    final latestAi = aiReply.isNotEmpty ? aiReply.last : null;

    return InkWell(
      onTap: () => context.push('/community/post/${post.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withAlpha(64),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _timeAgo(post.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    tooltip: 'Delete post',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete post?'),
                          content: const Text(
                            'This will permanently delete the post from the community.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete != true) return;
                      await context.read<ForumProvider>().deletePost(post.id);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Post deleted.')),
                      );
                    },
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${post.replies.where((r) => !r.isAiReply).length} replies',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (latestAi != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withAlpha(38)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AI: ${latestAi.content}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Tap to view & reply',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
