import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  final String id;
  final String name;
  final String description;
  final List<String> genres;
  final String status;
  final int totalChapters;
  final int latestChapter;
  final int views;
  final int follows;
  final double voteScore;
  final int voteCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String coverUrl;

  Manga({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.status,
    required this.totalChapters,
    required this.latestChapter,
    required this.views,
    required this.follows,
    required this.voteScore,
    required this.voteCount,
    required this.createdAt,
    required this.updatedAt,
    required this.coverUrl,
  });

  factory Manga.fromMap(Map<String, dynamic> map) {
    try {
      return Manga(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        genres: List<String>.from(map['genres'] as List? ?? []),
        status: map['status'] as String? ?? 'ongoing',
        totalChapters: map['total_chapters'] as int? ?? 0,
        latestChapter: map['latest_chapter'] as int? ?? 0,
        views: map['views'] as int? ?? 0,
        follows: map['follows'] as int? ?? 0,
        voteScore: (map['vote_score'] as num?)?.toDouble() ?? 0.0,
        voteCount: map['vote_count'] as int? ?? 0,
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : DateTime.parse(map['created_at'] as String? ??
                DateTime.now().toIso8601String()),
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : DateTime.parse(map['updated_at'] as String? ??
                DateTime.now().toIso8601String()),
        coverUrl: map['cover_url'] as String? ?? '',
      );
    } catch (e) {
      print('Lỗi khi chuyển đổi dữ liệu manga: $e');
      print('Dữ liệu gốc: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'genres': genres,
      'status': status,
      'total_chapters': totalChapters,
      'latest_chapter': latestChapter,
      'views': views,
      'follows': follows,
      'vote_score': voteScore,
      'vote_count': voteCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cover_url': coverUrl,
    };
  }

  Manga copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? genres,
    String? status,
    int? totalChapters,
    int? latestChapter,
    int? views,
    int? follows,
    double? voteScore,
    int? voteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverUrl,
  }) {
    return Manga(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      totalChapters: totalChapters ?? this.totalChapters,
      latestChapter: latestChapter ?? this.latestChapter,
      views: views ?? this.views,
      follows: follows ?? this.follows,
      voteScore: voteScore ?? this.voteScore,
      voteCount: voteCount ?? this.voteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
