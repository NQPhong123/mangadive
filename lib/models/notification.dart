import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  final String id;
  final String userId;
  final String type;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;
  final DateTime expiresAt;

  UserNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.data,
    required this.read,
    required this.createdAt,
    required this.expiresAt,
  });

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      read: map['read'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] is Timestamp
          ? (map['expiresAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['expiresAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  factory UserNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return UserNotification.fromMap(data);
  }

  // Hàm tạo thông báo chapter mới
  factory UserNotification.newChapter({
    required String userId,
    required String mangaId,
    required String title,
    required int chapterNumber,
  }) {
    final now = DateTime.now();
    // Thông báo hết hạn sau 30 ngày
    final expiresAt = now.add(const Duration(days: 30));
    
    return UserNotification(
      id: '',
      userId: userId,
      type: 'new_chapter',
      data: {
        'mangaId': mangaId,
        'title': title,
        'chapterNumber': chapterNumber,
      },
      read: false,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  // Hàm tạo thông báo cập nhật từ truyện đang theo dõi
  factory UserNotification.followUpdate({
    required String userId,
    required String mangaId,
    required String title,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 30));
    
    return UserNotification(
      id: '',
      userId: userId,
      type: 'follow_update',
      data: {
        'mangaId': mangaId,
        'title': title,
      },
      read: false,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  // Hàm tạo thông báo hệ thống
  factory UserNotification.system({
    required String userId,
    required String message,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 60));
    
    return UserNotification(
      id: '',
      userId: userId,
      type: 'system',
      data: {
        'message': message,
      },
      read: false,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'data': data,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  UserNotification copyWith({
    String? id,
    String? userId,
    String? type,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // Đánh dấu thông báo đã đọc
  UserNotification markAsRead() {
    return copyWith(read: true);
  }

  // Kiểm tra thông báo đã hết hạn chưa
  bool get isExpired => DateTime.now().isAfter(expiresAt);
} 