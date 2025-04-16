import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/reading_history.dart';

class Follow {
  final String mangaId;
  final ChapterProgress lastReadChapter;
  final int totalReadChapters;
  final int totalReadingTime;
  final DateTime lastReadAt;
  final Bookmark? bookmark;
  final DateTime createdAt;

  Follow({
    required this.mangaId,
    required this.lastReadChapter,
    required this.totalReadChapters,
    required this.totalReadingTime,
    required this.lastReadAt,
    this.bookmark,
    required this.createdAt,
  });

  factory Follow.fromMap(Map<String, dynamic> map) {
    return Follow(
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
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
    );
  }

  factory Follow.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Follow.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'mangaId': mangaId,
      'lastReadChapter': lastReadChapter.toMap(),
      'totalReadChapters': totalReadChapters,
      'totalReadingTime': totalReadingTime,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'bookmark': bookmark?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Follow copyWith({
    String? mangaId,
    ChapterProgress? lastReadChapter,
    int? totalReadChapters,
    int? totalReadingTime,
    DateTime? lastReadAt,
    Bookmark? bookmark,
    DateTime? createdAt,
  }) {
    return Follow(
      mangaId: mangaId ?? this.mangaId,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      totalReadChapters: totalReadChapters ?? this.totalReadChapters,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      bookmark: bookmark ?? this.bookmark,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 