import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingHistory {
  final String id;
  final String userId;
  final String mangaId;
  final LastReadChapter lastReadChapter;
  final int totalReadChapters;
  final int totalReadingTime;
  final DateTime lastReadAt;
  final Bookmark? bookmark;

  ReadingHistory({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.lastReadChapter,
    required this.totalReadChapters,
    required this.totalReadingTime,
    required this.lastReadAt,
    this.bookmark,
  });

  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      lastReadChapter: LastReadChapter.fromMap(
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

  factory ReadingHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ReadingHistory.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    final map = {
      'userId': userId,
      'mangaId': mangaId,
      'lastReadChapter': lastReadChapter.toMap(),
      'totalReadChapters': totalReadChapters,
      'totalReadingTime': totalReadingTime,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
    };

    if (bookmark != null) {
      map['bookmark'] = bookmark!.toMap();
    }

    return map;
  }

  ReadingHistory copyWith({
    String? id,
    String? userId,
    String? mangaId,
    LastReadChapter? lastReadChapter,
    int? totalReadChapters,
    int? totalReadingTime,
    DateTime? lastReadAt,
    Bookmark? bookmark,
  }) {
    return ReadingHistory(
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

class LastReadChapter {
  final int chapterNumber;
  final DateTime readAt;

  LastReadChapter({
    required this.chapterNumber,
    required this.readAt,
  });

  factory LastReadChapter.fromMap(Map<String, dynamic> map) {
    return LastReadChapter(
      chapterNumber: map['chapterNumber'] as int? ?? 0,
      readAt: map['readAt'] is Timestamp
          ? (map['readAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['readAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterNumber': chapterNumber,
      'readAt': Timestamp.fromDate(readAt),
    };
  }
}

class Bookmark {
  final int pageNumber;
  final DateTime createdAt;

  Bookmark({
    required this.pageNumber,
    required this.createdAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      pageNumber: map['pageNumber'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 