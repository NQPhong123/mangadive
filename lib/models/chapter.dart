import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String mangaId;
  final int chapterNumber;
  final DateTime createdAt;
  final int likes;
  final List<ChapterPage> pages;

  Chapter({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.createdAt,
    required this.likes,
    required this.pages,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      chapterNumber: map['chapter_number'] as int? ?? 0,
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] as String? ??
              DateTime.now().toIso8601String()),
      likes: map['likes'] as int? ?? 0,
      pages: (map['pages'] as List<dynamic>?)
              ?.map((e) => ChapterPage.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Chapter.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'mangaId': mangaId,
      'chapter_number': chapterNumber,
      'created_at': Timestamp.fromDate(createdAt),
      'likes': likes,
      'pages': pages.map((p) => p.toMap()).toList(),
    };
  }

  Chapter copyWith({
    String? id,
    String? mangaId,
    int? chapterNumber,
    DateTime? createdAt,
    int? likes,
    List<ChapterPage>? pages,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      pages: pages ?? this.pages,
    );
  }
}

class ChapterPage {
  final String imageUrl;
  final int pageNumber;

  ChapterPage({required this.imageUrl, required this.pageNumber});

  factory ChapterPage.fromMap(Map<String, dynamic> map) {
    return ChapterPage(
      imageUrl: map['image_url'] ?? '',
      pageNumber: map['page_number'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image_url': imageUrl,
      'page_number': pageNumber,
    };
  }
}
