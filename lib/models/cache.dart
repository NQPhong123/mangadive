import 'package:cloud_firestore/cloud_firestore.dart';

class CacheData {
  final String id;
  final List<String> data;
  final DateTime updatedAt;
  final DateTime expiresAt;

  CacheData({
    required this.id,
    required this.data,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory CacheData.fromMap(Map<String, dynamic> map) {
    return CacheData(
      id: map['id'] as String? ?? '',
      data: List<String>.from(map['data'] as List? ?? []),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] is Timestamp
          ? (map['expiresAt'] as Timestamp).toDate()
          : DateTime.parse(map['expiresAt'] as String? ??
              DateTime.now().add(const Duration(days: 1)).toIso8601String()),
    );
  }

  factory CacheData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return CacheData.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  CacheData copyWith({
    String? id,
    List<String>? data,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return CacheData(
      id: id ?? this.id,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // Kiểm tra cache đã hết hạn chưa
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Tạo cache mới với thời gian cụ thể
  factory CacheData.create({
    required String id,
    required List<String> data,
    Duration expiration = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    return CacheData(
      id: id,
      data: data,
      updatedAt: now,
      expiresAt: now.add(expiration),
    );
  }

  // Các loại cache thông dụng
  static String get popularMangasId => 'popularMangas';
  static String get newestMangasId => 'newestMangas';
  static String get trendingMangasId => 'trendingMangas';
} 