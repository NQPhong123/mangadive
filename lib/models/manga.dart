import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final List<String> genres;
  final String author;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> chapters;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.genres,
    required this.author,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.chapters = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'genres': genres,
      'author': author,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'chapters': chapters,
    };
  }

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImage: json['coverImage'] as String,
      genres: List<String>.from(json['genres']),
      author: json['author'] as String,
      viewCount: json['viewCount'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      chapters: List<String>.from(json['chapters']),
    );
  }
}
