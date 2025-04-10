import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String mangaId;
  final String userId;
  final int rating;
  final String? review;
  final int likes;
  final int reports;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.mangaId,
    required this.userId,
    required this.rating,
    this.review,
    required this.likes,
    required this.reports,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      rating: map['rating'] as int? ?? 0,
      review: map['review'] as String?,
      likes: map['likes'] as int? ?? 0,
      reports: map['reports'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Rating.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    final map = {
      'mangaId': mangaId,
      'userId': userId,
      'rating': rating,
      'likes': likes,
      'reports': reports,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (review != null) {
      map['review'] = review!;
    }

    return map;
  }

  Rating copyWith({
    String? id,
    String? mangaId,
    String? userId,
    int? rating,
    String? review,
    int? likes,
    int? reports,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      likes: likes ?? this.likes,
      reports: reports ?? this.reports,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Thêm like cho rating
  Rating addLike() {
    return copyWith(likes: likes + 1);
  }

  // Thêm report cho rating
  Rating addReport() {
    return copyWith(reports: reports + 1);
  }

  // Cập nhật đánh giá
  Rating updateRating({required int newRating, String? newReview}) {
    return copyWith(
      rating: newRating,
      review: newReview,
      updatedAt: DateTime.now(),
    );
  }
} 