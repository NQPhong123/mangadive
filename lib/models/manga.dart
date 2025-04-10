import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  final String id;
  final String title;
  final String titleLowercase;
  final String description;
  final String coverImage;
  final String author;
  final String artist;
  final String status;
  final List<String> genres;
  final int totalViews;
  final int totalFollowers;
  final double averageRating;
  final bool isPremium;
  final double price;
  final int lastChapterNumber;
  final int popularityScore;
  final List<String> searchKeywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  Manga({
    required this.id,
    required this.title,
    required this.titleLowercase,
    required this.description,
    required this.coverImage,
    required this.author,
    required this.artist,
    required this.status,
    required this.genres,
    required this.totalViews,
    required this.totalFollowers,
    required this.averageRating,
    required this.isPremium,
    required this.price,
    required this.lastChapterNumber,
    required this.popularityScore,
    required this.searchKeywords,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Manga.fromMap(Map<String, dynamic> map) {
    try {
      return Manga(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        titleLowercase: map['title_lowercase'] as String? ?? '',
        description: map['description'] as String? ?? '',
        coverImage: map['coverImage'] as String? ?? '',
        author: map['author'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        status: map['status'] as String? ?? 'ongoing',
        genres: List<String>.from(map['genres'] as List? ?? []),
        totalViews: map['totalViews'] as int? ?? 0,
        totalFollowers: map['totalFollowers'] as int? ?? 0,
        averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
        isPremium: map['isPremium'] as bool? ?? false,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        lastChapterNumber: map['lastChapterNumber'] as int? ?? 0,
        popularityScore: map['popularity_score'] as int? ?? 0,
        searchKeywords: List<String>.from(map['search_keywords'] as List? ?? []),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.parse(map['createdAt'] as String? ??
                DateTime.now().toIso8601String()),
        updatedAt: map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.parse(map['updatedAt'] as String? ??
                DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Lỗi khi chuyển đổi dữ liệu manga: $e');
      print('Dữ liệu gốc: $map');
      rethrow;
    }
  }

  factory Manga.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Manga.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'title_lowercase': titleLowercase,
      'description': description,
      'coverImage': coverImage,
      'author': author,
      'artist': artist,
      'status': status,
      'genres': genres,
      'totalViews': totalViews,
      'totalFollowers': totalFollowers,
      'averageRating': averageRating,
      'isPremium': isPremium,
      'price': price,
      'lastChapterNumber': lastChapterNumber,
      'popularity_score': popularityScore,
      'search_keywords': searchKeywords,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Manga copyWith({
    String? id,
    String? title,
    String? titleLowercase,
    String? description,
    String? coverImage,
    String? author,
    String? artist,
    String? status,
    List<String>? genres,
    int? totalViews,
    int? totalFollowers,
    double? averageRating,
    bool? isPremium,
    double? price,
    int? lastChapterNumber,
    int? popularityScore,
    List<String>? searchKeywords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLowercase: titleLowercase ?? this.titleLowercase,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      author: author ?? this.author,
      artist: artist ?? this.artist,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      totalViews: totalViews ?? this.totalViews,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      averageRating: averageRating ?? this.averageRating,
      isPremium: isPremium ?? this.isPremium,
      price: price ?? this.price,
      lastChapterNumber: lastChapterNumber ?? this.lastChapterNumber,
      popularityScore: popularityScore ?? this.popularityScore,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
