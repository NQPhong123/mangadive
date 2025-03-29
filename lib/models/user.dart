import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final String avatarUrl;
  final List<String> roles;
  final List<String> favoriteMangas;
  final List<Map<String, dynamic>> readingHistory;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.avatarUrl,
    required this.roles,
    required this.favoriteMangas,
    required this.readingHistory,
    required this.createdAt,
    required this.lastLoginAt,
    required this.updatedAt,
  });

  bool get isAdmin => roles.contains('admin');

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String? ?? '',
      roles: List<String>.from(map['roles'] ?? ['user']),
      favoriteMangas: List<String>.from(map['favorite_mangas'] ?? []),
      readingHistory:
          List<Map<String, dynamic>>.from(map['reading_history'] ?? []),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      lastLoginAt: (map['last_login_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'roles': roles,
      'favorite_mangas': favoriteMangas,
      'reading_history': readingHistory,
      'created_at': Timestamp.fromDate(createdAt),
      'last_login_at': Timestamp.fromDate(lastLoginAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    List<String>? roles,
    List<String>? favoriteMangas,
    List<Map<String, dynamic>>? readingHistory,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      favoriteMangas: favoriteMangas ?? this.favoriteMangas,
      readingHistory: readingHistory ?? this.readingHistory,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, avatarUrl: $avatarUrl)';
  }
}
