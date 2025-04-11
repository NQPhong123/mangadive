import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/reading_history.dart';

class Follow {
  final String id;
  final String userId;
  final String mangaId;
  final ChapterProgress lastReadChapter;
  final int totalReadChapters;
  final int totalReadingTime;
  final DateTime lastReadAt;
  final Bookmark? bookmark;

  Follow({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.lastReadChapter,
    required this.totalReadChapters,
    required this.totalReadingTime,
    required this.lastReadAt,
    this.bookmark,
  });

  factory Follow.fromMap(Map<String, dynamic> map) {
    return Follow(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      lastReadChapter: ChapterProgress.fromMap(
          map['lastReadChapter'] as Map<String, dynamic>? ?? {}),
      totalReadChapters: map['totalReadChapters'] as int? ?? 0,
      totalReadingTime: map['totalReadingTime'] as int? ?? 0,
      lastReadAt: map['lastReadAt'] is Timestamp
          ? (map['lastReadAt'] as Timestamp).toDate()
          : DateTime.parse(map['lastReadAt'] as String? ??
              DateTime.now().toIso8601String()),
      bookmark: map['bookmark'] != null
          ? Bookmark.fromMap(map['bookmark'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Follow.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Follow.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mangaId': mangaId,
      'lastReadChapter': lastReadChapter.toMap(),
      'totalReadChapters': totalReadChapters,
      'totalReadingTime': totalReadingTime,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'bookmark': bookmark?.toMap(),
    };
  }

  Follow copyWith({
    String? id,
    String? userId,
    String? mangaId,
    ChapterProgress? lastReadChapter,
    int? totalReadChapters,
    int? totalReadingTime,
    DateTime? lastReadAt,
    Bookmark? bookmark,
  }) {
    return Follow(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mangaId: mangaId ?? this.mangaId,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      totalReadChapters: totalReadChapters ?? this.totalReadChapters,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      bookmark: bookmark ?? this.bookmark,
    );
  }
} 