import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final int mangaCount;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.mangaCount,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      mangaCount: map['mangaCount'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Category.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'mangaCount': mangaCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? mangaCount,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mangaCount: mangaCount ?? this.mangaCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tăng số lượng manga trong category
  Category incrementMangaCount() {
    return copyWith(mangaCount: mangaCount + 1);
  }

  // Giảm số lượng manga trong category
  Category decrementMangaCount() {
    return copyWith(mangaCount: mangaCount > 0 ? mangaCount - 1 : 0);
  }
} 