import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/reading_history.dart';

class Follow {
  final String id;
  final String userId;
  final String mangaId;
  final DateTime createdAt;
  final LastReadChapter lastReadChapter;

  Follow({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.createdAt,
    required this.lastReadChapter,
  });

  factory Follow.fromMap(Map<String, dynamic> map) {
    return Follow(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastReadChapter: LastReadChapter.fromMap(
          map['lastReadChapter'] as Map<String, dynamic>? ?? {}),
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
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReadChapter': lastReadChapter.toMap(),
    };
  }

  Follow copyWith({
    String? id,
    String? userId,
    String? mangaId,
    DateTime? createdAt,
    LastReadChapter? lastReadChapter,
  }) {
    return Follow(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mangaId: mangaId ?? this.mangaId,
      createdAt: createdAt ?? this.createdAt,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
    );
  }
} 