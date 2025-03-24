import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> favoriteMangas;
  final Map<String, DateTime> readingHistory;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    required this.createdAt,
    required this.lastLoginAt,
    this.favoriteMangas = const [],
    this.readingHistory = const {},
    this.photoUrl,
  });

  bool get isAdmin => roles.contains('admin');

  User copyWith({
    String? id,
    String? email,
    String? username,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteMangas,
    Map<String, DateTime>? readingHistory,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteMangas: favoriteMangas ?? this.favoriteMangas,
      readingHistory: readingHistory ?? this.readingHistory,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'roles': roles,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'favoriteMangas': favoriteMangas,
      'readingHistory': readingHistory.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'photoUrl': photoUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp).toDate(),
      favoriteMangas: List<String>.from(json['favoriteMangas'] ?? []),
      readingHistory: Map<String, DateTime>.from(
        (json['readingHistory'] ?? {}).map(
          (key, value) => MapEntry(key, (value as Timestamp).toDate()),
        ),
      ),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, roles: $roles)';
  }
}
