import 'package:cloud_firestore/cloud_firestore.dart';

class MangaRef {
  final String mangaId;
  final int? chapterNumber;

  MangaRef({
    required this.mangaId,
    this.chapterNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'manga_id': mangaId,
      'chapter_number': chapterNumber,
    };
  }

  factory MangaRef.fromMap(Map<String, dynamic> map) {
    return MangaRef(
      mangaId: map['manga_id'] as String,
      chapterNumber: map['chapter_number'] as int?,
    );
  }
}

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int commentsCount;
  final DateTime lastActivityAt;
  final String status;
  final List<String> tags;
  final MangaRef? mangaRef;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.commentsCount,
    required this.lastActivityAt,
    required this.status,
    required this.tags,
    this.mangaRef,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'comments_count': commentsCount,
      'last_activity_at': Timestamp.fromDate(lastActivityAt),
      'status': status,
      'tags': tags,
      'manga_ref': mangaRef?.toMap(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
      likes: map['likes'] as int,
      commentsCount: map['comments_count'] as int,
      lastActivityAt: (map['last_activity_at'] as Timestamp).toDate(),
      status: map['status'] as String,
      tags: List<String>.from(map['tags']),
      mangaRef: map['manga_ref'] != null ? MangaRef.fromMap(map['manga_ref'] as Map<String, dynamic>) : null,
    );
  }
} 