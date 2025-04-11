import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingHistory {
  final String mangaId;
  final ChapterProgress lastReadChapter;
  final int totalReadChapters;
  final int totalReadingTime;
  final DateTime lastReadAt;
  final Bookmark? bookmark;

  ReadingHistory({
    required this.mangaId,
    required this.lastReadChapter,
    required this.totalReadChapters,
    required this.totalReadingTime,
    required this.lastReadAt,
    this.bookmark,
  });

  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      mangaId: map['mangaId'] as String,
      lastReadChapter: ChapterProgress.fromMap(map['lastReadChapter'] as Map<String, dynamic>),
      totalReadChapters: map['totalReadChapters'] as int,
      totalReadingTime: map['totalReadingTime'] as int,
      lastReadAt: (map['lastReadAt'] as Timestamp).toDate(),
      bookmark: map['bookmark'] != null 
          ? Bookmark.fromMap(map['bookmark'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mangaId': mangaId,
      'lastReadChapter': lastReadChapter.toMap(),
      'totalReadChapters': totalReadChapters,
      'totalReadingTime': totalReadingTime,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'bookmark': bookmark?.toMap(),
    };
  }
}

class ChapterProgress {
  final double chapterNumber;
  final DateTime readAt;

  ChapterProgress({
    required this.chapterNumber,
    required this.readAt,
  });

  factory ChapterProgress.fromMap(Map<String, dynamic> map) {
    return ChapterProgress(
      chapterNumber: map['chapterNumber'] as double,
      readAt: (map['readAt'] as Timestamp).toDate(),
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
      pageNumber: map['pageNumber'] as int,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 