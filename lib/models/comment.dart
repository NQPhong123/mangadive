import 'package:cloud_firestore/cloud_firestore.dart';

class CommentSource {
  final String? postId;
  final String? chapterId;
  final String? mangaId;

  CommentSource({
    this.postId,
    this.chapterId,
    this.mangaId,
  }) : assert(
          (postId != null && chapterId == null && mangaId == null) ||
          (postId == null && chapterId != null && mangaId != null),
          'Cung cấp postId hoặc (chapterId và mangaId), không phải cả hai',
        );

  Map<String, dynamic> toMap() {
    if (postId != null) {
      return {
        'postId': postId,
        'type': 'post',
      };
    } else {
      return {
        'chapterId': chapterId,
        'mangaId': mangaId,
        'type': 'chapter',
      };
    }
  }

  factory CommentSource.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;
    
    if (type == 'post') {
      return CommentSource(
        postId: map['postId'] as String,
      );
    } else {
      return CommentSource(
        chapterId: map['chapterId'] as String,
        mangaId: map['mangaId'] as String,
      );
    }
  }

  @override
  String toString() {
    if (postId != null) {
      return 'CommentSource(postId: $postId)';
    } else {
      return 'CommentSource(chapterId: $chapterId, mangaId: $mangaId)';
    }
  }
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final CommentSource source;
  final bool isSpoiler;
  final List<String> mentions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int repliesCount;
  final String status;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.source,
    this.isSpoiler = false,
    this.mentions = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.repliesCount,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'source': source.toMap(),
      'isSpoiler': isSpoiler,
      'mentions': mentions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'repliesCount': repliesCount,
      'status': status,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      source: CommentSource.fromMap(map['source']),
      isSpoiler: map['isSpoiler'] ?? false,
      mentions: List<String>.from(map['mentions'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      repliesCount: map['repliesCount'] ?? 0,
      status: map['status'] ?? 'active',
    );
  }
} 