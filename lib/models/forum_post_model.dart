class ForumReply {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final bool isAiReply;
  final DateTime timestamp;

  ForumReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.isAiReply,
    required this.timestamp,
  });

  factory ForumReply.fromMap(Map<String, dynamic> map) => ForumReply(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    content: map['content'] ?? '',
    isAiReply: map['isAiReply'] ?? false,
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'content': content,
    'isAiReply': isAiReply,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ForumPostModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? imageUrl;
  final List<ForumReply> replies;
  final int likes;
  final DateTime timestamp;

  ForumPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imageUrl,
    required this.replies,
    required this.likes,
    required this.timestamp,
  });

  factory ForumPostModel.fromMap(Map<String, dynamic> map) => ForumPostModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    content: map['content'] ?? '',
    imageUrl: map['imageUrl'],
    replies: (map['replies'] as List? ?? [])
        .map((e) => ForumReply.fromMap(e))
        .toList(),
    likes: map['likes'] ?? 0,
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'content': content,
    'imageUrl': imageUrl,
    'replies': replies.map((e) => e.toMap()).toList(),
    'likes': likes,
    'timestamp': timestamp.toIso8601String(),
  };
}
