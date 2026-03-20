import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/forum_post_model.dart';
import '../utils/secrets.dart';

class ForumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<ForumPostModel>> getPosts() async {
    final snapshot = await _db
        .collection('forum_posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => ForumPostModel.fromMap(doc.data()))
        .toList();
  }

  Future<ForumPostModel> createPost({
    required String userId,
    required String userName,
    required String content,
    String? imageUrl,
  }) async {
    final id = _uuid.v4();
    final post = ForumPostModel(
      id: id,
      userId: userId,
      userName: userName,
      content: content,
      imageUrl: imageUrl,
      replies: [],
      likes: 0,
      timestamp: DateTime.now(),
    );

    await _db.collection('forum_posts').doc(id).set(post.toMap());
    return post;
  }

  // Calls Claude API to generate an intelligent reply
  Future<ForumPostModel> generateAiReply({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': Secrets.claudeApiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': 'claude-haiku-4-5-20251001',
              'max_tokens': 300,
              'system': '''You are an expert agricultural assistant 
          specializing in betel leaf cultivation in Sri Lanka. 
          Give practical, helpful advice in simple language. 
          Keep replies concise and actionable.''',
              'messages': [
                {'role': 'user', 'content': content},
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      String aiReplyText =
          'Thank you for your question. '
          'Please consult your local agricultural officer for guidance.';

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        aiReplyText = data['content'][0]['text'] as String;
      }

      // Save AI reply to Firestore
      final replyId = _uuid.v4();
      final aiReply = ForumReply(
        id: replyId,
        userId: 'ai_assistant',
        userName: 'GreenScan AI',
        content: aiReplyText,
        isAiReply: true,
        timestamp: DateTime.now(),
      );

      await _db.collection('forum_posts').doc(postId).update({
        'replies': FieldValue.arrayUnion([aiReply.toMap()]),
      });

      // Return updated post
      final doc = await _db.collection('forum_posts').doc(postId).get();
      return ForumPostModel.fromMap(doc.data()!);
    } catch (e) {
      // If AI fails, still return the post without AI reply
      final doc = await _db.collection('forum_posts').doc(postId).get();
      return ForumPostModel.fromMap(doc.data()!);
    }
  }

  Future<ForumPostModel> addReply({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final reply = ForumReply(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      content: content,
      isAiReply: false,
      timestamp: DateTime.now(),
    );

    await _db.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.arrayUnion([reply.toMap()]),
    });

    final doc = await _db.collection('forum_posts').doc(postId).get();
    return ForumPostModel.fromMap(doc.data()!);
  }
}
