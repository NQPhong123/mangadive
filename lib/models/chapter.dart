import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String mangaId;
  final int chapterNumber;
  final List<Map<String, dynamic>> pages;
  final int views;
  final int likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.pages,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      chapterNumber: map['chapter_number'] as int,
      pages: List<Map<String, dynamic>>.from(
        (map['pages'] as List).map((x) => Map<String, dynamic>.from(x)),
      ),
      views: map['views'] as int,
      likes: map['likes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'chapter_number': chapterNumber,
      'pages': pages,
      'views': views,
      'likes': likes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Chapter copyWith({
    String? id,
    String? mangaId,
    int? chapterNumber,
    List<Map<String, dynamic>>? pages,
    int? views,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pages: pages ?? this.pages,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
