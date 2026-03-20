import '../models/forum_post_model.dart';

class ForumService {
  Future<List<ForumPostModel>> getPosts() async {
    // TODO: implement Firebase fetch
    return [];
  }

  Future<ForumPostModel> createPost({
    required String userId,
    required String userName,
    required String content,
    String? imageUrl,
  }) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<ForumPostModel> generateAiReply({
    required String postId,
    required String content,
  }) async {
    // TODO: implement Claude API call
    throw UnimplementedError();
  }

  Future<ForumPostModel> addReply({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    // TODO: implement
    throw UnimplementedError();
  }
}
